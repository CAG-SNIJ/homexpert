import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Service for handling Firebase Authentication and Firestore operations for staff
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in staff with email and password
  /// 
  /// Returns a UserModel if successful, throws an exception if failed
  Future<UserModel> signInStaff({
    required String staffId,
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with email and password
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign in failed: User is null');
      }

      // Get staff data from Firestore
      final staffDoc = await _firestore
          .collection('staff')
          .where('staffId', isEqualTo: staffId)
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (staffDoc.docs.isEmpty) {
        // Sign out if staff data not found
        await _auth.signOut();
        throw Exception('Staff account not found in database');
      }

      final staffData = staffDoc.docs.first.data();
      
      // Update last login timestamp
      await _firestore
          .collection('staff')
          .doc(staffDoc.docs.first.id)
          .update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Create and return UserModel
      return UserModel(
        id: userCredential.user!.uid,
        email: email.trim(),
        name: staffData['name'] ?? '',
        role: _roleFromString(staffData['role'] ?? 'staff'),
        phone: staffData['phone'],
        profileImage: staffData['profileImage'],
        createdAt: staffData['createdAt']?.toDate() ?? DateTime.now(),
        isVerified: userCredential.user!.emailVerified,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No staff account found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Sign in failed: ${e.message ?? 'Unknown error'}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Check if a staff ID exists in Firestore
  Future<bool> staffIdExists(String staffId) async {
    try {
      final querySnapshot = await _firestore
          .collection('staff')
          .where('staffId', isEqualTo: staffId)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get staff data by staff ID
  Future<Map<String, dynamic>?> getStaffData(String staffId) async {
    try {
      final querySnapshot = await _firestore
          .collection('staff')
          .where('staffId', isEqualTo: staffId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return querySnapshot.docs.first.data();
    } catch (e) {
      return null;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = 'Failed to send reset email: ${e.message ?? 'Unknown error'}';
      }
      throw Exception(errorMessage);
    }
  }

  /// Create a new staff account (Admin only - to be implemented)
  Future<UserModel> createStaffAccount({
    required String staffId,
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Account creation failed: User is null');
      }

      // Create staff document in Firestore
      await _firestore.collection('staff').doc(userCredential.user!.uid).set({
        'staffId': staffId,
        'email': email.trim(),
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': null,
      });

      return UserModel(
        id: userCredential.user!.uid,
        email: email.trim(),
        name: name,
        role: _roleFromString(role),
        createdAt: DateTime.now(),
        isVerified: false,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = 'Account creation failed: ${e.message ?? 'Unknown error'}';
      }
      throw Exception(errorMessage);
    }
  }

  /// Helper method to convert string role to UserRole enum
  UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'agent':
        return UserRole.agent;
      case 'staff':
        return UserRole.staff;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }
}


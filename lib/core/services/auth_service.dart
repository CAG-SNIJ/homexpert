import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  /// Check if backend server is running
  /// Returns true if backend is reachable
  Future<bool> isBackendRunning() async {
    return await _apiService.testConnection();
  }

  /// User/Agent Login
  /// 
  /// Parameters:
  /// - email: User's email address
  /// - password: User's password
  /// 
  /// Returns:
  /// - UserModel if successful
  /// - Throws exception if failed
  Future<UserModel> userLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/user/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final userData = data['user'];
        final token = data['token'];

        // Save token to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(AppConstants.userRoleKey, userData['role'] ?? 'user');

        // Create and save user model
        final user = UserModel(
          id: userData['id'].toString(),
          email: userData['email'],
          name: '${userData['firstName']} ${userData['lastName']}',
          role: _parseRole(userData['role']),
          createdAt: DateTime.now(),
        );

        // Save user data as JSON string
        await prefs.setString(
          AppConstants.userKey,
          jsonEncode(user.toJson()),
        );

        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Server responded with error
        final errorMessage = e.response?.data['message'] ?? 'Login failed';
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check if the backend server is running on http://localhost:3000');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Make sure the backend is running on http://localhost:3000');
      } else {
        throw Exception('Network error: ${e.message ?? "Please check your connection and ensure the backend server is running"}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Staff/Admin Login
  /// 
  /// Parameters:
  /// - staffId: Staff ID (e.g., ADMIN001)
  /// - password: User's password
  /// 
  /// Returns:
  /// - UserModel if successful
  /// - Throws exception if failed
  Future<UserModel> staffLogin({
    required String staffId,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/staff/login',
        data: {
          'staffId': staffId.trim(),
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final userData = data['user'];
        final token = data['token'];

        // Save token to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(AppConstants.userRoleKey, userData['role'] ?? 'staff');

        // Create and save user model
        final user = UserModel(
          id: userData['id'].toString(),
          email: userData['email'],
          name: '${userData['firstName']} ${userData['lastName']}',
          role: _parseRole(userData['role']),
          createdAt: DateTime.now(),
        );

        // Save user data as JSON string
        await prefs.setString(
          AppConstants.userKey,
          jsonEncode(user.toJson()),
        );

        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Server responded with error
        final errorMessage = e.response?.data['message'] ?? 'Login failed';
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check if the backend server is running on http://localhost:3000');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Make sure the backend is running on http://localhost:3000');
      } else {
        throw Exception('Network error: ${e.message ?? "Please check your connection and ensure the backend server is running"}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// User Registration
  /// 
  /// Parameters:
  /// - email: User's email address
  /// - password: User's password
  /// - name: User's full name
  /// - role: User's role (user, agent)
  /// 
  /// Returns:
  /// - Map with 'success' and 'message' keys
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'name': name.trim(),
          'role': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          // Save token if provided
          if (response.data['data']?['token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
              AppConstants.tokenKey,
              response.data['data']['token'],
            );
          }
          return {
            'success': true,
            'message': response.data['message'] ?? 'Registration successful',
          };
        } else {
          return {
            'success': false,
            'message': response.data['message'] ?? 'Registration failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Registration failed',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Registration failed';
        return {
          'success': false,
          'message': errorMessage,
        };
      } else {
        return {
          'success': false,
          'message': 'Network error. Please check your connection.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Verify if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get stored user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userRoleKey);
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    await prefs.remove(AppConstants.userRoleKey);
  }

  /// Get stored auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  /// Get current user profile
  /// Returns user profile data from backend
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiService.get('/auth/user/profile');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch user profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Failed to fetch user profile';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Update current user profile
  /// Parameters:
  /// - firstName, lastName, mobilePhone (required)
  /// - region, area, gender, birthdayMonth, birthdayYear (optional)
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String mobilePhone,
    String? region,
    String? area,
    String? gender,
    String? birthdayMonth,
    String? birthdayYear,
  }) async {
    try {
      final response = await _apiService.put(
        '/auth/user/profile',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'mobilePhone': mobilePhone,
          if (region != null && region.isNotEmpty) 'region': region,
          if (area != null && area.isNotEmpty) 'area': area,
          if (gender != null && gender.isNotEmpty) 'gender': gender,
          if (birthdayMonth != null && birthdayMonth.isNotEmpty) 'birthdayMonth': birthdayMonth,
          if (birthdayYear != null && birthdayYear.isNotEmpty) 'birthdayYear': birthdayYear,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Failed to update profile';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Change user password
  /// Parameters:
  /// - currentPassword: Current password
  /// - newPassword: New password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.put(
        '/auth/user/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Failed to change password';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Parse role string to UserRole enum
  UserRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'staff':
        return UserRole.staff;
      case 'agent':
        return UserRole.agent;
      default:
        return UserRole.user;
    }
  }
}

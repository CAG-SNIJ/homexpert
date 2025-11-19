import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Service for handling Firebase Storage operations (images only)
/// 
/// This service is used ONLY for storing and retrieving images.
/// All structured data (users, properties, transactions) should be stored in MySQL.
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload an image file to Firebase Storage
  /// 
  /// [file] - The image file to upload (File or XFile)
  /// [path] - The storage path (e.g., 'properties/images/', 'users/profiles/')
  /// [fileName] - Optional custom file name. If not provided, uses timestamp
  /// 
  /// Returns the download URL of the uploaded image
  Future<String> uploadImage({
    required dynamic file,
    required String path,
    String? fileName,
  }) async {
    try {
      // Convert XFile to File if needed
      File imageFile;
      if (file is XFile) {
        imageFile = File(file.path);
      } else if (file is File) {
        imageFile = file;
      } else {
        throw Exception('Invalid file type. Expected File or XFile');
      }

      // Generate file name if not provided
      final String finalFileName = fileName ?? 
          '${DateTime.now().millisecondsSinceEpoch}.${_getFileExtension(imageFile.path)}';

      // Create reference to the file location
      final Reference ref = _storage.ref().child('$path$finalFileName');

      // Upload file
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/${_getFileExtension(imageFile.path)}',
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Upload multiple images
  /// 
  /// Returns a list of download URLs in the same order as input files
  Future<List<String>> uploadMultipleImages({
    required List<dynamic> files,
    required String path,
  }) async {
    try {
      final List<String> urls = [];
      
      for (var file in files) {
        final url = await uploadImage(file: file, path: path);
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      throw Exception('Failed to upload images: ${e.toString()}');
    }
  }

  /// Delete an image from Firebase Storage
  /// 
  /// [imageUrl] - The full download URL of the image to delete
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract the path from the URL
      final Uri uri = Uri.parse(imageUrl);
      final String path = uri.pathSegments
          .skipWhile((segment) => segment != 'o')
          .skip(1)
          .join('/')
          .split('?')[0];

      // Decode the path (Firebase Storage URLs are encoded)
      final String decodedPath = Uri.decodeComponent(path);

      // Create reference and delete
      final Reference ref = _storage.ref().child(decodedPath);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: ${e.toString()}');
    }
  }

  /// Get download URL for an existing file
  /// 
  /// [path] - The storage path to the file
  Future<String> getDownloadUrl(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: ${e.toString()}');
    }
  }

  /// Upload property image
  /// 
  /// Convenience method for uploading property images
  Future<String> uploadPropertyImage({
    required dynamic file,
    required String propertyId,
    String? fileName,
  }) async {
    return uploadImage(
      file: file,
      path: 'properties/$propertyId/images/',
      fileName: fileName,
    );
  }

  /// Upload user profile image
  /// 
  /// Convenience method for uploading user profile images
  Future<String> uploadProfileImage({
    required dynamic file,
    required String userId,
    String? fileName,
  }) async {
    return uploadImage(
      file: file,
      path: 'users/$userId/profile/',
      fileName: fileName ?? 'profile.jpg',
    );
  }

  /// Upload document image
  /// 
  /// Convenience method for uploading document images
  Future<String> uploadDocumentImage({
    required dynamic file,
    required String documentId,
    String? fileName,
  }) async {
    return uploadImage(
      file: file,
      path: 'documents/$documentId/',
      fileName: fileName,
    );
  }

  /// Get file extension from file path
  String _getFileExtension(String path) {
    final parts = path.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return 'jpg'; // Default to jpg
  }

  /// Check if a file exists at the given path
  Future<bool> fileExists(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get file metadata: ${e.toString()}');
    }
  }
}


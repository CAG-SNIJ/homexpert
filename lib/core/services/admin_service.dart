import 'package:dio/dio.dart';
import '../models/dashboard_model.dart';
import '../models/user_list_model.dart';
import '../models/review_user_model.dart';
import '../models/staff_list_model.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  /// Get dashboard statistics
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _apiService.get('/admin/dashboard/stats');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return DashboardStats.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch dashboard stats');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Failed to fetch dashboard stats';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get recent activities
  Future<List<Activity>> getRecentActivities({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/admin/dashboard/activities',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> activitiesJson = response.data['data'] ?? [];
        return activitiesJson.map((json) => Activity.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch activities');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Failed to fetch activities';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get list of users with pagination and search
  Future<Map<String, dynamic>> getUsers({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/users',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> userList = response.data['data'] ?? [];
        final users = userList.map((json) => UserListItem.fromJson(json)).toList();
        final pagination = response.data['pagination'] ?? {};
        return {
          'users': users,
          'pagination': pagination,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load users');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error fetching users');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Create a new user
  Future<UserListItem> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String mobilePhone,
    String? region,
    String? area,
    String? gender,
    String? birthdayMonth,
    String? birthdayYear,
  }) async {
    try {
      final response = await _apiService.post(
        '/admin/users',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'mobilePhone': mobilePhone,
          if (region != null && region.isNotEmpty) 'region': region,
          if (area != null && area.isNotEmpty) 'area': area,
          if (gender != null && gender.isNotEmpty) 'gender': gender,
          if (birthdayMonth != null && birthdayMonth.isNotEmpty) 'birthdayMonth': birthdayMonth,
          if (birthdayYear != null && birthdayYear.isNotEmpty) 'birthdayYear': birthdayYear,
        },
      );
      if (response.statusCode == 201 && response.data['success'] == true) {
        return UserListItem.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create user');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error creating user');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Get user details by user ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _apiService.get('/admin/users/$userId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch user');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error fetching user');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Update a user by user ID
  Future<UserListItem> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String mobilePhone,
    String? region,
    String? area,
    String? gender,
    String? birthdayMonth,
    String? birthdayYear,
  }) async {
    try {
      final response = await _apiService.put(
        '/admin/users/$userId',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'mobilePhone': mobilePhone,
          if (region != null && region.isNotEmpty) 'region': region,
          if (area != null && area.isNotEmpty) 'area': area,
          if (gender != null && gender.isNotEmpty) 'gender': gender,
          if (birthdayMonth != null && birthdayMonth.isNotEmpty) 'birthdayMonth': birthdayMonth,
          if (birthdayYear != null && birthdayYear.isNotEmpty) 'birthdayYear': birthdayYear,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserListItem.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update user');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error updating user');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Update user account status (suspend/activate)
  Future<void> updateUserStatus(String userId, String status) async {
    try {
      final response = await _apiService.put(
        '/admin/users/$userId/status',
        data: {'status': status},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update user status');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error updating user status');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Get list of users pending review (KYC Pending, Suspended Pending)
  Future<Map<String, dynamic>> getReviewUsers({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/users/review',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> userList = response.data['data'] ?? [];
        final users = userList.map((json) => ReviewUserItem.fromJson(json)).toList();
        final pagination = response.data['pagination'] ?? {};
        return {
          'users': users,
          'pagination': pagination,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load review users');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error fetching review users');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Get list of staff members with pagination and search
  Future<Map<String, dynamic>> getStaffMembers({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/staff',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> staffList = response.data['data'] ?? [];
        final staff = staffList.map((json) => StaffListItem.fromJson(json)).toList();
        final pagination = response.data['pagination'] ?? {};
        return {
          'staff': staff,
          'pagination': pagination,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load staff');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error fetching staff');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Create a new staff member
  Future<StaffListItem> createStaff({
    required String staffRole,
    required String firstName,
    required String lastName,
    required String email,
    required String mobilePhone,
    String? region,
    String? area,
    String? gender,
    String? birthdayMonth,
    String? birthdayYear,
  }) async {
    try {
      final response = await _apiService.post(
        '/admin/staff',
        data: {
          'staffRole': staffRole,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'mobilePhone': mobilePhone,
          if (region != null && region.isNotEmpty) 'region': region,
          if (area != null && area.isNotEmpty) 'area': area,
          if (gender != null && gender.isNotEmpty) 'gender': gender,
          if (birthdayMonth != null && birthdayMonth.isNotEmpty)
            'birthdayMonth': birthdayMonth,
          if (birthdayYear != null && birthdayYear.isNotEmpty)
            'birthdayYear': birthdayYear,
        },
      );
      if (response.statusCode == 201 && response.data['success'] == true) {
        return StaffListItem.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create staff');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error creating staff');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Update staff active status (activate/inactivate)
  Future<void> updateStaffStatus({
    required String staffId,
    required bool isActive,
  }) async {
    try {
      final response = await _apiService.put(
        '/admin/staff/$staffId/status',
        data: {
          'status': isActive ? 'active' : 'inactive',
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update staff status');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error updating staff status');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Delete a user by user ID
  Future<void> deleteUser(String userId) async {
    try {
      final response = await _apiService.delete('/admin/users/$userId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete user');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error deleting user');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}


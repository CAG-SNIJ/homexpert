import 'package:dio/dio.dart';
import '../models/dashboard_model.dart';
import '../models/user_list_model.dart';
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


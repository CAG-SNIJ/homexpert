class UserListItem {
  final String userId;
  final String name;
  final String region;
  final String email;
  final String status;
  final DateTime dateJoined;

  UserListItem({
    required this.userId,
    required this.name,
    required this.region,
    required this.email,
    required this.status,
    required this.dateJoined,
  });

  factory UserListItem.fromJson(Map<String, dynamic> json) {
    // Handle both string and DateTime for created_at
    DateTime dateJoined;
    if (json['created_at'] != null) {
      if (json['created_at'] is String) {
        dateJoined = DateTime.parse(json['created_at']);
      } else {
        dateJoined = json['created_at'] as DateTime;
      }
    } else {
      dateJoined = DateTime.now();
    }

    return UserListItem(
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      name: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      region: json['region']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['account_status']?.toString() ?? json['status']?.toString() ?? 'active',
      dateJoined: dateJoined,
    );
  }
}


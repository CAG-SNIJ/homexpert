class StaffListItem {
  final String staffId;
  final String name;
  final String region;
  final String email;
  final String status;
  final DateTime dateJoined;

  StaffListItem({
    required this.staffId,
    required this.name,
    required this.region,
    required this.email,
    required this.status,
    required this.dateJoined,
  });

  factory StaffListItem.fromJson(Map<String, dynamic> json) {
    DateTime dateJoined;
    if (json['date_joined'] != null) {
      if (json['date_joined'] is String) {
        dateJoined = DateTime.parse(json['date_joined']);
      } else {
        dateJoined = json['date_joined'] as DateTime;
      }
    } else if (json['created_at'] != null) {
      dateJoined = DateTime.parse(json['created_at'].toString());
    } else {
      dateJoined = DateTime.now();
    }

    return StaffListItem(
      staffId: json['staff_id']?.toString() ?? json['staffId']?.toString() ?? '',
      name: json['name']?.toString() ??
          '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      region: json['region']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      dateJoined: dateJoined,
    );
  }
}


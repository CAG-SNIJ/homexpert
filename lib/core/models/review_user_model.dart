class ReviewUserItem {
  final String userId;
  final String name;
  final String email;
  final String accountStatus;
  final DateTime dateSubmitted;

  ReviewUserItem({
    required this.userId,
    required this.name,
    required this.email,
    required this.accountStatus,
    required this.dateSubmitted,
  });

  factory ReviewUserItem.fromJson(Map<String, dynamic> json) {
    // Handle both string and DateTime for date_submitted/created_at
    DateTime dateSubmitted;
    if (json['date_submitted'] != null) {
      if (json['date_submitted'] is String) {
        dateSubmitted = DateTime.parse(json['date_submitted']);
      } else {
        dateSubmitted = json['date_submitted'] as DateTime;
      }
    } else if (json['created_at'] != null) {
      if (json['created_at'] is String) {
        dateSubmitted = DateTime.parse(json['created_at']);
      } else {
        dateSubmitted = json['created_at'] as DateTime;
      }
    } else {
      dateSubmitted = DateTime.now();
    }

    return ReviewUserItem(
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      name: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      email: json['email']?.toString() ?? '',
      accountStatus: json['account_status']?.toString() ?? json['status']?.toString() ?? 'KYC Pending',
      dateSubmitted: dateSubmitted,
    );
  }
}


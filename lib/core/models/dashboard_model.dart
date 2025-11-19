class DashboardStats {
  final int totalUsers;
  final int totalAgents;
  final int totalListings;
  final int totalProperties;
  final int totalRent;
  final int totalSale;

  DashboardStats({
    required this.totalUsers,
    required this.totalAgents,
    required this.totalListings,
    required this.totalProperties,
    required this.totalRent,
    required this.totalSale,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalAgents: json['totalAgents'] ?? 0,
      totalListings: json['totalListings'] ?? 0,
      totalProperties: json['totalProperties'] ?? 0,
      totalRent: json['totalRent'] ?? 0,
      totalSale: json['totalSale'] ?? 0,
    );
  }
}

class Activity {
  final String id;
  final String staffName;
  final String action;
  final DateTime timestamp;
  final String? details;
  final String? entityType;
  final String? entityId;

  Activity({
    required this.id,
    required this.staffName,
    required this.action,
    required this.timestamp,
    this.details,
    this.entityType,
    this.entityId,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      staffName: json['staffName'] ?? 'Unknown',
      action: json['action'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      details: json['details'],
      entityType: json['entityType'],
      entityId: json['entityId'],
    );
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String get displayTimestamp {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}


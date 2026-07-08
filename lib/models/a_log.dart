class ALog {
  final String lid;
  final String user;
  final String action;
  final bool isAlert;
  final int? createdAtMs;

  ALog({
    required this.lid,
    required this.user,
    required this.action,
    required this.isAlert,
    this.createdAtMs,
  });

  factory ALog.fromMap(String lid, Map<String, dynamic> m) => ALog(
        lid: lid,
        user: m['user'] as String? ?? '',
        action: m['action'] as String? ?? '',
        isAlert: m['isAlert'] as bool? ?? false,
        createdAtMs: (m['timestamp'] is int) ? m['timestamp'] as int : null,
      );

  Map<String, dynamic> toMap() => {
        'user': user,
        'action': action,
        'isAlert': isAlert,
        'timestamp': createdAtMs,
      };
}

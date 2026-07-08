class AppUser {
  final String id;
  String name;
  String username;
  String assignedLockerId;
  String password;

  AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.assignedLockerId,
    this.password = 'user123',
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'username': username,
        'password': password,
        'assignedLockerId': assignedLockerId,
      };
}

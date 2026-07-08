enum LS { locked, unlocked, alert }

class Locker {
  final String id;
  final String label;
  LS status;
  final String? owner;
  final bool hasItem;

  Locker({
    required this.id,
    required this.label,
    this.status = LS.locked,
    this.owner,
    this.hasItem = false,
  });

  Map<String, dynamic> toMap() => {
        'label': label,
        'status': status.name,
        'owner': owner,
        'hasItem': hasItem,
      };

  factory Locker.fromMap(String id, Map<String, dynamic> map) {
    return Locker(
      id: id,
      label: map['label'] ?? 'Locker $id',
      status: parseStatus(map['status']),
      owner: map['owner']?.toString(),
      hasItem: map['hasItem'] == true,
    );
  }

  static LS parseStatus(String? s) {
    switch (s) {
      case 'unlocked':
        return LS.unlocked;
      case 'alert':
        return LS.alert;
      default:
        return LS.locked;
    }
  }
}

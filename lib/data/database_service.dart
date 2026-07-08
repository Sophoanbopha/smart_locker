import 'package:firebase_database/firebase_database.dart';
import '../models/locker.dart';
import '../models/app_user.dart';
import '../models/a_log.dart';

class DatabaseService {
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  /// Safely converts any Firebase Map (Map<Object?, Object?>) to Map<String, dynamic>
  static Map<String, dynamic> _safeMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }

  // ─────────────────────────────────────────────────────────────
  // REFERENCES
  // ─────────────────────────────────────────────────────────────
  static DatabaseReference lockerRef(String id) => _db.child('lockers/$id');
  static DatabaseReference usersRef() => _db.child('users');
  static DatabaseReference logsRef(String id) => _db.child('logs/$id');

  // ─────────────────────────────────────────────────────────────
  // LOCKERS
  // ─────────────────────────────────────────────────────────────
  static Stream<List<Locker>> allLockersStream() {
    return _db.child('lockers').onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw == null) return [];
      final data = _safeMap(raw);
      return data.entries.map((entry) {
        if (entry.value is! Map) {
          return Locker(
            id: entry.key,
            label: 'Locker ${entry.key}',
          );
        }
        return Locker.fromMap(
          entry.key,
          _safeMap(entry.value),
        );
      }).toList();
    });
  }

  static Stream<LS> lockerStatusStream(String lockerId) {
    return lockerRef(lockerId).child('status').onValue.map((event) {
      final raw = event.snapshot.value;
      return Locker.parseStatus((raw is String) ? raw : null);
    });
  }

  static Future<void> setLockerStatus(String lockerId, LS status) async {
    await lockerRef(lockerId).update({'status': status.name});
  }

  static Stream<bool> lockerHasItemStream(String lockerId) {
    return lockerRef(lockerId).child('hasItem').onValue.map((event) {
      return event.snapshot.value == true;
    });
  }

  // ─────────────────────────────────────────────────────────────
  // USERS
  // ─────────────────────────────────────────────────────────────
  static Stream<List<AppUser>> allUsersStream() {
    return usersRef().onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw == null) return [];
      final data = _safeMap(raw);
      return data.entries
          .where((entry) => entry.value is Map) // skip malformed entries
          .map((entry) {
        final m = _safeMap(entry.value);
        return AppUser(
          id: entry.key,
          name: m['name']?.toString() ?? '',
          username: m['username']?.toString() ?? entry.key,
          password: m['password']?.toString() ?? 'user123',
          assignedLockerId: m['assignedLockerId']?.toString() ?? '',
        );
      }).toList();
    });
  }

  static Future<void> addUser(AppUser user) async {
    // Save user node
    await usersRef().child(user.username).set(user.toMap());

    // Update locker with owner + label
    if (user.assignedLockerId.isNotEmpty) {
      await lockerRef(user.assignedLockerId).update({
        'owner': user.username,
        'label': 'Locker ${user.assignedLockerId}',
      });
    }
  }

  static Future<void> deleteUser(String username) async {
    try {
      // Read user's assigned locker first
      final snap = await usersRef().child(username).get();
      if (snap.exists && snap.value != null) {
        // FIX: safe cast instead of direct Map<String,dynamic>.from()
        final data = _safeMap(snap.value);
        final lockerId = data['assignedLockerId']?.toString() ?? '';
        if (lockerId.isNotEmpty) {
          // Clear owner from locker
          await lockerRef(lockerId).update({'owner': null});
        }
      }
      // Delete the user node
      await usersRef().child(username).remove();
    } catch (e) {
      // Re-throw so the UI can catch and display the error
      throw Exception('Failed to delete user "$username": $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOGS
  // ─────────────────────────────────────────────────────────────
  static Future<void> pushLog({
    required String lockerId,
    required String user,
    required String action,
    bool isAlert = false,
  }) async {
    await logsRef(lockerId).push().set({
      'user': user,
      'action': action,
      'isAlert': isAlert,
      'timestamp': ServerValue.timestamp,
    });
  }

  static Stream<List<ALog>> lockerLogsStream(String lockerId) {
    return logsRef(lockerId)
        .orderByChild('timestamp')
        .limitToLast(20)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return [];
      final raw = event.snapshot.value;
      if (raw == null) return [];
      final data = _safeMap(raw);
      if (data.isEmpty) return [];
      return data.entries
          .where((e) => e.value is Map)
          .map((e) => ALog.fromMap(
                e.key,
                _safeMap(e.value),
              ))
          .toList()
          .reversed
          .toList();
    });
  }
}

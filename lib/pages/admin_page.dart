import 'dart:async';
import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../data/database_service.dart';
import '../models/app_user.dart';
import '../models/locker.dart';
import '../widgets/locker_card.dart';
import '../widgets/stat_card.dart';
import 'login_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tc;

  List<Locker> _lockers = [];
  List<AppUser> _users = [];

  late StreamSubscription<List<Locker>> _lockerSub;
  late StreamSubscription<List<AppUser>> _userSub;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);

    _lockerSub = DatabaseService.allLockersStream()
        .listen((l) => setState(() => _lockers = l));

    _userSub = DatabaseService.allUsersStream()
        .listen((u) => setState(() => _users = u));
  }

  @override
  void dispose() {
    _tc.dispose();
    _lockerSub.cancel();
    _userSub.cancel();
    super.dispose();
  }

  // ── Toggle locker ──────────────────────────────────────────────
  Future<void> _toggle(Locker l) async {
    if (l.status == LS.alert) return;
    final newStatus = l.status == LS.locked ? LS.unlocked : LS.locked;
    try {
      await DatabaseService.setLockerStatus(l.id, newStatus);
      _snack(
          newStatus == LS.unlocked ? '${l.label} opened' : '${l.label} locked');
    } catch (e) {
      _snack('Failed to update: $e');
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg,
              style: const TextStyle(color: kB, fontWeight: FontWeight.bold)),
          backgroundColor: kY,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );

  // ── Add user dialog ────────────────────────────────────────────
  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'user123');
    String? selectedLockerId;

    // FIX: only consider users with a non-empty assignedLockerId as "taking" a locker
    final takenLockerIds = _users
        .where((u) => u.assignedLockerId.isNotEmpty)
        .map((u) => u.assignedLockerId)
        .toSet();

    final freeLockIds = _lockers
        .map((l) => l.id)
        .where((id) => !takenLockerIds.contains(id))
        .toList();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: kG2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add User',
              style: TextStyle(
                  color: kW, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            _dlgField(nameCtrl, 'Full name', Icons.person_outline),
            const SizedBox(height: 12),
            _dlgField(usernameCtrl, 'Username', Icons.alternate_email),
            const SizedBox(height: 12),
            _dlgField(passCtrl, 'Password', Icons.lock_outline),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: kG, borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLockerId,
                  hint: const Text('Assign locker',
                      style: TextStyle(color: kG3, fontSize: 14)),
                  dropdownColor: kG2,
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more, color: kY, size: 20),
                  items: freeLockIds.isEmpty
                      ? [
                          const DropdownMenuItem(
                              value: null,
                              child: Text('No free lockers',
                                  style: TextStyle(color: kG3, fontSize: 13)))
                        ]
                      : freeLockIds.map((id) {
                          final lbl =
                              _lockers.firstWhere((l) => l.id == id).label;
                          return DropdownMenuItem(
                            value: id,
                            child: Text(lbl,
                                style:
                                    const TextStyle(color: kW, fontSize: 14)),
                          );
                        }).toList(),
                  onChanged: freeLockIds.isEmpty
                      ? null
                      : (v) => setDlg(() => selectedLockerId = v),
                ),
              ),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: kG3)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kY,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final username = usernameCtrl.text.trim().toLowerCase();
                final password = passCtrl.text.trim();

                // FIX: show feedback instead of silently returning
                if (name.isEmpty || username.isEmpty || password.isEmpty) {
                  _snack('Please fill in all fields');
                  return;
                }
                if (selectedLockerId == null) {
                  _snack('Please assign a locker');
                  return;
                }

                // Prevent duplicate username
                if (_users.any((u) => u.username == username)) {
                  _snack('Username "$username" already exists');
                  return;
                }

                final newUser = AppUser(
                  id: username,
                  name: name,
                  username: username,
                  password: password,
                  assignedLockerId: selectedLockerId!,
                );

                try {
                  await DatabaseService.addUser(newUser);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _snack('$name added successfully');
                } catch (e) {
                  if (ctx.mounted) _snack('Failed to add user: $e');
                }
              },
              child: const Text('Add',
                  style: TextStyle(color: kB, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete confirm ─────────────────────────────────────────────
  void _confirmDelete(AppUser u) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kG2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove user?',
            style: TextStyle(
                color: kW, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
          'This will remove ${u.name} and free up their locker.',
          style: const TextStyle(color: kG3, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kG3)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () async {
              // FIX: wrap in try/catch and show error if delete fails
              try {
                await DatabaseService.deleteUser(u.username);
                if (context.mounted) Navigator.pop(context);
                _snack('${u.name} removed');
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  _snack('Failed to remove user: $e');
                }
              }
            },
            child: const Text('Remove',
                style: TextStyle(color: kW, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _dlgField(TextEditingController ctrl, String hint, IconData icon) =>
      TextField(
        controller: ctrl,
        style: const TextStyle(color: kW, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kG3, fontSize: 14),
          prefixIcon: Icon(icon, color: kY, size: 18),
          filled: true,
          fillColor: kG,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kY, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final open = _lockers.where((l) => l.status == LS.unlocked).length;
    final locked = _lockers.where((l) => l.status == LS.locked).length;
    final alert = _lockers.where((l) => l.status == LS.alert).length;

    return Scaffold(
      backgroundColor: kB,
      appBar: AppBar(
        backgroundColor: kB,
        elevation: 0,
        title: const Row(children: [
          Icon(Icons.admin_panel_settings, color: kY, size: 21),
          SizedBox(width: 8),
          Text('Admin Dashboard',
              style: TextStyle(
                  color: kW, fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kG3),
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const LoginPage())),
          ),
        ],
        bottom: TabBar(
          controller: _tc,
          labelColor: kY,
          unselectedLabelColor: kG3,
          indicatorColor: kY,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: .5),
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'LOCKERS'),
            Tab(text: 'USERS'),
          ],
        ),
      ),
      body: TabBarView(controller: _tc, children: [
        _OverviewTab(
          open: open,
          locked: locked,
          alert: alert,
          total: _lockers.length,
        ),
        ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _lockers.length,
          itemBuilder: (_, i) =>
              LockerCard(_lockers[i], () => _toggle(_lockers[i])),
        ),
        _UsersTab(
          users: _users,
          lockers: _lockers,
          onAdd: _showAddUserDialog,
          onDelete: _confirmDelete,
        ),
      ]),
    );
  }
}

// ─── OVERVIEW TAB ──────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final int open, locked, alert, total;
  const _OverviewTab({
    required this.open,
    required this.locked,
    required this.alert,
    required this.total,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Overview',
              style: TextStyle(
                  color: kW, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$total lockers total',
              style: const TextStyle(color: kG3, fontSize: 12)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              StatCard(Icons.grid_view_rounded, 'Total', '$total', kY),
              StatCard(Icons.lock_open_rounded, 'Open', '$open', kGrn),
              StatCard(Icons.lock_rounded, 'Locked', '$locked', kG3),
              StatCard(Icons.warning_amber, 'Alert', '$alert', kRed),
            ],
          ),
        ]),
      );
}

// ─── USERS TAB ─────────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  final List<AppUser> users;
  final List<Locker> lockers;
  final VoidCallback onAdd;
  final void Function(AppUser) onDelete;

  const _UsersTab({
    required this.users,
    required this.lockers,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Users',
                      style: TextStyle(
                          color: kW,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text('${users.length} registered',
                      style: const TextStyle(color: kG3, fontSize: 12)),
                ])),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_alt_1, color: kB, size: 16),
              label: const Text('Add User',
                  style: TextStyle(
                      color: kB, fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kY,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                elevation: 0,
              ),
            ),
          ]),
        ),
        Expanded(
          child: users.isEmpty
              ? const Center(
                  child: Text('No users yet.',
                      style: TextStyle(color: kG3, fontSize: 13)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final u = users[i];
                    final lockerLabel = lockers
                            .where((l) => l.id == u.assignedLockerId)
                            .map((l) => l.label)
                            .firstOrNull ??
                        'Unassigned';
                    return _UserCard(
                      user: u,
                      lockerLabel: lockerLabel,
                      onDelete: () => onDelete(u),
                    );
                  },
                ),
        ),
      ]);
}

// ─── USER CARD ─────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final AppUser user;
  final String lockerLabel;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.lockerLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kG2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kG),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: kY.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: kY, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(user.name,
                    style: const TextStyle(
                        color: kW, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('@${user.username}',
                    style: const TextStyle(color: kG3, fontSize: 12)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.lock_outline, color: kY, size: 12),
                  const SizedBox(width: 4),
                  Text(lockerLabel,
                      style: const TextStyle(
                          color: kY,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ]),
              ])),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: kRed, size: 22),
            tooltip: 'Remove user',
          ),
        ]),
      );
}

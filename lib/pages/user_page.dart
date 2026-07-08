import 'dart:async';
import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/widgets.dart';
import '../data/database_service.dart';
import '../models/app_user.dart';
import '../models/locker.dart';
import 'login_page.dart';

class UserPage extends StatefulWidget {
  final AppUser user;
  final Locker locker;

  const UserPage({
    super.key,
    required this.user,
    required this.locker,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late LS _status;
  late bool _hasItem;
  late StreamSubscription<LS> _statusSub;
  late StreamSubscription<bool> _hasItemSub;

  @override
  void initState() {
    super.initState();

    _status = widget.locker.status;
    _hasItem = widget.locker.hasItem;

    _statusSub =
        DatabaseService.lockerStatusStream(widget.locker.id).listen((s) {
      setState(() {
        _status = s;
      });
    });

    _hasItemSub =
        DatabaseService.lockerHasItemStream(widget.locker.id).listen((v) {
      setState(() {
        _hasItem = v;
      });
    });
  }

  @override
  void dispose() {
    _statusSub.cancel();
    _hasItemSub.cancel();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_status == LS.alert) return;

    final bool willOpen = _status == LS.locked;

    final LS newStatus = willOpen ? LS.unlocked : LS.locked;

    setState(() {
      _status = newStatus;
    });

    try {
      await DatabaseService.setLockerStatus(
        widget.locker.id,
        newStatus,
      );

      _snack(
        willOpen ? 'Locker opened' : 'Locker locked',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = willOpen ? LS.locked : LS.unlocked;
      });

      _snack('Firebase error: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: kB,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kY,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOpen = _status == LS.unlocked;
    final bool isAlert = _status == LS.alert;

    return Scaffold(
      backgroundColor: kB,
      appBar: AppBar(
        backgroundColor: kB,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: kY),
            SizedBox(width: 8),
            Text(
              'My Locker',
              style: TextStyle(
                color: kW,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: kG3,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Hello ${widget.user.name}',
              style: const TextStyle(
                color: kW,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kG2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    isAlert
                        ? Icons.warning
                        : isOpen
                            ? Icons.lock_open
                            : Icons.lock,
                    size: 90,
                    color: isAlert
                        ? kRed
                        : isOpen
                            ? kY
                            : kG3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.locker.label,
                    style: const TextStyle(
                      color: kW,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  statusBadge(_status),
                  const SizedBox(height: 10),
                  itemBadge(_hasItem),
                  const SizedBox(height: 30),
                  if (!isAlert)
                    yellowBtn(
                      isOpen ? 'LOCK' : 'UNLOCK',
                      isOpen ? Icons.lock : Icons.lock_open,
                      _toggle,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

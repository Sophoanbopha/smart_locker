import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../core/colors.dart';
import '../core/widgets.dart';
import '../core/decorations.dart';
import '../models/models.dart';
import 'admin_page.dart';
import 'user_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _uCtrl = TextEditingController();
  final _pCtrl = TextEditingController();

  bool _obs = true;
  bool _loading = false;
  String? _err;

  @override
  void dispose() {
    _uCtrl.dispose();
    _pCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _uCtrl.text.trim().toLowerCase();
    final password = _pCtrl.text.trim();

    debugPrint('>>> username: "$username"');
    debugPrint('>>> password: "$password"');

    if (username.isEmpty || password.isEmpty) {
      setState(() => _err = "Please enter your username and password");
      return;
    }

    setState(() {
      _loading = true;
      _err = null;
    });

    try {
      // ── Admin ──────────────────────────────────────────────────
      if (username == 'admin' && password == 'admin123') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPage()),
        );
        return;
      }

      // ── Firebase user lookup ───────────────────────────────────
      debugPrint('>>> looking up: users/$username');

      final snap = await FirebaseDatabase.instance.ref('users/$username').get();

      debugPrint('>>> snap.exists: ${snap.exists}');
      debugPrint('>>> snap.value: ${snap.value}');

      if (!snap.exists || snap.value == null) {
        setState(() {
          _err = "User not found";
          _loading = false;
        });
        return;
      }

      final data = Map<String, dynamic>.from(snap.value as Map);

      debugPrint('>>> data: $data');
      debugPrint('>>> stored password: "${data['password']}"');
      debugPrint('>>> entered password: "$password"');

      // ── Password check ─────────────────────────────────────────
      if (data['password']?.toString() != password) {
        setState(() {
          _err = "Incorrect password";
          _loading = false;
        });
        return;
      }

      // ── Build models ───────────────────────────────────────────
      final lockerId = data['assignedLockerId']?.toString() ?? '';

      debugPrint('>>> lockerId: "$lockerId"');

      final user = AppUser(
        id: username,
        name: data['name']?.toString() ?? username,
        username: username,
        assignedLockerId: lockerId,
      );

      final locker = lockerId.isNotEmpty
          ? await FirebaseDatabase.instance
              .ref('lockers/$lockerId')
              .get()
              .then((s) {
              debugPrint('>>> locker snap.exists: ${s.exists}');
              debugPrint('>>> locker snap.value: ${s.value}');
              if (s.exists && s.value != null) {
                return Locker.fromMap(
                  lockerId,
                  Map<String, dynamic>.from(s.value as Map),
                );
              }
              return Locker(id: lockerId, label: 'Locker $lockerId');
            })
          : Locker(id: lockerId, label: 'Locker $lockerId');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserPage(user: user, locker: locker),
        ),
      );
    } catch (e) {
      debugPrint('>>> ERROR: $e');
      setState(() => _err = "Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: kB,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(28, 0, 28, bottom + 20),
            child: Column(
              children: [
                // ── Logo ─────────────────────────────────────────
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: kY,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.lock_rounded, color: kB, size: 34),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SMART LOCKER',
                  style: TextStyle(
                    color: kW,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 36),

                // ── Username ──────────────────────────────────────
                TextField(
                  controller: _uCtrl,
                  style: const TextStyle(color: kW),
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: inputDec('Username', Icons.person_outline),
                ),
                const SizedBox(height: 12),

                // ── Password ──────────────────────────────────────
                TextField(
                  controller: _pCtrl,
                  obscureText: _obs,
                  style: const TextStyle(color: kW),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  decoration: inputDec('Password', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obs ? Icons.visibility_off : Icons.visibility,
                        color: kG3,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obs = !_obs),
                    ),
                  ),
                ),

                // ── Error ─────────────────────────────────────────
                if (_err != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _err!,
                    style: const TextStyle(color: kRed, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 22),

                // ── Button ────────────────────────────────────────
                _loading
                    ? const CircularProgressIndicator(color: kY)
                    : yellowBtn('LOGIN', Icons.login, _login),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

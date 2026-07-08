import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'core/colors.dart';
import 'pages/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartLockerApp());
}

class SmartLockerApp extends StatelessWidget {
  const SmartLockerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Smart Locker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: kB,
          colorScheme:
              const ColorScheme.dark(primary: kY, onPrimary: kB, surface: kG),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const LoginPage(),
      );
}

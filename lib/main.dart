import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fundamentals/providers/auth_providers.dart';
import 'package:fundamentals/screens/login_screens.dart';
import 'package:fundamentals/screens/profile_screens.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: auth.user != null
                ? const ProfileScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}

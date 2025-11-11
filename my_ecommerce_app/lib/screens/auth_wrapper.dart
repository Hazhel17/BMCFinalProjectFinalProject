import 'package:my_ecommerce_app/screens/home_screen.dart';
import 'package:my_ecommerce_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // Show loading spinner while waiting for initial auth check
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show HomeScreen
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // If user is logged out, show LoginScreen
        return const LoginScreen();
      },
    );
  }
}

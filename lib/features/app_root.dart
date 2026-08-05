import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import 'admin_dashboard_screen.dart';
import 'login_screen.dart';
import 'waiter_dashboard.dart';
import 'kds_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _GlobalLoading(message: "");
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const _GlobalLoading(message: "");
            }

            // যদি ইউজারের তথ্য ডাটাবেসে না থাকে (যেমন ডিলিট করে দেওয়া হয়েছে)
            if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }

            final userData = UserModel.fromFirestore(roleSnapshot.data!);
            final role = userData.role;

            switch (role) {
              case 'admin':
                return const AdminDashboardScreen();
              case 'waiter':
                return const WaiterScreen();
              case 'vendor_staff':
                return const KdsScreen();
              default:
                FirebaseAuth.instance.signOut();
                return const LoginScreen();
            }
          },
        );
      },
    );
  }
}

class _GlobalLoading extends StatelessWidget {
  final String message;
  const _GlobalLoading({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4F18)),
              ),
            ),
            const SizedBox(height: 24),
            if (message.isNotEmpty)
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              )
            else ...[
              const Text(
                "The Circle",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const Text(
                "CAFE & COMMUNITY SPACE",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

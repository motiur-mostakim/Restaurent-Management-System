import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard_screen.dart';
import 'waiter_dashboard.dart';
import 'kds_screen.dart';
import 'loading_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Initial Auth Loading
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _GlobalLoading(message: "");
        }

        final user = authSnapshot.data;

        // Not logged in -> Show Landing/Login
        if (user == null) {
          return const LandingScreen();
        }

        // Logged in -> Fetch Role from Firestore
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const _GlobalLoading(message: "");
            }

            // User document doesn't exist yet (Creation phase)
            if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
              return const _GlobalLoading(message: "Setting up profile...");
            }

            final data = roleSnapshot.data!.data() as Map<String, dynamic>;
            final role = data['role'];

            // Route based on role
            switch (role) {
              case 'admin':
                return const AdminDashboardScreen();
              case 'waiter':
                return const WaiterScreen();
              case 'vendor_staff':
                return const KdsScreen();
              default:
                return const LandingScreen();
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

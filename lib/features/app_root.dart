import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_management/features/splash/splash_screen.dart';
import '../model/user_model.dart';
import 'admin/admin_main_screen.dart';
import 'login_screen/login_screen.dart';
import 'waiter/waiter_main_screen.dart';
import 'kitchen/kitchen_main_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Auth state লোড হওয়ার সময় Splash Screen দেখাবে
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = authSnapshot.data;
        // যদি ইউজার লগইন করা না থাকে
        if (user == null) {
          return const LoginScreen();
        }

        // লগইন করা থাকলে Firestore থেকে তার রোল এবং রেস্টুরেন্ট আইডি চেক করবে
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
              try {
                final userData = UserModel.fromFirestore(roleSnapshot.data!);
                final role = userData.role.toLowerCase();

                switch (role) {
                  case 'super_admin':
                  case 'admin':
                    return const AdminMainScreen();
                  case 'waiter':
                    return const WaiterMainScreen();
                  case 'vendor_staff':
                    return const KitchenMainScreen();
                  default:
                    // যদি রোল না মেলে তবে লগআউট করে লগইন স্ক্রিনে পাঠাবে
                    return _handleInvalidRole();
                }
              } catch (e) {
                return const LoginScreen();
              }
            }

            // যদি Auth ইউজার থাকে কিন্তু Firestore-এ ডেটা না পাওয়া যায় (Registration sync বিলম্বিত হলে)
            if (roleSnapshot.hasData && !roleSnapshot.data!.exists) {
              // কয়েক সেকেন্ড অপেক্ষা করার পর যদি ডেটা না আসে তবে লগআউট করা নিরাপদ
              return const SplashScreen(); 
            }

            if (roleSnapshot.hasError) {
              return const LoginScreen();
            }

            return const SplashScreen();
          },
        );
      },
    );
  }

  Widget _handleInvalidRole() {
    FirebaseAuth.instance.signOut();
    return const LoginScreen();
  }
}

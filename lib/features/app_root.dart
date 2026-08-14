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
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting &&
            authSnapshot.data == null) {
          return const SplashScreen();
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
              return const SplashScreen();
            }

            if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
              try {
                final userData = UserModel.fromFirestore(roleSnapshot.data!);
                final role = userData.role;

                switch (role) {
                  case 'admin':
                    return const AdminMainScreen();
                  case 'waiter':
                    return const WaiterMainScreen();
                  case 'vendor_staff':
                    return const KitchenMainScreen();
                  default:
                    return const LoginScreen();
                }
              } catch (e) {
                return const LoginScreen();
              }
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
}

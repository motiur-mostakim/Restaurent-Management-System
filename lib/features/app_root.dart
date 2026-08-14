import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import 'admin/admin_main_screen.dart';
import 'login_screen.dart';
import 'waiter/waiter_main_screen.dart';
import 'kitchen/kitchen_main_screen.dart';
import 'splash/splash_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        return StreamBuilder<DocumentSnapshot?>(
          stream: user == null
              ? Stream.value(null)
              : FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
          builder: (context, roleSnapshot) {
            final bool isAuthLoading =
                authSnapshot.connectionState == ConnectionState.waiting;
            final bool isRoleLoading =
                user != null &&
                roleSnapshot.connectionState == ConnectionState.waiting &&
                !roleSnapshot.hasData;

            if (isAuthLoading || isRoleLoading) {
              return const SplashScreen(message: "");
            }
            if (user == null) {
              return const LoginScreen();
            }
            if (roleSnapshot.hasData &&
                roleSnapshot.data != null &&
                roleSnapshot.data!.exists) {
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
            }
            return const LoginScreen();
          },
        );
      },
    );
  }
}

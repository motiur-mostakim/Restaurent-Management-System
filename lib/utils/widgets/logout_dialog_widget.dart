import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Row(
        children: [
          Icon(Icons.logout_rounded, color: Colors.red),
          SizedBox(width: 12),
          Text("Sign Out", style: TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
      content: const Text(
        "Are you sure you want to end your current session? You'll need to login again to access the dashboard.",
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "CANCEL",
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            FirebaseAuth.instance.signOut();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "LOGOUT",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ),
      ],
    ),
  );
}

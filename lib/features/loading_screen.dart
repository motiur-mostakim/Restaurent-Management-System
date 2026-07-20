import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool loading = false;
  String? error;

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception("Google sign-in cancelled");
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await auth.signInWithCredential(credential);
  }

  Future<void> handleLogin(String role, {String? vendorId}) async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      UserCredential cred;

      try {
        cred = await signInWithGoogle();
      } catch (e) {
        debugPrint("Google failed → Anonymous login");
        cred = await auth.signInAnonymously();
      }

      await db.collection('users').doc(cred.user!.uid).set({
        'role': role,
        'vendorId': vendorId,
        'email': cred.user!.email ?? "$role@simulation.internal",
        'name':
            cred.user!.displayName ?? role[0].toUpperCase() + role.substring(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      setState(() {
        error = "Login failed. Enable Firebase Auth providers.";
      });
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// 🔥 TITLE
              const Text(
                "BentoBite",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Next-Gen Restaurant OS",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              /// 🔹 ROLE CARDS
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  roleCard(
                    title: "Administrator",
                    icon: Icons.admin_panel_settings,
                    onTap: () => handleLogin('admin'),
                  ),
                  roleCard(
                    title: "Waiter App",
                    icon: Icons.shopping_cart,
                    onTap: () => handleLogin('waiter'),
                  ),
                  roleCard(
                    title: "Kitchen (KDS)",
                    icon: Icons.local_fire_department,
                    onTap: () =>
                        handleLogin('vendor_staff', vendorId: 'fast_food'),
                  ),
                ],
              ),

              /// ❌ ERROR
              if (error != null)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 30),

              /// 🔄 LOADING
              if (loading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget roleCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: loading ? null : onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

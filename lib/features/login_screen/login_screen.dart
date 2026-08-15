import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../model/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _restaurantNameController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;
  String? _error;
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _designationController.dispose();
    _restaurantNameController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = "Please fill in all fields");
      return;
    }

    if (!_isLogin &&
        (_nameController.text.isEmpty || 
         _designationController.text.isEmpty ||
         _restaurantNameController.text.isEmpty)) {
      setState(() => _error = "Please fill in all registration fields");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    User? currentUser;

    try {
      if (_isLogin) {
        // লগইন করার সময়
        final cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        currentUser = cred.user;
        
        // Firestore থেকে তথ্য চেক করা
        final userDoc = await _db.collection('users').doc(cred.user!.uid).get();
        if (userDoc.exists) {
          final userData = UserModel.fromFirestore(userDoc);
          final prefs = await SharedPreferences.getInstance();
          if (userData.restaurantName != null) {
            await prefs.setString('restaurant_name', userData.restaurantName!);
          }
          if (userData.restaurantId != null) {
            await prefs.setString('restaurant_id', userData.restaurantId!);
          }
        } else {
          // যদি Auth-এ ইউজার থাকে কিন্তু Firestore-এ ডাটা না থাকে
          await _auth.signOut();
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: "User profile not found. Please register again.",
          );
        }
      } else {
        // রেজিস্ট্রেশন করার সময়
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        currentUser = cred.user;

        final restaurantId = const Uuid().v4();
        final restaurantName = _restaurantNameController.text.trim();

        // রেস্টুরেন্ট ডাটা সেভ
        await _db.collection('restaurants').doc(restaurantId).set({
          'name': restaurantName,
          'ownerUid': cred.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // ইউজার প্রোফাইল সেভ (super_admin হিসেবে)
        await _syncUserToFirestore(
          cred.user!,
          'super_admin',
          name: _nameController.text.trim(),
          designation: _designationController.text.trim(),
          restaurantName: restaurantName,
          restaurantId: restaurantId,
        );
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('restaurant_name', restaurantName);
        await prefs.setString('restaurant_id', restaurantId);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
      // যদি রেজিস্ট্রেশন অসম্পূর্ণ থাকে তবে Auth থেকে ইউজার রিমুভ করা
      if (!_isLogin && currentUser != null) {
        try {
          await currentUser.delete();
        } catch (_) {}
      }
      await _auth.signOut();
    } catch (e) {
      setState(() => _error = "Authentication failed: ${e.toString()}");
      await _auth.signOut();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _syncUserToFirestore(
    User user,
    String role, {
    String? name,
    String? designation,
    String? restaurantName,
    String? restaurantId,
  }) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email?.toLowerCase() ?? '',
      name:
          name ?? user.displayName ?? role[0].toUpperCase() + role.substring(1),
      role: role,
      designation: designation,
      restaurantName: restaurantName,
      restaurantId: restaurantId,
      vendorId: role == 'vendor_staff' ? 'fast_food' : null,
    );

    await _db
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap(), SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  size: 72,
                  color: Color(0xFFFF4F18),
                ),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? "Welcome Back" : "Register Restaurant",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  _isLogin
                      ? "Sign in to continue your work"
                      : "Register your restaurant as Super Admin",
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 80),
                if (!_isLogin) ...[
                  TextField(
                    controller: _restaurantNameController,
                    style: const TextStyle(color: Color(0xFF0F172A)),
                    decoration: _inputDecoration(
                      "Restaurant Name",
                      Icons.restaurant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Color(0xFF0F172A)),
                    decoration: _inputDecoration(
                      "Owner Name",
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _designationController,
                    style: const TextStyle(color: Color(0xFF0F172A)),
                    decoration: _inputDecoration(
                      "Designation (e.g. CEO)",
                      Icons.work_outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    "Email Address",
                    Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: _inputDecoration(
                    "Password",
                    Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF64748B),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleEmailAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4F18),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isLogin ? "Sign In" : "Register & Start",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: _isLogin
                              ? "Need a restaurant account? "
                              : "Already registered? ",
                        ),
                        TextSpan(
                          text: _isLogin ? "Register Now" : "Sign In",
                          style: const TextStyle(
                            color: Color(0xFFFF4F18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      filled: true,
      suffixIcon: suffixIcon,
      fillColor: const Color(0xFFF8FAFC),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF4F18), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/user_model.dart';

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

  bool _isLoading = false;
  bool _isLogin = true;
  String? _error;
  String _selectedRole = 'waiter';

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = "Please fill in all fields");
      return;
    }

    if (!_isLogin && (_nameController.text.isEmpty || _designationController.text.isEmpty)) {
      setState(() => _error = "Please fill in Name and Designation");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      UserCredential cred;
      if (_isLogin) {
        cred = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Only Admin can sign up from this screen
        cred = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await _syncUserToFirestore(
          cred.user!,
          'admin',
          name: _nameController.text.trim(),
          designation: _designationController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = "Authentication failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _syncUserToFirestore(User user, String role, {String? name, String? designation}) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: name ?? user.displayName ?? role[0].toUpperCase() + role.substring(1),
      role: role,
      designation: designation,
      vendorId: role == 'vendor_staff' ? 'fast_food' : null,
    );
    
    await _db.collection('users').doc(user.uid).set(
      userModel.toMap(),
      SetOptions(merge: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_menu, size: 72, color: Color(0xFFFF4F18)),
                const SizedBox(height: 20),
                const Text(
                  "Restaurant OS",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  "Unified Management Platform",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
                const SizedBox(height: 40),

                // Role selector only shown for Sign In
                if (_isLogin) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Signing in as:",
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _roleButton('admin', Icons.admin_panel_settings, "Admin"),
                      _roleButton('waiter', Icons.person, "Waiter"),
                      _roleButton('vendor_staff', Icons.countertops, "Kitchen"),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                if (!_isLogin) ...[
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Full Name", Icons.person_outline),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _designationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Designation", Icons.work_outline),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Email Address", Icons.email_outlined),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Password", Icons.lock_outline),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isLogin ? "Sign In" : "Create Admin Account",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      children: [
                        TextSpan(text: _isLogin ? "Don't have an account? " : "Already have an account? "),
                        TextSpan(
                          text: _isLogin ? "Register as Admin" : "Sign In",
                          style: const TextStyle(color: Color(0xFFFF4F18), fontWeight: FontWeight.bold),
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
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
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

  Widget _roleButton(String role, IconData icon, String label) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF4F18) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFFFF4F18) : Colors.white10,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF4F18), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }
}

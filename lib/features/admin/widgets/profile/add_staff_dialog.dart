import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/dashboard_provider.dart';

class AddStaffDialog extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;
  final List<String> roles;
  final String? adminRestaurantId;
  final String? adminRestaurantName;

  const AddStaffDialog({super.key,
    this.docId,
    this.data,
    required this.roles,
    this.adminRestaurantId,
    this.adminRestaurantName,
  });

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late String _selectedRole;
  String? _selectedVendorId;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  bool get isEdit => widget.docId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data?['name'] ?? '');
    _emailController = TextEditingController(text: widget.data?['email'] ?? '');
    _passwordController = TextEditingController();
    _selectedRole = widget.data?['role'] ?? 'waiter';
    _selectedVendorId = widget.data?['vendorId'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(List vendors) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == 'vendor_staff' && _selectedVendorId == null && vendors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a vendor for the vendor role")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isEdit) {
        await FirebaseFirestore.instance.collection('users').doc(widget.docId).update({
          'name': _nameController.text.trim(),
          'role': _selectedRole,
          'vendorId': _selectedRole == 'vendor_staff' ? _selectedVendorId : null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) Navigator.pop(context);
      } else {
        FirebaseApp? secondaryApp;
        try {
          secondaryApp = await Firebase.initializeApp(
            name: 'SecondaryApp',
            options: Firebase.app().options,
          );

          FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

          UserCredential userCredential = await secondaryAuth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          final String uid = userCredential.user!.uid;

          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'role': _selectedRole,
            'vendorId': _selectedRole == 'vendor_staff' ? _selectedVendorId : null,
            'restaurantId': widget.adminRestaurantId,
            'restaurantName': widget.adminRestaurantName,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account created successfully!")),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${e.toString()}")),
            );
          }
        } finally {
          if (secondaryApp != null) {
            await secondaryApp.delete();
          }
        }
      }
    } catch (e) {
      debugPrint("Save error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendors = Provider.of<DashboardProvider>(context, listen: false).vendors;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF4F18).withOpacity(0.1),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(isEdit ? Icons.manage_accounts_rounded : Icons.person_add_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEdit ? "Edit Staff Member" : "Add Staff Member",
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                  ),
                                  Text(
                                    isEdit ? "Update profile information" : "Create new staff credentials",
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.white54),
                          splashRadius: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModalSectionLabel("FULL NAME"),
                        TextFormField(
                          controller: _nameController,
                          validator: (v) => v!.isEmpty ? "Required" : null,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B), fontSize: 16),
                          decoration: _modalInputDecoration("Enter staff full name", Icons.person_rounded),
                        ),
                        const SizedBox(height: 20),
                        if (!isEdit) ...[
                          _buildModalSectionLabel("EMAIL ADDRESS"),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v!.isEmpty || !v.contains('@') ? "Enter a valid email" : null,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B), fontSize: 16),
                            decoration: _modalInputDecoration("Enter email address", Icons.alternate_email_rounded),
                          ),
                          const SizedBox(height: 20),
                          _buildModalSectionLabel("PASSWORD"),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: (v) => v!.length < 6 ? "Minimum 6 characters" : null,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B), fontSize: 16),
                            decoration: _modalInputDecoration("Enter password", Icons.lock_outline_rounded),
                          ),
                          const SizedBox(height: 20),
                        ],
                        _buildModalSectionLabel("DESIGNATION / ROLE"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedRole,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                              items: widget.roles.map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r == 'vendor_staff'
                                        ? (vendors.isEmpty ? 'KITCHEN' : 'VENDOR')
                                        : r.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontSize: 14),
                                  )
                              )).toList(),
                              onChanged: (v) => setState(() {
                                _selectedRole = v!;
                                if (_selectedRole != 'vendor_staff') _selectedVendorId = null;
                              }),
                            ),
                          ),
                        ),
                        if (_selectedRole == 'vendor_staff' && vendors.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildModalSectionLabel("ASSIGNED VENDOR"),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: const Text("Select Vendor", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                                value: _selectedVendorId,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                                items: vendors.map((v) => DropdownMenuItem(
                                    value: v.id,
                                    child: Text(v.name, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontSize: 14))
                                )).toList(),
                                onChanged: (v) => setState(() => _selectedVendorId = v),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                child: const Text("CANCEL", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () => _handleSave(vendors),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF4F18),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  elevation: 8,
                                  shadowColor: const Color(0xFFFF4F18).withOpacity(0.3),
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                                    : Text(isEdit ? "SAVE CHANGES" : "CREATE ACCOUNT", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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

  Widget _buildModalSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.5),
      ),
    );
  }

  InputDecoration _modalInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400, fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF4F18), width: 2)),
    );
  }
}

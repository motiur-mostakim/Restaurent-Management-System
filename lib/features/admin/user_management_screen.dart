import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/dashboard_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<String> _roles = ['waiter', 'vendor_staff'];

  void _showStaffDialog({String? docId, Map<String, dynamic>? data}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: docId == null ? "Add Staff" : "Edit Staff",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => _StaffModal(
        docId: docId,
        data: data,
        roles: _roles,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  void _deleteStaffDialog(String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Staff"),
        content: Text("Are you sure you want to remove $name? This staff member will no longer have access to the app."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('users').doc(docId).delete();
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                debugPrint("Delete error: $e");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("DELETE", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendors = Provider.of<DashboardProvider>(context).vendors;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Staff Management", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            onPressed: () => _showStaffDialog(),
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFFFF4F18), size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Divider(thickness: 1, color: Color(0xFFE2E8F0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "EXISTING STAFF MEMBERS",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1.5),
                  ),
                ),
                const Expanded(child: Divider(thickness: 1, color: Color(0xFFE2E8F0))),
              ],
            ),
            const SizedBox(height: 24),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').where('role', whereIn: ['waiter', 'vendor_staff']).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return Center(child: Text("No staff members found.", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)));
                
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isVendor = data['role'] == 'vendor_staff';
                    
                    String vendorName = "";
                    if (isVendor && data['vendorId'] != null) {
                      try {
                        vendorName = vendors.firstWhere((v) => v.id == data['vendorId']).name;
                      } catch(_) {
                        vendorName = "Unknown Vendor";
                      }
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isVendor ? const Color(0xFF3B82F6).withOpacity(0.1) : const Color(0xFFFF4F18).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isVendor ? Icons.storefront_rounded : Icons.person_rounded,
                              color: isVendor ? const Color(0xFF3B82F6) : const Color(0xFFFF4F18),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                                Text(data['email'] ?? '', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        data['role'].toString().replaceAll('_staff', '').toUpperCase(),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF475569), letterSpacing: 0.5),
                                      ),
                                    ),
                                    if (isVendor && vendorName.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(8)),
                                        child: Text(
                                          vendorName.toUpperCase(),
                                          style: const TextStyle(fontSize: 9, color: Color(0xFF1E40AF), fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              _ActionIconButton(
                                icon: Icons.edit_note_rounded,
                                color: const Color(0xFF3B82F6),
                                onTap: () => _showStaffDialog(docId: doc.id, data: data),
                              ),
                              const SizedBox(height: 8),
                              _ActionIconButton(
                                icon: Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                onTap: () => _deleteStaffDialog(doc.id, data['name'] ?? 'Staff'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _StaffModal extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;
  final List<String> roles;

  const _StaffModal({
    this.docId,
    this.data,
    required this.roles,
  });

  @override
  State<_StaffModal> createState() => _StaffModalState();
}

class _StaffModalState extends State<_StaffModal> {
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == 'vendor_staff' && _selectedVendorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a vendor for the vendor role")),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (isEdit) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(widget.docId).update({
          'name': _nameController.text.trim(),
          'role': _selectedRole,
          'vendorId': _selectedRole == 'vendor_staff' ? _selectedVendorId : null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) Navigator.pop(context);
      } catch (e) {
        debugPrint("Update error: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
        if (mounted) setState(() => _isLoading = false);
      }
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
                // Stylish Header
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
                            Column(
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

                // Body
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
                                  r == 'vendor_staff' ? 'VENDOR' : r.toUpperCase(),
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
                        if (_selectedRole == 'vendor_staff') ...[
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
                                onPressed: _isLoading ? null : _handleSave,
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

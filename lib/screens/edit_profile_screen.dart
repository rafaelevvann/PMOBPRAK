import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

const _kRed = Color(0xFFE8003D);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  String? _errorMsg;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _errorMsg = null;
      _loading = true;
    });

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMsg = 'Nama tidak boleh kosong';
        _loading = false;
      });
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _errorMsg = 'Format email tidak valid';
        _loading = false;
      });
      return;
    }

    // Simulasi delay singkat
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    final ok = context.read<AppState>().editProfile(name, email);
    setState(() => _loading = false);

    if (!ok) {
      setState(() => _errorMsg = 'Email sudah digunakan akun lain');
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui ✓'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar
            Consumer<AppState>(
              builder: (_, state, __) => Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: _kRed,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    state.currentUser?.name[0].toUpperCase() ?? '?',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              'Foto profil menggunakan inisial nama',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Error banner
            if (_errorMsg != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: _kRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(color: _kRed, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Form
            _buildField(
              label: 'Nama Lengkap',
              controller: _nameCtrl,
              icon: Icons.person_outline,
              type: TextInputType.name,
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'Email',
              controller: _emailCtrl,
              icon: Icons.email_outlined,
              type: TextInputType.emailAddress,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required TextInputType type,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _kRed, size: 20),
            hintText: 'Masukkan $label',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kRed, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

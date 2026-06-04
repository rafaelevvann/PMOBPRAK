import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

const kRed = Color(0xFFE8003D);

void showAuthModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const AuthModal(),
  );
}

class AuthModal extends StatefulWidget {
  const AuthModal({super.key});

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  bool isLogin = true;

  // Login controllers
  final _loginEmail = TextEditingController();
  final _loginPass = TextEditingController();

  // Register controllers
  final _regName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPass = TextEditingController();
  final _regPass2 = TextEditingController();

  // Role selection
  UserRole _selectedRole = UserRole.donatur;

  String? _errorMsg;

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPass.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPass.dispose();
    _regPass2.dispose();
    super.dispose();
  }

  void _doLogin() {
    setState(() => _errorMsg = null);
    final email = _loginEmail.text.trim();
    final pass = _loginPass.text;
    if (!email.contains('@')) {
      setState(() => _errorMsg = 'Email tidak valid');
      return;
    }
    if (pass.length < 6) {
      setState(() => _errorMsg = 'Password minimal 6 karakter');
      return;
    }
    final ok = context.read<AppState>().login(email, pass);
    if (!ok) {
      setState(() => _errorMsg = 'Email atau password salah');
      return;
    }
    Navigator.pop(context);
    final user = context.read<AppState>().currentUser!;
    final roleLabel = user.role == UserRole.admin
        ? 'Admin'
        : user.role == UserRole.fundraiser
            ? 'Fundraiser'
            : 'Donatur';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selamat datang kembali, $roleLabel! 👋'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _doRegister() {
    setState(() => _errorMsg = null);
    final name = _regName.text.trim();
    final email = _regEmail.text.trim();
    final pass = _regPass.text;
    final pass2 = _regPass2.text;
    if (name.isEmpty) {
      setState(() => _errorMsg = 'Nama tidak boleh kosong');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorMsg = 'Email tidak valid');
      return;
    }
    if (pass.length < 6) {
      setState(() => _errorMsg = 'Password minimal 6 karakter');
      return;
    }
    if (pass != pass2) {
      setState(() => _errorMsg = 'Password tidak cocok');
      return;
    }
    final ok = context
        .read<AppState>()
        .register(name, email, pass, role: _selectedRole);
    if (!ok) {
      setState(() => _errorMsg = 'Email sudah terdaftar');
      return;
    }
    Navigator.pop(context);
    final roleLabel = _selectedRole == UserRole.admin
        ? 'Admin'
        : _selectedRole == UserRole.fundraiser
            ? 'Fundraiser'
            : 'Donatur';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selamat datang, $name! 🎉 ($roleLabel)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Selamat Datang di BantuIn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Masuk atau daftar untuk mulai membantu sesama',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // ─── TABS
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _tabBtn(
                    'Masuk',
                    isLogin,
                    () => setState(() {
                      isLogin = true;
                      _errorMsg = null;
                    }),
                  ),
                  _tabBtn(
                    'Daftar',
                    !isLogin,
                    () => setState(() {
                      isLogin = false;
                      _errorMsg = null;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── ERROR
            if (_errorMsg != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(color: kRed, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

            // ─── FORM
            if (isLogin) ...[
              _inputField('Email', _loginEmail, TextInputType.emailAddress),
              const SizedBox(height: 12),
              _inputField(
                'Password',
                _loginPass,
                TextInputType.text,
                obscure: true,
              ),
              const SizedBox(height: 20),
              _submitBtn('Masuk', _doLogin),
            ] else ...[
              // ─── ROLE SELECTOR
              _buildRoleSelector(),
              const SizedBox(height: 16),
              _inputField('Nama Lengkap', _regName, TextInputType.name),
              const SizedBox(height: 12),
              _inputField('Email', _regEmail, TextInputType.emailAddress),
              const SizedBox(height: 12),
              _inputField(
                'Password',
                _regPass,
                TextInputType.text,
                obscure: true,
              ),
              const SizedBox(height: 12),
              _inputField(
                'Konfirmasi Password',
                _regPass2,
                TextInputType.text,
                obscure: true,
              ),
              const SizedBox(height: 20),
              _submitBtn('Daftar', _doRegister),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ─── ROLE SELECTOR WIDGET
  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar sebagai',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _roleBtn(
                icon: Icons.favorite_outline,
                label: 'Donatur',
                subtitle: 'Berdonasi',
                isActive: _selectedRole == UserRole.donatur,
                onTap: () => setState(() => _selectedRole = UserRole.donatur),
              ),
              const SizedBox(width: 4),
              _roleBtn(
                icon: Icons.campaign_outlined,
                label: 'Fundraiser',
                subtitle: 'Buat kampanye',
                isActive: _selectedRole == UserRole.fundraiser,
                onTap: () =>
                    setState(() => _selectedRole = UserRole.fundraiser),
              ),
              const SizedBox(width: 4),
              _roleBtn(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Admin',
                subtitle: 'Kelola sistem',
                isActive: _selectedRole == UserRole.admin,
                onTap: () => setState(() => _selectedRole = UserRole.admin),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roleBtn({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(color: kRed.withValues(alpha: 0.3), width: 1.5)
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: kRed.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? kRed : Colors.grey[500],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isActive ? kRed : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? kRed.withValues(alpha: 0.7) : Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController ctrl,
    TextInputType type, {
    bool obscure = false,
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
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kRed),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitBtn(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

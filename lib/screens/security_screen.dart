import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

const _kRed = Color(0xFFE8003D);

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  int _strength(String pass) {
    if (pass.isEmpty) return 0;
    int score = 0;
    if (pass.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pass)) score++;
    if (RegExp(r'[0-9]').hasMatch(pass)) score++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(pass)) score++;
    return score;
  }

  Future<void> _save() async {
    setState(() { _errorMsg = null; _loading = true; });
    final oldPass = _oldPassCtrl.text;
    final newPass = _newPassCtrl.text;
    final confirmPass = _confirmPassCtrl.text;
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      setState(() { _errorMsg = 'Semua kolom harus diisi'; _loading = false; });
      return;
    }
    if (newPass.length < 6) {
      setState(() { _errorMsg = 'Password baru minimal 6 karakter'; _loading = false; });
      return;
    }
    if (newPass != confirmPass) {
      setState(() { _errorMsg = 'Konfirmasi password tidak cocok'; _loading = false; });
      return;
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final ok = context.read<AppState>().changePassword(oldPass, newPass);
    setState(() => _loading = false);
    if (!ok) { setState(() => _errorMsg = 'Password lama salah'); return; }
    if (!mounted) return;
    _oldPassCtrl.clear(); _newPassCtrl.clear(); _confirmPassCtrl.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password berhasil diubah 🔒'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength(_newPassCtrl.text);
    final sColors = [Colors.grey.shade200, const Color(0xFFEF4444), const Color(0xFFF97316), const Color(0xFFEAB308), const Color(0xFF22C55E)];
    final sLabels = ['', 'Lemah', 'Sedang', 'Kuat', 'Sangat Kuat'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
        title: const Text('Keamanan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.black)),
        centerTitle: true,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.lock_outline, color: _kRed, size: 32),
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('Ubah Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            const SizedBox(height: 6),
            Center(child: Text('Gunakan password yang kuat untuk keamanan akun Anda', style: TextStyle(fontSize: 13, color: Colors.grey.shade600), textAlign: TextAlign.center)),
            const SizedBox(height: 32),
            if (_errorMsg != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFECDD3))),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: _kRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_errorMsg!, style: const TextStyle(color: _kRed, fontSize: 13))),
                ]),
              ),
            ],
            _passField('Password Lama', _oldPassCtrl, _showOld, () => setState(() => _showOld = !_showOld)),
            const SizedBox(height: 16),
            _passField('Password Baru', _newPassCtrl, _showNew, () => setState(() => _showNew = !_showNew), onChanged: (_) => setState(() {})),
            if (_newPassCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(children: List.generate(4, (i) => Expanded(child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(color: i < strength ? sColors[strength] : Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
              )))),
              const SizedBox(height: 4),
              Text(sLabels[strength], style: TextStyle(fontSize: 12, color: sColors[strength], fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 16),
            _passField('Konfirmasi Password Baru', _confirmPassCtrl, _showConfirm, () => setState(() => _showConfirm = !_showConfirm)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBBF7D0))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.lightbulb_outline, color: Color(0xFF16A34A), size: 16),
                  SizedBox(width: 6),
                  Text('Tips Password Kuat', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF16A34A))),
                ]),
                const SizedBox(height: 6),
                _tip('Minimal 8 karakter'),
                _tip('Kombinasi huruf besar dan kecil'),
                _tip('Sertakan angka'),
                _tip('Tambahkan karakter khusus (!@#\$%)'),
              ]),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _kRed, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                onPressed: _loading ? null : _save,
                child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Perbarui Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passField(String label, TextEditingController ctrl, bool show, VoidCallback onToggle, {ValueChanged<String>? onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        obscureText: !show,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline, color: _kRed, size: 20),
          suffixIcon: IconButton(icon: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade500, size: 20), onPressed: onToggle),
          hintText: 'Masukkan $label',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          filled: true, fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kRed, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    ]);
  }

  Widget _tip(String text) => Padding(
    padding: const EdgeInsets.only(top: 3),
    child: Row(children: [
      const Icon(Icons.check_circle_outline, size: 13, color: Color(0xFF16A34A)),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF166534))),
    ]),
  );
}

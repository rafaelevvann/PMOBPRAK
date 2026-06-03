import 'package:flutter/material.dart';

const _kRed = Color(0xFFE8003D);

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'Bagaimana cara berdonasi?',
      answer: 'Pilih kampanye yang ingin Anda dukung dari halaman Beranda atau Jelajahi, lalu ketuk tombol "Donasi Sekarang". Masukkan nominal yang ingin Anda donasikan dan konfirmasi.',
    ),
    _FaqItem(
      question: 'Apakah donasi saya aman?',
      answer: 'Ya, seluruh transaksi dilindungi dengan enkripsi SSL. Dana Anda langsung disalurkan kepada penyelenggara kampanye yang telah terverifikasi oleh tim BantuIn.',
    ),
    _FaqItem(
      question: 'Bagaimana cara melihat riwayat donasi?',
      answer: 'Buka tab "Donasi" di menu bawah, atau masuk ke halaman Profil dan ketuk "Riwayat Donasi". Semua donasi Anda akan tercatat di sana.',
    ),
    _FaqItem(
      question: 'Bisakah saya membatalkan donasi?',
      answer: 'Donasi yang sudah dikonfirmasi tidak dapat dibatalkan karena langsung diproses untuk kampanye. Namun jika ada kendala, hubungi tim support kami dalam 1x24 jam.',
    ),
    _FaqItem(
      question: 'Apakah ada biaya administrasi?',
      answer: 'BantuIn tidak memungut biaya administrasi dari donatur. 100% dari nominal yang Anda masukkan akan diteruskan ke kampanye yang dipilih.',
    ),
    _FaqItem(
      question: 'Bagaimana jika kampanye tidak mencapai target?',
      answer: 'Jika kampanye tidak mencapai target, dana tetap disalurkan secara proporsional kepada penerima manfaat sesuai kemampuan terkumpul.',
    ),
  ];

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
          'Bantuan',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.black),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8003D), Color(0xFFFF4D6D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ada yang bisa kami bantu?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tim support kami siap membantu Anda',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.support_agent, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Kontak
          const Text(
            'HUBUNGI KAMI',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),

          _contactTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@bantuin.id',
            color: const Color(0xFF3B82F6),
            onTap: () {},
          ),
          _contactTile(
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat',
            subtitle: 'Tersedia Senin–Jumat, 08.00–17.00 WIB',
            color: const Color(0xFF10B981),
            onTap: () {},
          ),
          _contactTile(
            icon: Icons.phone_outlined,
            title: 'Telepon',
            subtitle: '0800-1234-5678 (bebas pulsa)',
            color: const Color(0xFF8B5CF6),
            onTap: () {},
          ),

          const SizedBox(height: 24),

          const Text(
            'PERTANYAAN UMUM (FAQ)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),

          // FAQ accordion
          ..._faqs.map((faq) => _FaqTile(item: faq)),

          const SizedBox(height: 24),

          // Version info
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'BantuIn v1.0.0',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 BantuIn. All rights reserved.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  bool expanded = false;

  _FaqItem({required this.question, required this.answer});
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.item.expanded) _ctrl.value = 1;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => widget.item.expanded = !widget.item.expanded);
          widget.item.expanded ? _ctrl.forward() : _ctrl.reverse();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: _rotate,
                    child: const Icon(Icons.keyboard_arrow_down, color: _kRed, size: 20),
                  ),
                ],
              ),
              if (widget.item.expanded) ...[
                const SizedBox(height: 10),
                Text(
                  widget.item.answer,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

const _kRed = Color(0xFFE8003D);

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.black),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 8),
              _sectionHeader('Aktivitas Akun'),
              _notifTile(
                context,
                icon: Icons.favorite_border,
                title: 'Konfirmasi Donasi',
                subtitle: 'Notifikasi saat donasi Anda berhasil diproses',
                value: state.notifDonasi,
                key: 'donasi',
              ),
              _notifTile(
                context,
                icon: Icons.campaign_outlined,
                title: 'Update Kampanye',
                subtitle: 'Pemberitahuan progres kampanye yang Anda dukung',
                value: state.notifKampanye,
                key: 'kampanye',
              ),
              const SizedBox(height: 20),
              _sectionHeader('Konten & Promosi'),
              _notifTile(
                context,
                icon: Icons.newspaper_outlined,
                title: 'Berita & Artikel',
                subtitle: 'Artikel terbaru seputar kegiatan sosial',
                value: state.notifBerita,
                key: 'berita',
              ),
              _notifTile(
                context,
                icon: Icons.local_offer_outlined,
                title: 'Promo & Program Khusus',
                subtitle: 'Info program donasi spesial dan penggalangan dana',
                value: state.notifPromo,
                key: 'promo',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: _kRed, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Notifikasi penting seperti keamanan akun akan selalu dikirimkan meskipun dinonaktifkan.',
                        style: TextStyle(fontSize: 12, color: Colors.red.shade700, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9CA3AF),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _notifTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required String key,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _kRed, size: 20),
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
          Switch(
            value: value,
            onChanged: (val) => context.read<AppState>().setNotif(key, val),
            activeThumbColor: _kRed,
            activeTrackColor: const Color(0xFFFECDD3),
          ),
        ],
      ),
    );
  }
}

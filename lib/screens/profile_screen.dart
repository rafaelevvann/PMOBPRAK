import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/auth_modal.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'notification_screen.dart';
import 'help_screen.dart';
import 'my_campaigns_screen.dart';

const kRed = Color(0xFFE8003D);

void _showSwitchRoleDialog(BuildContext context, AppState state) {
  final targetRole =
      state.isFundraiser ? 'Donatur' : 'Fundraiser';
  final targetIcon =
      state.isFundraiser ? Icons.favorite_outline : Icons.campaign_outlined;
  final targetEmoji = state.isFundraiser ? '💝' : '🎯';

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.swap_horiz, color: kRed, size: 22),
          ),
          const SizedBox(width: 12),
          const Text(
            'Pindah Akun',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(targetIcon, color: kRed, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$targetEmoji $targetRole',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.isFundraiser
                            ? 'Berdonasi ke kampanye orang lain'
                            : 'Buat dan kelola kampanye donasi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Anda akan beralih dari mode ${state.isFundraiser ? "Fundraiser" : "Donatur"} ke mode $targetRole. Data Anda tetap tersimpan.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Batal',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          onPressed: () {
            state.switchRole();
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Berhasil beralih ke mode $targetRole! $targetEmoji'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text(
            'Ya, Pindah',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: state.currentUser == null
          ? _buildNotLogged(context)
          : _buildLogged(context, state),
    );
  }

  // ─── NOT LOGGED IN
  Widget _buildNotLogged(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: kRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Profil',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF2F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: kRed,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Masuk untuk Melanjutkan',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masuk atau buat akun untuk melihat riwayat donasi dan mengelola profil Anda.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.65,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
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
                        onPressed: () => showAuthModal(context),
                        child: const Text(
                          'Masuk / Daftar',
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
            ),
          ),
        ],
      ),
    );
  }

  // ─── LOGGED IN
  Widget _buildLogged(BuildContext context, AppState state) {
    return Column(
      children: [
        // ─── USER BANNER
        Container(
          color: kRed,
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: Text(
                  state.currentUser!.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                state.currentUser!.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                state.currentUser!.email,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  state.isAdmin
                      ? '🛡️ Admin'
                      : state.isFundraiser
                          ? '🎯 Fundraiser'
                          : '💝 Donatur',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _statItem(
                    state.formatRupiah(state.totalDonated),
                    'Total Donasi',
                  ),
                  const SizedBox(width: 24),
                  _statItem('${state.myDonations.length}x', 'Kampanye'),
                ],
              ),
            ],
          ),
        ),

        // ─── MENU
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 8),
              if (!state.isAdmin)
                _menuItem(
                  Icons.swap_horiz,
                  'Pindah Akun',
                  state.isFundraiser
                      ? 'Beralih ke mode Donatur'
                      : 'Beralih ke mode Fundraiser',
                  () => _showSwitchRoleDialog(context, state),
                ),
              if (state.isFundraiser)
                _menuItem(
                  Icons.campaign_outlined,
                  'Kampanye Saya',
                  'Kelola kampanye donasi Anda',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyCampaignsScreen()),
                  ),
                ),
              _menuItem(
                Icons.favorite_border,
                'Riwayat Donasi',
                'Lihat semua donasi Anda',
                () {
                  context.read<AppState>().setTab(state.isFundraiser ? 3 : 2);
                },
              ),
              _menuItem(
                Icons.person_outline,
                'Edit Profil',
                'Ubah nama dan email',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
              ),
              _menuItem(
                Icons.lock_outline,
                'Keamanan',
                'Ubah password',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SecurityScreen()),
                ),
              ),
              _menuItem(
                Icons.notifications_none,
                'Notifikasi',
                'Atur preferensi notifikasi',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                ),
              ),
              _menuItem(
                Icons.help_outline,
                'Bantuan',
                'FAQ dan hubungi kami',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                ),
              ),
              const SizedBox(height: 8),

              // ─── LOGOUT
              GestureDetector(
                onTap: () {
                  context.read<AppState>().logout();
                  context.read<AppState>().setTab(0);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    border: Border.all(
                      color: const Color(0xFFFECDD3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Keluar dari Akun',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kRed,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statItem(String num, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          num,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: kRed, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const Text(
              '›',
              style: TextStyle(fontSize: 18, color: Color(0xFFD1D5DB)),
            ),
          ],
        ),
      ),
    );
  }
}

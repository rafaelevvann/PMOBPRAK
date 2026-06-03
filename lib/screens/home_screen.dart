import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/campaign_card.dart';
import '../widgets/auth_modal.dart';
import '../widgets/donate_modal.dart';
import 'create_campaign_screen.dart';

const kRed = Color(0xFFE8003D);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildSidebar(context, state),
      body: Builder(
        builder: (ctx) => CustomScrollView(
          slivers: [
            // ─── APP BAR
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              pinned: true,
              automaticallyImplyLeading: false,
              title: Row(
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
                    'BantuIn',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ],
            ),

            // ─── USER BANNER
            if (state.currentUser != null)
              SliverToBoxAdapter(child: _buildUserBanner(state)),

            // ─── HERO
            SliverToBoxAdapter(child: _buildHero(context, state)),

            // ─── IMPACT
            SliverToBoxAdapter(child: _buildImpact()),

            // ─── CAMPAIGNS TITLE
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kampanye Unggulan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Jelajahi kampanye aktif kami dan buat dampak langsung.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── CAMPAIGN CARDS
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final c = state.campaigns[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: CampaignCard(
                    campaign: c,
                    onDonate: () => showDonateModal(context, c),
                  ),
                );
              }, childCount: state.campaigns.length),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  // ─── HERO SECTION
  Widget _buildHero(BuildContext context, AppState state) {
    return SizedBox(
      height: 380,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=800&q=80',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x1A000000),
                  Color(0x8C000000),
                  Color(0xCC000000),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bersama Kita Bisa\nMengubah Hidup',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Setiap donasi membuat perbedaan. Bergabunglah dengan kami untuk membawa harapan bagi masyarakat yang membutuhkan.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
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
                    onPressed: () {
                      if (state.currentUser == null) showAuthModal(context);
                    },
                    child: const Text(
                      'Mulai Donasi',
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
        ],
      ),
    );
  }

  // ─── USER BANNER
  Widget _buildUserBanner(AppState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8003D), Color(0xFFFF4D6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              if (state.isFundraiser) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'FUNDRAISER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
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
              color: Colors.white.withValues(alpha: 0.88)
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem(state.formatRupiah(state.totalDonated), 'Total Donasi'),
              const SizedBox(width: 24),
              _statItem('${state.myDonations.length}x', 'Kampanye Didukung'),
            ],
          ),
        ],
      ),
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
          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.88)),
        ),
      ],
    );
  }

  // ─── IMPACT SECTION
  Widget _buildImpact() {
    return Container(
      color: kRed,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dampak Global Kami',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Berkat donatur yang dermawan, kami telah membuat perbedaan nyata di komunitas di seluruh dunia.',
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.4,
            children: [
              _impactItem(Icons.people, '2.5Jt+', 'Kehidupan Terbantu'),
              _impactItem(Icons.favorite, '150Rb+', 'Donatur di Seluruh Dunia'),
              _impactItem(Icons.language, '65+', 'Negara Terjangkau'),
              _impactItem(Icons.monetization_on, 'Rp 45M+', 'Dana Terkumpul'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactItem(IconData icon, String num, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration:const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          num,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, 
          color: Colors.white.withValues(alpha: 0.88)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── SIDEBAR DRAWER
  Widget _buildSidebar(BuildContext context, AppState state) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: kRed,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'BantuIn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _sidebarItem(context, Icons.home, 'Beranda', () {
                  Navigator.pop(context);
                  context.read<AppState>().setTab(0);
                }),
                _sidebarItem(context, Icons.search, 'Kampanye', () {
                  Navigator.pop(context);
                  context.read<AppState>().setTab(1);
                }),
                _sidebarItem(
                  context,
                  Icons.language,
                  'Tentang Kami',
                  () => Navigator.pop(context),
                ),
                _sidebarItem(
                  context,
                  Icons.people,
                  'Dampak Kami',
                  () => Navigator.pop(context),
                ),
                if (state.isFundraiser)
                  _sidebarItem(
                    context,
                    Icons.add_circle_outline,
                    'Buat Kampanye',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CreateCampaignScreen()),
                      );
                    },
                  ),
                _sidebarItem(
                  context,
                  state.currentUser != null ? Icons.logout : Icons.login,
                  state.currentUser != null ? 'Keluar' : 'Masuk / Daftar',
                  () {
                    Navigator.pop(context);
                    if (state.currentUser != null) {
                      state.logout();
                    } else {
                      showAuthModal(context);
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF1F2937),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+1 (555) 123-4567\n123 Charity Street\nNew York, NY 10001',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2026 BantuIn. Hak cipta dilindungi.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF9FAFB))),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF374151)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/my_campaigns_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/admin_campaigns_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const BantuInApp(),
    ),
  );
}

class BantuInApp extends StatelessWidget {
  const BantuInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BantuIn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE8003D)),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const MainShell(),
      },
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isAdmin = state.isAdmin;
    final isFundraiser = state.isFundraiser;

    // ─── ADMIN NAVIGATION
    if (isAdmin) {
      final adminScreens = <Widget>[
        const AdminDashboardScreen(),
        const AdminUsersScreen(),
        const AdminCampaignsScreen(),
        const ProfileScreen(),
      ];

      final adminNavItems = <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.people_outline), label: 'Pengguna'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined), label: 'Kampanye'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profil'),
      ];

      final maxIndex = adminScreens.length - 1;
      final safeIndex = state.currentTabIndex.clamp(0, maxIndex);

      return Scaffold(
        body: IndexedStack(index: safeIndex, children: adminScreens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (i) => context.read<AppState>().setTab(i),
          selectedItemColor: const Color(0xFF1F2937),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 10.5,
          ),
          items: adminNavItems,
        ),
      );
    }

    // ─── DONATUR / FUNDRAISER NAVIGATION
    final screens = <Widget>[
      const HomeScreen(),
      const ExploreScreen(),
      if (isFundraiser) const MyCampaignsScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.search), label: 'Jelajahi'),
      if (isFundraiser)
        const BottomNavigationBarItem(
            icon: Icon(Icons.campaign), label: 'Kampanye'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.favorite_border),
        label: 'Donasi',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profil',
      ),
    ];

    final maxIndex = screens.length - 1;
    final safeIndex = state.currentTabIndex.clamp(0, maxIndex);

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (i) => context.read<AppState>().setTab(i),
        selectedItemColor: const Color(0xFFE8003D),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 10.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 10.5,
        ),
        items: navItems,
      ),
    );
  }
}


import 'package:flutter/material.dart';

// ─── MODEL: USER
class UserAccount {
  final String name;
  final String email;
  final String password;
  UserAccount({
    required this.name,
    required this.email,
    required this.password,
  });
}

// ─── MODEL: DONATION
class DonationRecord {
  final String userEmail;
  final String campaign;
  final int amount;
  final String date;
  final String img;
  DonationRecord({
    required this.userEmail,
    required this.campaign,
    required this.amount,
    required this.date,
    required this.img,
  });
}

// ─── MODEL: CAMPAIGN
class Campaign {
  final String title;
  final String category;
  final String description;
  final int collected;
  final int target;
  final int donors;
  final int daysLeft;
  final String imageUrl;

  Campaign({
    required this.title,
    required this.category,
    required this.description,
    required this.collected,
    required this.target,
    required this.donors,
    required this.daysLeft,
    required this.imageUrl,
  });

  double get progressPercent => collected / target;
}

// ─── APP STATE (Provider)
class AppState extends ChangeNotifier {
  UserAccount? currentUser;
  List<UserAccount> accounts = [];
  List<DonationRecord> donations = [];
  int currentTabIndex = 0;

  // ─── CAMPAIGN DATA
  final List<Campaign> campaigns = [
    Campaign(
      title: 'Education for Every Child',
      category: 'Education',
      description:
          'Help us provide quality education, books, and school supplies to children in need.',
      collected: 45000,
      target: 75000,
      donors: 892,
      daysLeft: 23,
      imageUrl:
          'https://images.unsplash.com/photo-1497486751825-1233686d5d80?w=600&q=80',
    ),
    Campaign(
      title: 'Clean Water for Communities',
      category: 'Water & Sanitation',
      description:
          'Build wells and water filtration systems to provide clean, safe drinking water.',
      collected: 62000,
      target: 100000,
      donors: 1245,
      daysLeft: 15,
      imageUrl:
          'https://images.unsplash.com/photo-1541544537156-7627a7a4aa1c?w=600&q=80',
    ),
    Campaign(
      title: 'Healthcare for Remote Areas',
      category: 'Healthcare',
      description:
          'Providing essential medical supplies and checkups to remote communities.',
      collected: 27000,
      target: 60000,
      donors: 638,
      daysLeft: 31,
      imageUrl:
          'https://images.unsplash.com/photo-1504813184591-01572f98c85f?w=600&q=80',
    ),
    Campaign(
      title: 'Food for Families',
      category: 'Food',
      description:
          'Distributing food packages to families affected by extreme poverty and drought.',
      collected: 18000,
      target: 40000,
      donors: 412,
      daysLeft: 18,
      imageUrl:
          'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=600&q=80',
    ),
    Campaign(
      title: 'Beasiswa Anak Bangsa',
      category: 'Education',
      description:
          'Memberikan beasiswa kepada anak-anak berprestasi dari keluarga kurang mampu.',
      collected: 33000,
      target: 50000,
      donors: 750,
      daysLeft: 40,
      imageUrl:
          'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=600&q=80',
    ),
  ];

  // ─── AUTH
  bool login(String email, String password) {
    final acc = accounts
        .where((a) => a.email == email && a.password == password)
        .firstOrNull;
    if (acc == null) return false;
    currentUser = acc;
    notifyListeners();
    return true;
  }

  bool register(String name, String email, String password) {
    if (accounts.any((a) => a.email == email)) return false;
    final acc = UserAccount(name: name, email: email, password: password);
    accounts.add(acc);
    currentUser = acc;
    notifyListeners();
    return true;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  // ─── DONATIONS
  void addDonation(String campaign, int amount, String img) {
    if (currentUser == null) return;
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')} '
        '${_monthName(now.month)} ${now.year}';
    donations.add(
      DonationRecord(
        userEmail: currentUser!.email,
        campaign: campaign,
        amount: amount,
        date: date,
        img: img,
      ),
    );
    notifyListeners();
  }

  List<DonationRecord> get myDonations => donations
      .where((d) => d.userEmail == currentUser?.email)
      .toList()
      .reversed
      .toList();

  int get totalDonated => myDonations.fold(0, (sum, d) => sum + d.amount);

  // ─── HELPERS
  void setTab(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[m - 1];
  }

  String formatRupiah(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }
}

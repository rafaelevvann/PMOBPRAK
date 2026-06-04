import 'package:flutter/material.dart';

// ─── ENUM: USER ROLE
enum UserRole { donatur, fundraiser, admin }

// ─── MODEL: USER
class UserAccount {
  String name;
  String email;
  String password;
  UserRole role;
  UserAccount({
    required this.name,
    required this.email,
    required this.password,
    this.role = UserRole.donatur,
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
  final String creatorEmail;
  final String location;

  Campaign({
    required this.title,
    required this.category,
    required this.description,
    required this.collected,
    required this.target,
    required this.donors,
    required this.daysLeft,
    required this.imageUrl,
    this.creatorEmail = '',
    this.location = '',
  });

  double get progressPercent => collected / target;
}

// ─── APP STATE (Provider)
class AppState extends ChangeNotifier {
  UserAccount? currentUser;
  List<UserAccount> accounts = [];
  List<DonationRecord> donations = [];
  int currentTabIndex = 0;

  // ─── NOTIFICATION PREFERENCES
  bool notifDonasi = true;
  bool notifKampanye = true;
  bool notifBerita = false;
  bool notifPromo = false;

  void setNotif(String key, bool val) {
    switch (key) {
      case 'donasi':
        notifDonasi = val;
        break;
      case 'kampanye':
        notifKampanye = val;
        break;
      case 'berita':
        notifBerita = val;
        break;
      case 'promo':
        notifPromo = val;
        break;
    }
    notifyListeners();
  }

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

  // ─── ROLE HELPERS
  bool get isFundraiser =>
      currentUser != null && currentUser!.role == UserRole.fundraiser;

  bool get isAdmin =>
      currentUser != null && currentUser!.role == UserRole.admin;

  void switchRole() {
    if (currentUser == null) return;
    currentUser!.role = currentUser!.role == UserRole.donatur
        ? UserRole.fundraiser
        : UserRole.donatur;
    // Reset tab index to avoid overflow when nav items change
    currentTabIndex = 0;
    notifyListeners();
  }

  List<Campaign> get myCampaigns => campaigns
      .where((c) => c.creatorEmail == currentUser?.email)
      .toList();

  // ─── ADMIN: GLOBAL STATS
  int get totalUsers => accounts.length;
  int get totalDonatur => accounts.where((a) => a.role == UserRole.donatur).length;
  int get totalFundraiser => accounts.where((a) => a.role == UserRole.fundraiser).length;
  int get totalCampaigns => campaigns.length;
  int get totalAllDonations => donations.fold(0, (sum, d) => sum + d.amount);
  int get totalDonationCount => donations.length;

  // ─── ADMIN: MANAGE CAMPAIGNS
  void deleteCampaign(int index) {
    if (!isAdmin || index < 0 || index >= campaigns.length) return;
    campaigns.removeAt(index);
    notifyListeners();
  }

  // ─── ADMIN: MANAGE USERS
  void deleteUser(int index) {
    if (!isAdmin || index < 0 || index >= accounts.length) return;
    final target = accounts[index];
    // Jangan hapus diri sendiri
    if (target.email == currentUser?.email) return;
    // Hapus donasi terkait
    donations.removeWhere((d) => d.userEmail == target.email);
    // Hapus campaign terkait
    campaigns.removeWhere((c) => c.creatorEmail == target.email);
    accounts.removeAt(index);
    notifyListeners();
  }

  void changeUserRole(int index, UserRole newRole) {
    if (!isAdmin || index < 0 || index >= accounts.length) return;
    final target = accounts[index];
    // Jangan ubah diri sendiri
    if (target.email == currentUser?.email) return;
    target.role = newRole;
    notifyListeners();
  }

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

  bool register(String name, String email, String password,
      {UserRole role = UserRole.donatur}) {
    if (accounts.any((a) => a.email == email)) return false;
    final acc =
        UserAccount(name: name, email: email, password: password, role: role);
    accounts.add(acc);
    currentUser = acc;
    notifyListeners();
    return true;
  }

  void logout() {
    currentUser = null;
    currentTabIndex = 0;
    notifyListeners();
  }

  // ─── EDIT PROFILE
  bool editProfile(String newName, String newEmail) {
    if (currentUser == null) return false;
    // cek email sudah dipakai user lain
    if (newEmail != currentUser!.email &&
        accounts.any((a) => a.email == newEmail)) {
      return false;
    }
    // update donations yang terkait
    final oldEmail = currentUser!.email;
    for (final d in donations) {
      if (d.userEmail == oldEmail) {
        donations[donations.indexOf(d)] = DonationRecord(
          userEmail: newEmail,
          campaign: d.campaign,
          amount: d.amount,
          date: d.date,
          img: d.img,
        );
      }
    }
    currentUser!.name = newName;
    currentUser!.email = newEmail;
    notifyListeners();
    return true;
  }

  // ─── CHANGE PASSWORD
  bool changePassword(String oldPass, String newPass) {
    if (currentUser == null) return false;
    if (currentUser!.password != oldPass) return false;
    currentUser!.password = newPass;
    notifyListeners();
    return true;
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

  // ─── CAMPAIGNS (FUNDRAISER)
  void addCampaign({
    required String title,
    required String category,
    required String description,
    required int target,
    required int daysLeft,
    required String imageUrl,
    String location = '',
  }) {
    if (currentUser == null) return;
    campaigns.add(
      Campaign(
        title: title,
        category: category,
        description: description,
        collected: 0,
        target: target,
        donors: 0,
        daysLeft: daysLeft,
        imageUrl: imageUrl,
        creatorEmail: currentUser!.email,
        location: location,
      ),
    );
    notifyListeners();
  }

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

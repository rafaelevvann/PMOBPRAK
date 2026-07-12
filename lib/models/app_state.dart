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
  final String paymentMethod;
  final String message;
  final bool isAnonymous;

  DonationRecord({
    required this.userEmail,
    required this.campaign,
    required this.amount,
    required this.date,
    required this.img,
    this.paymentMethod = 'QRIS',
    this.message = '',
    this.isAnonymous = false,
  });
}

// ─── MODEL: CAMPAIGN
class Campaign {
  final String title;
  final String category;
  final String description;
  int collected;
  final int target;
  int donors;
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
  List<DonationRecord> donations = [];
  int currentTabIndex = 0;

  // ─── HARDCODED ADMIN ACCOUNT
  List<UserAccount> accounts = [
    UserAccount(
      name: 'Admin Bantuln',
      email: 'admin123@gmail.com',
      password: 'admin123',
      role: UserRole.admin,
    ),
  ];

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
  final List<Campaign> campaigns = [];

  AppState() {
    campaigns.add(
      Campaign(
        title: 'Bantu Anak-anak di RSUD Bantul',
        category: 'Kesehatan',
        description:
            'Dukung pengobatan dan kebutuhan harian anak-anak yang sedang dirawat di rumah sakit serta keluarga mereka.',
        collected: 12500000,
        target: 25000000,
        donors: 184,
        daysLeft: 18,
        imageUrl:
            'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&q=80',
        creatorEmail: 'yayasan.bantuln@gmail.com',
        location: 'Bantul',
      ),
    );
  }

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
    // Admin tidak bisa didaftarkan, hanya lewat hardcode
    if (role == UserRole.admin) return false;
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
          paymentMethod: d.paymentMethod,
          message: d.message,
          isAnonymous: d.isAnonymous,
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
  void addDonation(
    String campaign,
    int amount,
    String img, {
    String paymentMethod = 'QRIS',
    String message = '',
    bool isAnonymous = false,
  }) {
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
        paymentMethod: paymentMethod,
        message: message,
        isAnonymous: isAnonymous,
      ),
    );

    // Update campaign stats
    final campIndex = campaigns.indexWhere((c) => c.title == campaign);
    if (campIndex != -1) {
      campaigns[campIndex].collected += amount;
      campaigns[campIndex].donors += 1;
    }

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

import 'package:flutter_test/flutter_test.dart';
import 'package:bantuin/models/app_state.dart';

void main() {
  group('AppState campaign seed', () {
    test('hanya memuat satu kampanye utama yang realistis', () {
      final state = AppState();

      expect(state.campaigns, hasLength(1));
      expect(state.campaigns.single.title, contains('Bantu'));
      expect(state.campaigns.single.target, greaterThan(0));
      expect(state.campaigns.single.daysLeft, greaterThan(0));
    });

    test('donasi menambah progress kampanye yang aktif', () {
      final state = AppState();
      state.currentUser = UserAccount(
        name: 'Test Donatur',
        email: 'test@example.com',
        password: '123456',
        role: UserRole.donatur,
      );

      state.addDonation(state.campaigns.single.title, 50000, 'assets/image/logo.png');

      expect(state.donations, hasLength(1));
      expect(state.campaigns.single.collected, 12550000);
      expect(state.campaigns.single.donors, 185);
    });
  });
}

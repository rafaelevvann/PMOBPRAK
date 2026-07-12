import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../screens/donation_flow_screen.dart';
import 'auth_modal.dart';

const kRed = Color(0xFFE8003D);

void showDonateModal(BuildContext context, Campaign campaign) {
  final state = context.read<AppState>();
  if (state.currentUser == null) {
    showAuthModal(context);
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DonationFlowScreen(campaign: campaign),
    ),
  );
}

class DonateModal extends StatefulWidget {
  final Campaign campaign;
  const DonateModal({super.key, required this.campaign});

  @override
  State<DonateModal> createState() => _DonateModalState();
}

class _DonateModalState extends State<DonateModal> {
  int selectedAmount = 0;
  final _customCtrl = TextEditingController();

  final List<int> amounts = [10000, 25000, 50000, 100000, 250000, 500000];

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

  void _confirm() {
    final amount = selectedAmount > 0
        ? selectedAmount
        : int.tryParse(_customCtrl.text) ?? 0;

    if (amount < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum donasi adalah Rp 1.000'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AppState>().addDonation(
      widget.campaign.title,
      amount,
      widget.campaign.imageUrl,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Donasi ${formatRupiah(amount)} berhasil! 🙏'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.campaign.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih atau masukkan nominal donasi (Rupiah)',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // ─── AMOUNT CHIPS
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: amounts.map((amt) {
                final selected = selectedAmount == amt;
                return GestureDetector(
                  onTap: () => setState(() {
                    selectedAmount = amt;
                    _customCtrl.clear();
                  }),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFFEF2F2) : Colors.white,
                      border: Border.all(
                        color: selected ? kRed : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formatRupiah(amt),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? kRed : const Color(0xFF374151),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // ─── CUSTOM INPUT
            TextField(
              controller: _customCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => selectedAmount = 0),
              decoration: InputDecoration(
                prefixText: 'Rp  ',
                prefixStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
                hintText: 'Nominal lain...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kRed),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Donasi minimum Rp 1.000. Dana 100% tersalurkan kepada penerima manfaat.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // ─── BUTTONS
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
                onPressed: _confirm,
                child: const Text(
                  'Konfirmasi Donasi',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: const Color(0xFF374151),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

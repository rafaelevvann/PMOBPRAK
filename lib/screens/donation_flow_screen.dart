import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

const kRed = Color(0xFFE8003D);

class DonationFlowScreen extends StatefulWidget {
  final Campaign campaign;
  const DonationFlowScreen({super.key, required this.campaign});

  @override
  State<DonationFlowScreen> createState() => _DonationFlowScreenState();
}

class _DonationFlowScreenState extends State<DonationFlowScreen> {
  int _currentStep = 1; // 1: Nominal, 2: Pembayaran, 3: Konfirmasi

  // Step 1: Nominal
  int _selectedAmount = 1000000; // Default Rp 1.000.000 matching screenshot
  final _customAmountCtrl = TextEditingController();
  final _messageCtrl = TextEditingController(text: 'Semangat'); // Default from screenshot
  bool _isAnonymous = false;

  // Step 2: Pembayaran
  String _selectedPaymentMethod = 'QRIS'; // Default matching screenshot

  // Step 3: Konfirmasi
  bool _agreeTerms = false;

  final List<int> presetAmounts = [25000, 50000, 100000, 250000, 500000, 1000000];

  @override
  void dispose() {
    _customAmountCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  int get _amount {
    if (_selectedAmount > 0) return _selectedAmount;
    return int.tryParse(_customAmountCtrl.text) ?? 0;
  }

  String _formatRupiah(int n) {
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

  Widget _buildPaymentLogo(String type) {
    Color bg;
    String text;
    switch (type) {
      case 'BCA':
        bg = const Color(0xFF005CAA);
        text = 'BCA';
        break;
      case 'BNI':
        bg = const Color(0xFFF15A24);
        text = 'BNI';
        break;
      case 'MDR':
        bg = const Color(0xFFF9A825);
        text = 'MDR';
        break;
      case 'GoPay':
        bg = const Color(0xFF00AED6);
        text = 'GoPay';
        break;
      case 'QRIS':
        bg = const Color(0xFFE11927);
        text = 'QRIS';
        break;
      default:
        bg = Colors.grey;
        text = '';
    }
    return Container(
      width: 52,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }

  void _submitDonation() {
    if (!_agreeTerms) return;

    final state = context.read<AppState>();
    state.addDonation(
      widget.campaign.title,
      _amount,
      widget.campaign.imageUrl,
      paymentMethod: _selectedPaymentMethod,
      message: _messageCtrl.text,
      isAnonymous: _isAnonymous,
    );

    // Return to main/explore and show success
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Donasi ${_formatRupiah(_amount)} berhasil! Terima kasih atas dukungan Anda. 🙏'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // ─── CUSTOM WEB-LIKE HEADER
          _buildWebHeader(context, user),

          // ─── STEP PROGRESS TRACKER
          _buildStepProgressTracker(),

          // ─── MAIN RESPONSIVE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT PANEL: Active Step Form (Flex 3)
                            Expanded(
                              flex: 3,
                              child: _buildLeftPanel(),
                            ),
                            const SizedBox(width: 24),
                            // RIGHT PANEL: Donation Summary (Flex 2)
                            Expanded(
                              flex: 2,
                              child: _buildRightPanel(),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildLeftPanel(),
                            const SizedBox(height: 24),
                            _buildRightPanel(),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── WEB-LIKE HEADER
  Widget _buildWebHeader(BuildContext context, UserAccount? user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: kRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'BantuIn',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // Menu Links (Visible on desktop/tablet)
              if (MediaQuery.of(context).size.width > 600)
                const Row(
                  children: [
                    Text('Kampanye', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                    SizedBox(width: 24),
                    Text('Tentang Kami', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                    SizedBox(width: 24),
                    Text('Dampak Kami', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                    SizedBox(width: 24),
                    Text('Kontak', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                  ],
                ),
              // User info & Button
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFFCE7F3),
                    child: Text(
                      user != null ? user.name[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: kRed,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Lihat Kampanye',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── STEP PROGRESS TRACKER
  Widget _buildStepProgressTracker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6)),
          bottom: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            children: [
              _buildStepItem(1, 'Nominal'),
              _buildStepConnector(1),
              _buildStepItem(2, 'Pembayaran'),
              _buildStepConnector(2),
              _buildStepItem(3, 'Konfirmasi'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(int stepNum, String title) {
    final isActive = _currentStep == stepNum;
    final isDone = _currentStep > stepNum;

    Color bg;
    Color textCol;
    Widget child;

    if (isDone) {
      bg = kRed;
      textCol = kRed;
      child = const Icon(Icons.check, color: Colors.white, size: 14);
    } else if (isActive) {
      bg = kRed;
      textCol = kRed;
      child = Text(
        '$stepNum',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
    } else {
      bg = const Color(0xFFE5E7EB);
      textCol = Colors.grey;
      child = Text(
        '$stepNum',
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
      );
    }

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
          child: child,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isActive || isDone ? FontWeight.w700 : FontWeight.w500,
            color: textCol,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int stepNum) {
    final isDone = _currentStep > stepNum;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isDone ? kRed : const Color(0xFFE5E7EB),
      ),
    );
  }

  // ─── LEFT PANEL (ACTIVE STEP FORM)
  Widget _buildLeftPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and header
          Row(
            children: [
              if (_currentStep > 1)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  onPressed: () => setState(() => _currentStep--),
                )
              else
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStepTitle(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      _getStepSubtitle(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Render active step layout
          if (_currentStep == 1)
            _buildStepNominal()
          else if (_currentStep == 2)
            _buildStepPembayaran()
          else
            _buildStepKonfirmasi(),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Pilih Nominal Donasi';
      case 2:
        return 'Metode Pembayaran';
      case 3:
        return 'Konfirmasi Donasi';
      default:
        return '';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 1:
        return 'Pilih atau ketik nominal yang ingin Anda donasikan';
      case 2:
        return 'Pilih cara Anda ingin membayar';
      case 3:
        return 'Periksa kembali detail donasi Anda sebelum mengirim';
      default:
        return '';
    }
  }

  // ─── STEP 1: NOMINAL
  Widget _buildStepNominal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid of preset amount chips
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 500 ? 3 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.3,
          children: presetAmounts.map((amt) {
            final isSelected = _selectedAmount == amt;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedAmount = amt;
                _customAmountCtrl.clear();
              }),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? kRed : Colors.white,
                  border: Border.all(
                    color: isSelected ? kRed : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatRupiah(amt),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Custom amount label & field
        const Text(
          'Atau masukkan nominal lain',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customAmountCtrl,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() => _selectedAmount = 0),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF374151), fontSize: 14),
            hintText: 'Contoh: 75000',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kRed, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Minimal donasi Rp 5.000',
          style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
        ),
        const SizedBox(height: 20),

        // Message
        const Text(
          'Pesan untuk Penggalang Dana (opsional)',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _messageCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tulis pesan dukungan Anda...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kRed, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 20),

        // Anonymous toggle
        Row(
          children: [
            Switch(
              value: _isAnonymous,
              onChanged: (val) => setState(() => _isAnonymous = val),
              activeThumbColor: kRed,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Donasi sebagai Anonim',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF374151)),
                  ),
                  Text(
                    'Nama Anda tidak akan ditampilkan di daftar donatur',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Submit Step button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (_amount < 5000) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Minimal donasi adalah Rp 5.000'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              setState(() => _currentStep = 2);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lanjut ke Pembayaran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── STEP 2: PEMBAYARAN
  Widget _buildStepPembayaran() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category 1: TRANSFER BANK
        const Text(
          'TRANSFER BANK',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF9CA3AF),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption('BCA', 'Bank BCA', 'Transfer via ATM / m-Banking / Internet Banking'),
        const SizedBox(height: 10),
        _buildPaymentOption('BNI', 'Bank BNI', 'Transfer via ATM / m-Banking / Internet Banking'),
        const SizedBox(height: 10),
        _buildPaymentOption('MDR', 'Bank Mandiri', 'Transfer via ATM / Livin by Mandiri'),

        const SizedBox(height: 24),

        // Category 2: DOMPET DIGITAL
        const Text(
          'DOMPET DIGITAL',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF9CA3AF),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption('GoPay', 'GoPay', 'Bayar langsung via aplikasi Gojek'),
        const SizedBox(height: 10),
        _buildPaymentOption('QRIS', 'QRIS', 'Bayar instan dengan QR code QRIS'),

        const SizedBox(height: 28),

        // Continue Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() => _currentStep = 3);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lanjut ke Konfirmasi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String code, String title, String desc) {
    final isSelected = _selectedPaymentMethod == code;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = code),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF2F2) : Colors.white,
          border: Border.all(
            color: isSelected ? kRed : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kRed : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: kRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Logo badge
            _buildPaymentLogo(code),
            const SizedBox(width: 14),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STEP 3: KONFIRMASI
  Widget _buildStepKonfirmasi() {
    final state = context.read<AppState>();
    final donatorName = state.currentUser?.name ?? 'Anonim';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Detail Table
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _buildDetailRow('Kampanye', widget.campaign.title, boldVal: true),
              const Divider(height: 24, color: Color(0xFFE5E7EB)),
              _buildDetailRow('Donatur', _isAnonymous ? 'Donatur Anonim' : donatorName),
              const Divider(height: 24, color: Color(0xFFE5E7EB)),
              _buildDetailRow('Metode Bayar', _selectedPaymentMethod),
              const Divider(height: 24, color: Color(0xFFE5E7EB)),
              _buildDetailRow('Nominal Donasi', _formatRupiah(_amount)),
              const Divider(height: 24, color: Color(0xFFE5E7EB)),
              _buildDetailRow('Biaya Layanan', 'Gratis', valColor: Colors.green),
              const Divider(height: 24, color: Color(0xFFE5E7EB)),
              _buildDetailRow('Total Pembayaran', _formatRupiah(_amount), valColor: kRed, boldVal: true),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Support Message display
        if (_messageCtrl.text.isNotEmpty) ...[
          const Text(
            'Pesan Anda',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF374151)),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Text(
              '"${_messageCtrl.text}"',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 13.5,
                color: kRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Terms and conditions agreement checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _agreeTerms,
              onChanged: (val) => setState(() => _agreeTerms = val ?? false),
              activeColor: kRed,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Saya menyetujui Syarat & Ketentuan Bantuln dan menyatakan bahwa donasi ini sah serta tidak melanggar hukum yang berlaku.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Final Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _agreeTerms ? kRed : const Color(0xFFE5E7EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _agreeTerms ? _submitDonation : null,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 18),
                SizedBox(width: 8),
                Text('Kirim Donasi Sekarang', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valColor, bool boldVal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: boldVal ? FontWeight.w800 : FontWeight.w600,
              color: valColor ?? const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // ─── RIGHT PANEL (DONATION SUMMARY SIDEBAR)
  Widget _buildRightPanel() {
    final pct = widget.campaign.progressPercent.clamp(0.0, 1.0);

    return Column(
      children: [
        // 1. Campaign mini card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.campaign.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE7F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.campaign.category.toLowerCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: kRed,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.campaign.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              // Creator Name
              Row(
                children: [
                  const CircleAvatar(
                    radius: 9,
                    backgroundColor: Color(0xFFFCE7F3),
                    child: Text(
                      'Y',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kRed),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Yayasan Harapan Timur',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 5,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(kRed),
                ),
              ),
              const SizedBox(height: 8),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatRupiah(widget.campaign.collected)} terkumpul',
                    style: const TextStyle(fontSize: 11.5, color: kRed, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${(pct * 100).toInt()}%',
                    style: const TextStyle(fontSize: 11.5, color: kRed, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'dari ${_formatRupiah(widget.campaign.target)} target',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  Text(
                    '${widget.campaign.daysLeft} hari lagi',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Ringkasan Donasi Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Donasi',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nominal', style: TextStyle(fontSize: 12.5, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                  Text(_formatRupiah(_amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Biaya Layanan', style: TextStyle(fontSize: 12.5, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                  const Text('Gratis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Metode', style: TextStyle(fontSize: 12.5, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                  Text(
                    _currentStep > 1 ? _selectedPaymentMethod : '—',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE5E7EB)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                  Text(
                    _formatRupiah(_amount),
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: kRed),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Donasi Aman & Terpercaya Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Donasi Aman & Terpercaya',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              _buildTrustpoint('100% tersalurkan ke penerima'),
              const SizedBox(height: 8),
              _buildTrustpoint('Terverifikasi & transparan'),
              const SizedBox(height: 8),
              _buildTrustpoint('Laporan disediakan berkala'),
              const SizedBox(height: 8),
              _buildTrustpoint('Terdaftar di Kemensos RI'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustpoint(String text) {
    return Row(
      children: [
        const Icon(Icons.check, color: Colors.green, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

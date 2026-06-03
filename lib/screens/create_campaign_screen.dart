import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

const kRed = Color(0xFFE8003D);

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  int _currentStep = 0;

  // Step 1: Info Dasar
  final _titleCtrl = TextEditingController();
  String _selectedCategory = '';
  final _locationCtrl = TextEditingController();

  // Step 2: Detail & Target
  final _targetCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Step 3: Media
  final _imageUrlCtrl = TextEditingController();

  final List<String> _categories = [
    'Education',
    'Healthcare',
    'Water & Sanitation',
    'Food',
    'Bencana Alam',
    'Lingkungan',
    'Sosial',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _targetCtrl.dispose();
    _daysCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        if (_titleCtrl.text.trim().isEmpty) {
          _showError('Judul kampanye harus diisi');
          return false;
        }
        if (_selectedCategory.isEmpty) {
          _showError('Pilih kategori kampanye');
          return false;
        }
        if (_locationCtrl.text.trim().isEmpty) {
          _showError('Lokasi harus diisi');
          return false;
        }
        return true;
      case 1:
        if (_targetCtrl.text.trim().isEmpty ||
            (int.tryParse(_targetCtrl.text.trim()) ?? 0) < 10000) {
          _showError('Target donasi minimal Rp 10.000');
          return false;
        }
        if (_daysCtrl.text.trim().isEmpty ||
            (int.tryParse(_daysCtrl.text.trim()) ?? 0) < 1) {
          _showError('Durasi kampanye minimal 1 hari');
          return false;
        }
        if (_descCtrl.text.trim().isEmpty) {
          _showError('Deskripsi kampanye harus diisi');
          return false;
        }
        return true;
      case 2:
        if (_imageUrlCtrl.text.trim().isEmpty) {
          _showError('URL gambar harus diisi');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: kRed),
    );
  }

  void _nextStep() {
    if (!_validateStep()) return;
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _publishCampaign() {
    final state = context.read<AppState>();
    state.addCampaign(
      title: _titleCtrl.text.trim(),
      category: _selectedCategory,
      description: _descCtrl.text.trim(),
      target: int.parse(_targetCtrl.text.trim()),
      daysLeft: int.parse(_daysCtrl.text.trim()),
      imageUrl: _imageUrlCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kampanye berhasil dipublikasi! 🎉'),
        backgroundColor: Colors.green,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildHeader(),
            _buildStepper(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    // Form + Preview side by side on wide screens
                    _buildFormArea(),
                    const SizedBox(height: 20),
                    _buildPreviewCard(),
                    const SizedBox(height: 24),
                    _buildNavButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── APP BAR
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: kRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          const Text(
            'BantuIn',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(Icons.chevron_left, size: 18, color: Color(0xFF374151)),
                const SizedBox(width: 2),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'FUNDRAISER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: kRed,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Buat Kampanye Baru',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Isi detail kampanye Anda agar bisa segera menerima donasi dari para donatur.',
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEPPER INDICATOR
  Widget _buildStepper() {
    final steps = ['Info Dasar', 'Detail & Target', 'Media', 'Review'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone ? kRed : const Color(0xFFE5E7EB),
                    ),
                  ),
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? kRed
                            : isActive
                                ? kRed
                                : const Color(0xFFE5E7EB),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey[500],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? kRed : Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                if (i < steps.length - 1 && i == 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < _currentStep
                          ? kRed
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── FORM AREA
  Widget _buildFormArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step label
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: kRed, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LANGKAH ${_currentStep + 1} DARI 4',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    _stepTitle(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Step content
          if (_currentStep == 0) _buildStep1(),
          if (_currentStep == 1) _buildStep2(),
          if (_currentStep == 2) _buildStep3(),
          if (_currentStep == 3) _buildStep4Review(),
        ],
      ),
    );
  }

  String _stepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Informasi Dasar';
      case 1:
        return 'Detail & Target';
      case 2:
        return 'Media';
      case 3:
        return 'Review & Publikasi';
      default:
        return '';
    }
  }

  // ─── STEP 1: INFO DASAR
  Widget _buildStep1() {
    return Column(
      children: [
        _formField(
          'Judul Kampanye',
          _titleCtrl,
          'cth: Bantuan Korban Gempa Cianjur 2025',
          maxLength: 100,
        ),
        const SizedBox(height: 16),
        _dropdownField('Kategori', _selectedCategory, _categories,
            (val) => setState(() => _selectedCategory = val ?? '')),
        const SizedBox(height: 16),
        _formField(
          'Lokasi Bencana / Wilayah',
          _locationCtrl,
          'cth: Cianjur, Jawa Barat',
        ),
      ],
    );
  }

  // ─── STEP 2: DETAIL & TARGET
  Widget _buildStep2() {
    return Column(
      children: [
        _formField(
          'Target Donasi (Rp)',
          _targetCtrl,
          'cth: 50000000',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _formField(
          'Durasi Kampanye (hari)',
          _daysCtrl,
          'cth: 30',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _formField(
          'Deskripsi Kampanye',
          _descCtrl,
          'Jelaskan tujuan kampanye Anda secara detail...',
          maxLines: 5,
        ),
      ],
    );
  }

  // ─── STEP 3: MEDIA
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formField(
          'URL Gambar Kampanye',
          _imageUrlCtrl,
          'https://example.com/image.jpg',
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        const Text(
          'Preview Gambar',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: _imageUrlCtrl.text.trim().isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _imageUrlCtrl.text.trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  ),
                )
              : _imagePlaceholder(),
        ),
        const SizedBox(height: 8),
        Text(
          'Gunakan URL gambar dari Unsplash atau sumber lain',
          style: TextStyle(fontSize: 11.5, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'Belum ada gambar',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ─── STEP 4: REVIEW
  Widget _buildStep4Review() {
    final target = int.tryParse(_targetCtrl.text.trim()) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _reviewRow('Judul', _titleCtrl.text),
        _reviewRow('Kategori', _selectedCategory),
        _reviewRow('Lokasi', _locationCtrl.text),
        _reviewRow('Target', _formatRupiah(target)),
        _reviewRow('Durasi', '${_daysCtrl.text} hari'),
        _reviewRow('Deskripsi', _descCtrl.text),
        const Divider(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kampanye Anda siap dipublikasi! Pastikan semua data sudah benar.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.green[800],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PREVIEW CARD
  Widget _buildPreviewCard() {
    final target = int.tryParse(_targetCtrl.text.trim()) ?? 0;
    return Container(
      width: double.infinity,
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
            'PREVIEW KAMPANYE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          // Image preview
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _imageUrlCtrl.text.trim().isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrlCtrl.text.trim(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined,
                                size: 32, color: Colors.grey[300]),
                            const SizedBox(height: 4),
                            Text('Belum ada gambar',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[400])),
                          ],
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined,
                            size: 32, color: Colors.grey[300]),
                        const SizedBox(height: 4),
                        Text('Belum ada gambar',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            _titleCtrl.text.isEmpty
                ? 'Judul kampanye akan muncul di sini...'
                : _titleCtrl.text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _titleCtrl.text.isEmpty
                  ? Colors.grey[400]
                  : const Color(0xFF1F2937),
              fontStyle:
                  _titleCtrl.text.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _descCtrl.text.isEmpty
                ? 'Deskripsi kampanye...'
                : _descCtrl.text,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 5,
              backgroundColor: Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(kRed),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp 0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kRed.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '0%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kRed.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          Text(
            target > 0 ? 'dari ${_formatRupiah(target)}' : 'dari —.—',
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ─── NAV BUTTONS
  Widget _buildNavButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
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
              onPressed: _prevStep,
              child: const Text(
                'Sebelumnya',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _currentStep == 3 ? _publishCampaign : _nextStep,
            child: Text(
              _currentStep == 3 ? 'Publikasi Kampanye' : 'Selanjutnya',
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ─── FORM HELPERS
  Widget _formField(
    String label,
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const Text(' *',
                style: TextStyle(color: kRed, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
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
      ],
    );
  }

  Widget _dropdownField(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const Text(' *',
                style: TextStyle(color: kRed, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value.isEmpty ? null : value,
              hint: Text(
                '— Pilih Kategori —',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e,
                      style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

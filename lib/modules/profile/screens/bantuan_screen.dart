import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/batik_patern.dart';

class BantuanScreen extends StatefulWidget {
  const BantuanScreen({super.key});

  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final List<Map<String, String>> faqList = [
    {
      'question': 'Bagaimana cara membuat laporan?',
      'answer':
          'Buka menu Lapor, ambil foto kerusakan jalan, lengkapi informasi laporan, kemudian kirim laporan.',
    },
    {
      'question': 'Kenapa lokasi tidak terdeteksi?',
      'answer':
          'Pastikan GPS perangkat aktif dan izin lokasi untuk aplikasi ROADIS telah diberikan.',
    },
    {
      'question': 'Bagaimana cara melihat status laporan?',
      'answer':
          'Buka menu Riwayat, kemudian pilih laporan yang ingin dilihat untuk mengetahui status terbarunya.',
    },
    {
      'question': 'Apa saja status laporan?',
      'answer': 'Status laporan terdiri dari Menunggu, Proses, dan Selesai.',
    },
    {
      'question': 'Bagaimana cara menghubungi admin?',
      'answer':
          'Buka detail laporan kemudian gunakan fitur chat untuk berkomunikasi dengan admin terkait.',
    },
    {
      'question': 'Apakah laporan langsung diterima admin?',
      'answer':
          'Laporan akan diproses oleh sistem dan diteruskan kepada admin yang berwenang berdasarkan jenis jalan dan wilayah laporan.',
    },
    {
      'question': 'Apakah foto kerusakan jalan wajib?',
      'answer':
          'Ya. Foto digunakan untuk membantu sistem mendeteksi kerusakan jalan dan menjadi bukti dalam laporan.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final filteredFaq = faqList.where((faq) {
      final query = searchQuery.toLowerCase();
      return faq['question']!.toLowerCase().contains(query) ||
          faq['answer']!.toLowerCase().contains(query);
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: Column(
          children: [
            _buildHeader(topInset),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Text(
                    'Panduan Penggunaan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenu(
                    icon: Icons.add_a_photo_outlined,
                    title: 'Membuat Laporan',
                    subtitle: 'Langkah mudah melaporkan kerusakan jalan',
                    onTap: () => _showPanduanLaporan(context),
                  ).animate().fadeIn(duration: 340.ms),
                  _buildMenu(
                    icon: Icons.location_on_outlined,
                    title: 'Lokasi & GPS',
                    subtitle: 'Panduan akurasi koordinat lokasi laporan',
                    onTap: () => _showPanduanLokasi(context),
                  ).animate().fadeIn(delay: 60.ms, duration: 340.ms),
                  _buildMenu(
                    icon: Icons.history_rounded,
                    title: 'Status Laporan',
                    subtitle: 'Cara memantau perkembangan penanganan',
                    onTap: () => _showPanduanStatus(context),
                  ).animate().fadeIn(delay: 120.ms, duration: 340.ms),
                  const SizedBox(height: 20),
                  Text(
                    'Pertanyaan yang Sering Ditanyakan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filteredFaq.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 40,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Bantuan tidak ditemukan',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coba gunakan kata kunci lainnya.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filteredFaq.map(
                      (faq) => _buildFaq(faq['question']!, faq['answer']!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double topInset) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.midnightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: Stack(
          children: [
            Positioned.fill(
              child: BatikPattern(
                color: Colors.white,
                opacity: 0.12,
                scale: 2.4,
                fadeOut: true,
              ),
            ),
            Positioned(
              top: -8,
              right: -15,
              width: 250,
              height: 230,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.28,
                  child: Image.asset(
                    'assets/images/burung_batik.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.30),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bantuan & Panduan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Temukan panduan & jawaban seputar ROADIS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.86),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => searchQuery = value);
                            },
                            maxLines: 1,
                            textAlignVertical: TextAlignVertical.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cari panduan atau pertanyaan...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => searchQuery = '');
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 15,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.lightIceBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF94A3B8),
        ),
        onTap: onTap,
      ),
    );
  }

  static Widget _buildFaq(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: AppColors.primaryColor,
        collapsedIconColor: const Color(0xFF64748B),
        title: Text(
          question,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            color: const Color(0xFF0F172A),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF475569),
                fontSize: 12.5,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showPanduanLaporan(BuildContext context) {
    _showPanduan(
      context: context,
      icon: Icons.add_a_photo_outlined,
      title: 'Cara Membuat Laporan',
      description:
          'Ikuti langkah berikut untuk melaporkan kerusakan jalan melalui ROADIS.',
      steps: const [
        {
          'title': 'Buka menu Lapor',
          'description':
              'Pilih menu Lapor pada halaman utama ROADIS untuk membuat laporan baru.',
        },
        {
          'title': 'Ambil foto kerusakan',
          'description':
              'Ambil foto kondisi jalan yang mengalami kerusakan dengan jelas.',
        },
        {
          'title': 'Deteksi kerusakan',
          'description':
              'Sistem akan mendeteksi kerusakan jalan berdasarkan foto yang diambil.',
        },
        {
          'title': 'Pastikan lokasi',
          'description':
              'Aktifkan GPS agar ROADIS dapat mengambil lokasi kerusakan jalan.',
        },
        {
          'title': 'Lengkapi laporan',
          'description':
              'Isi judul dan deskripsi untuk memberikan informasi tambahan mengenai kerusakan jalan.',
        },
        {
          'title': 'Kirim laporan',
          'description':
              'Periksa kembali informasi laporan, kemudian tekan tombol Kirim Laporan.',
        },
      ],
    );
  }

  static void _showPanduanLokasi(BuildContext context) {
    _showPanduan(
      context: context,
      icon: Icons.location_on_outlined,
      title: 'Lokasi & GPS',
      description:
          'Pastikan lokasi perangkat aktif agar ROADIS dapat menentukan lokasi kerusakan jalan.',
      steps: const [
        {
          'title': 'Aktifkan GPS',
          'description':
              'Aktifkan fitur lokasi atau GPS pada perangkat sebelum membuat laporan.',
        },
        {
          'title': 'Izinkan akses lokasi',
          'description':
              'Berikan izin akses lokasi kepada ROADIS ketika sistem meminta izin.',
        },
        {
          'title': 'Buka menu Lapor',
          'description':
              'Masuk ke menu Lapor untuk mulai membuat laporan kerusakan jalan.',
        },
        {
          'title': 'Lokasi diambil otomatis',
          'description':
              'ROADIS akan mengambil koordinat GPS dari lokasi perangkat saat laporan dibuat.',
        },
        {
          'title': 'Periksa lokasi',
          'description':
              'Pastikan lokasi yang ditampilkan sesuai dengan lokasi kerusakan jalan.',
        },
      ],
    );
  }

  static void _showPanduanStatus(BuildContext context) {
    _showPanduan(
      context: context,
      icon: Icons.history_rounded,
      title: 'Melihat Status Laporan',
      description:
          'Pantau perkembangan laporan kerusakan jalan yang telah kamu kirim.',
      steps: const [
        {
          'title': 'Buka menu Riwayat',
          'description':
              'Pilih menu Riwayat untuk melihat laporan yang pernah kamu kirim.',
        },
        {
          'title': 'Pilih laporan',
          'description':
              'Pilih salah satu laporan untuk membuka informasi lebih lengkap.',
        },
        {
          'title': 'Lihat detail laporan',
          'description':
              'Detail laporan menampilkan informasi kerusakan dan perkembangan penanganannya.',
        },
        {
          'title': 'Periksa status',
          'description':
              'Status laporan dapat berupa Menunggu, Proses, atau Selesai.',
        },
        {
          'title': 'Lihat informasi terbaru',
          'description':
              'Jika status laporan berubah, kamu dapat melihat perkembangan terbaru pada detail laporan.',
        },
      ],
    );
  }

  static void _showPanduan({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required List<Map<String, String>> steps,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.lightIceBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: AppColors.primaryColor, size: 26),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (int i = 0; i < steps.length; i++)
                    _buildStep(
                      number: '${i + 1}',
                      title: steps[i]['title']!,
                      description: steps[i]['description']!,
                      isLast: i == steps.length - 1,
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Mengerti',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildStep({
    required String number,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: AppColors.primaryColor.withOpacity(0.20),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      height: 1.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

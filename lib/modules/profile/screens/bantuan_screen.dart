import 'package:flutter/material.dart';

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
      'answer': 'Buka menu Lapor, ambil foto kerusakan jalan, lengkapi informasi laporan, kemudian kirim laporan.',
    },
    {
      'question': 'Kenapa lokasi tidak terdeteksi?',
      'answer': 'Pastikan GPS perangkat aktif dan izin lokasi untuk aplikasi ROADIS telah diberikan.',
    },
    {
      'question': 'Bagaimana cara melihat status laporan?',
      'answer': 'Buka menu Riwayat, kemudian pilih laporan yang ingin dilihat untuk mengetahui status terbarunya.',
    },
    {
      'question': 'Apa saja status laporan?',
      'answer': 'Status laporan terdiri dari Menunggu, Proses, dan Selesai.',
    },
    {
      'question': 'Bagaimana cara menghubungi admin?',
      'answer': 'Buka detail laporan kemudian gunakan fitur chat untuk berkomunikasi dengan admin terkait.',
    },
    {
      'question': 'Apakah laporan langsung diterima admin?',
      'answer': 'Laporan akan diproses oleh sistem dan diteruskan kepada admin yang berwenang berdasarkan jenis jalan dan wilayah laporan.',
    },
    {
      'question': 'Apakah foto kerusakan jalan wajib?',
      'answer': 'Ya. Foto digunakan untuk membantu sistem mendeteksi kerusakan jalan dan menjadi bukti dalam laporan.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaq = faqList.where((faq) {
      final query = searchQuery.toLowerCase();

      return faq['question']!.toLowerCase().contains(query) ||
          faq['answer']!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Bantuan & FAQ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // =====================================================
          // HEADER
          // =====================================================

          const Text(
            'Ada yang bisa kami bantu?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            'Temukan panduan dan jawaban seputar penggunaan ROADIS.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // =====================================================
          // SEARCH
          // =====================================================
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari bantuan...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // =====================================================
          // PANDUAN PENGGUNAAN
          // =====================================================
          const Text(
            'Panduan Penggunaan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _buildMenu(
            icon: Icons.add_a_photo_outlined,
            title: 'Membuat Laporan',
            subtitle: 'Cara melaporkan kerusakan jalan',
            onTap: () {
              _showPanduanLaporan(context);
            },
          ),

          _buildMenu(
            icon: Icons.location_on_outlined,
            title: 'Lokasi & GPS',
            subtitle: 'Panduan penggunaan lokasi',
            onTap: () {
              _showPanduanLokasi(context);
            },
          ),

          _buildMenu(
            icon: Icons.history,
            title: 'Status Laporan',
            subtitle: 'Cara melihat perkembangan laporan',
            onTap: () {
              _showPanduanStatus(context);
            },
          ),

          const SizedBox(height: 30),

          // =====================================================
          // FAQ
          // =====================================================
          const Text(
            'Pertanyaan yang Sering Ditanyakan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          if (filteredFaq.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 40, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Bantuan tidak ditemukan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Coba gunakan kata kunci lainnya.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ...filteredFaq.map(
              (faq) => _buildFaq(faq['question']!, faq['answer']!),
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ===========================================================
  // CARD MENU PANDUAN
  // ===========================================================

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
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ===========================================================
  // FAQ
  // ===========================================================

  static Widget _buildFaq(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // PANDUAN MEMBUAT LAPORAN
  // ===========================================================

  static void _showPanduanLaporan(BuildContext context) {
    _showPanduan(
      context: context,
      icon: Icons.add_a_photo_outlined,
      title: 'Cara Membuat Laporan',
      description: 'Ikuti langkah berikut untuk melaporkan kerusakan jalan melalui ROADIS.',
      steps: const [
        {
          'title': 'Buka menu Lapor',
          'description': 'Pilih menu Lapor pada halaman utama ROADIS untuk membuat laporan baru.',
        },
        {
          'title': 'Ambil foto kerusakan',
          'description':
              'Ambil foto kondisi jalan yang mengalami kerusakan dengan jelas.',
        },
        {
          'title': 'Deteksi kerusakan',
          'description': 'Sistem akan mendeteksi kerusakan jalan berdasarkan foto yang diambil.',
        },
        {
          'title': 'Pastikan lokasi',
          'description': 'Aktifkan GPS agar ROADIS dapat mengambil lokasi kerusakan jalan.',
        },
        {
          'title': 'Lengkapi laporan',
          'description': 'Isi judul dan deskripsi untuk memberikan informasi tambahan mengenai kerusakan jalan.',
        },
        {
          'title': 'Kirim laporan',
          'description': 'Periksa kembali informasi laporan, kemudian tekan tombol Kirim Laporan.',
        },
      ],
    );
  }

  // ===========================================================
  // PANDUAN LOKASI & GPS
  // ===========================================================

  static void _showPanduanLokasi(BuildContext context) {
    _showPanduan(
      context: context,
      icon: Icons.location_on_outlined,
      title: 'Lokasi & GPS',
      description: 'Pastikan lokasi perangkat aktif agar ROADIS dapat menentukan lokasi kerusakan jalan.',
      steps: const [
        {
          'title': 'Aktifkan GPS',
          'description': 'Aktifkan fitur lokasi atau GPS pada perangkat sebelum membuat laporan.',
        },
        {
          'title': 'Izinkan akses lokasi',
          'description': 'Berikan izin akses lokasi kepada ROADIS ketika sistem meminta izin.',
        },
        {
          'title': 'Buka menu Lapor',
          'description': 'Masuk ke menu Lapor untuk mulai membuat laporan kerusakan jalan.',
        },
        {
          'title': 'Lokasi diambil otomatis',
          'description': 'ROADIS akan mengambil koordinat GPS dari lokasi perangkat saat laporan dibuat.',
        },
        {
          'title': 'Periksa lokasi',
          'description': 'Pastikan lokasi yang ditampilkan sesuai dengan lokasi kerusakan jalan.',
        },
      ],
    );
  }

  // ===========================================================
  // PANDUAN STATUS LAPORAN
  // ===========================================================

  static void _showPanduanStatus(BuildContext context) {
    _showPanduan(
      context: context,
      icon: Icons.history,
      title: 'Melihat Status Laporan',
      description:
          'Pantau perkembangan laporan kerusakan jalan yang telah kamu kirim.',
      steps: const [
        {
          'title': 'Buka menu Riwayat',
          'description': 'Pilih menu Riwayat untuk melihat laporan yang pernah kamu kirim.',
        },
        {
          'title': 'Pilih laporan',
          'description':
              'Pilih salah satu laporan untuk membuka informasi lebih lengkap.',
        },
        {
          'title': 'Lihat detail laporan',
          'description': 'Detail laporan menampilkan informasi kerusakan dan perkembangan penanganannya.',
        },
        {
          'title': 'Periksa status',
          'description':
              'Status laporan dapat berupa Menunggu, Proses, atau Selesai.',
        },
        {
          'title': 'Lihat informasi terbaru',
          'description': 'Jika status laporan berubah, kamu dapat melihat perkembangan terbaru pada detail laporan.',
        },
      ],
    );
  }

  // ===========================================================
  // BOTTOM SHEET PANDUAN
  // ===========================================================

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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
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

                  const SizedBox(height: 22),

                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: const Color(0xFF2563EB), size: 27),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 26),

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
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Mengerti',
                        style: TextStyle(fontWeight: FontWeight.w600),
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

  // ===========================================================
  // ITEM LANGKAH
  // ===========================================================

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
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: const Color(0xFFDCE7FF),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.grey,
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

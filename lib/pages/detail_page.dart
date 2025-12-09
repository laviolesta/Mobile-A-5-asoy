import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'owner_profile_page.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isLiked = false;

  Future<void> _openWhatsApp() async {
    final Uri whatsapp = Uri.parse("https://wa.me/6281234567890");
    if (await canLaunchUrl(whatsapp)) {
      await launchUrl(whatsapp, mode: LaunchMode.externalApplication);
    }
  }

  void _showRentDialog() async {
    final DateTimeRange? pickedDate = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(), // tidak bisa pilih sebelum hari ini
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1E355D), // warna header
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final start = pickedDate.start;
      final end = pickedDate.end;
      final duration = end.difference(start).inDays + 1;

      // Menampilkan konfirmasi
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Konfirmasi Penyewaan"),
          content: Text(
              "Anda menyewa produk dari ${start.day}/${start.month}/${start.year} "
              "sampai ${end.day}/${end.month}/${end.year} "
              "($duration hari)"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                // LOGIKA: tandai produk sebagai tersewa
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Penyewaan berhasil diajukan!")),
                );
              },
              child: const Text("Konfirmasi"),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== HEADER CUSTOM =====
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isLiked = !isLiked;
                        });
                      },
                      child: Icon(
                        isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              /// ===== IMAGE =====
              Center(
                child: Image.network(
                  "https://i.imgur.com/JqKDdxj.png",
                  height: 260,
                ),
              ),

              const SizedBox(height: 16),

              /// ===== TITLE =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.product["name"],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E355D),
                  ),
                ),
              ),

              /// ===== PRICE + TERSEWA + LOVE =====
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.product["price"],
                      style: const TextStyle(fontSize: 16),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text("21 tersewa", style: TextStyle(fontSize: 12)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.favorite,
                                color: Colors.red, size: 18),
                            SizedBox(width: 4),
                            Text("20"),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),

              /// ===== LOCATION =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Text(widget.product["location"]),
                  ],
                ),
              ),

              const Divider(height: 32),

              /// ===== DESKRIPSI =====
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Deskripsi Produk",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  "Kalkulator ilmiah ini cocok untuk mahasiswa teknik. Dapat digunakan untuk perhitungan statistik, trigonometri, dan aljabar.",
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Kondisi barang: Bagus"),
              ),

              const Divider(height: 32),

              /// ===== RATING =====
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange),
                    SizedBox(width: 4),
                    Text("4.9  Rating Produk"),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// ===== REVIEW =====
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(child: Icon(Icons.person)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ref*****",
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            "Barangnya masih bagus. Masih mauka nanti sewa yah hehe",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const Divider(height: 32),

              /// ===== PEMILIK =====
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Pemilik",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: const Text("Nining Karins"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OwnerProfilePage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      /// ===== BOTTOM BAR =====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                ),
                label: const Text(
                  "Chat Pemilik",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _showRentDialog,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 204, 215, 234),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Sewa Produk"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

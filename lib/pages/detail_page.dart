import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'owner_profile_page.dart';

// Import services dan model (Asumsi path ini benar)
import '../../services/product_service.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isOwnerView; // BARU: True jika dibuka dari halaman Sewakan
  final List<String> likedProducts; // BARU: Daftar ID produk yang disukai

  const DetailPage({
    super.key,
    required this.product,
    required this.isOwnerView, // Wajib diisi
    required this.likedProducts, // Wajib diisi
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ProductService _productService = ProductService();
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Pastikan 'id' adalah String sebelum membandingkan.
    // Gunakan 'as String?' dan null-check pada id.
    final productId = widget.product['id'] as String?;

    // Inisialisasi status like: jika productId null, anggap tidak disukai (false).
    isLiked = productId != null && widget.likedProducts.contains(productId);
  }

  Future<void> _toggleLike() async {
    // Pastikan 'id' adalah String dan tidak null
    final productId = widget.product['id'] as String?;
    if (productId == null) return;

    // Asumsi ProductService memiliki metode toggleLike
    final success = await _productService.toggleProductLike(
        productId, !isLiked); // Menggunakan productId yang sudah pasti String

    if (success) {
      setState(() {
        isLiked = !isLiked;
        // Opsional: berikan feedback ke user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isLiked ? 'Produk disukai' : 'Suka dibatalkan')),
        );
      });
    }
  }

  Future<void> _openWhatsApp() async {
    // Gunakan nomor pemilik dari data produk jika tersedia
    final ownerPhone = widget.product['ownerPhone'] ?? '6281234567890';
    final Uri whatsapp = Uri.parse("https://wa.me/$ownerPhone");

    // PERBAIKAN: Gunakan .toString() pada Uri untuk canLaunchUrl agar lebih kompatibel dengan versi terbaru
    if (await canLaunchUrl(whatsapp)) {
      await launchUrl(whatsapp, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka WhatsApp')),
      );
    }
  }

  void _showRentDialog() async {
    final DateTimeRange? pickedDate = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1E355D),
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

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Konfirmasi Penyewaan"),
          content: Text(
              "Anda menyewa produk dari ${start.day}/${start.month}/${start.year} "
                  "sampai ${end.day}/${end.month}/${end.year} "
                  "(${duration} hari)"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Lakukan aksi pengajuan sewa ke Firestore di sini!
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Penyewaan berhasil diajukan!")),
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
      body: Column(
        children: [
          /// ===== HEADER (Dengan Tombol Like Kondisional) =====
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                ),
                // Tombol Like hanya muncul jika BUKAN Owner View
                if (!widget.isOwnerView)
                  GestureDetector(
                    onTap: _toggleLike, // Menggunakan fungsi toggle
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),

          /// ===== CONTENT =====
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE
                  Center(
                    child: Image.network(
                      widget.product["imageUrl"] ?? "https://via.placeholder.com/260",
                      height: 260,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// TITLE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.product["name"] ?? 'Nama Produk Tidak Diketahui', // Tambah null check pada title
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E355D),
                      ),
                    ),
                  ),

                  /// PRICE + TERSEWA + LOVE
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.product["price"] ?? "Rp 0/Hari",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                "${widget.product["rentedCount"] ?? 0} tersewa",
                                style: const TextStyle(fontSize: 12)
                            ),
                            const SizedBox(height: 4),
                            // Love count hanya muncul jika BUKAN Owner View
                            if (!widget.isOwnerView)
                              Row(
                                children: [
                                  const Icon(Icons.favorite, color: Colors.red, size: 18),
                                  const SizedBox(width: 4),
                                  Text("${widget.product["likesCount"] ?? 0}"),
                                ],
                              )
                          ],
                        )
                      ],
                    ),
                  ),

                  /// LOCATION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(widget.product["location"] ?? "-"),
                      ],
                    ),
                  ),

                  const Divider(height: 32),

                  /// DESKRIPSI
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Deskripsi Produk",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      widget.product["description"] ?? "Tidak ada deskripsi.",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Kondisi barang: ${widget.product["condition"] ?? 'Tidak diketahui'}"),
                  ),

                  const Divider(height: 32),

                  /// RATING
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text("${widget.product["rating"] ?? 'N/A'}  Rating Produk"), // Ambil dari data produk jika ada
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// REVIEW (Satu contoh Review)
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
                                  style: TextStyle(fontWeight: FontWeight.bold)),
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

                  /// PEMILIK (Hanya muncul jika BUKAN Owner View)
                  if (!widget.isOwnerView)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Pemilik",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(widget.product["ownerName"] ?? "Nining Karins"),
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

                  // Jarak tambahan jika Owner View, karena BottomBar akan hilang
                  if (widget.isOwnerView)
                    const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),

      /// ===== BOTTOM BAR (Hanya muncul jika BUKAN Owner View) =====
      bottomNavigationBar: widget.isOwnerView
          ? null // Return null jika Owner View (menghilangkan BottomBar)
          : Container(
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
                  backgroundColor: const Color(0xFF205781), // Warna Primer
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Ajukan Sewa"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
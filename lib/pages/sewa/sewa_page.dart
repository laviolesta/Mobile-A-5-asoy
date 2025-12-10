import 'package:flutter/material.dart';
import '../../widgets/header_widget.dart';
import '../../widgets/bottom_navbar.dart';
import '../../utils/no_animation_route.dart';
import '../detail_page.dart';
import '../rating_ulasan_page.dart'; 
import '../home_page.dart';
import '../notifikasi_page.dart';
import 'sewakan_page.dart'; 
// Tambahkan ProductService
import '../../services/product_service.dart'; 

// --- WIDGET KONTROL NAVIGASI BERSAMA (RentalHeaderControl) ---
// (Kode ini tetap sama dan dianggap sudah benar)
class RentalHeaderControl extends StatelessWidget {
  final bool isSewakanActive;

  const RentalHeaderControl({
    super.key,
    required this.isSewakanActive,
  });

  void _navigateToPage(BuildContext context, Widget targetPage) {
    Navigator.pushReplacement(
      context,
      NoAnimationPageRoute(page: targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF205781);
    const inactiveColor = Colors.black54;
    
    final activeTextStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: activeColor,
    );
    final inactiveTextStyle = const TextStyle(
      fontSize: 18,
      color: inactiveColor,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Tab Sewa
          GestureDetector(
            onTap: () {
              if (isSewakanActive) {
                _navigateToPage(context, const SewaPage());
              }
            },
            child: Column(
              children: [
                Text(
                  "Sewa",
                  style: isSewakanActive ? inactiveTextStyle : activeTextStyle,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  height: 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isSewakanActive ? Colors.transparent : activeColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          // Tab Sewakan
          GestureDetector(
            onTap: () {
              if (!isSewakanActive) {
                _navigateToPage(context, const SewakanPage());
              }
            },
            child: Column(
              children: [
                Text(
                  "Sewakan",
                  style: isSewakanActive ? activeTextStyle : inactiveTextStyle,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  height: 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isSewakanActive ? activeColor : Colors.transparent,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// --- END WIDGET KONTROL NAVIGASI BERSAMA ---


// =======================================================
// PERBAIKAN: UBAH MENJADI STATEFUL WIDGET
// =======================================================
class SewaPage extends StatefulWidget {
  const SewaPage({super.key});

  @override
  State<SewaPage> createState() => _SewaPageState();
}

class _SewaPageState extends State<SewaPage> {
  // Variabel untuk menyimpan liked products dan service
  final ProductService _productService = ProductService();
  List<String> _likedProducts = [];

  // ======= DATA PRODUK YANG SEDANG DISEWA USER =======
  List<Map<String, dynamic>> get currentRent => [
        {
          "name": "Kalkulator Ilmiah",
          "price": "Rp2.000/hari",
          "location": "Gowa, Jl. Mawar",
          "image": "assets/produk/kalkulator.png",
          "rating": "4.9",
          "rentedCount": "21",
          "favorite": 20,
          "rentalDuration": "Berakhir 12/12/2025", 
          "id": "rent_001", // Tambahkan ID dummy
        },
        {
          "name": "Kompor Portable",
          "price": "Rp3.000/hari",
          "location": "Tamalanrea",
          "image": "assets/produk/kompor.png", 
          "rating": "4.8",
          "rentedCount": "15",
          "favorite": 10,
          "rentalDuration": "Berakhir 15/01/2026", 
          "id": "rent_002",
        },
      ];

  // ======= DATA RIWAYAT SEWA USER =======
  List<Map<String, dynamic>> get rentHistory => [
        {
          "name": "Baju Putih",
          "price": "Rp3.000/hari",
          "location": "Gowa, Jl. Kelapa",
          "image": "assets/produk/baju_putih.png",
          "id": "hist_001", // Tambahkan ID dummy
        },
        {
          "name": "Jas Hitam", // Ubah nama agar berbeda
          "price": "Rp4.000/hari",
          "location": "Gowa, Jl. Kelapa",
          "image": "assets/produk/jas_hitam.png",
          "id": "hist_002",
        },
      ];

  @override
  void initState() {
    super.initState();
    _loadLikedProducts(); 
  }

  void _loadLikedProducts() async {
    final List<String> likedIds = await _productService.getLikedProductIds(); 
    
    if (mounted) {
      setState(() {
        _likedProducts = likedIds;
      });
    }
  }

  void _onNavTapped(BuildContext context, int index) {
    if (index == 1) return;
    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 2:
        page = const NotifikasiPage();
        break;
      default:
        page = const SewaPage();
    }
    Navigator.pushReplacement(
      context,
      NoAnimationPageRoute(page: page),
    );
  }

  // === CARD PRODUK YANG SEDANG DISEWA (Mirip HomePage) ===
  Widget _buildRentedProductCard(BuildContext context, Map<String, dynamic> item) {
    const bool isRented = true; 
    final bool isProductLiked = _likedProducts.contains(item['id']);

    return GestureDetector(
      onTap: () async {
        // PERBAIKAN 1: TAMBAHKAN PARAMETER DETAILPAGE
        await Navigator.push(
          context,
          NoAnimationPageRoute(
            page: DetailPage(
              product: item,
              isOwnerView: false, // User menyewa produk orang lain
              likedProducts: _likedProducts,
            ),
          ),
        );
        // Muat ulang setelah kembali
        _loadLikedProducts();
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: item["image"] != null && item["image"].startsWith('assets/')
                        ? Image.asset(item["image"], fit: BoxFit.cover,)
                        : const Icon(Icons.image, size: 50),
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  item["name"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item["price"],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      item["location"] ?? "",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "⭐ ${item["rating"]} | ${item["rentedCount"]} tersewa",
                      style: const TextStyle(fontSize: 11),
                    ),
                    Row(
                      children: [
                        Icon(
                          isProductLiked ? Icons.favorite : Icons.favorite_border,
                          color: isProductLiked ? Colors.red : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text("${item["favorite"]}", style: const TextStyle(fontSize: 12)),
                      ],
                    )
                  ],
                ) 
              ],
            ),
          ),

          // Overlay Status SEDANG DISEWA
          if (isRented)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "SEDANG DISEWA",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item["rentalDuration"] ?? "Tanggal tidak diketahui",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF205781),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Mengurus pengembalian ${item["name"]}')),
                        );
                      },
                      child: const Text('Kembalikan'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // === RIWAYAT PRODUK COMPACT (Sewa Lagi) ===
  Widget _buildHistoryProduct(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Gambar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item["image"] != null && item["image"].startsWith('assets/')
              ? Image.asset(
                  item["image"],
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 60,
                    width: 60,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 30, color: Colors.grey),
                    ),
                  ),
                )
              : Container(
                  height: 60,
                  width: 60,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image, size: 30, color: Colors.grey),
                  ),
                ),
          ),
          const SizedBox(width: 8),

          // 2. Info Produk (Expanded)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item["price"],
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  item["location"],
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),

          // 3. Tombol Berdampingan di Kanan
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 28), 
              Row(
                children: [
                  // Tombol Sewa Lagi
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF205781),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(60, 25), 
                      padding: const EdgeInsets.symmetric(horizontal: 6), 
                      textStyle: const TextStyle(fontSize: 10), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () async {
                      // PERBAIKAN 2: TAMBAHKAN PARAMETER DETAILPAGE
                      await Navigator.push(
                        context,
                        NoAnimationPageRoute(
                          page: DetailPage(
                            product: item,
                            isOwnerView: false,
                            likedProducts: _likedProducts,
                          ),
                        ),
                      );
                      _loadLikedProducts();
                    },
                    child: const Text("Sewa lagi"),
                  ),
                  const SizedBox(width: 4), 
                  // Tombol Beri Nilai
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(60, 25), 
                      padding: const EdgeInsets.symmetric(horizontal: 6), 
                      textStyle: const TextStyle(fontSize: 10), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: const BorderSide(color: Color(0xFF205781)),
                      foregroundColor: const Color(0xFF205781),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        NoAnimationPageRoute(
                          page: RatingUlasanPage(product: item),
                        ),
                      );
                    },
                    child: const Text("Beri Nilai"),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderWidget(title: "Produk yang Disewa"),
          
          // ===== TAB SEWA / SEWAKAN MENGGUNAKAN WIDGET KONTROL BERSAMA =====
          const RentalHeaderControl(isSewakanActive: false), 
          
          // ===== BODY =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === PRODUK YANG KAMU SEWA ===
                  const Text(
                    "Produk yang kamu sewa",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ==== GRID PRODUK DISEWA ====
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentRent.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.73,
                    ),
                    itemBuilder: (context, index) {
                      final item = currentRent[index];
                      return _buildRentedProductCard(context, item);
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // ==== RIWAYAT PRODUK ====
                  const Text(
                    "Riwayat produk yang disewa",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // ==== RIWAYAT PRODUK COMPACT ====
                  Column(
                    children: rentHistory.map((item) {
                      return _buildHistoryProduct(context, item);
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onNavTapped(context, index),
      ),
    );
  }
}
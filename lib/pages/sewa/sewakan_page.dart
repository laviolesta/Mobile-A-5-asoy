import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/header_widget.dart';
import '../../widgets/bottom_navbar.dart';
import '../../utils/no_animation_route.dart';
// Import halaman yang dibutuhkan
import '../home_page.dart';
import '../notifikasi_page.dart';
import 'sewa_page.dart';
import '../detail_page.dart';
// Import file Edit dan Create Product
import '../edit_product_page.dart';
import '../create_product_page.dart';
// Import ProductService
import '../../services/product_service.dart';

// --- START WIDGET KONTROL NAVIGASI BERSAMA (RentalHeaderControl) ---

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
                // Navigasi ke SewaPage (tampilan Penyewa)
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
                // Navigasi ke SewakanPage (tampilan Pemilik)
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


// Halaman SewakanPage
class SewakanPage extends StatefulWidget {
  const SewakanPage({super.key});

  @override
  State<SewakanPage> createState() => _SewakanPageState();
}

class _SewakanPageState extends State<SewakanPage> {
  final ProductService _productService = ProductService();
  List<String> _likedProducts = [];

  late Stream<QuerySnapshot> _ownerProductsStream;

  @override
  void initState() {
    super.initState();
    _ownerProductsStream = _productService.getOwnerProducts();
    _loadLikedProducts();
  }

  void _loadLikedProducts() async {
    if (_productService.currentUserId == null) return;

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
        page = const SewakanPage();
    }

    Navigator.pushReplacement(
      context,
      NoAnimationPageRoute(page: page),
    );
  }

  void _navigateToCreateProductPage(BuildContext context) async {
    await Navigator.push(
      context,
      NoAnimationPageRoute(page: const CreateProductPage()),
    );
    _loadLikedProducts();
  }

  // === CARD PRODUK SEWAKAN (Grid Style + Menu Edit/Hapus) ===
  Widget _buildRentedProductCard(BuildContext context, DocumentSnapshot productDoc) {
    final item = productDoc.data() as Map<String, dynamic>?;

    if (item == null) return const SizedBox.shrink();

    // Mapping data Firestore ke variabel lokal
    final bool isRented = item["isAvailable"] == false; // PENTING: Penentu status
    final String name = item["name"] ?? 'N/A';
    final String price = item["price"] ?? 'N/A';
    final String rawPrice = (item["raw_price"] ?? 0).toString();
    final String location = item["location"] ?? 'Lokasi tidak diketahui';
    final String imageUrl = item["imageUrl"] ?? 'assets/placeholder.png';
    final int likesCount = item["likesCount"] ?? 0;

    final double averageRating = (item['averageRating'] is num) ? (item['averageRating'] as num).toDouble() : 0.0;
    final int rentedCount = item['rentedCount'] ?? 0;
    final String ratingDisplay = averageRating.toStringAsFixed(1);

    // Mempersiapkan data yang akan dikirim ke halaman Edit/Detail
    final productDataForEdit = {
      "id": productDoc.id,
      "name": name,
      "price": rawPrice,
      "category": item["category"],
      "description": item["description"],
      "address": item["address"],
      "imageUrl": imageUrl,
    };

    final productDataForDetail = {
      ...item,
      "id": productDoc.id,
    };

    return Stack(
      children: [
        GestureDetector(
          // 💡 PERBAIKAN 1: Menonaktifkan klik jika sedang disewa
          onTap: isRented ? null : () async {
            // Navigasi ke DetailPage (Hanya jika tidak disewa)
            await Navigator.push(
              context,
              NoAnimationPageRoute(
                page: DetailPage(
                  product: productDataForDetail,
                  isOwnerView: true,
                  likedProducts: _likedProducts,
                ),
              ),
            );
            _loadLikedProducts();
          },
          child: Container(
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
                    child: imageUrl.startsWith('http')
                        ? Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.black38)))
                        : const Center(child: Icon(Icons.image, size: 50, color: Colors.black38)),
                  ),
                ),

                const SizedBox(height: 10),

                // Detail Produk
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        price,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                      const SizedBox(height: 2),

                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.grey),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("⭐ $ratingDisplay | $rentedCount tersewa",
                              style: const TextStyle(fontSize: 11)),
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: Colors.red, size: 16),
                              const SizedBox(width: 2),
                              Text("$likesCount", style: const TextStyle(fontSize: 12)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tombol Tiga Titik (...)
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              // 💡 Perubahan warna background tombol jika sedang disewa
                color: isRented ? Colors.transparent : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)
            ),
            // 💡 PERBAIKAN 2: Nonaktifkan PopupMenuButton jika sedang disewa
            child: isRented
                ? const SizedBox.shrink() // Sembunyikan tombol jika disewa
                : PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              padding: EdgeInsets.zero,
              onSelected: (String result) async {
                if (result == 'edit') {
                  // Navigasi ke Edit Produk
                  await Navigator.push(
                    context,
                    NoAnimationPageRoute(
                      page: EditProductPage(product: productDataForEdit),
                    ),
                  );
                } else if (result == 'delete') {
                  // LOGIKA HAPUS DENGAN KONFIRMASI
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Hapus Produk"),
                      content: Text("Anda yakin ingin menghapus produk '$name'? Tindakan ini tidak dapat dibatalkan."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final error = await _productService.deleteProduct(productDoc.id);
                    if (error == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Produk $name berhasil dihapus.')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menghapus: $error')),
                      );
                    }
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit Produk'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),

        // Overlay Status DISEWA
        if (isRented)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "DISEWA",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_productService.currentUserId == null) {
      return Scaffold(
        body: const Center(
          child: Text("Anda harus login untuk melihat produk yang Anda sewakan."),
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: 1, onTap: (_){}),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const HeaderWidget(title: "Produk yang Disewakan"),

          const RentalHeaderControl(isSewakanActive: true),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Produk yang kamu sewakan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _ownerProductsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan saat memuat produk: ${snapshot.error}. Pastikan Anda sudah membuat Composite Index yang diminta di Firebase Console.'));
                }

                final List<DocumentSnapshot> products = snapshot.data?.docs ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text(
                          "Belum ada produk yang disewakan.",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      return _buildRentedProductCard(context, products[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateProductPage(context),
        backgroundColor: const Color(0xFF205781),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onNavTapped(context, index),
      ),
    );
  }
}
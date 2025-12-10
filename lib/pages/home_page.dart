import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import ini untuk memformat tanggal
import '../widgets/header_widget.dart';
import '../widgets/bottom_navbar.dart';
import '../utils/no_animation_route.dart';
import '../pages/detail_page.dart';
import 'notifikasi_page.dart';
import 'sewa/sewa_page.dart';
import '../services/product_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();

  late Stream<QuerySnapshot> _availableProductsStream;

  final TextEditingController searchController = TextEditingController();
  String selectedFilter = "Semua";

  final List<String> filterOptions = [
    "Semua",
    "Tersedia",
    "Disewa",
    "ATK",
    "Pakaian",
    "Elektronik",
  ];

  List<String> _likedProducts = [];

  @override
  void initState() {
    super.initState();
    // Catatan: Asumsi getAvailableProducts() sudah diubah di ProductService
    // untuk mengambil semua produk yang TIDAK dimiliki pengguna (agar filter Disewa berfungsi).
    _availableProductsStream = _productService.getAllProductsForHomePage(); // Diganti agar semua produk masuk
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

  List<DocumentSnapshot> _applyFilterAndSearch(List<DocumentSnapshot> allProducts) {
    final searchQuery = searchController.text.toLowerCase().trim();
    final currentUserId = _productService.currentUserId;


    return allProducts.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = data["name"]?.toLowerCase() ?? '';
      final category = data["category"] ?? '';
      final ownerId = data["ownerId"] as String?; // Dapatkan ID pemilik

      // ===========================================
      // 1. LOGIKA PENGECUALIAN PRODUK MILIK SENDIRI
      // ===========================================
      // Jika pengguna login dan ID pemilik sama dengan ID pengguna, sembunyikan produk ini.
      if (currentUserId != null && ownerId == currentUserId) {
        return false;
      }

      final isAvailable = data["isAvailable"] ?? true;

      // 2. Search Match
      final searchMatch = name.contains(searchQuery);

      // 3. Filter Match
      bool filterMatch = true;
      if (selectedFilter == "Tersedia") {
        filterMatch = isAvailable == true;
      } else if (selectedFilter == "Disewa") {
        filterMatch = isAvailable == false;
      } else if (selectedFilter != "Semua") {
        filterMatch = category == selectedFilter;
      }

      // Gabungkan Search Match dan Filter Match
      return searchMatch && filterMatch;
    }).toList();
  }


  String get pageTitle {
    switch (selectedFilter) {
      case "Tersedia":
        return "Produk Tersedia";
      case "Disewa":
        return "Produk Sedang Disewa";
      case "Semua":
        return "Semua Produk";
      default:
        return "Kategori: $selectedFilter";
    }
  }

  void _onNavTapped(BuildContext context, int index) {
    if (index == 0) return;

    Widget page;
    switch (index) {
      case 1:
        page = const SewaPage();
        break;
      case 2:
        page = const NotifikasiPage();
        break;
      default:
        page = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      NoAnimationPageRoute(page: page),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: filterOptions.map((filter) {
            return ListTile(
              title: Text(filter),
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double gridSpacing = 12.0;

    int crossAxisCount = 2;
    if (screenWidth >= 900) {
      crossAxisCount = 4;
    } else if (screenWidth >= 700) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    // Menggunakan rasio tetap dari SewakanPage
    const double childAspectRatio = 0.65;

    return Scaffold(
      body: Column(
        children: [
          const HeaderWidget(title: "Beranda"),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Cari",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: const Column(
                    children: [
                      Icon(Icons.filter_alt, color: Color(0xFF1E355D)),
                      Text("Filter", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                pageTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _availableProductsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan saat memuat produk: ${snapshot.error}'));
                }

                final List<DocumentSnapshot> rawProducts = snapshot.data?.docs ?? [];
                // Lakukan filter pengecualian pemilik di sini
                final List<DocumentSnapshot> finalProducts = _applyFilterAndSearch(rawProducts);

                if (finalProducts.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada produk lain yang tersedia dengan kriteria ini."),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    itemCount: finalProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: gridSpacing,
                      crossAxisSpacing: gridSpacing,
                      childAspectRatio: childAspectRatio, // Menggunakan rasio tetap (0.65)
                    ),
                    itemBuilder: (context, index) {
                      final item = finalProducts[index].data() as Map<String, dynamic>?;
                      final productData = item?..['id'] = finalProducts[index].id;

                      if (productData == null) return const SizedBox.shrink();

                      return _buildProductCard(context, productData);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) => _onNavTapped(context, index),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> item) {

    final productId = item['id'] as String;
    // Fallback data yang aman
    final name = item['name'] ?? 'Nama Produk';
    final price = item['price'] ?? 'N/A';
    final location = item['location'] ?? 'Lokasi';
    final imageUrl = item['imageUrl'] ?? ''; // Diubah ke string kosong, bukan 'assets/placeholder.png'
    final likesCount = item['likesCount'] ?? 0;
    final isAvailable = item['isAvailable'] ?? true;

    // Ambil tanggal berakhir sewa (Asumsi nama field: rentalEndDate dan bertipe Timestamp)
    final Timestamp? rentalEndDateTimestamp = item['rentalEndDate'] as Timestamp?;
    final String rentalEndDate = rentalEndDateTimestamp != null
        ? DateFormat('dd MMM').format(rentalEndDateTimestamp.toDate())
        : 'Tidak diketahui';

    final double averageRating = (item['averageRating'] is num) ? (item['averageRating'] as num).toDouble() : 0.0;
    final int rentedCount = item['rentedCount'] ?? 0;

    final String ratingDisplay = averageRating.toStringAsFixed(1);

    final bool isProductLiked = _likedProducts.contains(productId);
    final bool isRented = !isAvailable;

    const double imageHeight = 150;

    return GestureDetector(
      // 💡 PERBAIKAN: Hanya aktifkan onTap jika produk tersedia (!isRented)
      onTap: isRented ? null : () async {
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
      child: Stack(
        children: [
          // KONTEN KARTU PRODUK
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: imageHeight,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.black38)),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),

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

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
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
                          Text(
                              "⭐ $ratingDisplay | $rentedCount tersewa",
                              style: const TextStyle(fontSize: 11)
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
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

          // 💡 PERBAIKAN: OVERLAY STATUS DISEWA
          if (isRented)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  // Menggunakan opacity yang konsisten
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "DISEWA", // Teks utama
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        // 💡 Tampilkan detail tanggal berakhir
                        "Tersedia kembali pada\n$rentalEndDate",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/bottom_navbar.dart';
import '../utils/no_animation_route.dart';
import '../pages/detail_page.dart';
import 'notifikasi_page.dart';
import 'sewa/sewa_page.dart';
// Tambahkan import ProductService
import '../services/product_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. DEKLARASI PRODUCT SERVICE
  final ProductService _productService = ProductService();

  final TextEditingController searchController = TextEditingController();
  String selectedFilter = "Semua";

  // Dummy data produk (Harusnya nanti diganti dengan StreamBuilder dari ProductService)
  final List<Map<String, dynamic>> products = [
    {
      "name": "Kalkulator Ilmiah",
      "price": "Rp2.000/hari",
      "category": "ATK",
      "status": "tersedia",
      "location": "Gowa, Jl. Mawar",
      "rentalInfo": null,
      "id": "prod_001",
    },
    {
      "name": "Almamater Unhas",
      "price": "Rp3.000/hari",
      "category": "Pakaian",
      "status": "tersedia",
      "location": "Gowa, Jl. Kenanga",
      "rentalInfo": null,
      "id": "prod_002",
    },
    {
      "name": "Baju Putih",
      "price": "Rp3.000/hari",
      "category": "Pakaian",
      "status": "tersedia",
      "location": "Gowa, Jl. Flamboyan",
      "rentalInfo": null,
      "id": "prod_003",
    },
    {
      "name": "Kompor Portable",
      "price": "Rp3.000/hari",
      "category": "Elektronik",
      "status": "tersedia",
      "location": "Tamalanrea",
      "rentalInfo": null,
      "id": "prod_004",
    },
    {
      "name": "Jas Hitam",
      "price": "Rp4.000/hari",
      "category": "Pakaian",
      "status": "tersedia",
      "location": "Gowa, Jl. Kelapa",
      "rentalInfo": null,
      "id": "prod_005",
    },
  ];

  final List<String> filterOptions = [
    "Semua",
    "Tersedia",
    "Disewa",
    "ATK",
    "Pakaian",
    "Elektronik",
  ];

  // Daftar ID produk yang disukai
  List<String> _likedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadLikedProducts();
  }

  // 2. FUNGSI UNTUK MEMUAT DATA LIKED PRODUCTS
  void _loadLikedProducts() async {
    final List<String> likedIds = await _productService.getLikedProductIds();

    if (mounted) {
      setState(() {
        _likedProducts = likedIds;
      });
    }
  }

  // === FILTER + SEARCH RESULT ===
  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final searchMatch = product["name"]
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

      bool filterMatch = true;

      if (selectedFilter == "Tersedia") {
        filterMatch = product["status"] == "tersedia";
      } else if (selectedFilter == "Disewa") {
        filterMatch = product["status"] == "disewa";
      } else if (selectedFilter != "Semua") {
        filterMatch = product["category"] == selectedFilter;
      }

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

  // === FILTER BOTTOM SHEET ===
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
    // Ambil ukuran layar untuk membuat grid responsif
    final double screenWidth = MediaQuery.of(context).size.width;
    // padding horizontal yang dipakai di GridView
    const double horizontalPadding = 16.0 * 2; // kiri+kanan
    const double gridSpacing = 12.0;

    // Tentukan crossAxisCount berdasarkan lebar layar
    int crossAxisCount = 2;
    if (screenWidth >= 900) {
      crossAxisCount = 4;
    } else if (screenWidth >= 700) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    // Hitung lebar item (tersisa setelah padding & spacing)
    final double usableWidth = screenWidth - horizontalPadding - (gridSpacing * (crossAxisCount - 1));
    final double itemWidth = usableWidth / crossAxisCount;

    // Tentukan target tinggi kartu (relatif)
    // Gunakan rasio yang nyaman sehingga konten tidak saling bertumpuk
    final double itemHeight = itemWidth * 1.25; // sedikit lebih tinggi dari lebar
    final double childAspectRatio = itemWidth / itemHeight;

    return Scaffold(
      body: Column(
        children: [
          const HeaderWidget(title: "Beranda"),

          // === Search + Filter ===
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

          // === Judul ===
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

          // === Grid Produk ===
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: filteredProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: gridSpacing,
                  crossAxisSpacing: gridSpacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  final item = filteredProducts[index];
                  return _buildProductCard(context, item, itemWidth, itemHeight);
                },
              ),
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

  // === CARD PRODUK + NAVIGASI KE DETAIL ===
  Widget _buildProductCard(BuildContext context, Map<String, dynamic> item, double itemWidth, double itemHeight) {
    // Tentukan apakah produk ini disukai atau tidak untuk ikon hati
    final bool isProductLiked = _likedProducts.contains(item['id']);
    final bool isRented = item["status"] == "disewa";

    // kalkulasi image height berdasarkan lebar item
    final double imageHeight = itemWidth * 0.55; // sekitar 55% dari lebar

    return GestureDetector(
      onTap: () async {
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              // Gunakan ukuran eksplisit agar isi menyesuaikan tinggi
              width: itemWidth,
              height: itemHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar (responsif)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: imageHeight,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 50),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    item["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Text(
                    item["price"],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item["location"],
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
                      const Text("⭐ 4.9 | 21 tersewa", style: TextStyle(fontSize: 11)),
                      Row(
                        children: [
                          Icon(
                            isProductLiked ? Icons.favorite : Icons.favorite_border,
                            color: isProductLiked ? Colors.red : Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          const Text("20", style: TextStyle(fontSize: 12)),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),

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
                      "DISEWAKAN",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item["rentalInfo"] != null
                          ? "${item["rentalInfo"].start.day}/${item["rentalInfo"].start.month} - ${item["rentalInfo"].end.day}/${item["rentalInfo"].end.month}"
                          : "Sedang disewa",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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

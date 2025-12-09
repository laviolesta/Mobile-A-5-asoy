import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/bottom_navbar.dart';
import '../utils/no_animation_route.dart';
import '../pages/detail_page.dart'; // pastikan path sesuai
import 'notifikasi_page.dart';
import 'sewa/sewa_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = "Semua";

  // Dummy data produk
  final List<Map<String, dynamic>> products = [
    {
      "name": "Kalkulator Ilmiah",
      "price": "Rp2.000/hari",
      "category": "ATK",
      "status": "tersedia",
      "location": "Gowa, Jl. Mawar",
      "rentalInfo": null,
    },
    {
      "name": "Almamater Unhas",
      "price": "Rp3.000/hari",
      "category": "Pakaian",
      "status": "tersedia",
      "location": "Gowa, Jl. Kenanga",
      "rentalInfo": null,
    },
    {
      "name": "Baju Putih",
      "price": "Rp3.000/hari",
      "category": "Pakaian",
      "status": "tersedia",
      "location": "Gowa, Jl. Flamboyan",
      "rentalInfo": null,
    },
    {
      "name": "Kompor Portable",
      "price": "Rp3.000/hari",
      "category": "Elektronik",
      "status": "tersedia",
      "location": "Tamalanrea",
      "rentalInfo": null,
    },
    {
      "name": "Jas Hitam",
      "price": "Rp4.000/hari",
      "category": "Pakaian",
      "status": "tersedia",
      "location": "Gowa, Jl. Kelapa",
      "rentalInfo": null,
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final item = filteredProducts[index];
                  return _buildProductCard(context, item);
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
  Widget _buildProductCard(BuildContext context, Map<String, dynamic> item) {
    final bool isRented = item["status"] == "disewa";

    return GestureDetector(
      onTap: () async {
        // Navigasi ke DetailPage
        await Navigator.push(
          context,
          NoAnimationPageRoute(
            page: DetailPage(product: item),
          ),
        );

        // Setelah kembali dari DetailPage, refresh state untuk overlay terbaru
        setState(() {});
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  item["name"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                      item["location"],
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    )
                  ],
                ),

                const Spacer(),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("⭐ 4.9 | 21 tersewa", style: TextStyle(fontSize: 11)),
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 16),
                        SizedBox(width: 2),
                        Text("20", style: TextStyle(fontSize: 12)),
                      ],
                    )
                  ],
                )
              ],
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

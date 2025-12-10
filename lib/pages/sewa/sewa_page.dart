// File: sewa_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/header_widget.dart';
import '../../widgets/bottom_navbar.dart';
import '../../utils/no_animation_route.dart';
import '../detail_page.dart';
import '../rating_ulasan_page.dart';
import '../home_page.dart';
import '../notifikasi_page.dart';
import 'sewakan_page.dart';
import '../../services/product_service.dart';
import 'package:intl/intl.dart';
import '../../services/notif_service.dart'; 
import '../../services/user_service.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

class RentalHeaderControl extends StatelessWidget {
  final bool isSewakanActive;

  const RentalHeaderControl({
    super.key,
    required this.isSewakanActive,
  });

  // ... (Sisa kode RentalHeaderControl) ...

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
                    )
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
                    )
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// =======================================================
// CLASS SEWA PAGE (MENGGUNAKAN FIRESTORE STREAM)
// =======================================================
class SewaPage extends StatefulWidget {
  const SewaPage({super.key});

  @override
  State<SewaPage> createState() => _SewaPageState();
}

class _SewaPageState extends State<SewaPage> {
  final ProductService _productService = ProductService();
  final UserService _userService = UserService(); // <--- INISIALISASI USER SERVICE
  final FirebaseAuth _auth = FirebaseAuth.instance; // <--- INISIALISASI FIREBASE AUTH

  List<String> _likedProducts = [];

  late Stream<QuerySnapshot> _currentRentStream;
  late Stream<QuerySnapshot> _rentHistoryStream;

  Future<String> _getCurrentUserName() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return 'Pengguna Tidak Terautentikasi';
    }

    try {
      final userData = await _userService.getUserData(currentUserId);
      return userData?['nama_lengkap'] ?? 'Pengguna #${currentUserId.substring(0, 5)}';
    } catch (e) {
      print("Error mengambil data pengguna: $e");
      return 'Penyewa';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLikedProducts();

    _currentRentStream = _productService.getCurrentRentals();
    _rentHistoryStream = _productService.getRentalHistory();
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

  // === FUNGSI KEMBALIKAN PRODUK ===
  void _handleReturnProduct(BuildContext context, String rentalId, String productId, String productName, String ownerId) async {
    
    final result = await _productService.processReturn(rentalId);
    
    if (mounted) {
      if (result == null) {
        
        // --- LOGIKA NOTIFIKASI PENGEMBALIAN KE PEMILIK ---
        if (ownerId != 'N/A') {
            final renterName = await _getCurrentUserName(); 

            try {
                await NotificationService.createNotification(
                    title: "Item '$productName' Telah Dikembalikan.",
                    description: "Item '$productName' telah dikembalikan oleh '$renterName', konfirmasi barang sudah ada di anda. ID Sewa: $rentalId",
                    userId: ownerId, 
                    productId: productId,
                    rentalId: rentalId,
                );
            } catch (e) {
                print("Gagal mengirim notifikasi pengembalian: $e");
            }
        }
        // --- AKHIR LOGIKA NOTIFIKASI ---
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permintaan pengembalian berhasil diajukan. Menunggu konfirmasi pemilik.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengajukan pengembalian: $result')),
        );
      }
    }
  }

  // === FUNGSI BARU: BATALKAN SEWA ===
  void _handleCancelRental(BuildContext context, String rentalId, String productId, String productName) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Batalkan Sewa"),
      content: Text("Anda yakin ingin membatalkan sewa produk '$productName'? Produk akan tersedia kembali."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.red))),
      ],
    ),
  );

  if (confirm == true) {
    
    // 1. Ambil data rental/produk untuk mendapatkan Owner ID
    String? ownerId;
    try {
      final rentalDoc = await FirebaseFirestore.instance.collection('rentals').doc(rentalId).get();
      if (rentalDoc.exists) {
        // Asumsi ownerId disimpan di dokumen rental
        ownerId = rentalDoc.data()?['ownerId'] as String?; 
      }
    } catch (e) {
      print("Gagal mendapatkan Owner ID dari rental: $e");
    }

    if (ownerId == null) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Gagal: ID Pemilik tidak ditemukan.')),
         );
       }
       return;
    }


    // 2. Proses Pembatalan Sewa
    final result = await _productService.cancelRental(rentalId, productId);

    if (mounted) {
      if (result == null) {
        
        // --- LOGIKA NOTIFIKASI PEMBATALAN SEWA KE PEMILIK ---
        final renterName = await _getCurrentUserName(); // Ambil nama penyewa
        
        try {
           await NotificationService.createNotification(
             title: "Sewa Dibatalkan: $productName",
             description: "$renterName telah membatalkan sewa produk '$productName'. Produk kini tersedia kembali.",
             userId: ownerId, // <--- Kirim ke pemilik produk
             productId: productId,
           );
        } catch (e) {
           print("Gagal mengirim notifikasi pembatalan sewa: $e");
        }
        // --- AKHIR LOGIKA NOTIFIKASI ---
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sewa produk $productName berhasil dibatalkan.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membatalkan sewa: $result')),
        );
      }
    }
  }
}


  // === CARD PRODUK YANG SEDANG DISEWA ===
  Widget _buildRentedProductCard(BuildContext context, Map<String, dynamic> item) {
    final productData = item['productData'] as Map<String, dynamic>? ?? {};
    final String rentalId = item['id'] ?? 'N/A';
    final String productId = productData['id'] ?? 'N/A';
    final String ownerId = item['ownerId'] ?? 'N/A';

    final bool isReturnRequested = item['returnRequested'] as bool? ?? false;
    final bool isProductLiked = _likedProducts.contains(productId);

    final name = productData['name'] ?? 'Nama Produk';
    final price = productData['price'] ?? 'N/A';
    final location = productData['location'] ?? 'Lokasi';
    final imageUrl = productData['imageUrl'] ?? '';
    final likesCount = productData['likesCount'] ?? 0;

    final Timestamp endDateTimestamp = item['endDate'] as Timestamp? ?? Timestamp.now();

    final double averageRating = (productData['averageRating'] is num) ? (productData['averageRating'] as num).toDouble() : 0.0;
    final int rentedCount = productData['rentedCount'] ?? 0;
    final String ratingDisplay = averageRating.toStringAsFixed(1);

    const double imageHeight = 150;

    // =======================================================
    // 🚀 LOGIKA TAMPILAN STATUS DISEWA
    // =======================================================
    String statusDisplay = 'DISEWA';
    Color statusColor = Colors.red;

    String rentalDetail;
    bool showKembalikanButton;
    bool showCancelButton = true; // Default, tampilkan tombol Batalkan

    if (isReturnRequested) {
      rentalDetail = 'Menunggu Konfirmasi Pengembalian';
      showKembalikanButton = false;
      showCancelButton = false; // Jika sudah request return, batalkan sewa tidak relevan
    } else {
      rentalDetail = 'Berakhir ${DateFormat('dd/MM/yyyy').format(endDateTimestamp.toDate())}';
      showKembalikanButton = true;
      // showCancelButton tetap true
    }
    // =======================================================


    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          NoAnimationPageRoute(
            page: DetailPage(
              product: productData,
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
                    height: imageHeight,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.image_not_supported, size: 40, color: Colors.black38)
                      ),
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
                      // Nama Produk
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Harga
                      Text(
                        price,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      // Lokasi
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
                              )
                          )
                        ],
                      ),

                      const Spacer(),

                      // Rating dan Favorite
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "⭐ $ratingDisplay | $rentedCount tersewa",
                            style: const TextStyle(fontSize: 11),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: isProductLiked ? Colors.red : Colors.grey,
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

          // Overlay Status SEDANG DISEWA
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      statusDisplay,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rentalDetail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 8),

                    // Tombol Kembalikan (Hanya muncul jika showKembalikanButton true)
                    if (showKembalikanButton)
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
                        onPressed: () => _handleReturnProduct(context, rentalId, productId, name, ownerId),
                        child: const Text('Kembalikan'),
                      ),

                    // Tombol BATALKAN SEWA (Hanya muncul jika showCancelButton true)
                    if (showCancelButton)
                      Padding(
                        padding: EdgeInsets.only(top: showKembalikanButton ? 4.0 : 0.0), // Tambahkan jarak jika tombol Kembalikan ada
                        child: TextButton(
                          onPressed: () => _handleCancelRental(context, rentalId, productId, name),
                          child: const Text(
                            'Batalkan Sewa',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white70
                            ),
                          ),
                        ),
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

  // ... (Sisanya _buildHistoryProduct dan build() tidak berubah) ...
  // === RIWAYAT PRODUK COMPACT (Sewa Lagi) ===
  Widget _buildHistoryProduct(BuildContext context, Map<String, dynamic> item) {
    // Item adalah dokumen 'rentals' dengan status 'Selesai'
    final productData = item['productData'] as Map<String, dynamic>? ?? {};

    // Ambil data produk dari productData
    final name = productData['name'] ?? 'Nama Produk';
    final price = productData['price'] ?? 'N/A';
    final location = productData['location'] ?? 'Lokasi';
    final imageUrl = productData['imageUrl'] ?? ''; // Diubah ke string kosong

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
          // 1. Gambar (Disederhanakan untuk hanya menggunakan Image.network)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 60,
              width: 60,
              color: Colors.grey[200],
              child: Image.network(
                imageUrl,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
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
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  price,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  location,
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
              // 💡 Teks status selesai di riwayat
              const Text(
                  "SELESAI",
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green
                  )
              ),
              const SizedBox(height: 4), // Disesuaikan jarak
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
                      await Navigator.push(
                        context,
                        NoAnimationPageRoute(
                          page: DetailPage(
                            product: productData, // Gunakan productData
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
                          page: RatingUlasanPage(product: productData), // Gunakan productData
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
                  // === PRODUK YANG KAMU SEWA (AKTIF/PENDING) ===
                  const Text(
                    "Produk yang kamu sewa",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ==== GRID PRODUK DISEWA (StreamBuilder) ====
                  StreamBuilder<QuerySnapshot>(
                    stream: _currentRentStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final List<DocumentSnapshot> activeRentals = snapshot.data?.docs ?? [];

                      if (activeRentals.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Center(child: Text("Belum ada produk yang sedang kamu sewa.")),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeRentals.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemBuilder: (context, index) {
                          final doc = activeRentals[index];
                          final item = doc.data() as Map<String, dynamic>;
                          item['id'] = doc.id; // Tambahkan ID dokumen penyewaan (rentalId)

                          return _buildRentedProductCard(context, item);
                        },
                      );
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

                  // ==== RIWAYAT PRODUK COMPACT (StreamBuilder) ====
                  StreamBuilder<QuerySnapshot>(
                    stream: _rentHistoryStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final List<DocumentSnapshot> historyRentals = snapshot.data?.docs ?? [];

                      if (historyRentals.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Center(child: Text("Riwayat penyewaan masih kosong.")),
                        );
                      }

                      return Column(
                        children: historyRentals.map((doc) {
                          final item = doc.data() as Map<String, dynamic>;
                          item['id'] = doc.id; // Tambahkan ID dokumen riwayat
                          return _buildHistoryProduct(context, item);
                        }).toList(),
                      );
                    },
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
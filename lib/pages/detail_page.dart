import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'owner_profile_page.dart';

// Import services
import '../../services/product_service.dart';
import '../../services/user_service.dart';
import '../../services/notif_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import Halaman Tujuan
import 'sewa/sewa_page.dart';
import '../../utils/no_animation_route.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isOwnerView;
  final List<String> likedProducts;

  const DetailPage({
    super.key,
    required this.product,
    required this.isOwnerView,
    required this.likedProducts,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance; 

  late bool isLiked;
  late int currentLikesCount;

  // Stream untuk ulasan (reviews)
  late Stream<QuerySnapshot> _reviewsStream;

  String get ownerName => widget.product["ownerName"] ?? "Pemilik Tidak Dikenal";
  String get ownerProfileUrl => widget.product["ownerProfileUrl"] ?? "";

  @override
  void initState() {
    super.initState();
    final productId = widget.product['id'] as String?;

    isLiked = productId != null && widget.likedProducts.contains(productId);
    currentLikesCount = widget.product["likesCount"] ?? 0;

    if (productId != null) {
      _reviewsStream = _productService.getProductReviews(productId);
    } else {
      _reviewsStream = Stream.empty();
    }
  }

  Future<void> _toggleLike() async {
    final productId = widget.product['id'] as String?;
    final currentUserId = _auth.currentUser?.uid; // ⬅️ AMBIL USER ID

    if (productId == null) return;

    // ⚠️ Guardrail: Cek apakah user sudah login
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk menyukai produk.')),
      );
      return;
    }


    final bool wasLiked = isLiked;

    // Optimistic UI Update
    setState(() {
      isLiked = !wasLiked;
      currentLikesCount += isLiked ? 1 : -1;
    });

    // 1. Update jumlah likes di dokumen produk
    final productSuccess = await _productService.toggleProductLike(productId, isLiked);

    // 2. Update daftar liked_products di dokumen pengguna
    final userSuccess = await _userService.toggleLike(currentUserId, productId);


    // Cek keberhasilan kedua operasi
    if (productSuccess && userSuccess == null) { // userSuccess null = berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLiked ? 'Produk disukai' : 'Suka dibatalkan')),
      );
    } else {
      // Jika salah satu gagal, kembalikan state sebelumnya
      if (mounted) {
        setState(() {
          isLiked = wasLiked;
          currentLikesCount += isLiked ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui status suka (Firestore Error)')),
        );
      }
    }
  }

  Future<void> _openWhatsApp() async {
    final ownerPhone = widget.product['ownerPhone'] ?? '6281234567890';
    final Uri whatsapp = Uri.parse("https://wa.me/$ownerPhone");

    if (await canLaunchUrl(whatsapp)) {
      await launchUrl(whatsapp, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka WhatsApp')),
      );
    }
  }

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
    return 'Pengguna Anonim';
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E355D),
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

      final productId = widget.product['id'] as String?;
      final ownerId = widget.product['ownerId'] as String?;

      if (productId == null || ownerId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Data produk atau pemilik tidak lengkap.")),
          );
        }
        return;
      }

      final productRef = FirebaseFirestore.instance.collection('products').doc(productId);


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
              onPressed: () async {
                Navigator.pop(context);

                final result = await _productService.submitRentalRequest(
                  productId: productId,
                  startDate: start,
                  endDate: end,
                  ownerId: ownerId,
                  productRef: productRef,
                );

                if (mounted) {
                  if (result == null) {
                    final currentUserName = await _getCurrentUserName();
                    final productName = widget.product["name"] ?? 'Produk Tidak Diketahui';

                    try {
                      await NotificationService.createNotification(
                        title: "Permintaan Sewa Baru: $productName",
                        description: "$currentUserName telah mengajukan permintaan sewa untuk produk Anda selama $duration hari. Silakan cek halaman Sewa untuk konfirmasi.",
                        userId: ownerId,
                        productId: productId,
                      );
                    } catch (e) {
                      print("Gagal mengirim notifikasi ke pemilik: $e"); 
                    }
                  }

                  if (result == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Penyewaan berhasil diajukan! Menunggu konfirmasi.")),
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      NoAnimationPageRoute(page: const SewaPage()),
                          (route) => false,
                    );


                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Gagal mengajukan penyewaan: $result")),
                    );
                  }
                }
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
    // Ambil data rating dan format
    final double averageRating = (widget.product['averageRating'] is num) ? (widget.product['averageRating'] as num).toDouble() : 0.0;
    final String ratingDisplay = averageRating.toStringAsFixed(1);

    // Tentukan warna ikon like kondisional
    final Color likeIconColor = isLiked ? Colors.red : Colors.grey;

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
                // Tombol Like di Pojok Kiri Atas
                if (!widget.isOwnerView)
                  GestureDetector(
                    onTap: _toggleLike, // Menggunakan fungsi toggle
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: likeIconColor, // Menggunakan warna kondisional
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
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image_not_supported, size: 80, color: Colors.black38),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// TITLE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.product["name"] ?? 'Nama Produk Tidak Diketahui',
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
                                  const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 18),
                                  const SizedBox(width: 4),
                                  Text("$currentLikesCount"), // Menggunakan currentLikesCount
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

                  const Divider(height: 32),

                  /// RATING (Dinamis dari averageRating)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text("$ratingDisplay Rating Produk"),
                        // Tambahkan jumlah ulasan (optional)
                        Text(" (${widget.product["reviewCount"] ?? 0} Ulasan)", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// REVIEW LIST (Menggunakan StreamBuilder)
                  _buildReviewList(),

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
                          leading: CircleAvatar(
                            // 💡 Menggunakan URL profil pemilik jika tersedia
                            backgroundImage: ownerProfileUrl.isNotEmpty
                                ? NetworkImage(ownerProfileUrl) as ImageProvider
                                : null,
                            child: ownerProfileUrl.isEmpty ? const Icon(Icons.person) : null,
                          ),
                          title: Text(ownerName),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OwnerProfilePage(),
                                // TODO: Kirim ID Pemilik ke OwnerProfilePage
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
          ? null
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

  // Widget baru untuk menampilkan daftar ulasan menggunakan StreamBuilder
  Widget _buildReviewList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _reviewsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Error memuat ulasan: ${snapshot.error}"),
          );
        }

        final List<DocumentSnapshot> reviews = snapshot.data?.docs ?? [];

        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Belum ada ulasan untuk produk ini.", style: TextStyle(color: Colors.grey)),
          );
        }

        // Tampilkan 3 ulasan teratas (atau semua jika kurang dari 3)
        return Column(
          children: reviews.take(3).map((reviewDoc) {
            final reviewData = reviewDoc.data() as Map<String, dynamic>;
            final reviewerName = reviewData['userName'] ?? 'Pengguna Anonim';
            final comment = reviewData['comment'] ?? 'Tidak ada ulasan.';
            final rating = reviewData['rating'] as num? ?? 0;
            final userProfileUrl = reviewData['userProfileUrl'] as String? ?? '';

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    // 💡 Menggunakan URL profil user jika tersedia
                    backgroundImage: userProfileUrl.isNotEmpty
                        ? NetworkImage(userProfileUrl) as ImageProvider
                        : null,
                    child: userProfileUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(reviewerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 14),
                                Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
                              ],
                            )
                          ],
                        ),
                        Text(
                          comment,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
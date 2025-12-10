import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Alias untuk mendukung File di Web dan Mobile
typedef UniversalImageFile = dynamic;

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ===================================
  // KONSTANTA CLOUDINARY
  // ⚠️ PASTIKAN NILAI INI SESUAI DENGAN AKUN ANDA!
  // ===================================
  static const String CLOUDINARY_CLOUD_NAME = 'diksekwav'; // Ganti dengan cloud name Anda
  static const String CLOUDINARY_UPLOAD_PRESET = 'my_product_preset'; // Ganti dengan upload preset Anda

  final String _uploadUrl = 'https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/image/upload';


  // ===================================
  // FUNGSI BANTUAN CLOUDINARY
  // ===================================

  Future<String?> uploadProductImage(UniversalImageFile imageFile, String productId) async {
    try {
      final bytes = kIsWeb
          ? await (imageFile as XFile).readAsBytes()
          : await (imageFile as File).readAsBytes();

      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      request.fields['upload_preset'] = CLOUDINARY_UPLOAD_PRESET;
      request.fields['public_id'] = 'produk_$productId';

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'product_image_${productId}.jpg',
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['secure_url'] as String;
      } else {
        debugPrint("Gagal mengunggah ke Cloudinary. Status: ${response.statusCode}, Body: ${response.body}");
        return null;
      }

    } catch (e) {
      debugPrint("Gagal mengunggah gambar ke Cloudinary: $e");
      return null;
    }
  }


  // ===================================
  // I. OPERASI PRODUK (Koleksi 'products')
  // ===================================

  Future<String?> createProduct({
    required String name,
    required String price,
    required int rawPrice,
    required String category,
    required String description,
    required String location,
    required String address,
    required UniversalImageFile? imageFile,
  }) async {
    if (currentUserId == null) return "Pengguna belum login. Silakan coba lagi.";
    if (imageFile == null) return "File gambar tidak boleh kosong.";

    try {
      final productRef = _firestore.collection('products').doc();
      final productId = productRef.id;

      final uploadedUrl = await uploadProductImage(imageFile, productId);

      if (uploadedUrl == null) {
        return "Gagal mengunggah gambar ke Cloudinary. Periksa log atau koneksi Anda.";
      }

      await productRef.set({
        'id': productId,
        'ownerId': currentUserId,
        'name': name,
        'price': price,
        'raw_price': rawPrice,
        'category': category,
        'description': description,
        'location': location,
        'address': address,
        'imageUrl': uploadedUrl,
        'isAvailable': true,
        'rentedCount': 0,
        'likesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      debugPrint("Gagal membuat produk (catch block): $e");
      return "Gagal membuat produk: ${e.toString().contains('Exception:') ? e.toString().split('Exception: ')[1] : e.toString()}";
    }
  }

  /// 🛠️ FUNGSI HAPUS PRODUK
  Future<String?> deleteProduct(String productId) async {
    try {
      final productRef = _firestore.collection('products').doc(productId);
      await productRef.delete();
      return null;
    } catch (e) {
      debugPrint("Gagal menghapus produk: $e");
      return "Gagal menghapus produk: ${e.toString()}";
    }
  }

  // =========================================================
  // 🟢 FUNGSI BARU (resetProductStatus)
  // [Dipanggil ketika rental dibatalkan/dihapus secara manual]
  // =========================================================
  Future<void> resetProductStatus(String productId) async {
    final productRef = _firestore.collection('products').doc(productId);

    // Set produk kembali tersedia dan hapus field sewa
    await productRef.update({
      'isAvailable': true,
      'rentalEndDate': FieldValue.delete(), // Hapus field ini
      // Hapus field terkait sewa lainnya jika ada (misal: currentRenterId)
    });
  }
  // =========================================================

  // Query untuk HomePage (Semua produk, filter dilakukan di sisi klien)
  Stream<QuerySnapshot> getAllProductsForHomePage() {
    return _firestore.collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Query untuk SewakanPage (Produk milik user yang sedang login)
  Stream<QuerySnapshot> getOwnerProducts() {
    if (currentUserId == null) return Stream.empty();

    return _firestore.collection('products')
        .where('ownerId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Metode untuk mendapatkan Stream Ulasan (Reviews)
  Stream<QuerySnapshot> getProductReviews(String productId) {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }


  // ===================================
  // II. OPERASI PENYEWAAN DAN LAINNYA ('rentals' collection)
  // ===================================

  // Mengambil produk yang sedang disewa oleh user saat ini
  Stream<QuerySnapshot> getCurrentRentals() {
    if (currentUserId == null) return Stream.empty();

    return _firestore.collection('rentals')
        .where('renterId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'Disewa')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Riwayat Produk (status: 'Selesai')
  Stream<QuerySnapshot> getRentalHistory() {
    if (currentUserId == null) return Stream.empty();

    return _firestore.collection('rentals')
        .where('renterId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'Selesai')
        .orderBy('endDate', descending: true)
        .snapshots();
  }

  // FUNGSI UNTUK PROSES KEMBALIKAN (dari SewaPage)
  Future<String?> processReturn(String rentalId) async {
    try {
      final rentalRef = _firestore.collection('rentals').doc(rentalId);

      await rentalRef.update({
        'returnRequested': true, // <-- FLAG: Permintaan pengembalian
        'returnRequestedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      debugPrint("Gagal mengajukan pengembalian: $e");
      return "Gagal mengajukan pengembalian: ${e.toString()}";
    }
  }

  // =========================================================
  // 🚀 FUNGSI UTAMA YANG DIPERBAIKI (submitRentalRequest)
  // [Memperbarui status produk di koleksi 'products']
  // =========================================================
  Future<String?> submitRentalRequest({
    required String productId,
    required DateTime startDate,
    required DateTime endDate,
    required String ownerId,
    required DocumentReference productRef,
  }) async {
    if (currentUserId == null) return "Pengguna belum login.";

    try {
      final productDoc = await productRef.get();
      if (!productDoc.exists) {
        return "Produk tidak ditemukan.";
      }
      final productData = productDoc.data() as Map<String, dynamic>?;

      if (productData == null) return "Gagal memuat data produk.";

      final productSnapshotData = Map<String, dynamic>.from(productData);

      // Hapus field yang tidak perlu disimpan di snapshot rental
      productSnapshotData.remove('createdAt');
      productSnapshotData.remove('isAvailable');
      productSnapshotData.remove('rentalEndDate');

      // 1. PERBAIKAN KRUSIAL: Update status produk di koleksi 'products'
      await productRef.update({
        'isAvailable': false,
        'rentalEndDate': Timestamp.fromDate(endDate), // <-- PENTING! Update tanggal berakhir sewa
      });

      // 2. Buat dokumen rental baru di koleksi 'rentals'
      final rentalRef = _firestore.collection('rentals').doc();

      await rentalRef.set({
        'id': rentalRef.id,
        'productId': productId,
        'productRef': productRef,
        'renterId': currentUserId,
        'ownerId': ownerId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'status': 'Disewa',
        'productData': productSnapshotData,
        'confirmationOwner': true,
        'createdAt': FieldValue.serverTimestamp(),
        'returnRequested': false,
      });

      return null;
    } catch (e) {
      debugPrint("Gagal mengajukan penyewaan: $e");
      return "Gagal mengajukan penyewaan: ${e.toString()}";
    }
  }
  // =========================================================

  // =========================================================
  // 🟢 FUNGSI BARU (confirmReturn)
  // [Mengembalikan status produk menjadi 'isAvailable: true' dan memindahkan rental ke riwayat]
  // =========================================================
  Future<String?> confirmReturn(String rentalId, String productId) async {
    if (currentUserId == null) return "Pengguna belum login.";

    final rentalRef = _firestore.collection('rentals').doc(rentalId);
    final productRef = _firestore.collection('products').doc(productId);

    try {
      // 💡 Verifikasi Pemilik (Verifikasi ini penting untuk keamanan)
      final rentalDoc = await rentalRef.get();
      if (!rentalDoc.exists || rentalDoc.data()?['ownerId'] != currentUserId) {
        return "Aksi ditolak. Anda bukan pemilik produk ini.";
      }

      final batch = _firestore.batch();

      // 1. Update dokumen Rental ke status Selesai
      batch.update(rentalRef, {
        'status': 'Selesai',
        'returnConfirmedAt': FieldValue.serverTimestamp(),
        'returnRequested': FieldValue.delete(), // Hapus flag permintaan
      });

      // 2. Update dokumen Produk agar Tersedia Kembali
      batch.update(productRef, {
        'isAvailable': true,
        'rentalEndDate': FieldValue.delete(), // Hapus tanggal berakhir sewa
        'rentedCount': FieldValue.increment(1), // Increment jumlah tersewa
      });

      await batch.commit();
      return null; // Sukses
    } catch (e) {
      debugPrint("Gagal konfirmasi pengembalian: $e");
      return "Gagal konfirmasi pengembalian: ${e.toString()}";
    }
  }
  // =========================================================


  Future<bool> toggleProductLike(String productId, bool targetLikedStatus) async {
    final uid = currentUserId;
    if (uid == null) return false;

    final userRef = _firestore.collection('users').doc(uid);
    final productRef = _firestore.collection('products').doc(productId);

    try {
      final batch = _firestore.batch();

      if (targetLikedStatus) {
        // Jika target status adalah LIKED (TRUE): Lakukan LIKE (+1)
        batch.update(userRef, {'liked_products': FieldValue.arrayUnion([productId])});
        batch.update(productRef, {'likesCount': FieldValue.increment(1)}); // Bertambah 1
      } else {
        // Jika target status adalah UNLIKED (FALSE): Lakukan UNLIKE (-1)
        batch.update(userRef, {'liked_products': FieldValue.arrayRemove([productId])});
        batch.update(productRef, {'likesCount': FieldValue.increment(-1)}); // Berkurang 1
      }

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint("Error liking/unliking product: $e");
      return false;
    }
  }

  Future<String?> cancelRental(String rentalId, String productId) async {
    if (currentUserId == null) return "Pengguna belum login.";

    final rentalRef = _firestore.collection('rentals').doc(rentalId);
    final productRef = _firestore.collection('products').doc(productId);

    try {
      // Gunakan Batch Write untuk memastikan kedua operasi berhasil atau gagal
      final batch = _firestore.batch();

      // 1. Hapus dokumen Rental dari koleksi 'rentals'
      batch.delete(rentalRef);

      // 2. Update dokumen Produk agar Tersedia Kembali di koleksi 'products'
      batch.update(productRef, {
        'isAvailable': true,
        'rentalEndDate': FieldValue.delete(), // Hapus tanggal berakhir sewa
      });

      await batch.commit();

      return null; // Sukses
    } catch (e) {
      debugPrint("Gagal membatalkan penyewaan: $e");
      return "Gagal membatalkan penyewaan: ${e.toString()}";
    }
  }

  Future<List<String>> getLikedProductIds() async {
    if (currentUserId == null) return [];

    try {
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey('liked_products')) {
          return List<String>.from((data['liked_products'] as List<dynamic>?) ?? []);
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching liked products: $e");
      return [];
    }
  }

  // FUNGSI UNTUK MENDAPATKAN DETAIL PRODUK BERDASARKAN ID
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final docSnapshot = await _firestore.collection('products').doc(productId).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        // Ambil data, dan pastikan ID dokumen dimasukkan ke dalam Map
        Map<String, dynamic> data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;
        return data;
      }
      return null; // Produk tidak ditemukan
    } catch (e) {
      print("Error fetching product by ID: $e");
      // Lempar error untuk ditangani di NotifDetailPage
      throw Exception("Gagal mengambil data produk: $e");
    }
  }
}
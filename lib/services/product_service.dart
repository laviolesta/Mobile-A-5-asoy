import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:firebase_storage/firebase_storage.dart'; 
import 'dart:io'; // Untuk tipe File (Mobile)
import 'package:image_picker/image_picker.dart'; // Untuk XFile (Web)
import 'dart:typed_data'; // Untuk Uint8List

// Tipe data universal untuk gambar
typedef UniversalImageFile = dynamic; 

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; 

  String? get currentUserId => _auth.currentUser?.uid;

  // ===================================
  // FUNGSI BANTUAN
  // ===================================
  
  /// Mengunggah file gambar ke Firebase Storage dan mengembalikan URL-nya.
  Future<String?> uploadProductImage(UniversalImageFile imageFile, String productId) async {
    try {
      final String fileName = '$productId.jpg';
      final Reference storageRef = _storage.ref().child('product_images').child(fileName);
      
      UploadTask uploadTask;

      if (kIsWeb) {
        // --- LOGIKA WEB: MENGUNGGAH DARI BYTES (DARI XFILE) ---
        // Menggunakan 'is XFile' check untuk keamanan
        if (imageFile is XFile) { 
            final bytes = await imageFile.readAsBytes();

            uploadTask = storageRef.putData(
                bytes, 
                SettableMetadata(contentType: 'image/jpeg')
            );
        } else {
            debugPrint("Error: Di web, imageFile bukan tipe XFile.");
            return null;
        }
      } else {
        // --- LOGIKA MOBILE: MENGUNGGAH DARI FILE (dart:io) ---
        // Menggunakan 'is File' check untuk keamanan
        if (imageFile is File) { 
            uploadTask = storageRef.putFile(imageFile);
        } else {
             debugPrint("Error: Di mobile, imageFile bukan tipe dart:io.File.");
            return null;
        }
      }
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
      
    } catch (e) {
      debugPrint("Gagal mengunggah gambar: $e");
      return null;
    }
  }

  // ===================================
  // I. OPERASI PRODUK (Koleksi 'products')
  // ===================================

  /// Menyimpan data dari CreateProductPage ke Firestore.
  Future<String?> createProduct({
    required String name,
    required String price, 
    required int rawPrice, 
    required String category,
    required String description,
    required String location,
    required String address, 
    required UniversalImageFile? imageFile, // Menerima tipe UniversalImageFile
  }) async {
    if (currentUserId == null) {
      return "Pengguna belum login. Silakan coba lagi.";
    }
    
    if (imageFile == null) {
      return "File gambar tidak boleh kosong.";
    }

    try {
      final productRef = _firestore.collection('products').doc();
      final productId = productRef.id;

      String imageUrl = "https://via.placeholder.com/260"; 

      // 1. Unggah Gambar
      final uploadedUrl = await uploadProductImage(imageFile, productId);
      
      if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
      } else {
          // Jika upload gagal, kembalikan error
          return "Gagal mengunggah gambar ke Storage. Periksa log atau koneksi Anda."; 
      }
      
      // 2. Simpan Data Produk ke Firestore
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
        'imageUrl': imageUrl, 
        'isAvailable': true,
        'rentedCount': 0,
        'likesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null; // Berhasil
    } catch (e) {
      debugPrint("Gagal membuat produk: $e");
      return "Gagal membuat produk: ${e.toString()}";
    }
  }

  // ===================================
  // FUNGSI LAIN (Tidak Diubah)
  // ===================================
  
  Stream<QuerySnapshot> getAvailableProducts() {
    return _firestore.collection('products')
      .where('isAvailable', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots();
  }

  Stream<QuerySnapshot> getOwnerProducts() {
    if (currentUserId == null) return Stream.empty();
    
    return _firestore.collection('products')
      .where('ownerId', isEqualTo: currentUserId)
      .snapshots();
  }

  /// Mengajukan Permintaan Sewa dari DetailPage.
  Future<String?> submitRentalRequest({
    required String productId,
    required DateTime startDate,
    required DateTime endDate,
    required String ownerId,
    required DocumentReference productRef, 
  }) async {
    if (currentUserId == null) return "Pengguna belum login.";

    try {
      final rentalRef = _firestore.collection('rentals').doc();
      
      await rentalRef.set({
        'id': rentalRef.id,
        'productId': productId,
        'productRef': productRef, 
        'renterId': currentUserId,
        'ownerId': ownerId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'status': 'Diajukan', 
        'confirmationOwner': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return null;
    } catch (e) {
      debugPrint("Gagal mengajukan penyewaan: $e");
      return "Gagal mengajukan penyewaan: ${e.toString()}";
    }
  }

  /// Menambah atau menghapus produk dari daftar 'liked_products' dan mengupdate 'likesCount'.
  Future<bool> toggleProductLike(String productId, bool currentlyLiked) async {
    final uid = currentUserId;
    if (uid == null) return false;
    
    final userRef = _firestore.collection('users').doc(uid);
    final productRef = _firestore.collection('products').doc(productId);

    try {
      final batch = _firestore.batch();
      
      if (currentlyLiked) {
        batch.update(userRef, {'liked_products': FieldValue.arrayRemove([productId])});
        batch.update(productRef, {'likesCount': FieldValue.increment(-1)});
      } else {
        batch.update(userRef, {'liked_products': FieldValue.arrayUnion([productId])});
        batch.update(productRef, {'likesCount': FieldValue.increment(1)});
      }
      
      await batch.commit(); 
      return true; 
    } catch (e) {
      debugPrint("Error liking/unliking product: $e");
      return false; 
    }
  }

  /// Mengambil daftar ID produk yang disukai oleh pengguna saat ini.
  Future<List<String>> getLikedProductIds() async {
    if (currentUserId == null) {
      return [];
    }
    
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
}
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ⚠️ PASTIKAN NILAI INI SUDAH DIGANTI DENGAN KONFIGURASI CLOUDINARY ANDA
  static const String CLOUDINARY_CLOUD_NAME = 'nama_cloud_anda'; 
  static const String CLOUDINARY_UPLOAD_PRESET = 'FLUTTER_PROFILE_PRESET'; 

  final String _collection = 'users';

  Future<void> createNewUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(
        user.toFirestore(), 
      );
      print("New user document created successfully for ID: ${user.id}");
    } catch (e) {
      print("Error creating user document: $e");
      rethrow;
    }
  }

  // 1. Stream User (Stream data profil)
  Stream<UserModel> streamUser(String userId) {
    final userRef = _firestore.collection(_collection).doc(userId);
    return userRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      } else {
        // Return model kosong (data 'N/A') jika dokumen tidak ditemukan
        return UserModel(
          id: userId,
          nama_lengkap: 'Pengguna Baru',
          email: 'N/A',
          nim: 'N/A',
          fakultas: 'N/A',
          jurusan: 'N/A',
          no_whatsapp: 'N/A',
        );
      }
    });
  }

  // 2. Update User Data (Generic)
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(userId).update(data);
    } catch (e) {
      print("Error updating user data: $e");
      rethrow;
    }
  }

  // 3. Update Nomor WhatsApp (Menggunakan nama field yang konsisten)
  Future<void> updateNoWhatsapp(String userId, String newNoWhatsapp) async {
    return updateUserData(userId, {
      'no_whatsapp': newNoWhatsapp, // 🔥 Pastikan field di Firestore adalah 'no_whatsapp'
    });
  }

  // 4. Upload Foto Profil ke CLOUDINARY
  Future<String> uploadProfilePhoto(String userId, String filePath) async {
    try {
      final file = File(filePath);

      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final cloudinaryUrl = 'https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/image/upload';

      final Map<String, String> body = {
        'file': 'data:image/png;base64,$base64Image',
        'upload_preset': CLOUDINARY_UPLOAD_PRESET,
        'public_id': 'profile_$userId',
        'folder': 'user_profiles',
      };

      final response = await http.post(
        Uri.parse(cloudinaryUrl),
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String downloadUrl = responseData['secure_url'];
        return downloadUrl;
      } else {
        throw Exception('Gagal mengupload foto ke Cloudinary. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print("Error uploading profile photo: $e");
      rethrow;
    }
  }

  // 5. Update URL Foto Profil (Menyimpan URL yang didapat dari Cloudinary ke Firestore)
  Future<void> updateProfilePhotoUrl(String userId, String photoUrl) async {
    return updateUserData(userId, {
      'photoUrl': photoUrl,
    });
  }

  // 6. Update daftar produk yang disukai (Digunakan di ProfilePage saat mode Edit)
  Future<void> updateLikedProducts(String userId, List<Map<String, dynamic>> likedProductIds) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'liked_products': likedProductIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating liked products: $e");
      rethrow;
    }
  }

  // 7. FUNGSI BARU UNTUK TOGGLE LIKE DARI DETAIL PAGE
  Future<String?> toggleLike(String userId, String productId) async {
    final userRef = _firestore.collection(_collection).doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);

        // Ambil daftar yang sudah ada. Jika null, inisialisasi dengan array kosong.
        List<String> currentLikes = (snapshot.data()?['liked_products'] as List<dynamic>?)
            ?.map((e) => e.toString()).toList() ?? [];

        if (currentLikes.contains(productId)) {
          // Hapus (Unlike)
          currentLikes.remove(productId);
        } else {
          // Tambah (Like)
          currentLikes.add(productId);
        }

        // Tulis kembali daftar yang diperbarui
        transaction.update(userRef, {
          'liked_products': currentLikes,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return null; // Sukses
    } catch (e) {
      print("Error toggling like status for user $userId: $e");
      return e.toString(); // Gagal
    }
  }

  // 8. Stream detail produk yang disukai (Digunakan di ProfilePage)
  Stream<List<Map<String, dynamic>>> getLikedProductDetailsStream(List<String> productIds) {

    // Firestore whereIn hanya mendukung maksimum 10 ID
    final List<String> safeProductIds = productIds.take(10).toList();

    if (safeProductIds.isEmpty) {
      return Stream.value([]);
    }

    // Mengambil ID produk yang disukai dan mencari detailnya
    return _firestore.collection('products')
        .where(FieldPath.documentId, whereIn: safeProductIds)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // 🟢 Koreksi: Hapus '!' karena data() dari QueryDocumentSnapshot tidak null
        return {'id': doc.id, ...data};
      }).toList();
    });
  }

  // 9. Fungsi ambil data user sekali jalan (non-stream)
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("Gagal mengambil data pengguna: $e");
      return null;
    }
  }
}
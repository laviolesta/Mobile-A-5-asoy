import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class UserService {
  // Instance dari Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // Nama Collection di Firebase
  final String _collection = 'users';

  // 1. Method untuk mendapatkan data user berdasarkan ID (menggunakan Stream)
  // Cocok untuk ProfilePage yang selalu update
  Stream<UserModel> streamUser(String userId) {
    // Mendapatkan reference ke dokumen user spesifik
    final userRef = _firestore.collection(_collection).doc(userId);

    // Mengembalikan Stream yang akan memancarkan UserModel setiap kali data berubah
    return userRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        // Menggunakan factory constructor dari UserModel
        return UserModel.fromFirestore(snapshot);
      } else {
        // Jika dokumen tidak ditemukan, lempar error atau kembalikan model default
        throw Exception("User document with ID $userId not found.");
      }
    });
  }

  // 2. Method untuk mengupdate satu atau beberapa field data user
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(userId).update(data);
      print("User data updated successfully for ID: $userId");
    } catch (e) {
      print("Error updating user data: $e");
      // Anda bisa lempar error lagi ke layer atas (UI)
      rethrow; 
    }
  }

  // 3. Method untuk mengupdate Nomor WhatsApp
  Future<void> updateNoWhatsapp(String userId, String newNoWhatsapp) async {
    return updateUserData(userId, {
      'no_whatsapp': newNoWhatsapp,
    });
  }

  // 4. Method untuk membuat user baru di Firestore
  Future<void> createNewUser(UserModel user) async {
    try {
      // Memastikan field konsisten menggunakan toFirestore() dari model
      await _firestore.collection(_collection).doc(user.id).set(
        user.toFirestore(), 
      );
    } catch (e) {
      print("Error creating user: $e");
      rethrow;
    }
  }

  // 5. Method untuk Upload Foto Profil dan mendapatkan URL
  Future<String> uploadProfilePhoto(String userId, String filePath) async {
    try {
      // 1. Definisikan Lokasi Storage (Folder/File ID)
      final String storagePath = 'profile_photos/$userId/profile.jpg';
      final file = File(filePath); // Perlu import 'dart:io' jika menggunakan File

      // 2. Lakukan Upload
      final uploadTask = _storage.ref(storagePath).putFile(file);

      // 3. Tunggu hingga Upload selesai
      final snapshot = await uploadTask.whenComplete(() {});

      // 4. Dapatkan Download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("Error uploading profile photo: $e");
      rethrow;
    }
  }

  // 6. Method untuk mengupdate URL Foto Profil
  Future<void> updateProfilePhotoUrl(String userId, String photoUrl) async {
    return updateUserData(userId, {
      'photoUrl': photoUrl, // Field di Firestore untuk menyimpan URL Foto
    });
  }

  // 7. Method untuk mengupdate daftar produk yang disukai
  Future<void> updateLikedProducts(String userId, List<Map<String, dynamic>> likedProductsData) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        // Menyimpan seluruh list map ke dalam field 'liked_products'
        'liked_products': likedProductsData, 
        // Optional: Anda bisa menambahkan timestamp update terakhir
        'updated_at': FieldValue.serverTimestamp(), 
      });
      print("Liked products list updated successfully for ID: $userId");
    } catch (e) {
      print("Error updating liked products: $e");
      rethrow;
    }
  }
}
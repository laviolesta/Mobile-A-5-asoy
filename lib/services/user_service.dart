import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  // Instance dari Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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
}
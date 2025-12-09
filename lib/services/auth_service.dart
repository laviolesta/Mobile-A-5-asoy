import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- FUNGSI LOGIN ---
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Berhasil
    } on FirebaseAuthException catch (e) {
      return e.message; // Gagal
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  // --- FUNGSI REGISTER + SIMPAN DATA LENGKAP ---
  Future<String?> signUp({
    required String email,
    required String password,
    required String nama,
    required String nim,
    required String fakultas,
    required String jurusan,
    required String noWhatsapp,
  }) async {
    try {
      // 1. Buat Akun Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 2. Simpan Data Profil ke Firestore
      String uid = userCredential.user!.uid;

      final newUser = UserModel(
      id: uid,
      nama_lengkap: nama,
      email: email,
      nim: nim,
      fakultas: fakultas,
      jurusan: jurusan,
      no_whatsapp: noWhatsapp,
    );

      await UserService().createNewUser(newUser);

      return null; // Berhasil
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Gagal mendaftar: $e";
    }
  }

  // --- LOGOUT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
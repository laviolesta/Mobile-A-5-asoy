import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- FUNGSI LOGIN (SIGN IN) ---
  Future<String?> signIn({required String email, required String password}) async {
    try {
      if (!email.endsWith('@student.unhas.ac.id')) {
        return 'Gunakan email kampus (@student.unhas.ac.id)!';
      }

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'Email tidak ditemukan.';
      if (e.code == 'wrong-password') return 'Password salah.';
      if (e.code == 'invalid-email') return 'Format email salah.';
      if (e.code == 'user-disabled') return 'Akun ini telah dinonaktifkan.';
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  // --- FUNGSI REGISTER (SIGN UP) ---
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
      if (!email.endsWith('@student.unhas.ac.id')) {
        return 'Wajib menggunakan email kampus (@student.unhas.ac.id)!';
      }

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

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'Email sudah terdaftar.';
      if (e.code == 'weak-password') return 'Password terlalu lemah.';
      return e.message;
    } catch (e) {
      return "Gagal mendaftar: $e";
    }
  }

  // --- FUNGSI RESET PASSWORD ---
  Future<String?> resetPassword({required String email}) async {
    try {
      if (!email.endsWith('@student.unhas.ac.id')) {
        return 'Gunakan email kampus (@student.unhas.ac.id)!';
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'Email tidak terdaftar.';
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  // --- LOGOUT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
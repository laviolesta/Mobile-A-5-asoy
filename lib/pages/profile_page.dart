import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/profil_header_widget.dart';
import '../widgets/product_card_widget.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService(); 
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker(); 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key untuk Snackbar

  bool _isEditing = false; 

  // Data produk yang disukai (diubah menjadi mutable List di State)
  List<Map<String, dynamic>> liked_products = [
    {
      'name': 'Baju Putih',
      'price': 'Rp3.000/hari',
      'location': 'Gowa, Jl.Kelapa',
      'rating': 4.5,
      'reviews': 8,
      'likes': 6,
    },
    {
      'name': 'Jas Hitam',
      'price': 'Rp4.000/hari',
      'location': 'Gowa, Jl. Kelapa',
      'rating': 4.5,
      'reviews': 8,
      'likes': 7,
    },
  ];

  void _toggleEditMode() async {
    if (_isEditing) {
      
      final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      
      if (currentUserId == null) {
          _showSnackbar('Gagal menyimpan: Anda tidak terautentikasi.');
          return;
      }

      try {
        await _userService.updateLikedProducts(
          currentUserId, 
          liked_products, // Kirim list Map yang sudah dimodifikasi (dihapus)
        );
        
        // Update UI state setelah berhasil menyimpan
        setState(() {
          _isEditing = false;
        });
        _showSnackbar('Perubahan produk yang disukai telah disimpan.');

      } catch (e) {
        _showSnackbar('Gagal menyimpan perubahan: $e');
        // Tetap di mode edit jika gagal menyimpan
        return; 
      }

    } else {
      // Logic Edit (Saat tombol "Edit" ditekan)
      setState(() {
        _isEditing = true;
      });
    }
  }

  // Fungsi edit like 
  void _deleteLikedProduct(int index) {
    
    setState(() {
      liked_products.removeAt(index);
    });
  }

  void _showSnackbar(String message) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  // Fungsi log-out
  Future<void> _logout() async {
    try {
      await _authService.signOut();
      // Navigasi ke halaman login dan hapus semua rute sebelumnya
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    } catch (e) {
      _showSnackbar('Gagal melakukan logout: $e');
    }
  }

  // Fungsi yang akan dijalankan saat tombol edit No WA diklik
  void _showEditWaDialog(){
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      _showSnackbar('Anda harus login untuk mengedit.');
      return;
    }

    final TextEditingController waController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit No. WhatsApp"),
          content: TextField(
            controller: waController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: "Masukkan Nomor WhatsApp Baru",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Simpan"),
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Lakukan pembaruan ke Firestore
                try {
                  await _userService.updateNoWhatsapp(
                    currentUserId, 
                    waController.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nomor WhatsApp berhasil diperbarui!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui No. WA: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi Upload Foto
  void _showImageSourcePicker(String currentUserId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery, currentUserId);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera, currentUserId);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi handle image picker & upload (placeholder)
  Future<void> _pickImage(ImageSource source, String currentUserId) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Memulai proses upload foto...')),
      );

      try {
        // 1. Upload pickedFile ke Firebase Storage & Dapatkan URL
        final String downloadURL = await _userService.uploadProfilePhoto(
          currentUserId, 
          pickedFile.path,
        );

        // 2. Simpan URL ke Firestore
        await _userService.updateProfilePhotoUrl(
          currentUserId, 
          downloadURL,
        );

        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('Foto Profil berhasil diperbarui!')),
        );
        
      } catch (e) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Gagal upload atau simpan URL: $e')),
        );
      }
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      key: navigatorKey, // Pasang GlobalKey di Scaffold
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentUserId == null) 
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Anda belum login atau sesi telah berakhir.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              )
            else
              StreamBuilder<UserModel>(
                stream: _userService.streamUser(currentUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  
                  if (snapshot.hasData) {
                    final UserModel user = snapshot.data!;
                    
                    return ProfileHeaderWidget(
                      nama: user.nama_lengkap,
                      email: user.email, 
                      nim: user.nim,
                      fakultas: user.fakultas,
                      jurusan: user.jurusan,
                      no_whatsapp: user.no_whatsapp, 
                      onEditWaTap: _showEditWaDialog, // 🔥 FUNGSI EDIT WA
                      onEditPhotoTap: () => _showImageSourcePicker(currentUserId), // 🔥 FUNGSI EDIT FOTO
                    );
                  }
                  
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Data profil tidak ditemukan.'),
                  ));
                },
              ),

            const Divider(height: 1, thickness: 1, color: Colors.grey),
            _buildLikedProductsSection(context),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Log Out",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedProductsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 24.0, left: 16.0, bottom: 8.0),
          child: Text(
            "Produk yang disukai",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 30,
                child: OutlinedButton(
                  // 🔥 Tombol Edit/Simpan: Panggil _toggleEditMode
                  onPressed: _toggleEditMode,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    side: BorderSide(color: _isEditing ? Colors.green : Colors.blue), // Warna berbeda
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: Text(
                    // 🔥 Ubah teks tombol berdasarkan state
                    _isEditing ? "Simpan" : "Edit",
                    style: TextStyle(fontSize: 14, color: _isEditing ? Colors.green : Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),

        SizedBox(
          height: 250, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: liked_products.length,
            itemBuilder: (context, index) {
              final product = liked_products[index];
              
              // 🔥 Menggunakan Stack untuk menampilkan icon 'X' di atas card
              return Stack(
                clipBehavior: Clip.none, // Penting agar icon 'X' tidak terpotong
                children: [
                  ProductCardWidget(product: product),
                  
                  if (_isEditing) // Hanya tampilkan saat mode edit
                    Positioned(
                      top: -5, // Posisikan sedikit di luar batas atas Card
                      right: 15, // Sesuaikan posisi horizontal
                      child: GestureDetector(
                        onTap: () => _deleteLikedProduct(index), // Panggil fungsi hapus
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2), // Border putih agar terlihat
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }
}
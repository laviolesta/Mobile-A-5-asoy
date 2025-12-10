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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isEditing = false;
  List<String> _likedIdsToRemove = [];

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // ✅ KOREKSI FUNGSI _toggleEditMode
  void _toggleEditMode(List<String> likedIdsFromStream) async {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      _showSnackbar('Gagal menyimpan: Anda tidak terautentikasi.');
      return;
    }

    if (_isEditing) {
      // --- MODE SIMPAN ---

      // Hitung ID produk yang tersisa dari ID ASLI di stream, dikurangi yang ditandai
      final List<String> liked_products = likedIdsFromStream
          .where((id) => !_likedIdsToRemove.contains(id))
          .toList();

      try {
        await _userService.updateLikedProducts(
          currentUserId,
          liked_products,
        );

        if (mounted) {
          setState(() {
            _isEditing = false;
            _likedIdsToRemove = [];
          });
          _showSnackbar('Perubahan produk yang disukai telah disimpan.');
        }

      } catch (e) {
        _showSnackbar('Gagal menyimpan perubahan: $e');
        return;
      }

    } else {
      // --- MODE EDIT (MEMULAI) ---
      setState(() {
        _isEditing = true;
        _likedIdsToRemove = [];
      });
    }
  }

  void _deleteLikedProduct(String productId) {
    setState(() {
      if (!_likedIdsToRemove.contains(productId)) {
        _likedIdsToRemove.add(productId);
      }
    });
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false); 
      }
    } catch (e) {
      _showSnackbar('Gagal melakukan logout: $e');
    }
  }

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

                try {
                  await _userService.updateNoWhatsapp(
                    currentUserId,
                    waController.text.trim(),
                  );
                  _showSnackbar('Nomor WhatsApp berhasil diperbarui!');
                } catch (e) {
                  _showSnackbar('Gagal memperbarui No. WA: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

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

  Future<void> _pickImage(ImageSource source, String currentUserId) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      if (!mounted) return;
      _showSnackbar('Memulai proses upload foto...');

      try {
        final String downloadURL = await _userService.uploadProfilePhoto(
          currentUserId,
          pickedFile.path,
        );

        await _userService.updateProfilePhotoUrl(
          currentUserId,
          downloadURL,
        );

        if (!mounted) return;
        _showSnackbar('Foto Profil berhasil diperbarui!');

      } catch (e) {
        if (!mounted) return;
        _showSnackbar('Gagal upload atau simpan URL: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      key: _scaffoldKey,
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
                    final List<String> likedProducts = user.liked_products ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeaderWidget(
                          nama: user.nama_lengkap,
                          email: user.email,
                          nim: user.nim,
                          fakultas: user.fakultas,
                          jurusan: user.jurusan,
                          no_whatsapp: user.no_whatsapp,
                          photoUrl: user.photoUrl,
                          onEditWaTap: _showEditWaDialog,
                          onEditPhotoTap: () => _showImageSourcePicker(currentUserId),
                        ),

                        const Divider(height: 1, thickness: 1, color: Colors.grey),

                        // Mengirim ID produk dari stream
                        _buildLikedProductsSection(context, likedProducts),
                      ],
                    );
                  }

                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Data profil tidak ditemukan.'),
                  ));
                },
              ),

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

  Widget _buildLikedProductsSection(BuildContext context, List<String> likedIdsFromStream) {

    // Daftar ID yang akan dicari detailnya (ID dari stream dikurangi ID yang ditandai untuk dihapus)
    final List<String> currentLikedIdsToDisplay = likedIdsFromStream
        .where((id) => !_likedIdsToRemove.contains(id))
        .toList();

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
                  // Mengirimkan daftar ID ASLI dari stream ke _toggleEditMode
                  onPressed: () => _toggleEditMode(likedIdsFromStream),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    side: BorderSide(color: _isEditing ? Colors.green : Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: Text(
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
          child: StreamBuilder<List<Map<String, dynamic>>>(
            // Mengirim daftar ID yang sudah difilter untuk ditampilkan
            stream: _userService.getLikedProductDetailsStream(currentLikedIdsToDisplay),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<Map<String, dynamic>> products = snapshot.data ?? [];

              if (products.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _isEditing && likedIdsFromStream.isNotEmpty
                          ? "Semua produk disukai telah ditandai untuk dihapus. Klik Simpan untuk konfirmasi."
                          : "Anda belum menyukai produk apa pun.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final productId = product['id'] as String;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ProductCardWidget(product: product),

                      if (_isEditing)
                        Positioned(
                          top: -5,
                          right: 15,
                          child: GestureDetector(
                            onTap: () => _deleteLikedProduct(productId),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
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
              );
            },
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
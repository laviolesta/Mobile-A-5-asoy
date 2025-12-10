import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // PENTING UNTUK CEK PLATFORM WEB
import 'dart:io'; // Digunakan hanya di mobile, tapi harus di-import
import 'dart:typed_data'; // PENTING: Untuk Uint8List
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/product_service.dart';

// Definisi typedef untuk ImageSource yang kompatibel (dynamic bisa File/XFile)
typedef UniversalImageFile = dynamic; 

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final ProductService _productService = ProductService(); 
  
  // === PERBAIKAN: DEKLARASI SEMUA CONTROLLER YANG HILANG ===
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController(); // <-- TAMBAHAN INI!
  final TextEditingController descriptionController = TextEditingController(); // <-- TAMBAHAN INI!
  final TextEditingController addressController = TextEditingController();
  
  String? selectedCategory;

  // State untuk Gambar Universal
  XFile? _selectedXFile; 
  final ImagePicker _picker = ImagePicker(); 
  Uint8List? _imageBytes; // Digunakan untuk preview di web

  final List<String> categories = ['Pakaian', 'ATK', 'Elektronik', 'Lain-lain'];

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // === FUNGSI: MENGAMBIL GAMBAR (UNIVERSAL) ===
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedXFile = pickedFile;
      });
      
      if (kIsWeb) {
        // Hanya di Web, kita perlu memuat bytes untuk ditampilkan
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    }
  }

  // === FUNGSI UTAMA: MENYIMPAN KE FIRESTORE (FINAL) ===
  void _saveProduct() async {
    final priceText = priceController.text.trim();
    
    // --- Validasi Input ---
    if (nameController.text.isEmpty || 
        priceText.isEmpty || 
        selectedCategory == null ||
        addressController.text.isEmpty ||
        _selectedXFile == null) // Cek XFile
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua bidang utama, termasuk foto produk.')),
      );
      return;
    }

    final rawPriceValue = int.tryParse(priceText) ?? 0;
    if (rawPriceValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga harus lebih dari Rp 0.')),
      );
      return;
    }

    final priceString = "Rp ${priceText}/hari";
    final locationPart = addressController.text.split(',').first.trim(); 
    
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menyimpan produk dan mengunggah gambar...'), duration: Duration(seconds: 3)),
    );

    // --- Penentuan Tipe Gambar Berdasarkan Platform ---
    final UniversalImageFile imageToSend;
    
    if (kIsWeb) {
      // Kirim XFile (yang bisa di-handle oleh Firebase Storage SDK) di web
      imageToSend = _selectedXFile; 
    } else {
      // Kirim File (dari dart:io) di mobile/desktop
      imageToSend = File(_selectedXFile!.path);
    }

    // --- Panggilan Service ---
    final errorMessage = await _productService.createProduct(
      name: nameController.text.trim(),
      price: priceString, 
      rawPrice: rawPriceValue,
      category: selectedCategory!,
      description: descriptionController.text.trim(),
      location: locationPart, 
      address: addressController.text.trim(),
      imageFile: imageToSend, 
    );

    // --- Tanggapan Hasil ---
    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk "${nameController.text}" berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // === FUNGSI: MENGAMBIL LOKASI REAL-TIME (Tidak Berubah) ===
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan lokasi dinonaktifkan. Mohon aktifkan GPS Anda.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak. Tidak dapat mengambil lokasi.')),
        );
        return;
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mengambil lokasi real-time...')),
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        final fullAddress = [
          place.subAdministrativeArea, 
          place.subLocality,           
          place.street,                
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        setState(() {
          addressController.text = fullAddress;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi real-time berhasil dimuat!'), backgroundColor: Colors.green),
        );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menemukan alamat dari koordinat.'), backgroundColor: Colors.orange),
        );
      }
      
    } catch (e) {
      debugPrint("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error saat mengambil lokasi: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double balancingSpaceWidth = 48.0 + 8.0; 
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // === AREA HEADER ===
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Buat Produk untuk Disewakan",
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: balancingSpaceWidth),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Nama Produk ---
                    const Text("Nama Produk"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Foto Produk (WIDGET PERBAIKAN UNIVERSAL) ---
                    const Text("Foto Produk"),
                    const SizedBox(height: 8),
                    GestureDetector( 
                      onTap: _pickImage, 
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: _selectedXFile != null
                            ? Builder( 
                                builder: (context) {
                                  if (kIsWeb && _imageBytes != null) {
                                    // Tampilkan dari bytes di web
                                    return Image.memory(
                                      _imageBytes!, 
                                      fit: BoxFit.cover,
                                    );
                                  } else if (!kIsWeb && _selectedXFile != null) {
                                    // Tampilkan dari File di mobile/desktop
                                    return Image.file(
                                        File(_selectedXFile!.path), 
                                        fit: BoxFit.cover,
                                    );
                                  }
                                  return const Center(child: Icon(Icons.add_a_photo, size: 30, color: Colors.grey));
                                }
                              )
                            : const Center(
                                child: Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // --- Kategori Produk ---
                    const Text("Kategori Produk"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      value: selectedCategory,
                      hint: const Text("Pilih Kategori"),
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Harga yang disewakan/hari ---
                    const Text("Harga yang disewakan/hari"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController, // <-- CONTROLLER DIGUNAKAN
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: "Rp ",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Deskripsi Produk ---
                    const Text("Deskripsi Produk"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController, // <-- CONTROLLER DIGUNAKAN
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: "Deskripsikan produk yang kamu sewakan dengan jujur",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Alamat ---
                    const Text("Alamat"),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.location_on, color: Color(0xFF205781)),
                      label: const Text(
                        "Gunakan lokasi saat ini",
                        style: TextStyle(color: Color(0xFF205781)),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Color(0xFF205781)),
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        hintText: "Kabupaten, Kecamatan, Nama Jalan",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // --- Tombol Simpan ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF205781),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Simpan", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
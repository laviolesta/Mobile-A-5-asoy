import 'package:flutter/material.dart';
// import '../../widgets/header_widget.dart'; // Dihapus karena akan dibuat inline

// Contoh data produk yang akan diedit
const Map<String, dynamic> dummyProductToEdit = {
  "name": "Almamater Unhas",
  "price": "3.000",
  "category": "Pakaian",
  "description": "Almamater Unhas adalah almamater yang digunakan oleh Universitas Hasanuddin. Ukuran almamaternya adalah L. Kondisi almamater masih bagus.",
  "address": "Gowa, Bontomarannu, Jl. Kelapa",
  "image_path": "assets/almamater.png", // Asumsi path gambar
};

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  // Menerima data produk yang akan diedit
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late String selectedCategory;

  final List<String> categories = ['Pakaian', 'ATK', 'Elektronik', 'Lain-lain'];

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data produk yang masuk
    nameController = TextEditingController(text: widget.product["name"]);
    priceController = TextEditingController(text: widget.product["price"]);
    descriptionController = TextEditingController(text: widget.product["description"]);
    addressController = TextEditingController(text: widget.product["address"]);
    selectedCategory = widget.product["category"];
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Logika untuk menyimpan perubahan produk
    if (nameController.text.isEmpty || priceController.text.isEmpty || selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua bidang utama.')),
      );
      return;
    }

    // Tampilkan notifikasi berhasil (simulasi)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produk "${nameController.text}" berhasil diperbarui!')),
    );
    
    // Kembali ke halaman sebelumnya (misal: SewakanPage)
    Navigator.pop(context);
  }

  // Simulasi pengambilan lokasi saat ini
  void _getCurrentLocation() {
    addressController.text = "Gowa, Bonto Marannu, Jl. Kelapa (Lokasi Baru)"; // Contoh lokasi baru
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lokasi saat ini dimuat.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lebar yang harus diseimbangkan (IconButton default width + padding)
    const double balancingSpaceWidth = 48.0 + 8.0; 

    return Scaffold(
      // Bungkus dengan SafeArea agar header tidak tertutup status bar
      body: SafeArea(
        child: Column(
          children: [
            // === AREA HEADER DIBUAT INLINE ===
            Padding(
              padding: const EdgeInsets.only(left: 8.0), // Padding di kiri untuk IconButton
              child: Row(
                children: [
                  // 1. Tombol Kembali
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); // Navigasi kembali
                    },
                  ),
                  
                  // 2. Judul (Di Tengah)
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Edit Produk",
                        style: TextStyle(
                          fontSize: 20, // Sesuaikan ukuran font sesuai desain HeaderWidget lama
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // 3. Spacer Kosong (Di Kanan) - Untuk menyeimbangkan Tombol Kembali
                  const SizedBox(width: balancingSpaceWidth),
                ],
              ),
            ),
            // =========================================
            
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

                    // --- Foto Produk ---
                    const Text("Foto Produk"),
                    const SizedBox(height: 8),
                    // Menampilkan gambar yang sudah ada (simulasi)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: widget.product["image_path"] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              // Hanya menggunakan Icon sebagai placeholder karena path asset tidak tersedia
                              child: const Center(child: Icon(Icons.photo, size: 40, color: Colors.brown)),
                            )
                          : const Center(
                              child: Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
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
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Harga yang disewakan/hari ---
                    const Text("Harga yang disewakan/hari"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
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
                      controller: descriptionController,
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
                        onPressed: _saveChanges,
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
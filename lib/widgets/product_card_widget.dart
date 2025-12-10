import 'package:flutter/material.dart';

class ProductCardWidget extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Catatan: Ini adalah placeholder untuk gambar
    return Container(
      width: 150, // Lebar kartu produk
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk (Placeholder)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Warna placeholder
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
              // Ganti dengan Image.asset atau Image.network jika sudah ada gambar
            ),
            child: Center(
              child: product['name'] == 'Jas Hitam' 
                ? const Icon(Icons.checkroom, size: 50, color: Colors.black)
                : const Icon(Icons.checkroom, size: 50, color: Colors.white),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Produk
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Harga
                Text(
                  product['price'],
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                // Lokasi
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      product['location'],
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Rating dan Disukai
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${product['rating']} • ${product['reviews']} tersewa',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    
                    // Jumlah Disukai
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 12, color: Colors.red),
                        Text(
                          '${product['likes']}',
                          style: const TextStyle(fontSize: 10, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
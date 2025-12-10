import 'package:flutter/material.dart';

class RatingUlasanPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const RatingUlasanPage({super.key, required this.product});

  @override
  State<RatingUlasanPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingUlasanPage> {
  double rating = 4.5;
  final TextEditingController reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProductCard(),
                    const SizedBox(height: 20),

                    _buildRatingRow(),
                    const SizedBox(height: 12),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Tulis ulasan minimal 50 karakter",
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildReviewBox(),
                    const SizedBox(height: 28),

                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 45, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 26, color: Colors.black87),
          ),
          const SizedBox(width: 16),
          const Text(
            "Penilaian Saya",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    final item = widget.product;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 70,
              height: 70,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 40),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(item["price"], style: const TextStyle(fontSize: 13, color: Colors.black54)),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 13, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(item["location"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          const Icon(Icons.favorite, color: Colors.red, size: 22)
        ],
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Beri Nilai", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),

        Row(
          children: List.generate(5, (index) {
            double starValue = index + 1;
            return GestureDetector(
              onTap: () => setState(() => rating = starValue.toDouble()),
              child: Icon(
                starValue <= rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28,
              ),
            );
          }),
        )
      ],
    );
  }

  Widget _buildReviewBox() {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2F2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: reviewController,
        maxLines: null,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Tulis ulasan Anda di sini...",
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: 200,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          if (reviewController.text.length < 50) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ulasan minimal 50 karakter!")),
            );
            return;
          }

          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C6CAE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Kirim",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

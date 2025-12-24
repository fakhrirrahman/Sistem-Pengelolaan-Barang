// lib/Models/food_product.dart

class FoodProduct {
  final String id;
  final String name;
  final String imagePath;
  final String category;
  final double price;
  final String description;
  final bool isAvailable;

  FoodProduct({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.price,
    required this.description,
    this.isAvailable = true,
  });

  // Daftar produk bahan makanan contoh
  static List<FoodProduct> getSampleProducts() {
    return [
      FoodProduct(
        id: '1',
        name: 'Beras Premium',
        imagePath: 'assets/images/beras.jpg',
        category: 'Serealia',
        price: 25000,
        description: 'Beras premium berkualitas tinggi',
      ),
      FoodProduct(
        id: '2',
        name: 'Wortel Segar',
        imagePath: 'assets/images/wortel.jpg',
        category: 'Sayuran',
        price: 15000,
        description: 'Wortel segar dari kebun lokal',
      ),
      FoodProduct(
        id: '3',
        name: 'Daging Sapi',
        imagePath: 'assets/images/daging_sapi.jpg',
        category: 'Daging',
        price: 120000,
        description: 'Daging sapi segar pilihan',
      ),
      FoodProduct(
        id: '4',
        name: 'Tomat Merah',
        imagePath: 'assets/images/tomat.jpg',
        category: 'Sayuran',
        price: 8000,
        description: 'Tomat merah segar dan manis',
      ),
      FoodProduct(
        id: '5',
        name: 'Ikan Salmon',
        imagePath: 'assets/images/salmon.jpg',
        category: 'Ikan',
        price: 180000,
        description: 'Ikan salmon segar impor',
      ),
      FoodProduct(
        id: '6',
        name: 'Kentang',
        imagePath: 'assets/images/kentang.jpg',
        category: 'Umbi-umbian',
        price: 12000,
        description: 'Kentang segar untuk berbagai masakan',
      ),
      FoodProduct(
        id: '7',
        name: 'Bawang Merah',
        imagePath: 'assets/images/bawang_merah.jpg',
        category: 'Bumbu',
        price: 20000,
        description: 'Bawang merah segar untuk bumbu masakan',
      ),
      FoodProduct(
        id: '8',
        name: 'Cabai Merah',
        imagePath: 'assets/images/cabai.jpg',
        category: 'Bumbu',
        price: 25000,
        description: 'Cabai merah pedas segar',
      ),
    ];
  }
}

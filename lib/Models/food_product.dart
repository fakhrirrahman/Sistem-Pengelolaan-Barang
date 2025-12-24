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

  factory FoodProduct.fromMap(Map<String, dynamic> map, String id) {
    return FoodProduct(
      id: id,
      name: map['name'] ?? '',
      imagePath: map['imagePath'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] is int) ? (map['price'] as int).toDouble() : (map['price'] ?? 0.0),
      description: map['description'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  static List<FoodProduct> getSampleProducts() {
    return [
      FoodProduct(
        id: '1',
        name: 'Nasi Goreng',
        imagePath: 'assets/images/beras.jpg',
        category: 'Makanan Utama',
        price: 15000,
        description: 'Nasi goreng spesial dengan telur dan ayam.',
        isAvailable: true,
      ),
      FoodProduct(
        id: '2',
        name: 'Ayam Bakar',
        imagePath: 'assets/images/daging_sapi.jpg',
        category: 'Makanan Utama',
        price: 20000,
        description: 'Ayam bakar dengan bumbu rempah.',
        isAvailable: true,
      ),
      FoodProduct(
        id: '3',
        name: 'Sayur Bayam',
        imagePath: 'assets/images/wortel.jpg',
        category: 'Sayuran',
        price: 5000,
        description: 'Sayur bayam segar.',
        isAvailable: false,
      ),
      FoodProduct(
        id: '4',
        name: 'Jus Jeruk',
        imagePath: 'assets/images/cabai.jpg',
        category: 'Minuman',
        price: 8000,
        description: 'Jus jeruk segar tanpa gula.',
        isAvailable: true,
      ),
    ];
  }
}
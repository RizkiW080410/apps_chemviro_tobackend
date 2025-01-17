class Product {
  final String name;
  final String categoryProduct;
  final String category;
  final String price; // Tidak nullable, dengan default
  final int? priceId;

  Product({
    required this.name,
    required this.categoryProduct,
    required this.category,
    this.price = "0", // Default value jika null
    this.priceId,
  });

  // Factory untuk membuat instance Product dari JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? 'Unknown', // Fallback jika null
      categoryProduct: json['category_product'] ?? 'Unknown Category',
      category: json['category'] ?? 'Unknown',
      price: json['price_product']?['price'] ?? "0", // Default jika null
      priceId: json['price_product']?['id'], // Bisa null
    );
  }
}

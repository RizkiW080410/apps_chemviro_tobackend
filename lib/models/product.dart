class Product {
  final String name;
  final String categoryProduct;
  final String category;
  final String? price;
  final int? priceId;

  Product({
    required this.name,
    required this.categoryProduct,
    required this.category,
    this.price,
    this.priceId,
  });

  // Factory untuk membuat instance Product dari JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      categoryProduct: json['category_product'],
      category: json['category'],
      price: json['price_product']?['price'], // Ambil harga dari price_product
      priceId: json['price_product']?['id'], // Ambil ID dari price_product
    );
  }
}

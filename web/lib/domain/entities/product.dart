class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  final String? description;
  bool favorite;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.description,
    this.favorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'image': image,
    };
  }
}
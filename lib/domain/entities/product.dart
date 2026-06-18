class Product {
  final int id;
  final String title;
  final double price;
  final String image; // sempre "image" na entidade, independente da API
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

  /// fromJson usado somente para desserialização do cache local,
  /// onde o campo já foi salvo como "image".
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'image': image,
    };
  }
}

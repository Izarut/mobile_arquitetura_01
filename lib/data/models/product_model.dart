import 'package:product_app/domain/entities/product.dart';

class ProductModel {
  final int id;
  final String title;
  final double price;
  final String image; // internamente mantemos "image" como nome do campo
  final String? description;
  bool favorite;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.description,
    this.favorite = false,
  });

  /// Cria um ProductModel a partir do JSON da DummyJSON.
  /// A API retorna o campo de imagem como "thumbnail".
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['thumbnail'] as String, // DummyJSON usa "thumbnail"
      description: json['description'] as String?,
    );
  }

  /// Converte uma entidade de domínio para model (usado ao salvar no cache).
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      title: product.title,
      price: product.price,
      image: product.image,
      description: product.description,
      favorite: product.favorite,
    );
  }

  /// Converte o model de volta para entidade de domínio.
  Product toEntity() {
    return Product(
      id: id,
      title: title,
      price: price,
      image: image,
      description: description,
      favorite: favorite,
    );
  }

  /// Serialização para cache local (mantém "image" como chave interna).
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

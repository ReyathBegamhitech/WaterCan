class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String shopName;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.shopName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'shopName': shopName,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Product',
        price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
        imageUrl: json['imageUrl']?.toString() ?? '',
        shopName: json['shopName']?.toString() ?? '',
      );
}

class CartItem {
  final ProductModel product;
  final int quantity;
  final int? returnEmptyCans;

  CartItem({
    required this.product,
    required this.quantity,
    this.returnEmptyCans,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
        'returnEmptyCans': returnEmptyCans,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: ProductModel.fromJson(json['product'] as Map<String, dynamic>? ?? {}),
        quantity: json['quantity'] != null ? int.tryParse(json['quantity'].toString()) ?? 1 : 1,
        returnEmptyCans: json['returnEmptyCans'] != null ? int.tryParse(json['returnEmptyCans'].toString()) : null,
      );
}

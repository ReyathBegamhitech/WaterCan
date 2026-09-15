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
        id: json['id'],
        name: json['name'],
        price: json['price'],
        imageUrl: json['imageUrl'],
        shopName: json['shopName'],
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
        product: ProductModel.fromJson(json['product']),
        quantity: json['quantity'],
        returnEmptyCans: json['returnEmptyCans'],
      );
}

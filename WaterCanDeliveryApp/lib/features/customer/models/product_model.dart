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
}

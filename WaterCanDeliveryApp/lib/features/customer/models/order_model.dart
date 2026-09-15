import 'product_model.dart';

enum OrderStatus {
  placed,
  accepted,
  preparing,
  outForDelivery,
  delivered,
  cancelled
}

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime timestamp;
  final String paymentMethod;
  OrderStatus status;
  final String? shopName;
  final String deliveryAddress;
  final String? customerName;
  final String? customerPhone;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
    required this.paymentMethod,
    this.status = OrderStatus.placed,
    this.shopName,
    this.deliveryAddress = '',
    this.customerName,
    this.customerPhone,
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  double get pricePerUnit => totalQuantity > 0 ? (totalAmount / totalQuantity) : totalAmount;

  String get sellerStatusString {
    switch (status) {
      case OrderStatus.placed: return 'Placed';
      case OrderStatus.accepted: return 'Accepted';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  Map<String, dynamic> toSellerOrderMap() {
    return {
      'orderId': id.startsWith('#') ? id : '#$id',
      'time': formattedDate,
      'status': sellerStatusString,
      'buyerName': customerName?.isNotEmpty == true ? customerName! : 'Customer',
      'buyerPhone': customerPhone?.isNotEmpty == true ? customerPhone! : 'Not provided',
      'quantity': totalQuantity > 0 ? totalQuantity : 1,
      'pricePerCan': pricePerUnit.round(),
      'deliveryAddress': deliveryAddress,
      'rawId': id,
    };
  }

  Map<String, dynamic> toSellerHistoryMap() {
    return {
      'orderId': id.startsWith('#') ? id : '#$id',
      'time': formattedDate,
      'status': sellerStatusString,
      'buyerName': customerName?.isNotEmpty == true ? customerName! : 'Customer',
      'buyerPhone': customerPhone?.isNotEmpty == true ? customerPhone! : 'Not provided',
      'amount': totalAmount.round(),
      'address': deliveryAddress.isNotEmpty ? deliveryAddress : 'No address provided',
      'rawId': id,
    };
  }

  String get formattedDate {
    // Simple formatter for our UI
    final today = DateTime.now();
    if (timestamp.day == today.day && timestamp.month == today.month && timestamp.year == today.year) {
      return 'Today, ${timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.hour >= 12 ? 'PM' : 'AM'}';
    }
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String get summaryText {
    if (items.isEmpty) return 'No items';
    if (items.length == 1) {
      return '${items.first.quantity}x ${items.first.product.name}';
    }
    return '${items.length} Items';
  }

  String get statusText {
    switch (status) {
      case OrderStatus.placed: return 'Order Placed';
      case OrderStatus.accepted: return 'Accepted';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
}

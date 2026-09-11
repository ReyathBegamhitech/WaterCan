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

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
    required this.paymentMethod,
    this.status = OrderStatus.placed,
    this.shopName,
    this.deliveryAddress = 'Flat 402, Lotus Heights, Outer Ring Road, Bellandur, Bengaluru • 560103',
  });

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

import 'product_model.dart';

enum OrderStatus {
  placed,
  accepted,
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
  final double? latitude;
  final double? longitude;
  final String? customerName;
  final String? customerPhone;
  final bool isFastDelivery;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
    required this.paymentMethod,
    this.status = OrderStatus.placed,
    this.shopName,
    this.deliveryAddress = '',
    this.latitude,
    this.longitude,
    this.customerName,
    this.customerPhone,
    this.isFastDelivery = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((i) => i.toJson()).toList(),
        'totalAmount': totalAmount,
        'timestamp': timestamp.toIso8601String(),
        'paymentMethod': paymentMethod,
        'status': status.index,
        'shopName': shopName,
        'deliveryAddress': deliveryAddress,
        'latitude': latitude,
        'longitude': longitude,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'is_fast_delivery': isFastDelivery,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'],
        items: (json['items'] as List).map((i) => CartItem.fromJson(i)).toList(),
        totalAmount: json['totalAmount'],
        timestamp: DateTime.parse(json['timestamp']).toLocal(),
        paymentMethod: json['paymentMethod'],
        status: OrderStatus.values[json['status'] ?? 0],
        shopName: json['shopName'],
        deliveryAddress: json['deliveryAddress'] ?? '',
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        customerName: json['customerName'] ?? json['buyer_name'],
        customerPhone: json['customerPhone'] ?? json['buyer_phone'],
        isFastDelivery: json['is_fast_delivery'] ?? json['isFastDelivery'] ?? false,
      );

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  double get pricePerUnit => totalQuantity > 0 ? (totalAmount / totalQuantity) : totalAmount;

  String get sellerStatusString {
    switch (status) {
      case OrderStatus.placed: return 'Placed';
      case OrderStatus.accepted: return 'Accepted';
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
      'latitude': latitude,
      'longitude': longitude,
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
      'latitude': latitude,
      'longitude': longitude,
      'isFastDelivery': isFastDelivery,
      'rawId': id,
    };
  }

  String get formattedDate {
    // Simple formatter for our UI
    final today = DateTime.now();
    if (timestamp.day == today.day && timestamp.month == today.month && timestamp.year == today.year) {
      int hour = timestamp.hour;
      String amPm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return 'Today, $hour:${timestamp.minute.toString().padLeft(2, '0')} $amPm';
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
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
}

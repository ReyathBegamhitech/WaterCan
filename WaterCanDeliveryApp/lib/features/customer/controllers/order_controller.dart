import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderController extends ChangeNotifier {
  // Pre-filled mock data so the UI still looks beautiful immediately
  final List<OrderModel> _orders = [
    // Completed
    OrderModel(
      id: 'ORD-97420',
      items: [
        CartItem(
          quantity: 2,
          product: ProductModel(
            id: 'p1',
            name: '25L Refill Can',
            price: 50,
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtFDY8L4f3JKhamQcGZaXg9fa3RstoZchc3JyiqdlCNdnoRt3Qcx-nqXK6C8KSNnLdAVkSLH0Khz0Gjfs1iqcSazsbdqrIdHyiCWDlN5zWyCoyjQQNDczOhlThRGzp_LzSDQ2Nz09alZY_AGfZsVC0LmgNveXjKZNx4OlCrdScsnSvLD289zYwQg2zj4qj6ZKYCIih2Z3FCEpQ8gCVbVwBXNMvyme2fFUzskpD8cCUrBVLis1pbaR2',
            shopName: 'Blue Drop Water Co.',
          ),
        )
      ],
      totalAmount: 100,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      paymentMethod: 'upi',
      status: OrderStatus.delivered,
      shopName: 'Blue Drop Water Co.',
    ),
    // Cancelled
    OrderModel(
      id: 'ORD-95112',
      items: [
        CartItem(
          quantity: 1,
          product: ProductModel(
            id: 'p2',
            name: '20L RO Purified Water Can',
            price: 45,
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCdgL5IALKwRiltkZqoDMPcUa05FP4rMG9v-qW6t8D4_zGjCmXjT3G-9136bYs4gNs1gwqj4Jhu8tKzSN5lYDggj7q8OWb9wN8ZYR_Zq3MeXiRtfI4B-j4OH1vu_Ytth_s5CS1d66rgOrMPT-yN5sCA4JNi9-gJwvG_UEkRCpHmSmJx6lBK37PXHS0p01SfsVvpKIz5U40POAZZAQnGDXkozBGSxWHHKC5PGnkqtlUcBdulK-w9xpi_',
            shopName: 'Unknown',
          ),
        )
      ],
      totalAmount: 45,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      paymentMethod: 'upi',
      status: OrderStatus.cancelled,
    ),
    // Active Preparing
    OrderModel(
      id: 'ORD-98104',
      items: [
        CartItem(
          quantity: 1,
          product: ProductModel(
            id: 'p3',
            name: '20L Copper Infused Water Can',
            price: 75,
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDzda0s1AdHVFefej4AvNZ3Z9ee-PRA9cKqvppjCKWz8CEGZjR-zuZRa90Bpt_-nJ21-KWJOFaHdad6a7J2LcD8m8MRa8RZUPL-iQg7kEabmJfTlTo64sLnkDJf35AjJfcCsEP8498Uc-Ddm27cOrDdXp8xDg-FbGaZFCS9XxjRlxNHJli_yue-EYwKoQu6dQtoKuChRXenxwtM1fYId1PtnBHRWgHOd8w0rdkX78LPlYVLuM26xD1z',
            shopName: 'Blue Drop Water Co.',
          ),
        )
      ],
      totalAmount: 75,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      paymentMethod: 'cod',
      status: OrderStatus.preparing,
      shopName: 'Blue Drop Water Co.',
    ),
  ];

  List<OrderModel> get activeOrders => _orders.where((o) => 
    o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled
  ).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<OrderModel> get completedOrders => _orders.where((o) => 
    o.status == OrderStatus.delivered
  ).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<OrderModel> get cancelledOrders => _orders.where((o) => 
    o.status == OrderStatus.cancelled
  ).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  void placeOrder(OrderModel newOrder) {
    _orders.add(newOrder);
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = OrderStatus.cancelled;
      notifyListeners();
    }
  }

  OrderModel? getOrder(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }
}

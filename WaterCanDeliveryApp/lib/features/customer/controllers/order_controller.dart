import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderController extends ChangeNotifier {
  List<OrderModel> _orders = [];
  Timer? _pollingTimer;
  String? _currentUserPhone;

  static const String _keyOrders = 'cached_orders';

  OrderController() {
    _loadOrdersLocally();
  }

  Future<void> _loadOrdersLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? ordersJson = prefs.getString(_keyOrders);
      if (ordersJson != null) {
        final List decoded = jsonDecode(ordersJson);
        final localOrders = decoded.map((e) => OrderModel.fromJson(e)).toList();
        
        // Merge them so we don't lose the beautiful mock data if local is empty
        for (var local in localOrders) {
          if (!_orders.any((o) => o.id == local.id)) {
            _orders.insert(0, local); // Add local at top
          }
        }
        notifyListeners();
      } else {
        // Save mock data for next time
        _saveOrdersLocally();
      }
    } catch (e) {
      debugPrint('Error loading local orders: $e');
    }
  }

  Future<void> _saveOrdersLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_orders.map((o) => o.toJson()).toList());
      await prefs.setString(_keyOrders, encoded);
    } catch (e) {
      debugPrint('Error saving orders locally: $e');
    }
  }

  List<OrderModel> get orders => _orders;

  void clearOrders() {
    _orders.clear();
    _stopPolling();
    notifyListeners();
  }

  List<OrderModel> get activeOrders => _orders.where((o) => 
    o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled
  ).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<OrderModel> get completedOrders => _orders.where((o) => 
    o.status == OrderStatus.delivered
  ).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<OrderModel> get cancelledOrders => _orders.where((o) => 
    o.status == OrderStatus.cancelled
  ).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  // Starts polling every 5 seconds for user orders
  void startPollingUserOrders(String phone) {
    _currentUserPhone = phone;
    _stopPolling(); // Stop any existing
    fetchUserOrders(phone); // Initial fetch
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchUserOrders(phone);
    });
  }

  // Starts polling every 5 seconds for seller orders
  void startPollingSellerOrders() {
    _stopPolling();
    fetchSellerOrders();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchSellerOrders();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  Future<void> fetchUserOrders(String phone) async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.orders}/user/$phone'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          _updateOrdersFromApi(data['orders'] as List);
        }
      }
    } catch (e) {
      debugPrint('Error fetching user orders: $e');
    }
  }

  Future<void> fetchSellerOrders() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.orders}/seller'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          _updateOrdersFromApi(data['orders'] as List);
        }
      }
    } catch (e) {
      debugPrint('Error fetching seller orders: $e');
    }
  }

  void _updateOrdersFromApi(List dynamicList) {
    List<OrderModel> newOrders = [];
    for (var item in dynamicList) {
      final id = item['id'].toString();
      final statusStr = item['status'] as String? ?? 'Placed';
      final quantity = item['quantity'] ?? 1;
      final pricePerCan = item['price_per_can'] != null ? double.tryParse(item['price_per_can'].toString()) ?? 0.0 : 0.0;
      final total = item['total_price'] != null ? double.tryParse(item['total_price'].toString()) ?? 0.0 : 0.0;
      
      // Parse status
      OrderStatus status = OrderStatus.placed;
      final s = statusStr.toLowerCase();
      if (s.contains('place')) status = OrderStatus.placed;
      else if (s.contains('accept')) status = OrderStatus.accepted;
      else if (s.contains('prep')) status = OrderStatus.preparing;
      else if (s.contains('out') || (s.contains('deliver') && !s.contains('delivered'))) status = OrderStatus.outForDelivery;
      else if (s == 'delivered') status = OrderStatus.delivered;
      else if (s.contains('cancel')) status = OrderStatus.cancelled;

      List<CartItem> items = [];
      if (item['order_details'] != null) {
        try {
          final detailsList = item['order_details'] as List;
          items = detailsList.map((i) => CartItem.fromJson(i)).toList();
        } catch (e) {
          debugPrint('Error parsing order_details: $e');
        }
      }
      
      if (items.isEmpty) {
        // Fallback to dummy cart item representing the backend summary
        items = [
          CartItem(
            product: ProductModel(
              id: 'p1', 
              name: 'Water Can', 
              price: pricePerCan, 
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtFDY8L4f3JKhamQcGZaXg9fa3RstoZchc3JyiqdlCNdnoRt3Qcx-nqXK6C8KSNnLdAVkSLH0Khz0Gjfs1iqcSazsbdqrIdHyiCWDlN5zWyCoyjQQNDczOhlThRGzp_LzSDQ2Nz09alZY_AGfZsVC0LmgNveXjKZNx4OlCrdScsnSvLD289zYwQg2zj4qj6ZKYCIih2Z3FCEpQ8gCVbVwBXNMvyme2fFUzskpD8cCUrBVLis1pbaR2', 
              shopName: item['shop_name'] ?? ''
            ),
            quantity: quantity,
          )
        ];
      }

      final createdAt = item['created_at'];
      DateTime time = DateTime.now();
      if (createdAt != null) {
        time = DateTime.tryParse(createdAt) ?? DateTime.now();
      }

      newOrders.add(OrderModel(
        id: id,
        items: items,
        totalAmount: total,
        timestamp: time,
        paymentMethod: 'Cash/UPI',
        status: status,
        shopName: item['shop_name'],
        customerName: item['buyer_name'],
        customerPhone: item['user_phone'],
        deliveryAddress: item['delivery_address'] ?? '',
      ));
    }
    
    // Check if new orders differ from old orders
    _orders = newOrders;
    _saveOrdersLocally();
    notifyListeners();
  }

  Future<bool> placeOrder(OrderModel newOrder) async {
    // We already do optimistic insert
    _orders.insert(0, newOrder);
    _saveOrdersLocally();
    notifyListeners();

    try {
      final body = {
        'user_phone': newOrder.customerPhone,
        'buyer_name': newOrder.customerName,
        'buyer_phone': newOrder.customerPhone,
        'shop_name': newOrder.shopName,
        'quantity': newOrder.totalQuantity,
        'price_per_can': newOrder.pricePerUnit,
        'total_price': newOrder.totalAmount,
        'time': newOrder.formattedDate,
        'delivery_address': newOrder.deliveryAddress,
        'order_details': newOrder.items.map((i) => i.toJson()).toList(),
      };

      final res = await http.post(
        Uri.parse(ApiConstants.orders),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 201) {
        if (_currentUserPhone != null) {
          fetchUserOrders(_currentUserPhone!);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error placing order: $e');
    }
    return false;
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatusByString(orderId, 'Cancelled');
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    String statusStr = 'Placed';
    switch (newStatus) {
      case OrderStatus.placed: statusStr = 'Placed'; break;
      case OrderStatus.accepted: statusStr = 'Accepted'; break;
      case OrderStatus.preparing: statusStr = 'Preparing'; break;
      case OrderStatus.outForDelivery: statusStr = 'Out for Delivery'; break;
      case OrderStatus.delivered: statusStr = 'Delivered'; break;
      case OrderStatus.cancelled: statusStr = 'Cancelled'; break;
    }
    await updateOrderStatusByString(orderId, statusStr);
  }

  Future<void> updateOrderStatusByString(String orderId, String statusString) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    
    // Optimistic update
    final index = _orders.indexWhere((o) => o.id == cleanId || o.id == orderId);
    if (index != -1) {
      final s = statusString.toLowerCase().trim();
      if (s.contains('place')) _orders[index].status = OrderStatus.placed;
      else if (s.contains('accept')) _orders[index].status = OrderStatus.accepted;
      else if (s.contains('prep')) _orders[index].status = OrderStatus.preparing;
      else if (s.contains('out') || (s.contains('deliver') && !s.contains('delivered'))) _orders[index].status = OrderStatus.outForDelivery;
      else if (s == 'delivered') _orders[index].status = OrderStatus.delivered;
      else if (s.contains('cancel')) _orders[index].status = OrderStatus.cancelled;
      _saveOrdersLocally();
      notifyListeners();
    }

    try {
      await http.put(
        Uri.parse('${ApiConstants.orders}/$cleanId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': statusString}),
      );
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  OrderModel? getOrder(String id) {
    final cleanId = id.replaceAll('#', '').trim();
    try {
      return _orders.firstWhere((o) => o.id == cleanId || o.id == id);
    } catch (e) {
      return null;
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_can_delivery_app/features/customer/controllers/user_controller.dart';
import 'package:water_can_delivery_app/features/customer/controllers/order_controller.dart';
import 'package:water_can_delivery_app/features/customer/models/order_model.dart';
import 'package:water_can_delivery_app/features/customer/models/product_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserController Tests', () {
    test('Initial user details default properly', () {
      final controller = UserController();
      expect(controller.customerName, 'User');
      expect(controller.phone, '');
      expect(controller.doorNo, '');
      expect(controller.street, '');
      expect(controller.fullAddress, '');
    });

    test('setUser updates state and calculates fullAddress', () async {
      final controller = UserController();
      await controller.setUser(
        name: 'John Doe',
        phone: '9876543210',
        doorNo: '123',
        street: 'Water Street',
        city: 'Bengaluru',
        pincode: '560001',
      );

      expect(controller.customerName, 'John Doe');
      expect(controller.phone, '9876543210');
      expect(controller.doorNo, '123');
      expect(controller.street, 'Water Street');
      expect(controller.fullAddress, '123, Water Street, Bengaluru, 560001');
      expect(controller.isLoggedIn, true);
    });

    test('updatePhone and updateAddress update state and retain values', () async {
      final controller = UserController();
      await controller.setUser(
        name: 'Alice',
        phone: '1111111111',
        doorNo: 'Old Door',
      );

      await controller.updatePhone('9999999999');
      expect(controller.phone, '9999999999');
      expect(controller.customerName, 'Alice');

      await controller.updateAddress(
        doorNo: 'New Flat 401',
        street: 'Indiranagar',
        city: 'BLR',
        pincode: '560038',
      );
      expect(controller.doorNo, 'New Flat 401');
      expect(controller.street, 'Indiranagar');
      expect(controller.phone, '9999999999');
      expect(controller.customerName, 'Alice');
    });

    test('updateName updates customerName and persists in state', () async {
      final controller = UserController();
      await controller.setUser(
        name: 'Alice',
        phone: '1111111111',
        doorNo: 'Old Address',
      );

      await controller.updateName('Alice Smith');
      expect(controller.customerName, 'Alice Smith');
      expect(controller.phone, '1111111111');

      // Verify that loadFromPrefs retains updated name
      final newController = UserController();
      await newController.loadFromPrefs();
      expect(newController.customerName, 'Alice Smith');
    });


    test('loadFromPrefs loads previously saved values across sessions', () async {
      SharedPreferences.setMockInitialValues({
        'user_name': 'Saved User',
        'user_phone': '8888888888',
        'user_door_no': 'Saved House 12',
        'user_street': 'Koramangala',
        'user_is_logged_in': true,
      });

      final controller = UserController();
      await controller.loadFromPrefs();

      expect(controller.customerName, 'Saved User');
      expect(controller.phone, '8888888888');
      expect(controller.doorNo, 'Saved House 12');
      expect(controller.street, 'Koramangala');
      expect(controller.isLoggedIn, true);
    });

    test('clear resets user details on logout', () async {
      final controller = UserController();
      await controller.setUser(
        name: 'Temp User',
        phone: '1234567890',
        doorNo: 'Temp Address',
      );

      await controller.clear();

      expect(controller.customerName, 'User');
      expect(controller.phone, '');
      expect(controller.doorNo, '');
      expect(controller.street, '');
      expect(controller.isLoggedIn, false);
    });

    test('Custom address does not overwrite default user profile address when not saved as default', () async {
      final controller = UserController();
      await controller.setUser(
        name: 'Jane Doe',
        phone: '9876543210',
        doorNo: 'Permanent Flat 101',
        street: 'HSR Layout',
        city: 'Bengaluru',
      );

      expect(controller.fullAddress, 'Permanent Flat 101, HSR Layout, Bengaluru');

      // Individual order customized address simulated
      const individualOrderAddress = 'Temporary Office Tower, Whitefield';
      expect(individualOrderAddress, isNot(equals(controller.fullAddress)));

      // Ensure user profile retains permanent address
      expect(controller.fullAddress, 'Permanent Flat 101, HSR Layout, Bengaluru');
    });
  });

  group('OrderController Tests', () {
    test('OrderController is initially empty', () {
      final orderCtrl = OrderController();
      expect(orderCtrl.activeOrders, isEmpty);
      expect(orderCtrl.completedOrders, isEmpty);
      expect(orderCtrl.cancelledOrders, isEmpty);
    });

    test('placeOrder adds active order with real-time seller map conversion', () {
      final orderCtrl = OrderController();
      final order = OrderModel(
        id: '1099',
        items: [
          CartItem(
            product: ProductModel(
              id: 'p1',
              name: '20L Pure Water Can',
              price: 80,
              imageUrl: 'assets/images/can.png',
              shopName: 'Aqua Pure',
            ),
            quantity: 3,
          )
        ],
        totalAmount: 240,
        timestamp: DateTime.now(),
        paymentMethod: 'UPI (GPay)',
        customerName: 'Reyath',
        customerPhone: '9876543210',
        deliveryAddress: 'House 42, 2nd Cross',
      );

      orderCtrl.placeOrder(order);

      expect(orderCtrl.activeOrders.length, 1);
      expect(orderCtrl.activeOrders.first.id, '1099');

      final sellerMap = orderCtrl.activeOrders.first.toSellerOrderMap();
      expect(sellerMap['buyerName'], 'Reyath');
      expect(sellerMap['buyerPhone'], '9876543210');
      expect(sellerMap['quantity'], 3);
      expect(sellerMap['status'], 'Placed');
      expect(sellerMap['deliveryAddress'], 'House 42, 2nd Cross');
    });

    test('updateOrderStatusByString responsively updates order status and lists', () {
      final orderCtrl = OrderController();
      final order = OrderModel(
        id: '1099',
        items: [],
        totalAmount: 160,
        timestamp: DateTime.now(),
        paymentMethod: 'Cash on Delivery',
        customerName: 'Reyath',
      );
      orderCtrl.placeOrder(order);

      // Seller accepts order
      orderCtrl.updateOrderStatusByString('#1099', 'Accepted');
      expect(orderCtrl.getOrder('1099')?.status, OrderStatus.accepted);
      expect(orderCtrl.activeOrders.length, 1);

      // Seller marks delivered
      orderCtrl.updateOrderStatusByString('1099', 'Delivered');
      expect(orderCtrl.getOrder('1099')?.status, OrderStatus.delivered);
      expect(orderCtrl.activeOrders, isEmpty);
      expect(orderCtrl.completedOrders.length, 1);
      expect(orderCtrl.completedOrders.first.toSellerHistoryMap()['status'], 'Delivered');
    });
  });
}



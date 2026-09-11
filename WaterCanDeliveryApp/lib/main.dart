import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/customer/controllers/order_controller.dart';

void main() {
  runApp(const WaterCanDeliveryApp());
}

class WaterCanDeliveryApp extends StatelessWidget {
  const WaterCanDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderController()),
      ],
      child: MaterialApp(
        title: 'Water Can Delivery App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF002DC7)),
          useMaterial3: true,
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

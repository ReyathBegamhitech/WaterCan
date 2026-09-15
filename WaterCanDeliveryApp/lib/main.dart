import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/customer/controllers/order_controller.dart';
import 'features/customer/controllers/user_controller.dart';

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
        ChangeNotifierProvider(create: (_) => UserController()..loadFromPrefs()),
      ],
      child: MaterialApp(
        title: 'Water Can Delivery App',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            ThemeData.light().textTheme,
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

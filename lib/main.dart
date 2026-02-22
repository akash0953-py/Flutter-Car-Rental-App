import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:rent_x/managers/booking_manager.dart';
import 'package:rent_x/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved bookings
  await BookingManager().loadBookings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

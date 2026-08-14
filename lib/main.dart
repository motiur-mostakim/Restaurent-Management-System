import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/dashboard_provider.dart';
import 'provider/waiterProvider.dart';
import 'provider/menu_provider.dart';
import 'provider/booking_provider.dart';
import 'provider/kds_provider.dart';

import 'features/app_root.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WaiterProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => KdsProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Restaurant App',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.orange[50],
        ),
        home: const AppRoot(),
      ),
    );
  }
}

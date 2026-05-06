import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:a_milk_filter/core/theme/app_theme.dart';
import 'package:a_milk_filter/features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise AdMob SDK — must complete before any ad is requested.
  await MobileAds.instance.initialize();

  // Lock to portrait — the split-view UX is portrait-first.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Transparent status bar + navigation bar for edge-to-edge immersion.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MilkFilterApp());
}

class MilkFilterApp extends StatelessWidget {
  const MilkFilterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A Milk Filter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}

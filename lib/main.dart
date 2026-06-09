import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

import 'data/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database authentication service
  await AuthService.init();

  // Force clean landscape or portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set style for systemic system navigation overlay top
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0C0A09),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const SpaceApp());
}

class SpaceApp extends StatelessWidget {
  const SpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "S'PACE PRESTIGE",
      debugShowCheckedModeBanner: false,

      // Royal design theme configuration
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0A09), // stone-950

        // Setup premium Inter typography paired with Playfair Display for headers
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme.copyWith(
                displayLarge: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
                titleLarge: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        ),

        // Colors palette
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC5A153), // Royal Gold
          secondary: Color(0xFF1C1917), // stone-900
          surface: Color(0xFF1C1917),
          onPrimary: Color(0xFF0C0A09),
          onSecondary: Colors.white,
        ),

        // Dropdown selection custom card styles
        cardTheme: CardThemeData(
          color: const Color(0xFF1C1917),
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),

        // Input fields styling
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0C0A09),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF292524)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC5A153), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF292524)),
          ),
          labelStyle: const TextStyle(color: Color(0xFFA8A29E)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

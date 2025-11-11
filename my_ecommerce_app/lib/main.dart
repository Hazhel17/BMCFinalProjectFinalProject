import 'package:my_ecommerce_app/providers/cart_provider.dart';
import 'package:my_ecommerce_app/screens/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Retained but not used in main()
import 'package:google_fonts/google_fonts.dart';

// APP COLOR PALETTE
const Color kForestGreen = Color(0xFF386641);
const Color kMossGreen = Color(0xFF6A994E);
const Color kPaleBeige = Color(0xFFF6F3E6);
const Color kRichBlack = Color(0xFF1D1F24);

Future<void> main() async {
  // 1. Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Run the app with ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final cartProvider = CartProvider();

        // Use your original initialization method or the one from the example,
        // depending on your CartProvider's actual API.
        // Assuming initializeAuthListener is the correct one for your app:
        cartProvider.initializeAuthListener();

        return cartProvider;
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Comics & Manga App', // Kept your title
      theme: ThemeData(
        // Kept your theme data and colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: kForestGreen,
          brightness: Brightness.light,
          primary: kForestGreen,
          onPrimary: Colors.white,
          secondary: kMossGreen,
          background: kPaleBeige,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: kPaleBeige,
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kForestGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          labelStyle: TextStyle(color: kForestGreen.withOpacity(0.8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kForestGreen, width: 2.0),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: kRichBlack,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:sportsdonationapp/src/features/screens/Home_Screen/Categories.dart';
import 'package:sportsdonationapp/src/features/screens/Home_Screen/chat_screen.dart';
import 'package:sportsdonationapp/src/features/screens/Home_Screen/setting.dart';
import 'package:sportsdonationapp/src/features/screens/Login_Register/login_screen.dart';
import 'package:sportsdonationapp/src/features/screens/Notifivation_screen/notification.dart';
import 'package:sportsdonationapp/src/features/screens/on_boarding/onboarding_screen.dart';
import 'package:sportsdonationapp/src/utils/theme/theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

final theme = ThemeData(
  primaryColor: const Color(0xFF00A979),
  scaffoldBackgroundColor: const Color(0xFFCCCCCC), // Background color for scaffolds
  textTheme: GoogleFonts.latoTextTheme(),
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme.copyWith(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading indicator while checking authentication state
          }
          if (snapshot.hasData) {
            return CategoriesScreen(); // User is logged in, show the main screen
          } else {
            return Onbording(); // User is not logged in, show the onboarding screen
          }
        },
      ),
      routes: {
        '/home': (context) => CategoriesScreen(),
        '/chat': (context) => ChatScreen(),
        '/notifications': (context) => NotificationScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

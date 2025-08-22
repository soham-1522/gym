import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soham/SplashScreen.dart';
import 'package:soham/screens/LoginScreen.dart';
import 'package:soham/screens/RegisterScreen.dart';
import 'package:soham/screens/GettingStartedScreen.dart';
import 'package:soham/screens/HomeScreen.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (_) => const GettingStartedScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        // add HomeScreen if needed
      },
    );

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(),
      routes: {
        LoginScreen.routeName: (ctx) => LoginScreen(),
        RegisterScreen.routeName: (ctx) => RegisterScreen(),
      },
        );
    }
}
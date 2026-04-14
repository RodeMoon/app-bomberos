import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_integrador_bomberos/screens/dashboard_screen.dart';
import 'package:proyecto_integrador_bomberos/screens/register_screen.dart';
import 'package:proyecto_integrador_bomberos/screens/login_screen.dart';
import 'package:proyecto_integrador_bomberos/screens/form_screen.dart';
import 'package:proyecto_integrador_bomberos/screens/splash_screen.dart'; // <- NUEVO
import 'package:proyecto_integrador_bomberos/utils/theme.dart';

FirebaseApp? storageApp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  storageApp = await Firebase.initializeApp(
    name: "storageApp",
    options: const FirebaseOptions(
      apiKey: "AIzaSyDZbCu-9Ne4BrNwE2NYor1GJPWcl9L6yXQ",
      appId: "1:975315557479:android:c4b5149b46f18d8e0a48c2",
      messagingSenderId: "975315557479",
      projectId: "alio-8d1bf",
      storageBucket: "alio-8d1bf.appspot.com",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Bomberos',
      home: const SplashScreen(), // <- Pantalla inicial ahora es el splash
      theme: const MaterialTheme(TextTheme()).light(),
      routes: {
        "/login": (context) => const LoginScreen(),
        "/splash": (context) => const SplashScreen(),
        "/home": (context) => const DashboardScreen(),
        "/register": (context) => const RegisterScreen(),
        "/form": (context) => const ReportFormScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:chatify/pages/login_page.dart';
import 'package:chatify/pages/registration_page.dart';
import 'package:flutter/material.dart';
import './services/navigation_service.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatify',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(42, 117, 188, 1),
        scaffoldBackgroundColor: Color.fromRGBO(28, 27, 27, 1),
        colorScheme: ColorScheme.dark(
          primary: Color.fromRGBO(42, 117, 188, 1),
          secondary: Color.fromRGBO(42, 117, 188, 1),
        ),
      ),
      navigatorKey: NavigationService.instance.navigatorKey,
      initialRoute: "login",
      routes: {
        "login": (BuildContext _context) => LoginPage(),
        "register": (BuildContext _context) => RegistrationPage(),
      },
    );
  }
}

import 'package:app_calidad/screens/home.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CalidadApp());

class CalidadApp extends StatelessWidget {
  const CalidadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calidad App',
      initialRoute: '/',
      routes: {'/': (context) => const HomePage(),
      },
      
      // home:  HomePage(),
    );
  }
}

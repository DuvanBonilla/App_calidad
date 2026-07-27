import 'package:app_calidad/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  // Necesario antes de inicializaciones async
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();

  // Iniciar aplicación
  runApp(const CalidadApp());
}

class CalidadApp extends StatelessWidget {
  const CalidadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calidad App',
      initialRoute: '/',
      routes: {'/': (context) => const HomePage()},

      // home:  HomePage(),
    );
  }
}

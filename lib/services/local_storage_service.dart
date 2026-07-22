import 'dart:convert';
import 'package:app_calidad/models/caja_calidad.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _key = "cajas_calidad";
  static const String _keyFotos = 'fotos_generales_calidad';

  /// Guardar cajas
  static Future<void> guardarCajas(List<CajaCalidad> cajas) async {
    final prefs = await SharedPreferences.getInstance();

    final json = cajas.map((e) => e.toJson()).toList();

    await prefs.setString(_key, jsonEncode(json));
  }

  /// Obtener cajas
  static Future<List<CajaCalidad>> obtenerCajas() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_key);

    if (data == null) return [];

    final List<dynamic> json = jsonDecode(data);

    return json.map((e) => CajaCalidad.fromJson(e)).toList();
  }

  /// Limpiar almacenamiento
  static Future<void> limpiarCajas() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }

  //metodo de guardar fotos

  static Future<void> guardarFotosGenerales(List<String> fotos) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_keyFotos, fotos);
  }

  static Future<List<String>> obtenerFotosGenerales() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_keyFotos) ?? [];
  }

  static Future<void> limpiarFotosGenerales() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyFotos);
  }
}

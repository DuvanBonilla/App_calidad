import 'dart:convert';
import 'package:app_calidad/api/config.dart';
import 'package:app_calidad/models/defect.dart.dart';
import 'package:app_calidad/services/defect_cache_service.dart';
import 'package:http/http.dart' as http;

class DefectService {
  static Future<List<Defect>> getDefects() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/api_trazabilidad/api/defectos.php",
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Error HTTP ${response.statusCode}");
      }

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (body["ok"] != true) {
        throw Exception(body["msg"] ?? "Error al consultar defectos.");
      }

      final List<Defect> defectos = (body["data"] as List)
          .map((e) => Defect.fromJson(e))
          .toList();

      // Guardar la última versión recibida
      await DefectCacheService.guardarDefectos(defectos);

      return defectos;
    } catch (e) {
      // Si falla Internet o el servidor,
      // intenta usar la copia local.
      final defectosLocales =
          await DefectCacheService.obtenerDefectos();

      if (defectosLocales.isNotEmpty) {
        return defectosLocales;
      }

      throw Exception(
        "No fue posible obtener los defectos del servidor y no existe una copia local.",
      );
    }
  }
}
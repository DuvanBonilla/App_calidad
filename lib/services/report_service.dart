import 'dart:convert';
import 'package:app_calidad/api/config.dart';
import 'package:http/http.dart' as http;

class ReportService {
  static Future<void> enviarReporte({
    required Map<String, dynamic> datos,
    required List<String> fotos,
  }) async {
    print("===== RUTAS DE LAS FOTOS =====");

    for (final foto in fotos) {
      print(foto);
    }
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
        "${ApiConfig.baseUrl}/api_trazabilidad/api/guardar_reporte.php",
      ),
    );

    // JSON
    request.fields["datos"] = jsonEncode(datos);

    // Fotos
    for (int i = 0; i < fotos.length; i++) {
      request.files.add(await http.MultipartFile.fromPath("foto$i", fotos[i]));
    }

    // DEBUG
    print("=========== JSON ENVIADO ===========");
    print(const JsonEncoder.withIndent("  ").convert(datos));

    print("=========== FOTOS ===========");
    for (final foto in fotos) {
      print(foto);
    }

    final response = await request.send();

    final body = await response.stream.bytesToString();

    print("=========== RESPUESTA DEL SERVIDOR ===========");
    print(body);

    dynamic decoded;

    try {
      decoded = jsonDecode(body);
    } catch (_) {
      throw Exception("El servidor devolvió una respuesta inválida.");
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        "La respuesta del servidor no tiene el formato esperado.",
      );
    }

    final Map<String, dynamic> json = decoded;

    //logs
    if (json["logs"] != null) {
      print("=========== LOGS PHP ===========");

      for (final log in json["logs"]) {
        print(log);
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        json["msg"]?.toString() ?? "Error HTTP ${response.statusCode}",
      );
    }

    if (json["ok"] != true) {
      throw Exception(
        json["error"]?.toString() ??
            json["msg"]?.toString() ??
            "No fue posible enviar el reporte.",
      );
    }
  }
}

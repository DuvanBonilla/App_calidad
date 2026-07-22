import 'dart:convert';
import 'package:app_calidad/api/config.dart';
import 'package:app_calidad/models/defect.dart.dart';
import 'package:http/http.dart' as http;

class DefectService {
  static Future<List<Defect>> getDefects() async {

    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/api_trazabilidad/api/defectos.php",
      ),
    );

    final Map<String, dynamic> body =
        jsonDecode(response.body);

    if (body["ok"] == true) {

      final List<dynamic> data = body["data"];

      return data
          .map((e) => Defect.fromJson(e))
          .toList();

    }

    throw Exception(body["msg"]);
  }
}
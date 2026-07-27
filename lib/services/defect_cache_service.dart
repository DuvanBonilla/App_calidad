import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/defect.dart.dart';

class DefectCacheService {
  static const String _boxName = "cache";
  static const String _key = "defectos";

  static Future<void> guardarDefectos(List<Defect> defectos) async {
    final box = await Hive.openBox(_boxName);

    final lista = defectos
        .map(
          (e) => {
            "id": e.id,
            "name": e.name,
          },
        )
        .toList();

    await box.put(_key, jsonEncode(lista));
  }

  static Future<List<Defect>> obtenerDefectos() async {
    final box = await Hive.openBox(_boxName);

    final json = box.get(_key);

    if (json == null) {
      return [];
    }

    final List<dynamic> lista = jsonDecode(json);

    return lista
        .map((e) => Defect.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> borrarDefectos() async {
    final box = await Hive.openBox(_boxName);

    await box.delete(_key);
  }
}
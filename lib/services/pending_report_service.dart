import 'package:hive_flutter/hive_flutter.dart';

class PendingReportService {
  static const String _boxName = "pending_reports";

  /// Guarda un reporte pendiente.
  static Future<void> guardarReporte({
    required Map<String, dynamic> datos,
    required List<String> fotos,
  }) async {
    final box = await Hive.openBox(_boxName);

    await box.add({
      "datos": datos,
      "fotos": fotos,
      "fechaGuardado": DateTime.now().toIso8601String(),
    });
  }

  /// Obtiene todos los reportes pendientes.
  static Future<List<Map<String, dynamic>>> obtenerReportes() async {
    final box = await Hive.openBox(_boxName);

    return box.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Elimina un reporte por índice.
  static Future<void> eliminarReporte(int index) async {
    final box = await Hive.openBox(_boxName);

    await box.deleteAt(index);
  }

  /// Cantidad de pendientes.
  static Future<int> cantidadPendientes() async {
    final box = await Hive.openBox(_boxName);

    return box.length;
  }

  /// Elimina todos.
  static Future<void> limpiar() async {
    final box = await Hive.openBox(_boxName);

    await box.clear();
  }
}
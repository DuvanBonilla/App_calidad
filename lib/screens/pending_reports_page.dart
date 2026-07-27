import 'package:app_calidad/services/pending_report_service.dart';
import 'package:app_calidad/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

class PendingReportsPage extends StatefulWidget {
  const PendingReportsPage({super.key});

  @override
  State<PendingReportsPage> createState() => _PendingReportsPageState();
}

class _PendingReportsPageState extends State<PendingReportsPage> {
  List<Map<String, dynamic>> reportes = [];

  @override
  void initState() {
    super.initState();
    cargarReportes();
  }

  Future<void> cargarReportes() async {
    final lista = await PendingReportService.obtenerReportes();

    setState(() {
      reportes = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reportes pendientes",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: HexColor('10401d'),
        shadowColor: Colors.black,
        elevation: 10,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: reportes.isEmpty
          ? const Center(child: Text("No existen reportes pendientes."))
          : ListView.builder(
              itemCount: reportes.length,
              itemBuilder: (context, index) {
                final reporte = reportes[index];

                final datos = Map<String, dynamic>.from(reporte["datos"]);

                final resumen = List<dynamic>.from(datos["resumen"]);

                final fotos = List<dynamic>.from(reporte["fotos"]);

                final fecha = DateTime.parse(reporte["fechaGuardado"]);

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.cloud_off, color: Colors.orange),
                    title: Text(datos["placa"] ?? ""),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat("dd/MM/yyyy HH:mm").format(fecha)),
                        Text("Resumen: ${resumen.length}"),
                        Text("Fotos: ${fotos.length}"),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        BuildContext? loadingContext;

                        try {
                          final datos = Map<String, dynamic>.from(
                            reporte["datos"],
                          );

                          final fotos = List<String>.from(
                            reporte["fotos"] ?? [],
                          );

                          // Mostrar diálogo de carga
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogContext) {
                              loadingContext = dialogContext;

                              return const AlertDialog(
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Text("Enviando reporte..."),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          // Enviar reporte
                          await ReportService.enviarReporte(
                            datos: datos,
                            fotos: fotos,
                          );

                          if (!mounted) return;

                          // Cerrar SOLO el diálogo de carga
                          if (loadingContext != null) {
                            Navigator.of(loadingContext!).pop();
                            loadingContext = null;
                          }

                          // Eliminar de pendientes
                          await PendingReportService.eliminarReporte(index);

                          if (!mounted) return;

                          // Recargar lista
                          await cargarReportes();

                          if (!mounted) return;

                          // Mostrar éxito
                          await showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text("Reporte enviado"),
                                content: const Text(
                                  "El reporte pendiente fue enviado correctamente.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: const Text("Aceptar"),
                                  ),
                                ],
                              );
                            },
                          );
                        } catch (e) {
                          if (!mounted) return;

                          // Si el diálogo de carga sigue abierto, cerrarlo
                          if (loadingContext != null) {
                            Navigator.of(loadingContext!).pop();
                            loadingContext = null;
                          }

                          if (!mounted) return;

                          // El reporte NO se elimina.
                          // Sigue almacenado en pendientes.
                          await showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text("No fue posible enviar"),
                                content: Text(
                                  "El reporte continúa guardado en pendientes.\n\n$e",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: const Text("Aceptar"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: const Text("Enviar"),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

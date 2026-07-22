import 'dart:io';

import 'package:app_calidad/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class FotosGeneralesPage extends StatefulWidget {
  const FotosGeneralesPage({super.key});

  @override
  State<FotosGeneralesPage> createState() => _FotosGeneralesPageState();
}

class _FotosGeneralesPageState extends State<FotosGeneralesPage> {
  final ImagePicker _picker = ImagePicker();

  List<String> fotos = [];

  @override
  void initState() {
    super.initState();
    cargarFotos();
  }

  Future<void> cargarFotos() async {
    fotos = await LocalStorageService.obtenerFotosGenerales();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> tomarFoto() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (imagen == null) return;

    final dir = await getApplicationDocumentsDirectory();

    final carpeta = Directory("${dir.path}/fotos_calidad");

    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }

    final nombre =
        "foto_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final destino = "${carpeta.path}/$nombre";

    await File(imagen.path).copy(destino);

    fotos.add(destino);

    await LocalStorageService.guardarFotosGenerales(fotos);

    setState(() {});
  }

  Future<void> seleccionarGaleria() async {
    final List<XFile> imagenes = await _picker.pickMultiImage(
      imageQuality: 80,
    );

    if (imagenes.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();

    final carpeta = Directory("${dir.path}/fotos_calidad");

    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }

    for (final img in imagenes) {
      final nombre =
          "foto_${DateTime.now().microsecondsSinceEpoch}.jpg";

      final destino = "${carpeta.path}/$nombre";

      await File(img.path).copy(destino);

      fotos.add(destino);
    }

    await LocalStorageService.guardarFotosGenerales(fotos);

    setState(() {});
  }

  Future<void> eliminarFoto(int index) async {
    final archivo = File(fotos[index]);

    if (await archivo.exists()) {
      await archivo.delete();
    }

    fotos.removeAt(index);

    await LocalStorageService.guardarFotosGenerales(fotos);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6F8),

      appBar: AppBar(
        backgroundColor: const Color(0xff10401D),
        title: const Text(
          "Fotos Generales",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "camera",
            backgroundColor: const Color(0xff10401D),
            onPressed: tomarFoto,
            child: const Icon(Icons.camera_alt,color: Colors.white),
          ),

          const SizedBox(height: 12),

          FloatingActionButton(
            heroTag: "gallery",
            backgroundColor: Colors.blue,
            onPressed: seleccionarGaleria,
            child: const Icon(Icons.photo_library,color: Colors.white),
          ),
        ],
      ),

      body: fotos.isEmpty
          ? const Center(
              child: Text(
                "No hay fotos agregadas.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(15),

              itemCount: fotos.length,

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),

              itemBuilder: (_, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        File(fotos[index]),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

                    Positioned(
                      top: 5,
                      right: 5,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            eliminarFoto(index);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
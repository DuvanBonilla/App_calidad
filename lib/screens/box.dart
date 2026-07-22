import 'package:app_calidad/models/caja_calidad.dart';
import 'package:app_calidad/screens/resumen.dart';
import 'package:app_calidad/services/defect_service.dart';
import 'package:flutter/material.dart';
import '../models/defect.dart.dart';
import 'package:app_calidad/services/local_storage_service.dart';

class CalidadPage extends StatefulWidget {
  const CalidadPage({super.key});

  @override
  State<CalidadPage> createState() => _CalidadPageState();
}

class _CalidadPageState extends State<CalidadPage> {
  final TextEditingController ibmController = TextEditingController();
  String? tapaSeleccionada;
  List<Defect> defectos = [];
  final Set<int> defectosSeleccionados = {};
  final List<CajaCalidad> cajas = [];
  bool cargando = true;

  final List<String> tapas = [
    'COLOMBIA',
    'MAXIMO',
    'MIGUELITA KRAFT',
    'MIGUELITA ROSADO',
    'BACANO',
    'ROSY',
    'FYFFES KRAFT',
    'FYFFES COOK EXOTIC',
    'GENERICO',
    'CONSERBA 50LB',
    'CONSERBA 40LB (BOLSITA)',
    'CONSERBA 20LB',
    'NATURE 40LB',
    'EXOTIC PLANTAINS',
  ];

  @override
  void initState() {
    super.initState();
    cargarDefectos();
    cargarCajasLocales();
  }

  Future<void> cargarDefectos() async {
    try {
      defectos = await DefectService.getDefects();
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (!mounted) return;

    setState(() {
      cargando = false;
    });
  }

  // Cargar cajas desde el almacenamiento local
  Future<void> cargarCajasLocales() async {
    final cajasGuardadas = await LocalStorageService.obtenerCajas();

    setState(() {
      cajas.clear();
      cajas.addAll(cajasGuardadas);
    });
  }

  Future<void> guardarCaja() async {
    final ibm = ibmController.text.trim();

    if (ibm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ingrese el IBM.")));

      return;
    }
    if (tapaSeleccionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Seleccione una tapa.")));
      return;
    }

    setState(() {
      cajas.add(
        CajaCalidad(
          tapa: tapaSeleccionada!,
          ibm: ibm,
          defectos: defectosSeleccionados.toList(),
        ),
      );

      ibmController.clear();

      defectosSeleccionados.clear();
    });
    await LocalStorageService.guardarCajas(cajas);
  }

  Future<void> eliminarCaja(int index) async {
    setState(() {
      cajas.removeAt(index);
    });

    await LocalStorageService.guardarCajas(cajas);
  }

  void nuevaCaja() {
    setState(() {
      ibmController.clear();

      defectosSeleccionados.clear();
    });
  }

  @override
  void dispose() {
    ibmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6F8),

      appBar: AppBar(
        title: const Text(
          "Control de Calidad",
          style: TextStyle(color: Colors.white),
        ),

        centerTitle: true,

        backgroundColor: const Color(0xff10401D),

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  Card(
                    elevation: 5,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(18),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          const Text(
                            "Nueva Caja",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          TextField(
                            controller: ibmController,

                            keyboardType: TextInputType.number,

                            decoration: InputDecoration(
                              labelText: "IBM",

                              prefixIcon: const Icon(
                                Icons.inventory_2_outlined,
                              ),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: tapaSeleccionada,
                            decoration: InputDecoration(
                              labelText: 'Tapa',
                              prefixIcon: const Icon(Icons.layers_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            items: tapas.map((tapa) {
                              return DropdownMenuItem<String>(
                                value: tapa,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    tapa,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                tapaSeleccionada = value;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Defectos",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Wrap(
                            spacing: 8,

                            runSpacing: 8,

                            children: defectos.map((e) {
                              final selected = defectosSeleccionados.contains(
                                e.id,
                              );

                              return FilterChip(
                                label: Text(e.name),

                                selected: selected,

                                checkmarkColor: Colors.white,

                                selectedColor: const Color(0xff10401D),

                                labelStyle: TextStyle(
                                  color: selected ? Colors.white : Colors.black,
                                ),

                                onSelected: (value) {
                                  setState(() {
                                    if (value) {
                                      defectosSeleccionados.add(e.id);
                                    } else {
                                      defectosSeleccionados.remove(e.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 25),

                          SizedBox(
                            height: 55,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff10401D),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: guardarCaja,
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text(
                                "Guardar Caja",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Cajas calificadas (${cajas.length})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (cajas.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            "No hay cajas registradas",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cajas.length,
                    itemBuilder: (context, index) {
                      final caja = cajas[index];

                      final nombresDefectos = caja.defectos
                          .map((id) {
                            final defecto = defectos.firstWhere(
                              (d) => d.id == id,
                            );

                            return defecto.name;
                          })
                          .join(", ");

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),

                        elevation: 4,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xff10401D),
                            child: Icon(Icons.inventory_2, color: Colors.white),
                          ),

                          title: Text(
                            "IBM: ${caja.ibm}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),

                              Text(
                                "Tapa: ${caja.tapa}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                nombresDefectos.isEmpty
                                    ? "Sin defectos"
                                    : nombresDefectos,
                              ),
                            ],
                          ),

                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await eliminarCaja(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff10401D),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          if (index == 0) {
            // Ya estás en esta pantalla
            return;
          }

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResumenPage()),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: "Cajas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: "Resumen",
          ),
        ],
      ),
    );
  }
}

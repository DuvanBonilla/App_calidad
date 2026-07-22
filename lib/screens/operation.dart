import 'dart:async';
import 'package:app_calidad/screens/box.dart';
import 'package:app_calidad/screens/fotos.dart';
import 'package:app_calidad/screens/resumen.dart';
import 'package:app_calidad/services/local_storage_service.dart';
import 'package:app_calidad/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week_of_year/week_of_year.dart';

class OperacionPage extends StatefulWidget {
  const OperacionPage({super.key});

  @override
  State<OperacionPage> createState() => _OperacionPageState();
}

class SharedPreferenceHelper {
  static Future<List<String>> getSummaryList() async {
    final prefs = await SharedPreferences.getInstance();
    final summaryList = prefs.getStringList('summaryList');
    return summaryList ?? [];
  }

  static Future<void> saveSummaryList(List<String> summaryList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('summaryList', summaryList);
  }

  static Future<void> clearSummaryList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('summaryList');
  }
}

class _OperacionPageState extends State<OperacionPage> {
  final List<Item> _datas = generateItems(1);
  final TextEditingController tapaController = TextEditingController();
  final TextEditingController placaController = TextEditingController();

  List<String> trazabilidades = [];
  List<Map<String, String>> savedDataList = [];
  String placaValue = '';
  String _currentCode = '';
  int _ibmCounter = 0;
  String? selectedOption = '';
  final List<String> _dataList = [];
  final List<String> _summaryList = [];
  final TextEditingController _textEditingController = TextEditingController();
  late final _focusNode = FocusNode();
  Timer? _focusTimer;
  bool _autoBarcodeInput = false;
  int get dataListCount => _dataList.length;
  late SharedPreferences _prefs;
  int cantidadCaracteres = 4;

  void _addDataToList(String code) async {
    final text = code.trim();
    if (text.isNotEmpty) {
      _textEditingController.clear();
      if (text == "IBM") {
        _ibmCounter++;
      }
      _dataList.insert(0, text);

      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('dataList', _dataList);
      await Future.delayed(Duration.zero);
      prefs.setInt('ibmCounter', _ibmCounter);
      setState(() {});
    }
  }

  void _removeDataFromList(int index) async {
    _dataList.removeAt(index);
    setState(() {});

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('dataList', _dataList);
  }

  void _clearDataList() async {
    _dataList.clear();
    setState(() {});

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('dataList', _dataList);
  }

  void _loadSummaryList() async {
    final prefs = await SharedPreferences.getInstance();
    final summaryList = prefs.getStringList('summaryList');
    if (summaryList != null) {
      setState(() {
        _summaryList.addAll(summaryList);
        // contadorBotonGuardar = 1;
      });
    }
  }

  Map<String, int> _getDataCount() {
    final countMap = <String, int>{};
    for (final data in _dataList) {
      if (countMap.containsKey(data)) {
        countMap[data] = countMap[data]! + 1;
      } else {
        countMap[data] = 1;
      }
    }
    return countMap;
  }

  //Finaliza funciones

  @override
  void initState() {
    super.initState();
    _loadDataList();
    _loadSummaryList();
    _initSharedPreferences().then((_) {
      _loadData();
    });
    _loadSavedValues();
    _textEditingController.addListener(addCodeAutomatically);
  }

  void addCodeAutomatically() {
    final enteredCode = _textEditingController.text;
    if (enteredCode.length == cantidadCaracteres) {
      if (!_autoBarcodeInput) {
        _addDataToList(enteredCode);
        _textEditingController.clear();
      } else {
        _autoBarcodeInput = false;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.removeListener(addCodeAutomatically);
    _textEditingController.dispose();
    _focusTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveValues() async {
    await _prefs.setString('tapa', tapaController.text);
    await _prefs.setString('placa', placaController.text);
  }

  Future<void> _loadSavedValues() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      tapaController.text = _prefs.getString('tapa') ?? '';
      placaController.text = _prefs.getString('placa') ?? '';
    });
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> limpiarFormulario() async {
    // Limpiar controllers
    placaController.clear();
    tapaController.clear();
    _textEditingController.clear();
    // Limpiar listas
    _dataList.clear();
    _summaryList.clear();

    // Reiniciar contador
    _ibmCounter = 0;
    // Limpiar SharedPreferences
    await _prefs.remove('placa');
    await _prefs.remove('tapa');
    await _prefs.remove('dataList');
    await _prefs.remove('ibmCounter');

    if (mounted) {
      setState(() {});
    }
  }

  void _loadData() {
    final placa = _prefs.getString('placa');
    placaController.text = placa ?? '';
  }

  void _saveSummaryList(List<String> summaryList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('summaryList', summaryList);
  }

  void _loadDataList() async {
    final prefs = await SharedPreferences.getInstance();
    final dataList = prefs.getStringList('dataList');
    if (dataList != null) {
      setState(() {
        _dataList.addAll(dataList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: const Text(
            'Formulario',
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
          actions: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.only(right: 16.0),
            //   child: Image.asset('assets/image/LogoBlanco.png'),
            // ),
            IconButton(
              tooltip: "Enviar reporte",
              icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
              onPressed: () async {
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Enviar reporte"),
                    content: const Text(
                      "¿Está seguro de enviar el reporte?\n\n"
                      "Una vez enviado correctamente se eliminarán los datos almacenados localmente.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancelar"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Enviar"),
                      ),
                    ],
                  ),
                );

                if (confirmar != true) return;

                bool dialogoCargaAbierto = false;

                try {
                  /// Resumen
                  final resumen = await SharedPreferenceHelper.getSummaryList();

                  /// Calidad
                  final calidad = await LocalStorageService.obtenerCajas();

                  /// Fotos
                  final fotos =
                      await LocalStorageService.obtenerFotosGenerales();

                  /// Validaciones
                  if (placaController.text.trim().isEmpty) {
                    throw Exception("Debe ingresar la placa.");
                  }

                  if (resumen.isEmpty) {
                    throw Exception("No hay información del resumen.");
                  }

                  /// Construir reporte
                  final reporte = {
                    "placa": placaController.text.trim(),
                    "fecha": DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
                    "semana": DateTime.now().weekOfYear,
                    "resumen": resumen,
                    "calidad": calidad.map((e) => e.toJson()).toList(),
                  };

                  if (!mounted) return;

                  /// Mostrar carga
                  dialogoCargaAbierto = true;

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Expanded(child: Text("Enviando reporte...")),
                        ],
                      ),
                    ),
                  );

                  /// Enviar
                  await ReportService.enviarReporte(
                    datos: reporte,
                    fotos: fotos,
                  );

                  if (!mounted) return;

                  /// Cerrar carga
                  if (dialogoCargaAbierto) {
                    Navigator.of(context).pop();
                    dialogoCargaAbierto = false;
                  }

                  /// Limpiar almacenamiento
                  await SharedPreferenceHelper.clearSummaryList();
                  await LocalStorageService.limpiarCajas();
                  await LocalStorageService.limpiarFotosGenerales();

                  await limpiarFormulario();

                  if (!mounted) return;

                  /// Éxito
                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Reporte enviado"),
                      content: const Text(
                        "El reporte fue enviado correctamente.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Aceptar"),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  /// Cerrar carga únicamente si está abierta
                  if (dialogoCargaAbierto) {
                    Navigator.of(context).pop();
                    dialogoCargaAbierto = false;
                  }

                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Error"),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Aceptar"),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ExpansionPanelList(
                // key: UniqueKey(),
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    // _datas[index].isExpanded = !isExpanded;
                    //todo esta propiedad (bool isExpanded) es una propiedad que te la da el callbacks es decir
                    //cuando la expandes, se pone en true, que pasa que tenias un "!isExpanded"
                    //por lo que estabas negando lo que te decir, en este caso, cuando el te ponia TRUE
                    //tu lo negabas y ponias FALSE de esa forma no se expandia
                    _datas[index].isExpanded = isExpanded;
                  });
                },
                children: _datas.map<ExpansionPanel>((Item item) {
                  return ExpansionPanel(
                    backgroundColor: Colors.grey.shade300,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(title: Text(item.headerValue));
                    },
                    body: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.expandedValue,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField(
                                  value: selectedOption,
                                  items: const [
                                    DropdownMenuItem(
                                      value: '',
                                      child: Text(''),
                                    ),
                                    DropdownMenuItem(
                                      value: 'NATURE 40LB',
                                      child: Text('NATURE 40LB'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'COLOMBIA',
                                      child: Text('COLOMBIA'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'MAXIMO',
                                      child: Text('MAXIMO'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'MIGUELITA KRAFT',
                                      child: Text('MIGUELITA KRAFT'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'MANZANO',
                                      child: Text('MANZANO'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'ROSY',
                                      child: Text('ROSY'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'MIGUELITA ROSADO',
                                      child: Text('MIGUELITA ROSADO'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'BACANO',
                                      child: Text('BACANO'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'FYFFES KRAFT',
                                      child: Text('FYFFES KRAFT'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'FYFFES COOK EXOTIC',
                                      child: Text('FYFFES COOK EXOTIC'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'GENERICO',
                                      child: Text('GENERICO'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'CONSERBA 50LB',
                                      child: Text('CONSERBA 50LB'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'CONSERBA 40LB (BOLSITA)',
                                      child: Text('CONSERBA 40LB (BOLSITA)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'CONSERBA 20LB',
                                      child: Text('CONSERBA 20LB'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'EXOTIC PLANTAINS',
                                      child: Text('EXOTIC PLANTAINS'),
                                    ),
                                  ],
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedOption = value ?? '';
                                      tapaController.text = selectedOption!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Tapa',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  controller: placaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Placa',
                                  ),
                                  onTap: () {
                                    // Coloca aquí la lógica para generar el valor de Tapa
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      // placaValue = value;
                                      // placaController.text = value;
                                    });
                                    _saveValues();
                                  },
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.check_circle_outline),
                            onTap: () {
                              setState(() {
                                item.isExpanded = !item.isExpanded;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: IconButton(
                                  onPressed: () async {
                                    await _prefs.remove('tapa');
                                    await _prefs.remove('placa');

                                    setState(() {
                                      tapaController.clear();
                                      placaController.clear();
                                      selectedOption = '';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isExpanded: item.isExpanded,
                  );
                }).toList(),
              ),
              const SizedBox(width: 10, height: 10),

              // Podemos iniciar acá el ingreso de datos para el excel
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Text(
                            'Cajas = $dataListCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          Checkbox(
                            value: cantidadCaracteres == 3,
                            onChanged: (value) {
                              setState(() {
                                cantidadCaracteres = 3;
                              });
                            },
                          ),
                          const Text('3'),
                          Checkbox(
                            value: cantidadCaracteres == 4,
                            onChanged: (value) {
                              setState(() {
                                cantidadCaracteres = 4;
                              });
                            },
                          ),
                          const Text('4'),
                          Checkbox(
                            value: cantidadCaracteres == 5,
                            onChanged: (value) {
                              setState(() {
                                cantidadCaracteres = 5;
                              });
                            },
                          ),
                          const Text('5'),
                        ],
                      ),
                    ),
                    TextFormField(
                      focusNode: _focusNode,
                      autofocus: true,
                      controller: _textEditingController,
                      keyboardType: TextInputType.number,
                      onChanged: (enteredCode) {
                        setState(() {
                          _currentCode = enteredCode;
                          if (enteredCode.length == cantidadCaracteres) {
                            _addDataToList(_currentCode);
                            _currentCode = '';
                            _textEditingController.clear();

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!_autoBarcodeInput) {
                                FocusScope.of(context).requestFocus(_focusNode);
                              } else {
                                _autoBarcodeInput = false;
                              }
                            });
                          }
                        });

                        // Mantener el enfoque en el campo de texto
                        Timer(const Duration(milliseconds: 200), () {
                          _focusNode.requestFocus();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Ingrese IBM',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor(
                              '10401d',
                            ), // Color con HexColor
                          ),
                          onPressed: () {
                            // _addDataToList();
                            _addDataToList(_currentCode);
                            _currentCode = '';
                          },
                          child: const Text(
                            'Agregar',
                            style: TextStyle(
                              color: Colors
                                  .white, // Cambia el color del texto a blanco
                            ),
                          ),
                        ),
                        // const SizedBox(height: 8.0),

                        // const SizedBox(height: 16.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor(
                              '10401d',
                            ), // Color con HexColor
                          ),
                          onPressed: () {
                            final dateTime = DateTime.now();
                            final dateFormat = DateFormat(
                              'dd/MM/yyyy HH-mm-ss',
                            );
                            final formattedDateTime = dateFormat.format(
                              dateTime,
                            );
                            final dateFormatDay = DateFormat.EEEE();
                            final formattedDay = dateFormatDay.format(dateTime);
                            final countMap = _getDataCount();
                            final summaryList = <String>[];
                            for (final key in countMap.keys) {
                              summaryList.add(
                                '$key :  ${countMap[key]} : ${_dataList.length} : ${tapaController.text} : ${placaController.text} : ${formattedDateTime.simplifyText()} : ${formattedDay.simplifyText()}',
                              );
                            }
                            // summaryList.add('Total cajas : ${_dataList.length}');
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 600.0,
                                      maxHeight: 700.0,
                                    ),
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Center(
                                          child: Text(
                                            'Información de Cajas',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16.0),
                                        SingleChildScrollView(
                                          child: SizedBox(
                                            height:
                                                300.0, // Altura fija para el contenido desplazable
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: summaryList.length,
                                              itemBuilder:
                                                  (
                                                    BuildContext context,
                                                    int index,
                                                  ) {
                                                    return Text(
                                                      summaryList[index],
                                                      style: const TextStyle(
                                                        fontSize: 16.0,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: HexColor(
                                                  'bf545a',
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(
                                                  context,
                                                ).pop(); // Cerrar el diálogo
                                              },
                                              child: const Text(
                                                'Cerrar',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10.0),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (tapaController
                                                    .text
                                                    .isEmpty) {
                                                  // Mostrar aviso de campo vacío
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10.0,
                                                              ),
                                                        ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                22.0,
                                                              ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Text(
                                                                'Atención',
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      20.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 22.0,
                                                              ),
                                                              const Text(
                                                                'El campo "TAPA" está vacío. Por favor, ingrese la información requerida.',
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          18.0,
                                                                    ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              const SizedBox(
                                                                height: 22.0,
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  ); // Cerrar el diálogo
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            30.0,
                                                                      ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10.0,
                                                                        ),
                                                                  ),
                                                                ),
                                                                child: const Text(
                                                                  'OK',
                                                                  style:
                                                                      TextStyle(
                                                                        fontSize:
                                                                            18.0,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  // Guardar la información
                                                  setState(() {
                                                    _summaryList.addAll(
                                                      summaryList,
                                                    );
                                                    _saveSummaryList(
                                                      _summaryList,
                                                    );
                                                    _clearDataList();
                                                    tapaController.clear();
                                                    _textEditingController
                                                        .clear();
                                                  });
                                                  Navigator.of(
                                                    context,
                                                  ).pop(); // Cerrar el diálogo
                                                }
                                                // print(summaryList);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: HexColor(
                                                  '10401d',
                                                ),
                                              ),
                                              child: const Text(
                                                'Guardar',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            'Resumen',
                            style: TextStyle(
                              color: Colors
                                  .white, // Cambia el color del texto a blanco
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: _dataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (_dataList[index] == "IBM") {
                          _ibmCounter++;
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${index + 1}. ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _dataList[index] == "IBM"
                                      ? _ibmCounter.toString()
                                      : '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('  '),
                                Text(_dataList[index]),
                              ],
                            ),
                            // Text(_dataList[index]),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 25,
                              ),
                              onPressed: () => _removeDataFromList(index),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor('10401d'), // Color con HexColor
                    ),
                    onPressed: _clearDataList,
                    child: const Text(
                      'Borrar Todo',
                      style: TextStyle(
                        color:
                            Colors.white, // Cambia el color del texto a blanco
                      ),
                    ),
                  ),
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: HexColor('10401d'), // Color con HexColor
                  //   ),
                  //   onPressed: enviarExcel,
                  //   child: const Text(
                  //     'Enviar',
                  //     style: TextStyle(
                  //       color:
                  //           Colors.white, // Cambia el color del texto a blanco
                  //     ),
                  //   ),
                  // ),
                ],
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
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalidadPage()),
                );
                break;

              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResumenPage()),
                );
                break;

              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FotosGeneralesPage()),
                );
                break;
            }
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: 'Cajas',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Resumen',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.photo_camera_rounded),
              label: 'Fotos',
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  bool isExpanded;
  String headerValue;
  String expandedValue;

  Item({
    required this.isExpanded,
    required this.headerValue,
    required this.expandedValue,
  });
}

List<Item> generateItems(int numberOfItems) {
  return List.generate(numberOfItems, (int index) {
    return Item(
      isExpanded: false,
      headerValue: 'Valores',
      expandedValue: 'Ingrese la Información',
    );
  });
}

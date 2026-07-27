class CajaCalidad {
  final String ibm;
  final String tapa;
  final List<int> defectos;

  // Texto escrito cuando seleccionan OTRO
  final String? otroDefecto;

  CajaCalidad({required this.ibm, required this.tapa, required this.defectos, this.otroDefecto});

  Map<String, dynamic> toJson() {
    return {"ibm": ibm, "tapa": tapa, "defectos": defectos, "otroDefecto": otroDefecto};
  }

  factory CajaCalidad.fromJson(Map<String, dynamic> json) {
    return CajaCalidad(
      tapa: json["tapa"],
      ibm: json["ibm"],
      defectos: List<int>.from(json["defectos"]),
      otroDefecto: json["otroDefecto"],
    );
  }
}

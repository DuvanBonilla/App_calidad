class CajaCalidad {
  final String ibm;
  final String tapa;
  final List<int> defectos;

  CajaCalidad({required this.ibm, required this.tapa, required this.defectos});

  Map<String, dynamic> toJson() {
    return {"ibm": ibm, "tapa": tapa, "defectos": defectos};
  }

  factory CajaCalidad.fromJson(Map<String, dynamic> json) {
    return CajaCalidad(
      tapa: json["tapa"],
      ibm: json["ibm"],
      defectos: List<int>.from(json["defectos"]),
    );
  }
}

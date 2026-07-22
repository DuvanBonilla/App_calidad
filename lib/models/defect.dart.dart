class Defect {
  final int id;
  final String name;

  Defect({
    required this.id,
    required this.name,
  });

  factory Defect.fromJson(Map<String, dynamic> json) {
    return Defect(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
    );
  }
}
class Patient {
  final String id;
  final String name;
  final int age;
  final String sex;
  final double weightKg;
  final double heightCm;
  final String reason;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
    required this.weightKg,
    required this.heightCm,
    required this.reason,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      sex: json['sex'] as String,
      weightKg: (json['weight_kg'] as num).toDouble(),
      heightCm: (json['height_cm'] as num).toDouble(),
      reason: json['reason'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'sex': sex,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'reason': reason,
      'notes': notes,
    };
  }
}

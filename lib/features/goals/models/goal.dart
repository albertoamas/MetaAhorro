import 'progress.dart';

class Goal {
  String id;
  String name;
  double targetAmount;
  double currentAmount;
  String currency;
  DateTime? deadline;
  String? description;
  List<Progress> progressHistory; // Historial de progreso

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.currency,
    this.deadline,
    this.description,
    this.progressHistory = const [], // Inicializar como lista vacía
  });

  // Método copyWith actualizado
  Goal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? deadline,
    String? description,
    List<Progress>? progressHistory,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      progressHistory: progressHistory ?? this.progressHistory,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'currency': currency,
      'deadline': deadline?.toIso8601String(),
      'description': description,
      'progressHistory': progressHistory.map((p) => p.toJson()).toList(),
    };
  }

  // Crear una meta desde JSON
  factory Goal.fromJson(String id, Map<String, dynamic> json) {
    return Goal(
      id: id,
      name: json['name'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'],
      currency: json['currency'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      description: json['description'],
      progressHistory: (json['progressHistory'] as List<dynamic>?)
              ?.map((p) => Progress.fromJson(p))
              .toList() ??
          [],
    );
  }
}
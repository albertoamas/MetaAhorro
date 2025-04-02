class Progress {
  final double amount;
  final DateTime date;
  final String? description;

  Progress({
    required this.amount,
    required this.date,
    this.description,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  // Crear un objeto Progress desde JSON
  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}
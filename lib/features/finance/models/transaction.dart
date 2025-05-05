class Transaction {
  String id;
  final String type;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
  final String profile;
  final String? userId; // Nuevo campo para almacenar el ID del usuario
  final String? description;
  final String? goalId;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    required this.profile,
    this.userId,
    this.description,
    this.goalId,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': date.toIso8601String(),
      'profile': profile,
      'userId': userId,
      'goalId': goalId,
      'description': description,
    };
  }

  // Crear una transacción desde JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: '', // El ID se asignará después
      type: json['type'],
      amount: json['amount'],
      currency: json['currency'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      profile: json['profile'] ?? 'USD',
      userId: json['userId'],
      goalId: json['goalId'],
      description: json['description'],
    );
  }
}
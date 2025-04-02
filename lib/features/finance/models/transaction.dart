class Transaction {
  String id;
  final String type;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
  final String profile; // Campo obligatorio
  final String? goalId; // Nuevo campo opcional para asociar con una meta
  final String? description;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    required this.profile,
    this.goalId, // Inicializar el nuevo campo
    this.description,
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
      'goalId': goalId, // Incluir el nuevo campo
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
      goalId: json['goalId'], // Leer el nuevo campo
      description: json['description'],
    );
  }
}
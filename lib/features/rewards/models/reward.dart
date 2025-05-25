// Modelo para representar las recompensas y logros en la aplicación
import 'package:cloud_firestore/cloud_firestore.dart';

enum RewardType {
  badge,       // Insignias (medallas, trofeos)
  achievement, // Logros (hitos alcanzados)
  milestone    // Hitos específicos del progreso
}

enum RewardCategory {
  savings,     // Relacionado con ahorro
  expenses,    // Relacionado con control de gastos
  goals,       // Relacionado con metas cumplidas
  streak,      // Relacionado con constancia/racha
  special      // Eventos especiales o desafíos
}

class Reward {
  final String id;
  final String title;       // Título del logro
  final String description; // Descripción del logro
  final String iconPath;    // Ruta del icono/imagen de la recompensa
  final RewardType type;    // Tipo de recompensa
  final RewardCategory category; // Categoría de la recompensa
  final int level;          // Nivel de dificultad (1-5)
  final double progress;    // Progreso actual (0-100%)
  final double target;      // Meta para completar el logro
  final bool isUnlocked;    // Si ya está desbloqueado
  final DateTime? unlockDate; // Fecha de desbloqueo
  final String? criteria;   // Criterio para desbloquear (descripción)
  final Map<String, dynamic>? metadata; // Datos adicionales

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.category,
    required this.level,
    this.progress = 0.0,
    required this.target,
    this.isUnlocked = false,
    this.unlockDate,
    this.criteria,
    this.metadata,
  });

  // Método para clonar con cambios
  Reward copyWith({
    String? id,
    String? title,
    String? description,
    String? iconPath,
    RewardType? type,
    RewardCategory? category,
    int? level,
    double? progress,
    double? target,
    bool? isUnlocked,
    DateTime? unlockDate,
    String? criteria,
    Map<String, dynamic>? metadata,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      category: category ?? this.category,
      level: level ?? this.level,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockDate: unlockDate ?? this.unlockDate,
      criteria: criteria ?? this.criteria,
      metadata: metadata ?? this.metadata,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'level': level,
      'progress': progress,
      'target': target,
      'isUnlocked': isUnlocked,
      'unlockDate': unlockDate?.toIso8601String(),
      'criteria': criteria,
      'metadata': metadata,
    };
  }

  // Crear desde JSON
  factory Reward.fromJson(String id, Map<String, dynamic> json) {
    return Reward(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconPath: json['iconPath'] ?? '',
      type: _stringToRewardType(json['type'] ?? 'badge'),
      category: _stringToRewardCategory(json['category'] ?? 'savings'),      level: json['level'] ?? 1,
      progress: (json['progress'] != null) ? (json['progress'] as num).toDouble() : 0.0,
      target: (json['target'] != null) ? (json['target'] as num).toDouble() : 100.0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockDate: json['unlockDate'] != null ? DateTime.parse(json['unlockDate']) : null,
      criteria: json['criteria'],
      metadata: json['metadata'],
    );
  }

  // Crear desde Firestore
  factory Reward.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Reward.fromJson(doc.id, data);
  }

  // Convertir string a enum RewardType
  static RewardType _stringToRewardType(String type) {
    switch (type) {
      case 'badge':
        return RewardType.badge;
      case 'achievement':
        return RewardType.achievement;
      case 'milestone':
        return RewardType.milestone;
      default:
        return RewardType.badge;
    }
  }

  // Convertir string a enum RewardCategory
  static RewardCategory _stringToRewardCategory(String category) {
    switch (category) {
      case 'savings':
        return RewardCategory.savings;
      case 'expenses':
        return RewardCategory.expenses;
      case 'goals':
        return RewardCategory.goals;
      case 'streak':
        return RewardCategory.streak;
      case 'special':
        return RewardCategory.special;
      default:
        return RewardCategory.savings;
    }
  }
}
// Historial de recompensas para seguimiento de logros desbloqueados
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardHistory {
  final String id;
  final String rewardId;    // ID de la recompensa conseguida
  final String rewardTitle; // Título de la recompensa (para evitar consultas adicionales)
  final DateTime unlockDate; // Fecha de desbloqueo
  final String triggerAction; // Qué acción desbloqueó la recompensa
  final Map<String, dynamic>? metadata; // Detalles adicionales sobre el desbloqueo

  RewardHistory({
    required this.id,
    required this.rewardId,
    required this.rewardTitle,
    required this.unlockDate,
    required this.triggerAction,
    this.metadata,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'rewardId': rewardId,
      'rewardTitle': rewardTitle,
      'unlockDate': unlockDate.toIso8601String(),
      'triggerAction': triggerAction,
      'metadata': metadata,
    };
  }

  // Crear desde JSON
  factory RewardHistory.fromJson(String id, Map<String, dynamic> json) {
    return RewardHistory(
      id: id,
      rewardId: json['rewardId'] ?? '',
      rewardTitle: json['rewardTitle'] ?? '',
      unlockDate: json['unlockDate'] != null 
        ? DateTime.parse(json['unlockDate']) 
        : DateTime.now(),
      triggerAction: json['triggerAction'] ?? '',
      metadata: json['metadata'],
    );
  }

  // Crear desde Firestore
  factory RewardHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RewardHistory.fromJson(doc.id, data);
  }
}

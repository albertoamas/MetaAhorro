import 'package:flutter/material.dart';
import '../models/reward_history.dart';
import '../services/rewards_service.dart';

class RewardHistoryScreen extends StatelessWidget {
  const RewardHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RewardsService _rewardsService = RewardsService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Logros',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3C2FCF),
      ),
      body: StreamBuilder<List<RewardHistory>>(
        stream: _rewardsService.getRewardHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar el historial: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay logros desbloqueados aún',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Sigue usando la app para desbloquear logros!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          final historyItems = snapshot.data!;
          // Agrupar por mes y año
          final groupedHistory = _groupHistoryByMonth(historyItems);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedHistory.length,
            itemBuilder: (context, index) {
              final monthGroup = groupedHistory.keys.elementAt(index);
              final items = groupedHistory[monthGroup]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      monthGroup,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3C2FCF),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, itemIndex) {
                      final item = items[itemIndex];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3C2FCF).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: Color(0xFF3C2FCF),
                            ),
                          ),
                          title: Text(
                            item.rewardTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                item.triggerAction,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(item.unlockDate),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Agrupar por mes y año
  Map<String, List<RewardHistory>> _groupHistoryByMonth(
      List<RewardHistory> items) {
    final Map<String, List<RewardHistory>> grouped = {};

    for (var item in items) {
      final date = item.unlockDate;
      String key = _getMonthYearString(date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      grouped[key]!.add(item);
    }

    return grouped;
  }

  String _getMonthYearString(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

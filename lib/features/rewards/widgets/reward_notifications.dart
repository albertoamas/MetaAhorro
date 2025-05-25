import 'package:flutter/material.dart';
import '../models/reward.dart';

class RewardNotifications {
  // Mostrar notificación de logro desbloqueado
  static void showRewardUnlockedNotification(
    BuildContext context,
    Reward reward,
  ) {
    // Icono basado en el tipo de recompensa
    IconData iconData;
    Color iconColor;

    switch (reward.type) {
      case RewardType.badge:
        iconData = Icons.military_tech;
        iconColor = Colors.amber;
        break;
      case RewardType.achievement:
        iconData = Icons.emoji_events;
        iconColor = Colors.orange;
        break;
      case RewardType.milestone:
        iconData = Icons.flag;
        iconColor = Colors.teal;
        break;
    }

    // Mostrar SnackBar animado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Logro Desbloqueado!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    reward.title,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3C2FCF),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // Navegar a la pantalla de detalles del logro
            Navigator.pushNamed(
              context,
              '/rewards',
              arguments: reward.id,
            );
          },
        ),
      ),
    );
  }

  // Mostrar diálogo de logro desbloqueado
  static void showRewardUnlockedDialog(
    BuildContext context,
    Reward reward,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOutQuad,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.5 + (value * 0.5),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3C2FCF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 50,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '¡FELICIDADES!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Has desbloqueado un logro',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        reward.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3C2FCF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        reward.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C2FCF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Genial',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
    );
  }
}

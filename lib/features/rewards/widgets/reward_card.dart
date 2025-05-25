import 'package:flutter/material.dart';
import '../models/reward.dart';

class RewardCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback? onTap;
  final bool showProgress;

  const RewardCard({
    Key? key,
    required this.reward,
    this.onTap,
    this.showProgress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: reward.isUnlocked ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: reward.isUnlocked ? const Color(0xFF3C2FCF) : Colors.grey.shade300,
          width: reward.isUnlocked ? 1.5 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top part with icon and level
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge icon or placeholder
                  _buildRewardIcon(),
                  
                  // Level indicator
                  _buildLevelIndicator(),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Title
              Text(
                reward.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: reward.isUnlocked ? const Color(0xFF3C2FCF) : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 5),
              
              // Description
              Text(
                reward.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (showProgress) ...[
                const SizedBox(height: 10),
                
                // Progress bar
                _buildProgressBar(),
                
                const SizedBox(height: 5),
                
                // Progress text
                _buildProgressText(),
              ],
              
              // Unlock status
              if (reward.isUnlocked && reward.unlockDate != null) ...[
                const SizedBox(height: 8),
                _buildUnlockInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRewardIcon() {
    // Si hay una ruta de icono, intentar cargarla, de lo contrario usar un icono predeterminado
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
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: reward.isUnlocked 
            ? Colors.white 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        boxShadow: reward.isUnlocked ? [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ] : null,
      ),
      child: Icon(
        iconData,
        color: reward.isUnlocked ? iconColor : Colors.grey,
        size: 24,
      ),
    );
  }
  
  Widget _buildLevelIndicator() {
    final List<Widget> stars = [];
    
    for (int i = 0; i < reward.level; i++) {
      stars.add(
        Icon(
          Icons.star,
          size: 14,
          color: reward.isUnlocked 
              ? _getLevelColor() 
              : Colors.grey.shade400,
        ),
      );
    }
    
    return Row(
      children: stars,
    );
  }
  
  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: reward.progress / reward.target,
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(
          reward.isUnlocked 
              ? _getLevelColor() 
              : const Color(0xFF3C2FCF).withOpacity(0.6),
        ),
        minHeight: 6,
      ),
    );
  }
  
  Widget _buildProgressText() {
    return Text(
      '${reward.progress.toInt()}% completado',
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }
  
  Widget _buildUnlockInfo() {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          size: 12,
          color: Colors.green,
        ),
        const SizedBox(width: 4),
        Text(
          'Desbloqueado el ${_formatDate(reward.unlockDate!)}',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Color _getLevelColor() {
    switch (reward.level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.redAccent;
      default:
        return const Color(0xFF3C2FCF);
    }
  }
}

// Widget para mostrar recompensas pequeñas (ej. en listas o carruseles)
class SmallRewardCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback? onTap;

  const SmallRewardCard({
    Key? key,
    required this.reward,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: reward.isUnlocked ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: reward.isUnlocked ? const Color(0xFF3C2FCF) : Colors.transparent,
          width: reward.isUnlocked ? 1 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge icon
              Icon(
                _getIconData(),
                size: 28,
                color: reward.isUnlocked 
                    ? _getIconColor() 
                    : Colors.grey.shade400,
              ),
              
              const SizedBox(height: 6),
              
              // Title
              Text(
                reward.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: reward.isUnlocked ? Colors.black87 : Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Level stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  reward.level,
                  (index) => Icon(
                    Icons.star,
                    size: 10,
                    color: reward.isUnlocked 
                        ? _getIconColor()
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getIconData() {
    switch (reward.type) {
      case RewardType.badge:
        return Icons.military_tech;
      case RewardType.achievement:
        return Icons.emoji_events;
      case RewardType.milestone:
        return Icons.flag;
    }
  }
  
  Color _getIconColor() {
    switch (reward.type) {
      case RewardType.badge:
        return Colors.amber;
      case RewardType.achievement:
        return Colors.orange;
      case RewardType.milestone:
        return Colors.teal;
    }
  }
}
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'progress_bar.dart';

class TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress; // 0.0 .. 1.0
  final String buttonLabel;
  final VoidCallback? onContinue; // 👈 callback adicionado

  const TopicCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.buttonLabel = 'Continuar',
    this.onContinue, // 👈 callback opcional
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cement),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _Title(title: title, subtitle: subtitle)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: onContinue, // 👈 usa o callback
                child: Text(buttonLabel),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressBar(value: progress),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String title, subtitle;
  const _Title({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }
}

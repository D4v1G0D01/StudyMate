import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final double value; // 0.0 a 1.0
  final double height;
  final Color? color;

  const ProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: Colors.black12,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0, 1).toDouble(), // ✅ corrigido
          child: Container(
            color: color ?? AppColors.accent, // ✅ usa cor padrão do tema
          ),
        ),
      ),
    );
  }
}

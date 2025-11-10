import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuizzesScreen extends StatelessWidget {
  const QuizzesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        Container(
          color: AppColors.ash,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Quizzes', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: const [
                _KpiBox('Média de acertos:', '87%'),
                SizedBox(width: 16),
                _KpiBox('Quizzes terminados', '54'),
              ],
            ),
            const SizedBox(height: 18),
            _QuizGrid(items: const [
              _QuizItem('Matemática - Funções Quadráticas', '⚡ 10 Questões'),
              _QuizItem('História do Brasil: República', '⚡ 15 Questões'),
              _QuizItem('Biologia - Genética Básica', '⚡ 10 Questões'),
              _QuizItem('Química - Cadeias Carbônicas', '⚡ 20 Questões'),
            ]),
          ]),
        ),
      ],
    );
  }
}

class _KpiBox extends StatelessWidget {
  final String title, value;
  const _KpiBox(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    final isPercent = value.endsWith('%');
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cement),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isPercent ? AppColors.success : AppColors.accent,
            ),
          ),
        ]),
      ),
    );
  }
}

class _QuizGrid extends StatelessWidget {
  final List<_QuizItem> items;
  const _QuizGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF8F8F8F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (_, c) {
          final isWide = c.maxWidth > 560;
          final cross = isWide ? 4 : 2;
          return GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .78),
            itemBuilder: (_, i) => items[i],
          );
        },
      ),
    );
  }
}

class _QuizItem extends StatelessWidget {
  final String title, subtitle;
  const _QuizItem(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black54, width: 2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.black54)),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            child: const Text('Iniciar Quiz'),
          ),
        ),
      ]),
    );
  }
}

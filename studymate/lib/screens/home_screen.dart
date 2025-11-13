import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';
import '../widgets/topic_card.dart';
import '../widgets/progress_bar.dart';
import 'flashcard_detail_screen.dart'; // 🔹 importa a tela de Flashcards

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openFlashcards(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardDetailScreen(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        _Section(
          title: 'Home',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Linha dos 3 cards
              const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    StatCard(title: 'Flashcards', value: '42', subtitle: 'Revisados'),
                    SizedBox(width: 16),
                    StatCard(title: 'Quizzes', value: '3', subtitle: 'Completos'),
                    SizedBox(width: 16),
                    StatCard(title: 'Tempo de estudo', value: '44min', subtitle: 'Hoje'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Tópicos Recentes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              // 🔹 Torna os TopicCards clicáveis
           TopicCard(
  title: 'Matemática - \nTrigonometria',
  subtitle: '24 flashcards',
  progress: 0.65,
  onContinue: () => _openFlashcards(context, 'Matemática - Trigonometria'),
),
const SizedBox(height: 12),

TopicCard(
  title: 'História -\nSegunda Guerra',
  subtitle: '34 flashcards',
  progress: 0.45,
  onContinue: () => _openFlashcards(context, 'História - Segunda Guerra'),
),
const SizedBox(height: 12),

TopicCard(
  title: 'Biologia - Células',
  subtitle: '18 flashcards',
  progress: 0.30,
  onContinue: () => _openFlashcards(context, 'Biologia - Células'),
),

              const SizedBox(height: 16),

              // Meta diária + Sequência (caixas pequenas)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: _box(),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Meta diária', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 6),
                          Text('44min de\nestudo', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 8),
                          ProgressBar(value: 0.73, height: 8),
                          SizedBox(height: 6),
                          Text('44/60', style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 140,
                    padding: const EdgeInsets.all(14),
                    decoration: _box(),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sequência', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(height: 10),
                        Text('7', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
                        Text('dias', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _box() => BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cement),
      );
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ash,
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

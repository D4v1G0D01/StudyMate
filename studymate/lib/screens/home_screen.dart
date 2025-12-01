import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studymate/screens/login.dart';
import '../theme/app_colors.dart';
import '../widgets/topic_card.dart';
import 'flashcard_detail_screen.dart'; // 🔹 importa a tela de Flashcards

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openFlashcards(BuildContext context, String title) {
    // Verifica se há um usuário logado
    if (FirebaseAuth.instance.currentUser != null) {
      // 3. Se logado: Navega para a tela de flashcards
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FlashcardDetailScreen(title: title),
        ),
      );
    } else {
      // 4. Se NÃO logado: Redireciona para a tela de Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para acessar os flashcards.'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    }
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
              ),
              const SizedBox(height: 24),
              const Text('Tópicos Recentes',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              // 🔹 Torna os TopicCards clicáveis
              TopicCard(
                title: 'Matemática - \nTrigonometria',
                subtitle: '24 flashcards',
                progress: 0.65,
                onContinue: () =>
                    _openFlashcards(context, 'Matemática - Trigonometria'),
              ),
              const SizedBox(height: 12),

              TopicCard(
                title: 'História -\nSegunda Guerra',
                subtitle: '34 flashcards',
                progress: 0.45,
                onContinue: () =>
                    _openFlashcards(context, 'História - Segunda Guerra'),
              ),
              const SizedBox(height: 12),

              TopicCard(
                title: 'Biologia - Células',
                subtitle: '18 flashcards',
                progress: 0.30,
                onContinue: () =>
                    _openFlashcards(context, 'Biologia - Células'),
              ),

              const SizedBox(height: 16),
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

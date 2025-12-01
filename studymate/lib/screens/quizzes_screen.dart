import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studymate/screens/login.dart';
import '../theme/app_colors.dart';
import 'quiz_detail_screen.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_QuizItem> _customQuizzes = [];

  void _addQuiz() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _customQuizzes.add(_QuizItem(text, '⚡ 10 Questões'));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<_QuizItem> allQuizzes = [
      const _QuizItem('Matemática - Funções Quadráticas', ''),
      const _QuizItem('História do Brasil: República', ''),
      const _QuizItem('Biologia - Genética Básica', ''),
      const _QuizItem('Química - Cadeias Carbônicas', ''),
      ..._customQuizzes,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        Container(
          color: AppColors.ash,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quizzes',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              // 🔹 Campo de texto + botão adicionar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Adicionar novo tema de quiz...",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addQuiz,
                    icon: const Icon(Icons.add),
                    label: const Text("Adicionar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              
              const SizedBox(height: 18),

              _QuizGrid(items: allQuizzes),
            ],
          ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        ),
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
              crossAxisCount: cross,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: .78,
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
            if (FirebaseAuth.instance.currentUser != null) {
                  // Se ESTIVER logado, navega para a tela de estudo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  QuizDetailScreen(title: title),
                    ),
                  );
                } else {
                  // Se NÃO ESTIVER logado, exibe uma mensagem e leva para o Login
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Você precisa fazer login para estudar.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              child: const Text('Estudar'),
          ),
        ),
      ]),
    );
  }
}



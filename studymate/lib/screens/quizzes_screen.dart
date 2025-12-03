import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Criação do Tópico (Inicializa contadores zerados)
  Future<void> _addQuiz(User user) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('topics').add({
        'uid': user.uid,
        'title': text,
        'type': 'quiz',
        'questionCount': 0,
        'answeredCount': 0,
        'correctCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _controller.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  Future<void> _deleteTopic(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Quiz?"),
        content: const Text("Essa ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('topics').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentUser = authSnapshot.data;

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
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  
                  // Input de Novo Quiz
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: currentUser != null
                                ? "Adicionar novo tema..."
                                : "Faça login para adicionar",
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabled: currentUser != null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: currentUser != null
                            ? () => _addQuiz(currentUser)
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              },
                        icon: const Icon(Icons.add),
                        label: const Text("Adicionar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (currentUser == null)
                    _buildLoginWarning(context)
                  else
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('topics')
                          .where('uid', isEqualTo: currentUser.uid)
                          .where('type', isEqualTo: 'quiz')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return const Center(child: Text("Nenhum quiz encontrado."));
                        }

                        // Grid de Quizzes
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
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: docs.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cross,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.78,
                                ),
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  final data = doc.data() as Map<String, dynamic>;

                                  return _QuizItem(
                                    title: data['title'] ?? 'Sem título',
                                    docId: doc.id,
                                    onDelete: () => _deleteTopic(doc.id),
                                    // Pega os contadores do Firestore
                                    total: data['questionCount'] ?? 0,
                                    answered: data['answeredCount'] ?? 0,
                                    correct: data['correctCount'] ?? 0,
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoginWarning(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text("Faça login para ver seus quizzes"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginPage())),
            child: const Text("Ir para Login"),
          )
        ],
      ),
    );
  }
}

class _QuizItem extends StatelessWidget {
  final String title, docId;
  final VoidCallback onDelete;
  final int total, answered, correct;

  const _QuizItem({
    super.key,
    required this.title,
    required this.docId,
    required this.onDelete,
    required this.total,
    required this.answered,
    required this.correct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black54, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Lógica de exibição dos contadores
          if (total == 0)
            const Text("0 questões",
                style: TextStyle(color: Colors.black54, fontSize: 12))
          else ...[
            Text(
              '$total questões',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            if (answered > 0) ...[
              Text(
                'Resp: $answered/$total',
                style: const TextStyle(color: Colors.black54, fontSize: 11),
              ),
              Text(
                'Acertos: $correct',
                style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 11),
              ),
            ] else
              const Text("Não iniciado",
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                // Navega passando o ID do documento
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuizDetailScreen(title: title, topicId: docId),
                  ),
                );
                // Atualiza a tela ao voltar (para atualizar contadores)
                if (context.mounted) {
                  (context as Element).markNeedsBuild();
                }
              },
              child: const Text('Estudar'),
            ),
          ),
        ],
      ),
    );
  }
}
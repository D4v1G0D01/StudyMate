import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studymate/screens/login.dart';
import '../theme/app_colors.dart';
import 'flashcard_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _addFlashcard(User user) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('topics').add({
        'uid': user.uid,
        'title': text,
        'subtitle': '0 cards', // Você pode atualizar isso depois com a qtde real
        'type': 'flashcard',
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
    // Pergunta antes de apagar (Segurança)
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Tópico?"),
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
                  const Text('Flashcards',
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  
                  // Campo de Input + Botão
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: currentUser != null
                                ? "Adicionar novo flashcard..."
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
                            ? () => _addFlashcard(currentUser)
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
                          .where('type', isEqualTo: 'flashcard')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final docs = snapshot.data?.docs ?? [];
                        
                        if (docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("Nenhum tópico criado ainda."),
                            ),
                          );
                        }

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
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cross,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.78,
                                ),
                                itemBuilder: (context, index) {

                                  final doc = docs[index];
                                  final data = doc.data() as Map<String, dynamic>;

                                  return _CardItem(
                                    title: data['title'] ?? 'Sem título',
                                    docId: doc.id,
                                    onDelete: () => _deleteTopic(doc.id),
                                    count: data['cardCount'] ?? 0,
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
          const Text("Faça login para ver seus flashcards"),
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

class _CardItem extends StatelessWidget {
  final String title, docId;
  final VoidCallback onDelete;
  final int count;

  const _CardItem({
    super.key,
    required this.title,
    required this.docId,
    required this.onDelete,
    required this.count,
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
          const SizedBox(height: 4),

          Text(
            '$count cards', 
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),

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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardDetailScreen(
                      title: title, 
                      topicId: docId // Passa o ID
                    ),
                  ),
                );
                // Atualiza a tela ao voltar
                if (context.mounted) (context as Element).markNeedsBuild();
              },
              child: const Text('Estudar'),
            ),
          ),
        ],
      ),
    );
  }
}
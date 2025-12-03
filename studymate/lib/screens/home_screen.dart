import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studymate/screens/login.dart';
import '../theme/app_colors.dart';
import 'flashcard_detail_screen.dart';
import 'quiz_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const Center(child: Text("Faça login para ver seu progresso."));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            Container(
              color: AppColors.ash,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Olá, Estudante! 👋',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Tópicos Recentes',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('topics')
                        .where('uid', isEqualTo: user.uid)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text("Nenhum estudo iniciado ainda."),
                        );
                      }

                      return Column(
                        children: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return _RecentTopicCard(
                            title: data['title'] ?? '',
                            type: data['type'] ?? 'flashcard',
                            docId: doc.id,
                            // Passa os dados diretos do documento
                            stats: data, 
                          );
                        }).toList(),
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
}

class _RecentTopicCard extends StatelessWidget {
  final String title;
  final String type;
  final String docId;
  final Map<String, dynamic> stats; // Recebe os dados brutos

  const _RecentTopicCard({
    required this.title,
    required this.type,
    required this.docId,
    required this.stats,
  });

  // Busca estatísticas (adaptado para nova lógica híbrida ou local)
  Future<Map<String, dynamic>> _getStats() async {
    
    final prefs = await SharedPreferences.getInstance();

    if (type == 'flashcard') {
      return {'count': 0, 'progress': 0.0}; 
    } else {
      return {'count': 0, 'progress': 0.0};
    }
  }

  void _navigateToDetail(BuildContext context) async {
    if (type == 'flashcard') {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FlashcardDetailScreen(
              title: title, 
              topicId: docId
            )),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QuizDetailScreen(
              title: title, 
              topicId: docId
            )),
      );
    }
    // Força atualização ao voltar
    if (context.mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isQuiz = type == 'quiz';
    
    final count = isQuiz 
        ? (stats['questionCount'] ?? 0) 
        : (stats['cardCount'] ?? 0);
        
    final answered = stats['answeredCount'] ?? 0;
    
    // Cálculo seguro de progresso
    double progress = 0.0;
    if (isQuiz && count > 0) {
      progress = answered / count;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isQuiz ? Colors.purple[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isQuiz ? Icons.quiz_outlined : Icons.style_outlined,
                  color: isQuiz ? Colors.purple : Colors.blue[800],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "Toque para abrir", // Simplifiquei o texto pois o contador local não é mais confiável
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _navigateToDetail(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Abrir", style: TextStyle(fontSize: 12)),
              )
            ],
          ),
        ],
      ),
    );
  }
}
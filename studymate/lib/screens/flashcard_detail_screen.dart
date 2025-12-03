import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_colors.dart';

class FlashcardDetailScreen extends StatefulWidget {
  final String title;
  final String topicId;

  const FlashcardDetailScreen({
    super.key, 
    required this.title, 
    required this.topicId
  });

  @override
  State<FlashcardDetailScreen> createState() => _FlashcardDetailScreenState();
}

class _FlashcardDetailScreenState extends State<FlashcardDetailScreen> {
  bool loading = false;
  int currentIndex = 0;
  bool showAnswer = false;

  // Referência para a subcoleção deste tópico específico
  CollectionReference get cardsRef => FirebaseFirestore.instance
      .collection('topics')
      .doc(widget.topicId)
      .collection('cards');

  Future<void> generateFlashcards() async {
    const openRouterKey = "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";
    const endpoint = "https://openrouter.ai/api/v1/chat/completions";

    setState(() {
      loading = true;
      showAnswer = false;
      currentIndex = 0;
    });

    try {
      final snapshot = await cardsRef.get();
      String previousCards = snapshot.docs.map((d) => d['frente']).join("; ");

      final prompt = """
      Gere OBRIGATORIAMENTE 10 flashcards únicos e variados sobre o tema "${widget.title}"
      CONTEXTO:
      O usuário já tem estes cards, NÃO GERE PERGUNTAS REPETIDAS OU SIMILARES A ESTAS:
      $previousCards.
      Cada flashcard deve ter:
      Frente: uma pergunta curta ou termo.
      Verso: uma explicação objetiva e correta.
      Evite perguntas semelhantes ou repetidas.
      Formato EXATO:
      1. Frente: ...
        Verso: ...
      2. Frente: ...
        Verso: ...
      """;

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Authorization": "Bearer $openRouterKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://studymate.app",
          "X-Title": "StudyMate",
        },
        body: jsonEncode({
          "model": "mistralai/mistral-7b-instruct",
          "messages": [{"role": "user", "content": prompt}],
          "temperature": 1.0,
          "max_tokens": 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data["choices"][0]["message"]["content"];
        final newCards = _parseFlashcards(text);

        if (newCards.isNotEmpty) {
          final batch = FirebaseFirestore.instance.batch();
          final topicRef = FirebaseFirestore.instance.collection('topics').doc(widget.topicId);

          for (var card in newCards) {
            final docRef = cardsRef.doc();
            batch.set(docRef, {
              'frente': card['frente'],
              'verso': card['verso'],
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          batch.update(topicRef, {
            'cardCount': FieldValue.increment(newCards.length),
          });

          await batch.commit();
        }
      }
    } catch (e) {
      print("Erro: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<Map<String, String>> _parseFlashcards(String text) {
    final regex = RegExp(r'\d+\.\s*Frente:\s*(.*?)\s*Verso:\s*(.*?)(?=\d+\.|$)', dotAll: true);
    return regex.allMatches(text).map((m) => {
          "frente": m.group(1)!.trim(),
          "verso": m.group(2)!.trim(),
        }).toList();
  }

  void nextCard(int total) {
    if (currentIndex < total - 1) {
      setState(() {
        currentIndex++;
        showAnswer = false;
      });
    }
  }

  void previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.nero,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: generateFlashcards,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cardsRef.orderBy('createdAt', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (loading) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: generateFlashcards,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, 
                  foregroundColor: Colors.white
                ),
                child: const Text("Gerar Flashcards com IA"),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          if (currentIndex >= docs.length) currentIndex = 0; 

          final currentCard = docs[currentIndex].data() as Map<String, dynamic>;

          return Container(
            color: AppColors.ash,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    constraints: const BoxConstraints(minHeight: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Flashcard ${currentIndex + 1}/${docs.length}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          showAnswer ? currentCard['verso'] : currentCard['frente'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: showAnswer ? Colors.green[800] : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() => showAnswer = !showAnswer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(showAnswer ? "Ocultar Resposta" : "Mostrar Resposta"),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: currentIndex > 0 ? previousCard : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: currentIndex < docs.length - 1 ? () => nextCard(docs.length) : null,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
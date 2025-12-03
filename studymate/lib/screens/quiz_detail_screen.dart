import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_colors.dart';

class QuizDetailScreen extends StatefulWidget {
  final String title;
  final String topicId;

  const QuizDetailScreen({
    super.key,
    required this.title,
    required this.topicId,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  bool loading = false;

  CollectionReference get questionsRef => FirebaseFirestore.instance
      .collection('topics')
      .doc(widget.topicId)
      .collection('questions');

  Future<void> _submitAnswer(String docId, int selectedIndex, String correctText, String selectedText) async {
    bool isCorrect = false;
    
    // Normalização para comparação (remove espaços e ignora maiúsculas/minúsculas)
    final sText = selectedText.trim().toLowerCase();
    final cText = correctText.trim().toLowerCase();
    
    // Verifica se a opção contém o texto da resposta ou se começa com a mesma letra (ex: "a)")
    if (sText.contains(cText) || sText.split(')')[0] == cText.split(')')[0]) {
      isCorrect = true;
    }

    // 1. Atualiza a questão individual
    await questionsRef.doc(docId).update({
      'userSelected': selectedIndex,
      'isRevealed': true,
    });

    // 2. Atualiza o contador global no Tópico Pai (para a tela de listagem)
    final topicRef = FirebaseFirestore.instance.collection('topics').doc(widget.topicId);
    await topicRef.update({
      'answeredCount': FieldValue.increment(1),
      'correctCount': FieldValue.increment(isCorrect ? 1 : 0),
    });
  }

  Future<void> generateQuestions() async {
    const openRouterKey = "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";
    const endpoint = "https://openrouter.ai/api/v1/chat/completions";

    setState(() => loading = true);

    try {
      final topicRef = FirebaseFirestore.instance.collection('topics').doc(widget.topicId);
      final snapshot = await questionsRef.get();
      
      // Pega perguntas anteriores para evitar repetição
      String contextData = snapshot.docs.map((d) => (d.data() as Map)['pergunta'] ?? '').join(", ");

      final prompt = """
      Gere 10 perguntas de múltipla escolha sobre "${widget.title}".
      Evite repetir: $contextData.

      REGRAS DE FORMATAÇÃO (IMPORTANTE):
      1. Separe CADA pergunta com uma linha contendo apenas "---".
      2. Não numere as perguntas (Não escreva "1.", apenas o texto).
      3. Indique a resposta correta com o prefixo "Correta:".

      MODELO EXATO DE SAÍDA:
      Qual é a capital da França?
      A) Londres
      B) Paris
      C) Berlim
      D) Madri
      Correta: B) Paris
      ---
      Qual a fórmula da água?
      A) H2O
      B) CO2
      C) O2
      D) NaCl
      Correta: A) H2O
      ---
      (Continue até completar 10 perguntas)
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
          "temperature": 0.5, // Mais baixo para ser mais fiel à formatação
          "max_tokens": 2500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data["choices"][0]["message"]["content"];
        
        print("🤖 RAW TEXT: $text"); // Debug

        // Chama o parser corrigido
        final newQuestions = _parseQuestions(text);

        print("✅ Perguntas extraídas: ${newQuestions.length}"); // Debug

        if (newQuestions.isNotEmpty) {
          final batch = FirebaseFirestore.instance.batch();

          for (var q in newQuestions) {
            final doc = questionsRef.doc();
            batch.set(doc, {
              ...q,
              'userSelected': null,
              'isRevealed': false,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
          
          // Atualiza o contador de total de questões
          batch.update(topicRef, {
            'questionCount': FieldValue.increment(newQuestions.length),
          });

          await batch.commit();
        } else {
           throw "O parser retornou 0 perguntas. Verifique o console.";
        }
      } else {
        throw "Erro API: ${response.statusCode}";
      }
    } catch (e) {
      print("Erro: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> _parseQuestions(String text) {
    List<Map<String, dynamic>> result = [];
    
    final blocks = text.split('---');

    for (var block in blocks) {
      final lines = block.trim().split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      
      if (lines.length < 4) continue;

      String pergunta = "";
      List<String> opcoes = [];
      String? correta;

      for (var line in lines) {
        if (RegExp(r'^[A-D]\)').hasMatch(line)) {
          opcoes.add(line);
        } else if (line.toLowerCase().startsWith('correta:')) {
          correta = line.split(':').sublist(1).join(':').trim();
        } else {
          if (pergunta.isEmpty) pergunta = line;
        }
      }

      if (pergunta.isNotEmpty && opcoes.length >= 2 && correta != null) {
        result.add({
          "pergunta": pergunta,
          "opcoes": opcoes,
          "correta": correta,
        });
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz: ${widget.title}"),
        backgroundColor: AppColors.nero,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Gerar mais perguntas",
            onPressed: generateQuestions,
          )
        ],
      ),
      body: loading 
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            stream: questionsRef.orderBy('createdAt').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text("Nenhuma pergunta encontrada."),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: generateQuestions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Gerar Perguntas com IA"),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  
                  final opcoes = List<String>.from(data['opcoes'] ?? []);
                  final correta = data['correta'] ?? "";
                  final userSelected = data['userSelected'] as int?;
                  final isRevealed = data['isRevealed'] as bool? ?? false;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${index + 1}. ${data['pergunta']}", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(opcoes.length, (optIndex) {
                            return RadioListTile<int>(
                              title: Text(opcoes[optIndex]),
                              value: optIndex,
                              groupValue: userSelected,
                              activeColor: Colors.black,
                              contentPadding: EdgeInsets.zero,
                              onChanged: isRevealed ? null : (val) {
                                // Passa os textos para validar a resposta
                                _submitAnswer(doc.id, val!, correta, opcoes[val]);
                              },
                            );
                          }),
                          
                          if (isRevealed)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Correta: $correta", 
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_colors.dart';

class QuizDetailScreen extends StatefulWidget {
  final String title;
  const QuizDetailScreen({super.key, required this.title});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  bool loading = true;
  List<Map<String, dynamic>> questions = [];
  List<int?> selectedAnswers = [];
  List<bool> revealedAnswers = [];

  @override
  void initState() {
    super.initState();
    generateQuestions(initial: true);
  }

  Future<void> generateQuestions({bool initial = false}) async {
    const openRouterKey = String.fromEnvironment("OPENROUTER_KEY");
    const endpoint = "https://openrouter.ai/api/v1/chat/completions";

    // Histórico das perguntas já geradas
    String previousQuestions = questions.isEmpty
        ? "Nenhuma pergunta anterior."
        : questions.map((q) => q["pergunta"]).join("\n");

    int offset = questions.length;

    final prompt = """
Você é um gerador de quizzes inteligentes em português.
Gere 5 novas perguntas de múltipla escolha **diferentes das anteriores**, sobre o tema "${widget.title}".

Evite repetir tópicos, anos, nomes ou fatos já citados abaixo:
${previousQuestions}

Cada pergunta deve:
- Ser objetiva e clara.
- Ter 4 alternativas (A, B, C, D).
- Indicar qual é a alternativa correta.
- Continuar a numeração a partir de ${offset + 1}.

Formato EXATO:
Pergunta ${offset + 1}: ...
A) ...
B) ...
C) ...
D) ...
Correta: ...
""";

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Authorization": "Bearer $openRouterKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://studymate.app",
          "X-Title": "StudyMate"
        },
        body: jsonEncode({
          "model": "mistralai/mistral-7b-instruct",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.9, // mais criatividade
          "max_tokens": 800
        }),
      );

      print("Código da resposta: ${response.statusCode}");
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data["choices"][0]["message"]["content"];

        // Remove ruídos e tokens indesejados
        text = text
            .replaceAll(RegExp(r'<.?s>'), '')
            .replaceAll(RegExp(r'<.?/?>'), '')
            .replaceAll(RegExp(r'\*\*'), '')
            .replaceAll(RegExp(r'---'), '')
            .replaceAll(RegExp(r'\r'), '')
            .trim();

        final newQuestions = _parseQuestions(text);

        setState(() {
          if (initial) {
            questions = newQuestions;
          } else {
            for (var q in newQuestions) {
              if (!questions.any((old) => old["pergunta"] == q["pergunta"])) {
                questions.add(q);
              }
            }
          }

          selectedAnswers = List.filled(questions.length, null);
          revealedAnswers = List.filled(questions.length, false);
          loading = false;
        });
      } else {
        print("Erro: ${response.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      print("Erro ao gerar perguntas: $e");
      setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> _parseQuestions(String text) {
    final blocks = text.split(RegExp(r'(?=Pergunta\s*\d*:)'));
    List<Map<String, dynamic>> qList = [];

    for (var block in blocks) {
      final lines =
          block.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (lines.isEmpty) continue;

      String pergunta = lines.first.trim();
      List<String> opcoes = [];
      String? correta;

      for (var line in lines.skip(1)) {
        final l = line.trim();
        if (RegExp(r'^[A-D]\)').hasMatch(l)) {
          opcoes.add(l);
        } else if (l.toLowerCase().startsWith('correta')) {
          correta = l.split(':').last.trim();
        }
      }

      if (pergunta.isNotEmpty && opcoes.isNotEmpty && correta != null) {
        qList.add({
          "pergunta": pergunta,
          "opcoes": opcoes,
          "correta": correta,
        });
      }
    }

    return qList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quiz - ${widget.title}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.nero,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Gerar novas perguntas",
            onPressed: () => generateQuestions(),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? const Center(child: Text("Não foi possível gerar perguntas."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (_, i) {
                    final q = questions[i];
                    final opcoes = q["opcoes"] as List<String>;
                    final correta = q["correta"] as String;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              q["pergunta"],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),

                            ...List.generate(opcoes.length, (j) {
                              return RadioListTile<int>(
                                title: Text(opcoes[j]),
                                value: j,
                                groupValue: selectedAnswers[i],
                                onChanged: revealedAnswers[i]
                                    ? null
                                    : (value) {
                                        setState(() {
                                          selectedAnswers[i] = value;
                                        });
                                      },
                              );
                            }),

                            const SizedBox(height: 8),

                            ElevatedButton(
                              onPressed: revealedAnswers[i]
                                  ? null
                                  : () {
                                      if (selectedAnswers[i] != null) {
                                        setState(() {
                                          revealedAnswers[i] = true;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.nero,
                              ),
                              child: const Text("Confirmar"),
                            ),

                            if (revealedAnswers[i])
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  "Resposta correta: $correta",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

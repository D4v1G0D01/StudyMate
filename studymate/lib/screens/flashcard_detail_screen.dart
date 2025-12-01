import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class FlashcardDetailScreen extends StatefulWidget {
  final String title;

  const FlashcardDetailScreen({super.key, required this.title});

  @override
  State<FlashcardDetailScreen> createState() => _FlashcardDetailScreenState();
}

class _FlashcardDetailScreenState extends State<FlashcardDetailScreen> {
  bool loading = false;
  List<Map<String, String>> flashcards = [];
  int currentIndex = 0;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('flashcards_${widget.title}');
    if (saved != null) {
      setState(() {
        flashcards = saved.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
      });
    }
  }

  Future<void> _saveFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = flashcards.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('flashcards_${widget.title}', encoded);
  }

  Future<void> generateFlashcards() async {
    const openRouterKey = String.fromEnvironment("OPENROUTER_KEY");
    const endpoint = "https://openrouter.ai/api/v1/chat/completions";

    final prompt = """
Gere 10 flashcards únicos e variados sobre o tema "${widget.title}".
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

    setState(() {
      loading = true;
      showAnswer = false;
      currentIndex = 0;
    });

    try {
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
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 1.0,
          "max_tokens": 900,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data["choices"][0]["message"]["content"]
            .replaceAll(RegExp(r'\r'), '')
            .replaceAll(RegExp(r'\*'), '')
            .trim();

        final newCards = _parseFlashcards(text);

        if (newCards.isNotEmpty) {
          setState(() {
            flashcards.addAll(newCards);
            loading = false;
          });
          await _saveFlashcards();
        } else {
          setState(() => loading = false);
        }
      } else {
        print("Erro: ${response.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      print("Erro ao gerar flashcards: $e");
      setState(() => loading = false);
    }
  }

  /// 🔹 Parser robusto (detecção por blocos 1. Frente / Verso)
  List<Map<String, String>> _parseFlashcards(String text) {
    final regex = RegExp(
        r'\d+\.\s*Frente:\s*(.*?)\s*Verso:\s*(.*?)(?=\d+\.|$)',
        dotAll: true,
        caseSensitive: false);
    final matches = regex.allMatches(text);
    return matches
        .map((m) => {
              "frente": m.group(1)!.trim(),
              "verso": m.group(2)!.trim(),
            })
        .where((c) => c["frente"]!.isNotEmpty && c["verso"]!.isNotEmpty)
        .toList();
  }

  void nextCard() {
    if (currentIndex < flashcards.length - 1) {
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
    final hasCards = flashcards.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Flashcards - ${widget.title}",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.nero,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Gerar novos flashcards",
            onPressed: generateFlashcards,
          ),
        ],
      ),
      body: Container(
        color: AppColors.ash,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : !hasCards
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Clique abaixo para gerar 10 flashcards sobre o tema.",
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: generateFlashcards,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(14),
                          ),
                          child: const Text("Gerar Flashcards"),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Flashcard ${currentIndex + 1}/${flashcards.length}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  showAnswer
                                      ? flashcards[currentIndex]['verso'] ?? ''
                                      : flashcards[currentIndex]['frente'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: showAnswer
                                        ? Colors.green[800]
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => showAnswer = !showAnswer),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          child: Text(
                            showAnswer
                                ? "Ocultar resposta"
                                : "Mostrar resposta",
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              iconSize: 36,
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: previousCard,
                            ),
                            IconButton(
                              iconSize: 36,
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: nextCard,
                            ),
                          ],
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_colors.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _controller = TextEditingController();
  String responseText = "";
  bool loading = false;

  Future<void> askAI() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      loading = true;
      responseText = "";
    });

    const apiKey = String.fromEnvironment("OPENROUTER_KEY");
    const endpoint = "https://openrouter.ai/api/v1/chat/completions";

    final body = jsonEncode({
      "model": "gpt-4o-mini",
      "messages": [
        {"role": "user", "content": question}
      ],
      "temperature": 0.7,
      "max_tokens": 400
    });

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://studymate.app",
          "X-Title": "StudyMate"
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data["choices"][0]["message"]["content"];
        setState(() {
          responseText = text.trim();
          loading = false;
        });
      } else {
        setState(() {
          responseText =
              "Erro ${response.statusCode}: não foi possível gerar resposta.";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        responseText = "Erro ao conectar com a IA: $e";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Área da IA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.nero,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          Container(
            color: AppColors.ash,
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Pergunte ao seu parceiro',
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset('assets/logo_brain.png',
                          width: 56, height: 56, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 12),
                    const Text('Tudo pronto? Então vamos lá!',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Campo de texto para digitar a pergunta
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Digite a sua pergunta aqui...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.cement),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                minLines: 1,
                maxLines: 4,
              ),

              const SizedBox(height: 12),

              // Botão de envio
              ElevatedButton.icon(
                onPressed: loading ? null : askAI,
                icon: const Icon(Icons.send),
                label: const Text("Perguntar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.nero,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Resposta da IA
              if (loading)
                const Center(child: CircularProgressIndicator())
              else if (responseText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cement),
                  ),
                  child: Text(
                    responseText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

              const SizedBox(height: 24),
              const Text('Dicas para os melhores prompts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cement),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bullet('Seja específico na sua pergunta'),
                    _Bullet('Mencione o nível de profundidade desejado'),
                    _Bullet('Peça exemplos práticos'),
                    _Bullet('Solicite analogias para melhor compreensão'),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}

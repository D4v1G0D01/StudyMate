import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'flashcard_detail_screen.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_CardItem> _customCards = [];

  void _addFlashcard() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _customCards.add(_CardItem(text, '1 flashcard'));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<_CardItem> allCards = [
      const _CardItem('Matemática - Trigonometria', '24 flashcards'),
      const _CardItem('História - Segunda Guerra', '34 flashcards'),
      const _CardItem('Biologia - Células', '18 flashcards'),
      const _CardItem('Química - Tabela Periódica', '40 flashcards'),
      ..._customCards,
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
              const Text('Flashcards',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              // 🔹 Campo de texto + botão adicionar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Adicionar novo flashcard...",
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
                    onPressed: _addFlashcard,
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

              Row(
                children: [
                  _MetricBox(title: 'Total de cards', value: '${allCards.length}'),
                  const SizedBox(width: 16),
                  const _MetricBox(title: 'Cards dominados', value: '54'),
                ],
              ),
              const SizedBox(height: 18),

              _Grid(items: allCards),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String title, value;
  const _MetricBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cement),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final List<_CardItem> items;
  const _Grid({required this.items});

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

class _CardItem extends StatelessWidget {
  final String title, subtitle;
  const _CardItem(this.title, this.subtitle);

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
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardDetailScreen(title: title),
                  ),
                );
              },
              child: const Text('Estudar'),
            ),
          ),
        ],
      ),
    );
  }
}

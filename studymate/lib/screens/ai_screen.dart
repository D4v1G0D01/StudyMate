import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        Container(
          color: AppColors.ash,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Área da IA', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            const Text('Pergunte à IA', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            // bloco central com a logo
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
                    child: Image.asset('assets/logo_brain.png', width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tudo pronto? Então vamos lá!', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // input fake estático
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cement),
              ),
              child: const Text('Digite a sua pergunta aqui...', style: TextStyle(color: Colors.black54)),
            ),
            const SizedBox(height: 24),
            const Text('Dicas para os melhores prompts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
          const Text('•  ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/flashcards_screen.dart';
import 'screens/quizzes_screen.dart';
import 'package:studymate/screens/Profile_screen.dart';

void main() {
  runApp(const StudyMateApp());
}

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.nero,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      home: const _Shell(),
    );
  }
}

/// Shell com bottom navigation FIXO + IndexedStack
class _Shell extends StatefulWidget {
  const _Shell({Key? key}) : super(key: key);

  @override
  State<_Shell> createState() => _ShellState();
}


class _ShellState extends State<_Shell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    AIScreen(),
    FlashcardsScreen(),
    QuizzesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyMate'),
        actions: [
          IconButton(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            icon: const Icon(Icons.person),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile_screen())
              );
            })
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _FooterNav(
        current: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Rodapé cinza fixo com ícones (fica sempre visível)
class _FooterNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;

  const _FooterNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.footer,
          border: Border(top: BorderSide(color: AppColors.cement, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Item(icon: Icons.home_filled, label: 'Home', index: 0, current: current, onTap: onTap),
            _Item(icon: Icons.smart_toy, label: 'IA', index: 1, current: current, onTap: onTap),
            _Item(icon: Icons.view_agenda, label: 'Cards', index: 2, current: current, onTap: onTap),
            _Item(icon: Icons.quiz_rounded, label: 'Quizzes', index: 3, current: current, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _Item({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: active ? 26 : 24, color: Colors.black87),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}

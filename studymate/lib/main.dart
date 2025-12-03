import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:studymate/screens/firebase_options.dart';
import 'package:studymate/screens/profile_screen.dart';
import 'package:studymate/screens/login.dart';
import 'package:studymate/theme/theme_controller.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/flashcards_screen.dart';
import 'screens/quizzes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  await ThemeController.loadTheme();

  runApp(const StudyMateApp());
}

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'StudyMate',
          debugShowCheckedModeBanner: false,
          
          theme: ThemeData(
            useMaterial3: false,
            scaffoldBackgroundColor: AppColors.ash, 
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

          darkTheme: ThemeData(
            useMaterial3: false,
            brightness: Brightness.dark, 
            scaffoldBackgroundColor: const Color(0xFF121212), // Fundo preto
            cardColor: const Color(0xFF1E1E1E), // Cards cinza escuro
            fontFamily: 'Arial',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black),
              titleMedium: TextStyle(color: Colors.black),
              titleSmall: TextStyle(color: Colors.black),
              displayLarge: TextStyle(color: Colors.black),
              displayMedium: TextStyle(color: Colors.black),
              displaySmall: TextStyle(color: Colors.black),
              headlineMedium: TextStyle(color: Colors.black),
              headlineSmall: TextStyle(color: Colors.black),
              labelLarge: TextStyle(color: Colors.black),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black, // AppBar preta
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

          themeMode: currentMode,
          
          home: const _Shell(),
        );
      },
    );
  }
}

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
            onPressed: () {
              if (FirebaseAuth.instance.currentUser != null) {
                Navigator.push(
                  context,
                  // Garanta que o nome da classe aqui é ProfileScreen (maiusculo)
                  MaterialPageRoute(builder: (context) => const ProfileScreen()) 
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage())
                );
              }
            }
          )
        ],
      ),
      // Usa IndexedStack para manter o estado das abas
      body: IndexedStack(index: _index, children: _pages),
      
      bottomNavigationBar: _FooterNav(
        current: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Rodapé cinza fixo com ícones
class _FooterNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;

  const _FooterNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Detecta se está escuro para ajustar a cor do rodapé
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          // Ajusta a cor do footer no modo escuro para não ficar estranho
          color: isDark ? const Color(0xFF1E1E1E) : AppColors.footer,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[800]! : AppColors.cement, 
              width: 1
            )
          ),
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
    const iconColor = Colors.black87; 

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: active ? 26 : 24, color: iconColor),
          const SizedBox(height: 2),
          Text(
            label, 
            style: TextStyle(
              fontSize: 11, 
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: iconColor
            )
          ),
        ],
      ),
    );
  }
}
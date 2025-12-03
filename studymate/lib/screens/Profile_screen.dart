import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studymate/theme/app_colors.dart';
import 'package:studymate/theme/theme_controller.dart';
import 'package:studymate/widgets/stat_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? 'Email não encontrado';
    final String nome = user?.displayName ?? email.split('@')[0];
    final String photoUrl = user?.photoURL ?? '';

    // Verifica se o modo atual é escuro para ajustar o Switch
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      // ⚠️ IMPORTANTE: Removemos o Container com cor fixa. 
      // O Scaffold já usa a cor do tema definida no main.dart
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.nero,
                backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 75, color: Colors.white)
                    : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: 400,
                child: StatCard(title: 'Nome', value: nome, subtitle: 'Nome de exibição'),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 400,
                child: StatCard(title: 'Email', value: email, subtitle: 'Conta Google'),
              ),

              const SizedBox(height: 20),
              
              Container(
                width: 400,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  // Usa a cor do cartão do tema atual
                  color: Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade600),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Aparência", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Modo Escuro", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: isDarkMode,
                      activeColor: AppColors.success,
                      onChanged: (val) {
                        // Chama o controller global
                        ThemeController.toggleTheme(val);
                      }, 
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 400,
                child: StatCard(title: 'ID', value: 'Protegido', subtitle: user?.uid ?? '...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
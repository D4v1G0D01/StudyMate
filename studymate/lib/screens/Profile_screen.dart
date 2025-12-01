import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studymate/theme/app_colors.dart';
import 'package:studymate/widgets/stat_card.dart';
import 'package:studymate/screens/login.dart'; // Para redirecionar se sair

class Profile_screen extends StatelessWidget {
  const Profile_screen({super.key});

  // Função para deslogar
  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Fecha a tela de perfil e volta para a home
    Navigator.pop(context); 
    
    // Opcional: Mostrar aviso que saiu
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você saiu da conta.'))
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Pegar o usuário atual logado
    final User? user = FirebaseAuth.instance.currentUser;

    // Se por acaso o usuário for nulo (erro raro), mostramos algo padrão
    final String email = user?.email ?? 'Email não encontrado';
    List<String> partesEmail = email.split('@');
    final String nome = user?.displayName ?? partesEmail[0]; // O nome precisa ser configurado no cadastro
    final String photoUrl = user?.photoURL ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: Colors.black,
        actions: [
           // Botão de Sair na barra superior
           IconButton(
             icon: const Icon(Icons.logout),
             onPressed: () => _signOut(context),
           )
        ],
      ),
      body: Container(
        color: AppColors.ash,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color.fromARGB(255, 23, 0, 0),
                // Se tiver foto no Firebase mostra ela, senão mostra o ícone
                backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty 
                    ? const Icon(Icons.person, size: 75, color: Colors.white) 
                    : null,
              ),

              const SizedBox(height: 60),

              // CARTÃO 1: Nome (Do Firebase ou Padrão)
              SizedBox(
                width: 400,
                child: StatCard(
                    title: 'Nome', 
                    value: nome, // Variável do Firebase
                    subtitle: 'Nome de exibição'
                ),
              ),
              
              const SizedBox(height: 20),

              // CARTÃO 2: Email (Do Firebase - Esse é o mais importante)
              SizedBox(
                width: 400,
                child: StatCard(
                    title: 'Email', 
                    value: email, // Variável do Firebase
                    subtitle: user?.emailVerified == true ? 'Verificado' : 'Não verificado'
                ),
              ),

              const SizedBox(height: 20),

              // CARTÃO 3: ID do Usuário (UID é único no Firebase)
              SizedBox(
                width: 400,
                child: StatCard(
                    title: 'ID da Conta', 
                    value: 'ID Seguro', 
                    subtitle: user?.uid ?? '...'
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Botão de Sair Grande (Opcional, já tem no AppBar)
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _signOut(context),
                  child: const Text("Sair da Conta"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
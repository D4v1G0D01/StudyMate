import 'package:flutter/material.dart';
import 'package:studymate/theme/app_colors.dart';
import 'package:studymate/widgets/stat_card.dart';

class Profile_screen extends StatelessWidget{
  const Profile_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: Colors.black
      ),

      
      body: Container(
        
        color: AppColors.ash,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
          
        child: const SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              CircleAvatar(
                radius: 60, // tamanho do círculo
                backgroundColor: Color.fromARGB(255, 23, 0, 0), // cor de fundo
                child: Icon(
                  Icons.person,
                  size: 75,
                  color: Colors.white, // cor do ícone
                ),
              ),

              SizedBox(height: 60),
                
                
              SizedBox(
                width: 400, // largura fixa para todos
                child: StatCard(title: 'Nome', value: 'Joao Paulo', subtitle: 'gonçalves'),
              ),
              SizedBox(height: 20,),
              SizedBox(
                width: 400,
                child: StatCard(title: 'Idade ', value: '22', subtitle: '26/02/2003'),
              ),
              SizedBox(height: 20,),
              SizedBox(
                width: 400,
                child: StatCard(title: 'Email ', value: 'JoaoVaz@gmail.com', subtitle: 'confirmado'),
              ),
              SizedBox(height: 20,),
              SizedBox(
                width: 400,
                child: StatCard(title: 'lorem ', value: 'Lorem ipsun', subtitle: 'lorem'),
              ),
            ],
          ),
        )
      ),
    );
  }
}
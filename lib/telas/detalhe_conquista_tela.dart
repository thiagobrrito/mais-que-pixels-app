// lib/telas/detalhe_conquista_tela.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meu_primeiro_app/models/conquista.dart';
import 'package:meu_primeiro_app/models/usuarios.dart';
import 'package:meu_primeiro_app/services/auth_services.dart';
import 'package:meu_primeiro_app/services/user_data_service.dart';
import 'package:meu_primeiro_app/widgets/profile_button.dart';

class DetalheConquistaTela extends StatelessWidget {
  final Conquista conquista;

  const DetalheConquistaTela({super.key, required this.conquista});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE5EDE4);
    const Color accentColor = Color(0xFF98B586);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // ===========================================================
                // HEADER
                // ===========================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer<AuthService>(
                    builder: (context, auth, child) {
                      final uid = auth.usuario?.uid;
                      if (uid == null) {
                        return _buildHeaderPlaceholder();
                      }

                      return Consumer<UserDataService>(
                        builder: (context, userData, child) {
                          return StreamBuilder<Usuario?>(
                            stream: userData.getUserStream(uid),
                            builder: (context, snapshot) {
                              final usuario = snapshot.data;

                              String nome = "Olá!";
                              String pontos = "0 pontos";

                              if (usuario != null) {
                                nome = "Olá, ${usuario.nome.split(' ').first}!";
                                pontos = "${usuario.pontos} pontos";
                              }

                              return _buildHeader(nome, pontos);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // ===========================================================
                // CARTÃO VERDE
                // ===========================================================
                Container(
                  width: 280,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.military_tech,
                        size: 90,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        conquista.titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Data da conquista 
                if (conquista.data != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      conquista.data!,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Descrição
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    conquista.descricao,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),

          // BOTÃO FECHAR
          Positioned(
            top: 45,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, size: 32, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // BOTÃO COMPARTILHAR
          Positioned(
            top: 45,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.share, size: 26, color: Colors.black87),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // HEADER COMPLETO
  // ===============================================================
  Widget _buildHeader(String nome, String pontos) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // FOTO + NOME
        Expanded(
          child: Row(
            children: [
              const ProfileButton(), 
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Você desbloqueou uma conquista!',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // PONTOS
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              const SizedBox(width: 5),
              Text(
                pontos,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderPlaceholder() {
    return _buildHeader("Olá!", "0 pontos");
  }
}
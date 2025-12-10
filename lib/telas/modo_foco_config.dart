// lib/telas/modo_foco_config.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_services.dart';
import 'modo_foco_em_andamento.dart';
import 'tela_principal.dart';
import 'package:meu_primeiro_app/widgets/main_bottom_nav.dart';
import 'package:meu_primeiro_app/widgets/profile_button.dart';

class ModoFocoConfigTela extends StatefulWidget {
  const ModoFocoConfigTela({Key? key}) : super(key: key);

  @override
  State<ModoFocoConfigTela> createState() => _ModoFocoConfigTelaState();
}

class _ModoFocoConfigTelaState extends State<ModoFocoConfigTela> {
  final List<int> _options = [15, 30, 40, 60];
  int _selected = 30;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF273C75),
            Color(0xFF4C5C99),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(auth),

        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Modo Foco",
                    style: TextStyle(
                      fontFamily: 'MochiyPopOne',
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        "Focar nem sempre é fácil, especialmente com uma tela por perto 24 horas por dia. "
                        "Com o nosso Modo Foco, você pode definir um timer exclusivo para manter a concentração total!",
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("🚨", style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Atenção: evitar sair do aplicativo para entrar em redes sociais. "
                              "Se isso acontecer, o timer será reiniciado automaticamente.",
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                _buildGridOptions(),

                const SizedBox(height: 26),

                _buildStartButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // ⭐ AQUI ENTRA O MENU PADRONIZADO
        bottomNavigationBar: const MainBottomNavBar(currentIndex: 4),
      ),
    );
  }

  // ==================================================
  // APP BAR
  // ==================================================

  PreferredSizeWidget _buildAppBar(AuthService auth) {
    if (auth.usuario == null) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Modo Foco"),
      );
    }

    final doc = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(auth.usuario!.uid);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      title: StreamBuilder<DocumentSnapshot>(
        stream: doc.snapshots(),
        builder: (context, snapshot) {
          String nome = "Olá!";

          if (snapshot.hasData) {
            final data = snapshot.data!.data() as Map?;
            if (data != null) {
              nome = "Olá, ${data['nome'].split(' ').first}!";
            }
          }

          return Row(
            children: [
              const ProfileButton(),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Vamos viver algo novo hoje?",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      color: Color(0xFFDBE1F2),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
      actions: [
        StreamBuilder<DocumentSnapshot>(
          stream: doc.snapshots(),
          builder: (context, snapshot) {
            int pontos = 0;

            if (snapshot.hasData) {
              final data = snapshot.data!.data() as Map?;
              pontos = data?['pontos'] ?? 0;
            }

            return Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events,
                      color: Colors.amber, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '$pontos',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ==================================================
  // OPÇÕES DE TEMPO
  // ==================================================

  Widget _buildGridOptions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 2.4,
      children: _options.map((m) => _timeOption(m)).toList(),
    );
  }

  Widget _timeOption(int minutes) {
    bool selected = _selected == minutes;

    return GestureDetector(
      onTap: () => setState(() => _selected = minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            "$minutes min",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: selected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ==================================================
  // BOTÃO PRINCIPAL
  // ==================================================

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ModoFocoEmAndamentoTela(durationMinutes: _selected),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "Vamos começar!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
// lib/telas/tela_categorias.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meu_primeiro_app/models/categorias.dart';
import 'package:meu_primeiro_app/models/missao.dart';
import 'package:meu_primeiro_app/services/auth_services.dart';
import 'package:meu_primeiro_app/services/user_data_service.dart';
import 'package:meu_primeiro_app/services/mission_service.dart';
import 'package:meu_primeiro_app/telas/detalhe_missao_tela.dart';
import 'package:meu_primeiro_app/widgets/main_bottom_nav.dart';
import 'package:meu_primeiro_app/widgets/profile_button.dart';

class TelaCategorias extends StatefulWidget {
  final String? initialCategory;

  const TelaCategorias({super.key, this.initialCategory});

  @override
  State<TelaCategorias> createState() => _TelaCategoriasState();
}

class _TelaCategoriasState extends State<TelaCategorias> {
  String categoriaSelecionada = mockCategories.first.title;
  bool loading = true;
  List<Missao> missoes = [];

  late MissionService missionService;
  late AuthService authService;
  late UserDataService userDataService;

  @override
  void initState() {
    super.initState();

    if (widget.initialCategory != null) {
      categoriaSelecionada = widget.initialCategory!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _buscarMissoes());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    missionService = Provider.of<MissionService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    userDataService = Provider.of<UserDataService>(context, listen: false);
  }

  Future<void> _buscarMissoes() async {
    setState(() => loading = true);

    final result = await missionService.getMissionsByCategory(categoriaSelecionada);

    setState(() {
      missoes = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EDE4),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 10),
            _buildTitle(),

            const SizedBox(height: 15),
            _buildCategorySelector(),

            const SizedBox(height: 20),
            Expanded(child: _buildMissionList()),
          ],
        ),
      ),

      bottomNavigationBar: const MainBottomNavBar(currentIndex: 0),
    );
  }

  // -------------------------------------------------------
  // HEADER
  // -------------------------------------------------------
  Widget _buildHeader() {
    final user = authService.usuario;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const ProfileButton(),

          const SizedBox(width: 12),

          if (user == null)
            const Text(
              "Carregando...",
              style: TextStyle(fontFamily: "MochiyPopOne", fontSize: 20),
            )
          else
            StreamBuilder(
              stream: userDataService.getUserStream(user.uid),
              builder: (context, snapshot) {
                String nome = "Olá!";

                if (snapshot.hasData) {
                  final dados = snapshot.data!;
                  nome = "Olá, ${dados.nome.split(' ').first}!";
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontFamily: "MochiyPopOne",
                        fontSize: 22,
                        color: Color(0xFF3A6A4D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Escolha uma categoria!",
                      style: TextStyle(
                        fontFamily: "Lato",
                        color: Colors.black54,
                      ),
                    ),
                  ],
                );
              },
            ),

          const Spacer(),

          // Pontos
          StreamBuilder(
            stream: user == null ? null : userDataService.getUserStream(user.uid),
            builder: (context, snapshot) {
              int pontos = snapshot.hasData ? snapshot.data!.pontos : 0;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "$pontos pts",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // TÍTULO
  // -------------------------------------------------------
  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Categorias",
        style: TextStyle(
          fontFamily: "MochiyPopOne",
          fontSize: 30,
          color: Color(0xFF3A6A4D),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // SELETOR DE CATEGORIAS
  // -------------------------------------------------------
  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: mockCategories.map((cat) {
          final bool selecionada = categoriaSelecionada == cat.title;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () async {
                setState(() => categoriaSelecionada = cat.title);
                _buscarMissoes();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 120,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: selecionada ? const Color(0xFF8AAE8A) : const Color(0xFFC4D5C4),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: selecionada
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(cat.icon, color: Colors.white, size: 30),
                    const SizedBox(height: 6),
                    Text(
                      cat.title,
                      style: const TextStyle(
                        fontFamily: "Lato",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // -------------------------------------------------------
  // LISTA DE MISSÕES
  // -------------------------------------------------------
  Widget _buildMissionList() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (missoes.isEmpty) {
      return const Center(
        child: Text(
          "Nenhuma missão nesta categoria.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: missoes.length,
      itemBuilder: (context, i) {
        final m = missoes[i];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetalheMissaoTela(missao: m)),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  style: const TextStyle(
                    fontFamily: "Lato",
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    m.difficulty ?? "Fácil",
                    style: const TextStyle(
                      fontFamily: "Lato",
                      color: Color(0xFF3A6A4D),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "+${m.points} pontos",
                    style: const TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A6A4D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// lib/telas/tela_principal.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meu_primeiro_app/models/missao.dart';
import 'package:meu_primeiro_app/models/usuarios.dart';
import 'package:meu_primeiro_app/models/categorias.dart';
import 'package:meu_primeiro_app/services/auth_services.dart';
import 'package:meu_primeiro_app/services/mission_service.dart';
import 'package:meu_primeiro_app/services/user_data_service.dart';
import 'package:meu_primeiro_app/telas/detalhe_missao_tela.dart';
import 'package:meu_primeiro_app/telas/tela_estatisticas.dart';
import 'package:meu_primeiro_app/telas/tela_login.dart';
import 'package:meu_primeiro_app/telas/tela_categorias.dart';
import 'package:meu_primeiro_app/telas/modo_foco_config.dart';
import 'package:meu_primeiro_app/widgets/main_bottom_nav.dart';
import 'package:meu_primeiro_app/widgets/profile_button.dart';

class TelaPrincipal extends StatefulWidget {
  final int initialIndex;

  const TelaPrincipal({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  List<Missao> _missions = [];
  Missao? _currentMission;
  bool _loadingMissions = true;

  int _selectedIndex = 0;

  late MissionService _missionService;
  late UserDataService _userDataService;

  final Random _random = Random();

  final List<Shadow> _textShadow = const [
    Shadow(
      blurRadius: 3.0,
      color: Colors.black54,
      offset: Offset(1.0, 1.0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _missionService = Provider.of<MissionService>(context, listen: false);
    _userDataService = Provider.of<UserDataService>(context, listen: false);

    if (_loadingMissions) _loadMissions();
  }

  Future<void> _loadMissions() async {
    final missions = await _missionService.getMissions();

    setState(() {
      _missions = missions;
      _loadingMissions = false;

      if (missions.isNotEmpty) {
        _currentMission = missions[_random.nextInt(missions.length)];
      }
    });
  }

  void _sortearNovaMissao() {
    if (_missions.isEmpty) return;

    setState(() {
      _currentMission = _missions[_random.nextInt(_missions.length)];
    });
  }

  Widget _buildBody(AuthService auth) {
    switch (_selectedIndex) {
      case 0:
        return _buildHome(auth);
      case 1:
        return const TelaEstatisticas();
      default:
        return _buildHome(auth);
    }
  }

  Widget _buildHome(AuthService authService) {
    const Color primaryColor = Color(0xFF3A6A4D);
    const Color lightGreenBackgroundColor = Color(0xFFE8F5E9);

    if (_loadingMissions) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_currentMission == null) {
      return const Center(
        child: Text("Nenhuma missão disponível."),
      );
    }

    final mission = _currentMission!;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: primaryColor,
          expandedHeight: 200,
          
          actions: const [
            ProfileButton(),
          ],
          
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/header_tela_inicial.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: _buildHeader(authService),
                )
              ],
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMissionCard(
                      mission,
                      lightGreenBackgroundColor,
                      authService,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TelaCategorias(),
                          ),
                        );
                      },
                      child: _buildSectionTitle("Categorias"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  _buildCategories(),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionTitle("Desafios em Destaque"),
                  ),
                  const SizedBox(height: 15),

                  _buildFeaturedChallenges(authService),
                ],
              ),
            )
          ]),
        )
      ],
    );
  }

  Widget _buildHeader(AuthService auth) {
    if (auth.usuario == null) {
      return Text(
        "Olá!",
        style: TextStyle(
          fontFamily: 'MochiyPopOne',
          fontSize: 28,
          color: Colors.white,
          shadows: _textShadow,
        ),
      );
    }

    return StreamBuilder<Usuario?>(
      stream: _userDataService.getUserStream(auth.usuario!.uid),
      builder: (context, snapshot) {
        String nome = "Olá!";
        String pontos = "Carregando...";

        if (snapshot.hasData) {
          nome = "Olá, ${snapshot.data!.nome.split(' ').first}!";
          pontos = "Seus pontos: ${snapshot.data!.pontos}";
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nome,
              style: TextStyle(
                fontFamily: 'MochiyPopOne',
                fontSize: 28,
                color: Colors.white,
                shadows: _textShadow,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              pontos,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                color: Colors.white,
                shadows: _textShadow,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMissionCard(Missao mission, Color bg, AuthService auth) {
    return InkWell(
      onTap: () {
        if (auth.usuario == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalheMissaoTela(missao: mission),
          ),
        );
      },
      child: Container(
        height: 290,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IgnorePointer(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: _buildCategoryTag(
                      mission.categoryTitle,
                      mission.categoryIcon,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Missão Diária",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mission.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5E8D4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "+${mission.points} pontos",
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      color: Color(0xFF3A6A4D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _sortearNovaMissao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Sortear Missão",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTag(String title, String iconName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFC8E6C9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconFromString(iconName),
            size: 16,
            color: const Color(0xFF3A6A4D),
          ),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A6A4D),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFromString(String icon) {
    switch (icon) {
      case "spa":
        return Icons.spa;
      case "favorite":
        return Icons.favorite;
      case "self_improvement":
        return Icons.self_improvement;
      case "flash_on":
        return Icons.flash_on;
      case "brush":
        return Icons.brush;
      default:
        return Icons.flag;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'MochiyPopOne',
        fontSize: 24,
        color: Colors.white,
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: mockCategories.map((c) {
          return Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TelaCategorias(
                      initialCategory: c.title,
                    ),
                  ),
                );
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: c.color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Icon(c.icon, color: Colors.white, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      c.title,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedChallenges(AuthService auth) {
    final destaques = _missions.take(3).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: destaques.map((m) {
          return Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: () {
                if (auth.usuario == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalheMissaoTela(missao: m),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 140,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF8AAE8A),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5E8D4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "+${m.points} pts",
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A6A4D),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF3A6A4D),
      body: _buildBody(auth),

      bottomNavigationBar: const MainBottomNavBar(currentIndex: 0),
    );
  }
}
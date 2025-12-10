// lib/telas/tela_estatisticas.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meu_primeiro_app/services/stats_service.dart';
import 'package:meu_primeiro_app/services/auth_services.dart';
import 'package:meu_primeiro_app/services/user_data_service.dart';
import 'package:meu_primeiro_app/models/usuarios.dart';
import 'tela_principal.dart';
import 'package:meu_primeiro_app/widgets/profile_button.dart';
// ------------------------------------------------------------
// TELA ESTATÍSTICAS
// ------------------------------------------------------------

class TelaEstatisticas extends StatefulWidget {
  const TelaEstatisticas({Key? key}) : super(key: key);

  @override
  State<TelaEstatisticas> createState() => _TelaEstatisticasState();
}

class _TelaEstatisticasState extends State<TelaEstatisticas>
    with SingleTickerProviderStateMixin {

  final StatsService _statsService = StatsService();

  Map<String, double> percentuais = {};
  int totalMissoes = 0;
  int streak = 0;
  int recorde = 0;
  List<Map<String, dynamic>> conquistas = [];
  bool carregando = true;

  final List<String> keys = ["zen", "coragem", "gentileza", "criatividade"];
  final List<String> nomes = ["Zen", "Coragem", "Gentileza", "Criatividade"];

  final List<Color> cores = [
    const Color(0xFF8AAE8A),
    const Color(0xFFFF8A65),
    const Color(0xFFACD6A5),
    const Color(0xFFBA68C8),
  ];

  late AnimationController _ctrl;
  late Animation<double> _donutReveal;
  late Animation<double> _rotateAnim;
  late List<Animation<double>> _legendFadeAnims;
  late Animation<double> _cardsAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _donutReveal = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );

    _rotateAnim = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.45)),
    );

    _cardsAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.7, 1.0),
    );

    _legendFadeAnims = List.generate(
      4,
      (i) => CurvedAnimation(
        parent: _ctrl,
        curve: Interval(0.35 + i * 0.08, 0.65),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => carregando = true);

    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.usuario?.uid;
    if (uid == null) return;

    final p = await _statsService.getPercentualPorCategoria(uid, keys);
    final t = await _statsService.getTotalMissoes(uid);
    final s = await _statsService.getStreak(uid);
    final r = await _statsService.getRecordePontosDia(uid);
    final c = await _statsService.getConquistas(uid);

    setState(() {
      percentuais = {for (var k in keys) k: (p[k] ?? 0)};
      totalMissoes = t;
      streak = s;
      recorde = r;
      conquistas = List<Map<String, dynamic>>.from(c ?? []);
      carregando = false;
    });

    _ctrl.forward(from: 0);
  }

  // MAPEAMENTO DE ÍCONES (igual à tela principal)
  IconData _iconPorCategoria(String key) {
    switch (key) {
      case 'zen':
        return Icons.spa;
      case 'criatividade':
        return Icons.lightbulb_outline;
      case 'gentileza':
        return Icons.volunteer_activism;
      case 'coragem':
        return Icons.terrain;
      default:
        return Icons.flag;
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFE5EDE4);
    const green = Color(0xFF3A6A4D);

    final auth = Provider.of<AuthService>(context);
    final userService = Provider.of<UserDataService>(context);

    return Scaffold(
      backgroundColor: background,

      // HEADER IGUAL AO DA HOME
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          color: green,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  
                  // ⭐ ALTERAÇÃO: ProfileButton no lugar do Avatar estático
                  const ProfileButton(), 
                  const SizedBox(width: 12),

                  // Olá + Nome
                  Expanded(
                    child: StreamBuilder<Usuario?>(
                      stream: userService.getUserStream(auth.usuario!.uid),
                      builder: (context, snapshot) {
                        final nome = snapshot.hasData
                            ? "Olá, ${snapshot.data!.nome.split(' ').first}!"
                            : "Olá!";

                        return Text(
                          nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'MochiyPopOne',
                          ),
                        );
                      },
                    ),
                  ),

                  // Pontos
                  StreamBuilder<Usuario?>(
                    stream: userService.getUserStream(auth.usuario!.uid),
                    builder: (_, snap) {
                      String pontos = snap.hasData
                          ? "${snap.data!.pontos} pts"
                          : "...";

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.emoji_events,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              pontos,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarDados,
              child: _buildBody(background),
            ),

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ------------------------------------------------------------
  // CORPO
  // ------------------------------------------------------------

  Widget _buildBody(Color background) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TÍTULO PRINCIPAL LOGO ABAIXO DO HEADER

          const SizedBox(height: 25),

          _buildDonut(background),

          const SizedBox(height: 30),

          const Text(
            "Suas Conquistas",
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'MochiyPopOne',
              color: Color(0xFF3A6A4D),
            ),
          ),

          const SizedBox(height: 14),

          _buildConquistas(),

          const SizedBox(height: 28),

          FadeTransition(
            opacity: _cardsAnim,
            child: Column(
              children: [
                const Text(
            "Estatísticas",
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'MochiyPopOne',
              color: Color(0xFF3A6A4D),
            ),
          ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard("Missões", "$totalMissoes"),
                    _buildStatCard("Streak", "$streak dias"),
                    _buildStatCard("Recorde", "$recorde pts"),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DONUT + LEGENDA
  // ------------------------------------------------------------

  Widget _buildDonut(Color background) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final reveal = _donutReveal.value;
                final rotation = _rotateAnim.value;

                final animated =
                    {for (var k in keys) k: (percentuais[k] ?? 0) * reveal};

                return Transform.rotate(
                  angle: rotation,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      percentuais: animated,
                      colors: cores,
                      keys: keys,
                    ),
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: background,
                        ),
                        child: const Icon(
                          Icons.spa,
                          size: 40,
                          color: Color(0xFF3A6A4D),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 14,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(keys.length, (i) {
              final key = keys[i];
              final pct = percentuais[key] ?? 0;

              return FadeTransition(
                opacity: _legendFadeAnims[i],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6)
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: cores[i],
                        child: Icon(
                          _iconPorCategoria(key),
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nomes[i],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text("${pct.toStringAsFixed(0)}%",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CONQUISTAS
  // ------------------------------------------------------------

  Widget _buildConquistas() {
    final items = conquistas.isEmpty
        ? [
            {'titulo': 'Semeador de Gentileza', 'descricao': 'Complete missões gentileza', 'conquistado': false},
            {'titulo': 'Explorador da Coragem', 'descricao': 'Complete missões coragem', 'conquistado': false},
            {'titulo': 'Guru da Criatividade', 'descricao': 'Complete missões criativas', 'conquistado': false},
            {'titulo': 'Mestre do Zen', 'descricao': 'Complete missões zen', 'conquistado': false},
          ]
        : conquistas;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((c) {
          final ganhou = c['conquistado'] == true;

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ganhou ? const Color(0xFFDFF6E9) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ganhou ? const Color(0xFF3A6A4D) : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      ganhou ? const Color(0xFF3A6A4D) : Colors.grey,
                  child: const Icon(Icons.emoji_events, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  c['titulo'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  c['descricao'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ------------------------------------------------------------
  // CARD DE ESTATÍSTICAS
  // ------------------------------------------------------------

  Widget _buildStatCard(String titulo, String valor) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM NAV
  // ------------------------------------------------------------

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: const Color(0xFF3A6A4D),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 1) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TelaPrincipal(initialIndex: index)),
        );
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Estatísticas"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "Histórico"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Conexões"),
        BottomNavigationBarItem(icon: Icon(Icons.nights_stay), label: "Foco"),
      ],
    );
  }
}

// ------------------------------------------------------------
// PINTURA DO DONUT
// ------------------------------------------------------------

class _DonutPainter extends CustomPainter {
  final Map<String, double> percentuais;
  final List<Color> colors;
  final List<String> keys;

  _DonutPainter({
    required this.percentuais,
    required this.colors,
    required this.keys,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final ringWidth = radius * 0.33;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..color = Colors.grey.shade300;

    canvas.drawCircle(center, radius - ringWidth / 2, bgPaint);

    final total = percentuais.values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;

    double start = -pi / 2;

    for (int i = 0; i < keys.length; i++) {
      final valor = percentuais[keys[i]] ?? 0;
      final sweep = (valor / total) * 2 * pi;

      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius - ringWidth / 2,
        ),
        start,
        sweep,
        false,
        paint,
      );

      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) {
    return oldDelegate.percentuais != percentuais;
  }
}
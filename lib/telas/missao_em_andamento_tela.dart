// lib/telas/missao_em_andamento_tela.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meu_primeiro_app/models/missao.dart';
import 'package:meu_primeiro_app/telas/missao_concluida_tela.dart';
import 'package:meu_primeiro_app/services/auth_services.dart';
import 'package:meu_primeiro_app/services/user_data_service.dart';
import 'package:meu_primeiro_app/models/usuarios.dart';
import 'package:provider/provider.dart';
import 'package:meu_primeiro_app/widgets/profile_button.dart';

class MissaoEmAndamentoTela extends StatefulWidget {
  final Missao missao;

  const MissaoEmAndamentoTela({Key? key, required this.missao}) : super(key: key);

  @override
  _MissaoEmAndamentoTelaState createState() => _MissaoEmAndamentoTelaState();
}

class _MissaoEmAndamentoTelaState extends State<MissaoEmAndamentoTela> {
  late Timer _timer;
  late Duration _remainingTime;
  bool _isPaused = false;
  final UserDataService _userDataService = UserDataService();

  @override
  void initState() {
    super.initState();
    _remainingTime = _parseDuration(widget.missao.time);
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Converte string (ex: "5 minutos", "1 hora") para Duration
  Duration _parseDuration(String timeString) {
    final parts = timeString.toLowerCase().split(' ');

    if (parts.length < 2) {
      return const Duration(minutes: 5);
    }

    final int? value = int.tryParse(parts[0]);
    if (value == null) {
      return const Duration(minutes: 5);
    }

    final String unit = parts[1];
    switch (unit) {
      case 'minuto':
      case 'minutos':
        return Duration(minutes: value);
      case 'hora':
      case 'horas':
        return Duration(hours: value);
      case 'segundo':
      case 'segundos':
        return Duration(seconds: value);
      default:
        return const Duration(minutes: 5);
    }
  }

  // Formata Duration como HH:MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // Inicia o timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          } else {
            _timer.cancel();
            // Ao terminar, navega para tela de missão concluída
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MissaoConcluidaTela(
                    missao: widget.missao,
                  ),
                ),
              );
            });
          }
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _abandonarMissao(BuildContext context) {
    _timer.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Missão abandonada. Tente novamente mais tarde.'),
        backgroundColor: Colors.orange,
      ),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE5EDE4);
    const Color accentColor = Color(0xFF98B586);
    const Color darkColor = Color(0xFF3A6A4D);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 125.0),
                  child: _buildMissionCard(accentColor),
                ),
                // imagem da missão (se existir)
                if (widget.missao.imageAsset.isNotEmpty)
                  Image.asset(widget.missao.imageAsset, height: 250)
                else
                  const SizedBox(height: 250),
              ],
            ),
            const SizedBox(height: 30),
            _buildTimerDisplay(accentColor),
            const SizedBox(height: 20),
            _buildTimerControls(darkColor, context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Cabeçalho com dados do usuário
  Widget _buildHeader(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final String? uid = authService.usuario?.uid;

    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 10),
      child: FutureBuilder<Usuario?>(
        future: uid != null ? _userDataService.getUserData(uid) : Future.value(null),
        builder: (context, snapshot) {
          final usuario = snapshot.data;

          String nome = 'Analu!';
          String pontos = '0 pontos';

          if (usuario != null) {
            nome = '${usuario.nome.split(' ').first}!';
            pontos = '${usuario.pontos} pontos';
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                            'Olá, $nome',
                            style: const TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.bold, fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Vamos viver algo novo hoje?',
                            style: TextStyle(fontFamily: 'Lato', color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                    Text(pontos, style: const TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimerDisplay(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatDuration(_remainingTime),
        style: const TextStyle(
          fontFamily: 'MochiyPopOne',
          fontSize: 40,
          color: Color(0xFF3A6A4D),
        ),
      ),
    );
  }

  Widget _buildTimerControls(Color darkColor, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _togglePause,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: darkColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
              child: Text(
                _isPaused ? 'Retomar' : 'Dar uma pausa',
                style: const TextStyle(fontSize: 18, fontFamily: 'Lato', fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => _abandonarMissao(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: darkColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            child: const Text(
              'Abandonar Missão',
              style: TextStyle(fontSize: 16, fontFamily: 'Lato'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTag(_formatCategoryLabel(widget.missao.categoryId), null, accentColor),
              _buildTag(widget.missao.difficulty, null, accentColor),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.missao.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'MochiyPopOne', fontSize: 28, height: 1.2),
          ),
          const SizedBox(height: 15),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD5E8D4),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(
                '+${widget.missao.points} pontos',
                style: const TextStyle(fontFamily: 'Lato', color: Color(0xFF3A6A4D), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            widget.missao.description,
            style: const TextStyle(fontFamily: 'Lato', color: Colors.black54, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.black54, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.missao.time,
                style: const TextStyle(fontFamily: 'Lato', color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, IconData? icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: Colors.white, size: 16),
          if (icon != null) const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontFamily: 'Lato', fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatCategoryLabel(String categoryId) {
    if (categoryId.isEmpty) return '';
    return categoryId[0].toUpperCase() + categoryId.substring(1);
  }
}
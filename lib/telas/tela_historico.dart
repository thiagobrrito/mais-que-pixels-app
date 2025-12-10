// lib/telas/tela_historico.dart 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meu_primeiro_app/services/auth_services.dart';
import 'package:meu_primeiro_app/services/user_data_service.dart';
import 'package:meu_primeiro_app/services/stats_service.dart';
import 'package:meu_primeiro_app/models/usuarios.dart';
import 'package:meu_primeiro_app/widgets/main_bottom_nav.dart';
import 'package:meu_primeiro_app/widgets/profile_button.dart';

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({Key? key}) : super(key: key);

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  String categoriaSelecionada = "Todas";

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final userDataService = Provider.of<UserDataService>(context);
    final statsService = Provider.of<StatsService>(context);

    final uid = auth.usuario?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFE8EFE6),
      body: SafeArea(
        child: uid == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Carregando usuário...'),
                  ],
                ),
              )
            : Column(
                children: [
                  // cabeçalho
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: StreamBuilder<Usuario?>(
                      stream: userDataService.getUserStream(uid),
                      builder: (context, snapUser) {
                        String nomeDisplay = 'Olá!';
                        String pontosDisplay = '...';

                        if (snapUser.hasData && snapUser.data != null) {
                          final usuario = snapUser.data!;
                          nomeDisplay = 'Olá, ${usuario.nome.split(' ').first}';
                          pontosDisplay = '${usuario.pontos} pts'; 
                        }
                        
                        // --- LAYOUT DO CABEÇALHO ---
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Elemento 1: Profile Button
                            const ProfileButton(), 

                            const SizedBox(width: 12),
                            
                            // Elemento 2: Nome e Saudação
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nomeDisplay,
                                    style: const TextStyle(
                                      fontFamily: 'MochiyPopOne', 
                                      fontSize: 20, 
                                      color: Colors.black87
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Vamos viver algo novo hoje?', 
                                    style: TextStyle(fontSize: 13, color: Colors.black54),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8), // Pequeno espaço entre o nome e os pontos

                            // Elemento 3: Container de Pontos
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Diminui o padding horizontal
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                children: [
                                  const Icon(Icons.emoji_events, size: 18, color: Colors.amber),
                                  const SizedBox(width: 4), // Diminui o espaço
                                  Text(pontosDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // titulo
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Minha Jornada', style: TextStyle(fontFamily: 'MochiyPopOne', fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF3A6A4D))),
                  ),

                  const SizedBox(height: 12),

                  // filtros
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: ["Todas", "Zen", "Criatividade", "Gentileza", "Coragem"].map((cat) {
                        final ativo = categoriaSelecionada == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => setState(() => categoriaSelecionada = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: ativo ? const Color(0xFF8BB58A) : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Text(cat, style: TextStyle(fontWeight: FontWeight.bold, color: ativo ? Colors.white : Colors.black)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // lista de historico 
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: statsService.getCompletedMissions(uid),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snap.hasError) {
                          return Center(child: Text('Erro ao carregar histórico: ${snap.error}'));
                        }

                        var lista = snap.data ?? [];

                        if (categoriaSelecionada != 'Todas') {
                          lista = lista.where((m) => (m['categoria'] ?? '').toString().toLowerCase() == categoriaSelecionada.toLowerCase()).toList();
                        }

                        if (lista.isEmpty) {
                          return const Center(child: Text('Nenhuma missão concluída.', style: TextStyle(color: Colors.black54)));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: lista.length,
                          itemBuilder: (context, index) {
                            final item = lista[index];

                            final title = item['titulo'] ?? item['descricao'] ?? 'Missão Sem Título';
                            
                            String formattedDate = item['data'] is String 
                                ? item['data'] 
                                : (item['data'] != null && item['data'].runtimeType.toString().contains('Timestamp'))
                                    ? (item['data'] as dynamic).toDate().toString().split(' ')[0] 
                                    : 'Sem Data';


                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 3))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 6),
                                    Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(children: [const Icon(Icons.local_florist, color: Color(0xFF8BB58A)), const SizedBox(width: 6), Text(item['categoria'] ?? '')]),
                                        Text('+${item['pontosGanhos'] ?? 0} pts', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8BB58A))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),

      bottomNavigationBar: const MainBottomNavBar(currentIndex: 2),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// REGISTRA UMA MISSÃO CONCLUÍDA
  Future<void> concluirMissao({
    required String idMissao,
    required String categoriaId,
    required int pontos,
  }) async {
    final uid = _auth.currentUser!.uid;
    final agora = DateTime.now();

    final userRef = _db.collection('usuarios').doc(uid);

    // Recuperar dados atuais do usuário
    final snapUser = await userRef.get();
    final userData = snapUser.data() ?? {};

    int pontosAtuais = userData['pontos'] ?? 0;
    int missoesConcluidas = userData['missoesConcluidas'] ?? 0;

    // --- ATUALIZAR PONTOS + MISSÕES CONCLUÍDAS ---
    await userRef.update({
      'pontos': pontosAtuais + pontos,
      'missoesConcluidas': missoesConcluidas + 1,
    });

    // --- REGISTRAR NO HISTÓRICO ---
    await _db.collection('historico_pontos').add({
      'idUsuario': uid,
      'idMissao': idMissao,
      'categoriaId': categoriaId,
      'pontosGanho': pontos,
      'data': agora,
    });

    // --- ATUALIZAR OFENSIVA ---
    await _atualizarOfensiva(uid);

    // --- ATUALIZAR RECORDE DIÁRIO ---
    await _atualizarRecorde(uid, agora);

    // --- CHECAR CONQUISTAS ---
    await _verificarConquistas(uid);
  }

  // ---------------------------------------------------------------------------
  // OFENSIVA – DIAS SEGUIDOS
  // ---------------------------------------------------------------------------

  Future<void> _atualizarOfensiva(String uid) async {
    final userRef = _db.collection('usuarios').doc(uid);
    final hoje = DateTime.now();

    final snapUser = await userRef.get();
    final data = snapUser.data() ?? {};

    int ofensivaAtual = data['ofensivaAtual'] ?? 0;
    DateTime? ultimaData = data['ultimaMissao'] != null
        ? (data['ultimaMissao'] as Timestamp).toDate()
        : null;

    // Cálculo de dias seguidos
    if (ultimaData != null) {
      final ontem = hoje.subtract(const Duration(days: 1));

      bool ehMesmoDia = _mesmoDia(ultimaData, hoje);
      bool ehOntem = _mesmoDia(ultimaData, ontem);

      if (ehMesmoDia) {
        // Nada muda (já contou hoje)
      } else if (ehOntem) {
        ofensivaAtual += 1;
      } else {
        ofensivaAtual = 1; // reinicia
      }
    } else {
      ofensivaAtual = 1;
    }

    await userRef.update({
      'ofensivaAtual': ofensivaAtual,
      'ultimaMissao': hoje,
    });
  }

  bool _mesmoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ---------------------------------------------------------------------------
  // RECORDE DIÁRIO
  // ---------------------------------------------------------------------------

  Future<void> _atualizarRecorde(String uid, DateTime agora) async {
    final userRef = _db.collection('usuarios').doc(uid);

    final snapUser = await userRef.get();
    final data = snapUser.data() ?? {};

    int recorde = data['recordeDiario'] ?? 0;

    // Buscar quantas missões o usuário fez hoje
    final inicioDia =
        DateTime(agora.year, agora.month, agora.day, 0, 0, 0);
    final fimDia =
        DateTime(agora.year, agora.month, agora.day, 23, 59, 59);

    final query = await _db
        .collection('historico_pontos')
        .where('idUsuario', isEqualTo: uid)
        .where('data', isGreaterThanOrEqualTo: inicioDia)
        .where('data', isLessThanOrEqualTo: fimDia)
        .get();

    int missoesHoje = query.docs.length;

    if (missoesHoje > recorde) {
      await userRef.update({'recordeDiario': missoesHoje});
    }
  }

  // ---------------------------------------------------------------------------
  // CONQUISTAS
  // ---------------------------------------------------------------------------

  Future<void> _verificarConquistas(String uid) async {
    final userRef = _db.collection('usuarios').doc(uid);

    final snapUser = await userRef.get();
    final userData = snapUser.data() ?? {};

    List conquistasAtuais =
        List.from(userData['conquistas'] ?? []);

    // Buscar conquistas cadastradas
    final conquistasSnap = await _db.collection('conquistas').get();

    for (var c in conquistasSnap.docs) {
      final dados = c.data();
      final categoria = dados['categoriaId'];
      final requisito = dados['requisito'];

      // contar quantas missões da categoria o usuário já fez
      final query = await _db
          .collection('historico_pontos')
          .where('idUsuario', isEqualTo: uid)
          .where('categoriaId', isEqualTo: categoria)
          .get();

      int total = query.docs.length;

      if (total >= requisito && !conquistasAtuais.contains(c.id)) {
        // desbloquear conquista
        conquistasAtuais.add(c.id);

        await userRef.update({'conquistas': conquistasAtuais});
      }
    }
  }
}

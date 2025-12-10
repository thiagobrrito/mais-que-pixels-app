import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =====================================================
  // TOTAL DE MISSÕES CONCLUÍDAS
  // =====================================================
  Future<int> getTotalMissoes(String uid) async {
    final historicoRef =
        _firestore.collection('usuarios').doc(uid).collection('historico');

    final snap = await historicoRef.get();
    return snap.docs.length;
  }

  // =====================================================
  // PONTUAÇÃO TOTAL DO USUÁRIO
  // =====================================================
  Future<int> getTotalPontos(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();
    if (!doc.exists) return 0;

    final data = doc.data() as Map<String, dynamic>;
    final pontos = data['pontos'];

    if (pontos is num) return pontos.toInt();

    return int.tryParse(pontos.toString()) ?? 0;
  }

  // =====================================================
  // PERCENTUAL POR CATEGORIA
  // =====================================================
  Future<Map<String, double>> getPercentualPorCategoria(
      String uid, List<String> categorias) async {
    final historicoRef =
        _firestore.collection('usuarios').doc(uid).collection('historico');

    final snap = await historicoRef.get();

    if (snap.docs.isEmpty) {
      return {for (var c in categorias) c: 0.0};
    }

    Map<String, int> contagem = {for (var c in categorias) c: 0};
    int registrosValidos = 0;

    for (var doc in snap.docs) {
      final data = doc.data();

      String raw = "";

      if (data['categoria'] != null && data['categoria'].toString().trim().isNotEmpty) {
        raw = data['categoria'].toString();
      } else if (data['categoriaId'] != null) {
        raw = data['categoriaId'].toString();
      } else if (data['categoryId'] != null) {
        raw = data['categoryId'].toString();
      } else if (data['categoryTitle'] != null) {
        raw = data['categoryTitle'].toString();
      }

      raw = raw.trim().toLowerCase();
      if (raw.isEmpty) continue;

      final categoriaNorm = _normalize(raw);

      for (var cat in categorias) {
        if (_normalize(cat) == categoriaNorm) {
          contagem[cat] = contagem[cat]! + 1;
          registrosValidos++;
          break;
        }
      }
    }

    if (registrosValidos == 0) {
      return {for (var c in categorias) c: 0.0};
    }

    return {
      for (var c in categorias)
        c: (contagem[c]! / registrosValidos) * 100
    };
  }

  String _normalize(String s) {
    final t = s.trim().toLowerCase();

    return t
        .replaceAll("á", "a")
        .replaceAll("à", "a")
        .replaceAll("ã", "a")
        .replaceAll("â", "a")
        .replaceAll("é", "e")
        .replaceAll("ê", "e")
        .replaceAll("í", "i")
        .replaceAll("ó", "o")
        .replaceAll("ô", "o")
        .replaceAll("õ", "o")
        .replaceAll("ú", "u")
        .replaceAll("ç", "c");
  }

  // =====================================================
  // DIAS SEGUIDOS
  // =====================================================
  Future<int> getStreak(String uid) async {
    final historicoRef =
        _firestore.collection('usuarios').doc(uid).collection('historico');

    final snap = await historicoRef.get();

    if (snap.docs.isEmpty) return 0;

    Set<DateTime> datas = {};

    for (var doc in snap.docs) {
      final data = doc.data();
      if (data['data'] == null) continue;

      try {
        final ts = data['data'] as Timestamp;
        final dt = ts.toDate();
        datas.add(DateTime(dt.year, dt.month, dt.day));
      } catch (_) {}
    }

    if (datas.isEmpty) return 0;

    final list = datas.toList()..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final hoje = DateTime(now.year, now.month, now.day);
    final ontem = hoje.subtract(const Duration(days: 1));

    if (!(datas.contains(hoje) || datas.contains(ontem))) return 0;

    int streak = 1;
    DateTime diaAtual = list.first;

    for (int i = 1; i < list.length; i++) {
      if (diaAtual.difference(list[i]).inDays == 1) {
        streak++;
        diaAtual = list[i];
      } else {
        break;
      }
    }

    return streak;
  }

  // =====================================================
  // RECORDE DE PONTOS EM UM ÚNICO DIA
  // =====================================================
  Future<int> getRecordePontosDia(String uid) async {
    final historicoRef =
        _firestore.collection('usuarios').doc(uid).collection('historico');

    final snap = await historicoRef.get();
    if (snap.docs.isEmpty) return 0;

    Map<String, int> pontosPorDia = {};

    for (var doc in snap.docs) {
      final d = doc.data();
      if (d['data'] == null) continue;

      final ts = (d['data'] as Timestamp).toDate();
      final dia = DateFormat('yyyy-MM-dd').format(ts);

      final pontos = d['pontosGanhos'];
      final p = (pontos is num) ? pontos.toInt() : int.tryParse("$pontos") ?? 0;

      pontosPorDia[dia] = (pontosPorDia[dia] ?? 0) + p;
    }

    if (pontosPorDia.isEmpty) return 0;

    return pontosPorDia.values.reduce((a, b) => a > b ? a : b);
  }

  // =====================================================
  // CONQUISTAS
  // =====================================================
  Future<List<Map<String, dynamic>>> getConquistas(String uid) async {
    final ref = _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('conquistas');

    final snap = await ref.get();

    return snap.docs.map((d) => {"id": d.id, ...d.data()}).toList();
  }

  // =====================================================
  // LISTA PARA A TELA "HISTÓRICO"
  // =====================================================
  Future<List<Map<String, dynamic>>> getCompletedMissions(String uid) async {
    final historicoRef =
        _firestore.collection('usuarios').doc(uid).collection('historico');

    final snap = await historicoRef.get();
    if (snap.docs.isEmpty) return [];

    List<Map<String, dynamic>> lista = [];

    for (var doc in snap.docs) {
      final d = doc.data();

      // DATA
      DateTime? dt;
      if (d['data'] is Timestamp) {
        dt = (d['data'] as Timestamp).toDate();
      } else if (d['data'] is DateTime) {
        dt = d['data'] as DateTime;
      }

      // DESCRIÇÃO
      String descricao = "";
      if (d['descricao'] != null) descricao = d['descricao'];
      if (d['description'] != null) descricao = d['description'];
      if (d['descricaoMissao'] != null) descricao = d['descricaoMissao'];

      // CATEGORIA
      String categoria = "";
      if (d['categoria'] != null) categoria = d['categoria'];
      if (d['categoryTitle'] != null) categoria = d['categoryTitle'];
      if (d['categoriaId'] != null) categoria = d['categoriaId'];

      // PONTOS
      int pontos = 0;
      final rawPontos =
          d['pontosGanhos'] ?? d['pontos'] ?? d['points'] ?? 0;
      pontos = (rawPontos is num)
          ? rawPontos.toInt()
          : int.tryParse(rawPontos.toString()) ?? 0;

      if (dt != null) {
        final f = DateFormat("dd 'de' MMMM", "pt_BR");
        String dataFormatada = f.format(dt);
        dataFormatada =
            dataFormatada[0].toUpperCase() + dataFormatada.substring(1);

        lista.add({
          "data": dataFormatada,
          "descricao": descricao,
          "categoria": categoria,
          "pontos": pontos,
          "timestamp": dt,
        });
      }
    }

    lista.sort((a, b) {
      final da = a["timestamp"] as DateTime;
      final db = b["timestamp"] as DateTime;
      return db.compareTo(da);
    });

    return lista
        .map((m) => {
              "data": m["data"],
              "descricao": m["descricao"],
              "categoria": m["categoria"],
              "pontos": m["pontos"],
            })
        .toList();
  }
}

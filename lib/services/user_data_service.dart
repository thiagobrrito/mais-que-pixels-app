// lib/services/user_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meu_primeiro_app/models/usuarios.dart';

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference _usersCollection =
      _firestore.collection('usuarios');

  // STREAM do usuário
  Stream<Usuario?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return Usuario.fromFirestore(snapshot.data() as Map<String, dynamic>, uid);
    });
  }

  // GET único
  Future<Usuario?> getUserData(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;

    return Usuario.fromFirestore(doc.data() as Map<String, dynamic>, uid);
  }

  // Atualiza pontos + contador
  Future<void> updateMissionCompletion(String uid, int points) async {
    await _usersCollection.doc(uid).update({
      'pontos': FieldValue.increment(points),
      'missoesConcluidas': FieldValue.increment(1),
    });
  }
  // Salva histórico de missões concluídas
  Future<void> saveMissionHistory({
    required String uid,
    required String title,
    required String categoria,
    required int pontosGanhos,
  }) async {
    final historicoRef =
        _usersCollection.doc(uid).collection('historico');

    await historicoRef.add({
      'titulo': title,
      'categoria': categoria,
      'pontosGanhos': pontosGanhos,
      'data': Timestamp.now(),
    });
  }

  // Atualizar perfil completo
  Future<void> updateProfile(String uid, String nome, String? photoUrl) async {
    await _usersCollection.doc(uid).update({
      'nome': nome,
      'photoUrl': photoUrl,
    });
  }

  // Atualizar só a foto
  Future<void> updateProfilePhotoUrl(String uid, String photoUrl) async {
    await _usersCollection.doc(uid).update({
      'photoUrl': photoUrl,
    });
  }
}

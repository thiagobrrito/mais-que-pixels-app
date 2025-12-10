import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meu_primeiro_app/models/missao.dart';

class MissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Missao>> getMissions() async {
    try {
      final snapshot = await _firestore.collection('missoes').get();

      return snapshot.docs.map((doc) {
        return Missao.fromFirestore(
          doc.data(), 
          doc.id,    
        );
      }).toList();
    } catch (e) {
      print('Erro ao carregar missões: $e');
      return [];
    }
  }

  Future<List<Missao>> getMissionsByCategory(String categoryTitle) async {
    try {
      final snapshot = await _firestore
          .collection('missoes')
          .where('categoryTitle', isEqualTo: categoryTitle)
          .get();

      return snapshot.docs.map((doc) {
        return Missao.fromFirestore(
          doc.data(), 
          doc.id,    
        );
      }).toList();
    } catch (e) {
      print('Erro ao carregar missões da categoria $categoryTitle: $e');
      return [];
    }
  }
}

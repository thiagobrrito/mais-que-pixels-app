// lib/models/usuarios.dart - CÓDIGO FINAL CORRIGIDO

import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String? id; 
  final String nome;
  final String email;
  final int pontos;
  final int missoesConcluidas;
  final String? photoUrl; 

  Usuario({
    this.id, 
    required this.nome, 
    required this.email,
    this.pontos = 0, 
    this.missoesConcluidas = 0, 
    this.photoUrl,
  });

  // Método de conveniência para cópia
  Usuario copyWith({
    String? id, 
    String? nome, 
    String? email,
    int? pontos,
    int? missoesConcluidas,
    String? photoUrl,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      pontos: pontos ?? this.pontos,
      missoesConcluidas: missoesConcluidas ?? this.missoesConcluidas, 
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory Usuario.fromFirestore(Map<String, dynamic> data, String uid) {
    return Usuario(
      id: uid, 
      nome: data['nome'] as String? ?? 'Nome não definido',
      email: data['email'] as String? ?? 'Email não definido',
      pontos: (data['pontos'] as num?)?.toInt() ?? 0, 
      missoesConcluidas: (data['missoesConcluidas'] as num?)?.toInt() ?? 0,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'pontos': pontos,
      'missoesConcluidas': missoesConcluidas,
      'photoUrl': photoUrl,
    };
  }
}
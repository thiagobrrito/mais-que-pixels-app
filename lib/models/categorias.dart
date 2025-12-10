// lib/models/categorias.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ---------------------------------------------------------
// MODELO DE CATEGORIA COM ID
// ---------------------------------------------------------
class CategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

// LISTA DAS CATEGORIAS
const List<CategoryModel> mockCategories = [
  CategoryModel(
    id: 'zen',
    title: 'Zen',
    icon: Icons.spa,
    color: Color(0xFF8AAE8A),
  ),
  CategoryModel(
    id: 'criatividade',
    title: 'Criatividade',
    icon: Icons.lightbulb_outline,
    color: Color(0xFF8AAE8A),
  ),
  CategoryModel(
    id: 'gentileza',
    title: 'Gentileza',
    icon: Icons.volunteer_activism,
    color: Color(0xFF8AAE8A),
  ),
  CategoryModel(
    id: 'coragem',
    title: 'Coragem',
    icon: Icons.terrain,
    color: Color(0xFF8AAE8A),
  ),
];

// ---------------------------------------------------------
// MODELO DOS DESAFIOS EM DESTAQUE
// ---------------------------------------------------------
class HighlightChallengeModel {
  final String title;
  final int points;
  final Color color;

  const HighlightChallengeModel({
    required this.title,
    required this.points,
    required this.color,
  });

  String get formattedPoints => '+${points} pontos';
}

// ---------------------------------------------------------
// MODELO SIMPLES DE MISSÃO
// ---------------------------------------------------------
class MissionModel {
  final String title;
  final int points;
  final String categoryTitle;
  final IconData categoryIcon;

  const MissionModel({
    required this.title,
    required this.points,
    required this.categoryTitle,
    required this.categoryIcon,
  });
}

// ---------------------------------------------------------
// MODELO DETALHADO
// ---------------------------------------------------------

enum MissionDifficulty { Facil, Medio, Dificil }

class DetailedMissionModel {
  final String title;
  final String description;
  final int points;
  final String categoryTitle;
  final IconData categoryIcon;
  final MissionDifficulty difficulty;
  final String time;
  final String imageAsset;

  const DetailedMissionModel({
    required this.title,
    required this.description,
    required this.points,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.difficulty,
    required this.time,
    required this.imageAsset,
  });

  factory DetailedMissionModel.fromFirestore(Map<String, dynamic> data) {
    MissionDifficulty _getDifficulty(String? diff) {
      if (diff == 'Médio') return MissionDifficulty.Medio;
      if (diff == 'Difícil') return MissionDifficulty.Dificil;
      return MissionDifficulty.Facil;
    }

    IconData _getIcon(String iconName) {
      switch (iconName) {
        case 'Icons.spa':
          return Icons.spa;
        case 'Icons.lightbulb_outline':
          return Icons.lightbulb_outline;
        case 'Icons.volunteer_activism':
          return Icons.volunteer_activism;
        case 'Icons.terrain':
          return Icons.terrain;
        default:
          return Icons.help_outline;
      }
    }

    return DetailedMissionModel(
      title: data['title'] as String? ?? 'Missão sem título',
      description: data['description'] as String? ?? 'Sem descrição.',
      points: (data['points'] as num?)?.toInt() ?? 0,
      categoryTitle: data['categoryTitle'] as String? ?? 'Geral',
      categoryIcon: _getIcon(data['categoryIcon'] as String? ?? ''),
      difficulty: _getDifficulty(data['difficulty'] as String? ?? 'Fácil'),
      time: data['time'] as String? ?? 'Indefinido',
      imageAsset: data['imageAsset'] as String? ?? 'assets/default.png',
    );
  }

  String get difficultyAsString {
    switch (difficulty) {
      case MissionDifficulty.Facil:
        return 'Fácil';
      case MissionDifficulty.Medio:
        return 'Médio';
      case MissionDifficulty.Dificil:
        return 'Difícil';
    }
  }
}

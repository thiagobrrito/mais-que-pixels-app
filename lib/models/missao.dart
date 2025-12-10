import 'package:flutter/material.dart';

class Missao {
  final String id;
  final String categoryId;    
  final String categoryIcon;    
  final String categoryTitle;
  final String description;
  final String difficulty;
  final String imageAsset;
  final int points;
  final String time;
  final String title;

  Missao({
    required this.id,
    required this.categoryId,
    required this.categoryIcon,
    required this.categoryTitle,
    required this.description,
    required this.difficulty,
    required this.imageAsset,
    required this.points,
    required this.time,
    required this.title,
  });

  factory Missao.fromFirestore(Map<String, dynamic> map, String id) {
    return Missao(
      id: id,
      categoryId: map['categoriaId'] ?? map['categoryId'] ?? '',
      categoryIcon: map['categoryIcon'] ?? '',
      categoryTitle: map['categoryTitle'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? '',
      imageAsset: map['imageAsset'] ?? '',
      points: map['points'] ?? 0,
      time: map['time'] ?? '',
      title: map['title'] ?? '',
    );
  }
}

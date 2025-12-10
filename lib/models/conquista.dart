class Conquista {
  final String id;
  final String titulo;
  final String descricao;
  final bool conquistado;
  final String? data;

  Conquista({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.conquistado,
    this.data,
  });

  factory Conquista.fromMap(Map<String, dynamic> map) {
    return Conquista(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      conquistado: map['conquistado'] == true,
      data: map['data'],
    );
  }
}


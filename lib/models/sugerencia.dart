class Sugerencia {
  final int? id;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String userHash;
  final int likes;
  final DateTime? createdAt;
  final String estado;
  final DateTime? updatedAt;

  Sugerencia({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.userHash,
    this.likes = 0,
    this.createdAt,
    this.estado = 'pendiente',
    this.updatedAt,
  });

  factory Sugerencia.fromJson(Map<String, dynamic> json) {
    return Sugerencia(
      id: json['id'] as int?,
      titulo: json['titulo'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'mejora',
      userHash: json['user_hash'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      estado: json['estado'] as String? ?? 'pendiente',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'user_hash': userHash,
      'likes': likes,
    };
  }

  Sugerencia copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    String? tipo,
    String? userHash,
    int? likes,
    DateTime? createdAt,
    String? estado,
    DateTime? updatedAt,
  }) {
    return Sugerencia(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      userHash: userHash ?? this.userHash,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      estado: estado ?? this.estado,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
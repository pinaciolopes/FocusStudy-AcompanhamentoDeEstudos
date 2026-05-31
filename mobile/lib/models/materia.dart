// Model para Matéria
class Materia {
  final int? id;
  final String nome;

  Materia({
    this.id,
    required this.nome,
  });

  // Converte JSON do Django para objeto Dart
  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'],
      nome: json['nome'],
    );
  }

  // Converte objeto Dart para JSON (para enviar ao Django)
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
    };
  }

  // Para criar uma cópia com valores atualizados
  Materia copyWith({
    int? id,
    String? nome,
  }) {
    return Materia(
      id: id ?? this.id,
      nome: nome ?? this.nome,
    );
  }
}
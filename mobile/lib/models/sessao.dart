// Model para Sessão de Estudo
class SessaoEstudo {
  final int? id;
  final int materiaId;
  final DateTime data;
  final double horasEstudadas;
  final String anotacoes;

  SessaoEstudo({
    this.id,
    required this.materiaId,
    required this.data,
    required this.horasEstudadas,
    required this.anotacoes,
  });

  // Converte JSON do Django para objeto Dart
  factory SessaoEstudo.fromJson(Map<String, dynamic> json) {
    return SessaoEstudo(
      id: json['id'],
      materiaId: json['materia_id'],
      data: DateTime.parse(json['data']),
      horasEstudadas: json['horas_estudadas'].toDouble(),
      anotacoes: json['anotacoes'] ?? '',
    );
  }

  // Converte objeto Dart para JSON (para enviar ao Django)
  Map<String, dynamic> toJson() {
    return {
      'materia_id': materiaId,
      'data': data.toIso8601String().split('T').first,
      'horas_estudadas': horasEstudadas,
      'anotacoes': anotacoes,
    };
  }

  // Para criar uma cópia com valores atualizados
  SessaoEstudo copyWith({
    int? id,
    int? materiaId,
    DateTime? data,
    double? horasEstudadas,
    String? anotacoes,
  }) {
    return SessaoEstudo(
      id: id ?? this.id,
      materiaId: materiaId ?? this.materiaId,
      data: data ?? this.data,
      horasEstudadas: horasEstudadas ?? this.horasEstudadas,
      anotacoes: anotacoes ?? this.anotacoes,
    );
  }
}

// Classe para estatísticas do dashboard
class DashboardStats {
  final double totalHoras;
  final int totalSessoes;
  final double mediaPorSessao;
  final String materiaMaisEstudada;
  final double horasHoje;

  DashboardStats({
    required this.totalHoras,
    required this.totalSessoes,
    required this.mediaPorSessao,
    required this.materiaMaisEstudada,
    required this.horasHoje,
  });
}
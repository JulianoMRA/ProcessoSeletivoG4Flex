import 'package:fala_torcedor/models/plano.dart';

class Equipe {
  final String? id;
  final String nome;
  final String serie;
  final int qtdSocios;
  final List<Plano> planos;

  Equipe({
    this.id,
    required this.nome,
    required this.serie,
    required this.qtdSocios,
    this.planos = const [],
  });

  factory Equipe.fromJson(Map<String, dynamic> json) {
    return Equipe(
      id: json['id'] as String,
      nome: json['nome'] as String,
      serie: json['serie'] as String,
      qtdSocios: json['qtd_socios'] as int,
      planos: json['planos'] != null
          ? (json['planos'] as List)
              .map((plano) => Plano.fromJson(plano))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'serie': serie,
      'qtd_socios': qtdSocios,
    };
  }
}

import 'package:fala_torcedor/models/plano.dart';
import 'package:fala_torcedor/models/campeonato.dart';

class Equipe {
  final String? id;
  final String nome;
  final int qtdSocios;
  final List<Plano> planos;
  final List<Campeonato> campeonatos;

  Equipe({
    this.id,
    required this.nome,
    required this.qtdSocios,
    this.planos = const [],
    this.campeonatos = const [],
  });

  factory Equipe.fromJson(Map<String, dynamic> json) {
    return Equipe(
      id: json['id'] as String,
      nome: json['nome'] as String,
      qtdSocios: json['qtd_socios'] as int,
      planos: json['planos'] != null
          ? (json['planos'] as List)
              .map((plano) => Plano.fromJson(plano))
              .toList()
          : [],
      campeonatos: json['campeonatos'] != null
          ? (json['campeonatos'] as List)
              .map((c) => Campeonato.fromJson(c))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
    };
  }
}

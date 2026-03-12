import 'package:fala_torcedor/models/equipe.dart';

class Campeonato {
  final String? id;
  final String nome;
  final String temporada;
  final List<Equipe> equipes;

  Campeonato({
    this.id,
    required this.nome,
    required this.temporada,
    this.equipes = const [],
  });

  factory Campeonato.fromJson(Map<String, dynamic> json) {
    return Campeonato(
      id: json['id'] as String,
      nome: json['nome'] as String,
      temporada: json['temporada'] as String,
      equipes: json['equipes'] != null
          ? (json['equipes'] as List)
              .map((e) => Equipe.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'temporada': temporada,
    };
  }

  String get nomeCompleto => '$nome $temporada';
}

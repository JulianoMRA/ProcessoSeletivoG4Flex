import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/models/plano.dart';

class Torcedor {
  final String? id;
  final String nome;
  final String cpf;
  final DateTime nascimento;
  final String equipeId;
  final String planoId;
  final Equipe? equipe;
  final Plano? plano;

  Torcedor({
    this.id,
    required this.nome,
    required this.cpf,
    required this.nascimento,
    required this.equipeId,
    required this.planoId,
    this.equipe,
    this.plano,
  });

  factory Torcedor.fromJson(Map<String, dynamic> json) {
    Equipe? equipe;
    Plano? plano;

    if (json['equipes'] != null) {
      equipe = Equipe.fromJson(json['equipes']);
    } else if (json['equipe_nome'] != null) {
      equipe = Equipe(
        id: json['equipe_id'] as String,
        nome: json['equipe_nome'] as String,
        serie: json['equipe_serie'] as String,
        qtdSocios: 0,
      );
    }

    if (json['planos'] != null) {
      plano = Plano.fromJson(json['planos']);
    } else if (json['plano_nome'] != null) {
      plano = Plano(
        id: json['plano_id'] as String,
        nome: json['plano_nome'] as String,
        valor: (json['plano_valor'] is String)
            ? double.parse(json['plano_valor'])
            : (json['plano_valor'] as num).toDouble(),
      );
    }

    return Torcedor(
      id: json['id'] as String,
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      nascimento: DateTime.parse(json['nascimento'] as String),
      equipeId: json['equipe_id'] as String,
      planoId: json['plano_id'] as String,
      equipe: equipe,
      plano: plano,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpf': cpf,
      'nascimento': nascimento.toIso8601String().split('T').first,
      'equipe_id': equipeId,
      'plano_id': planoId,
    };
  }
}

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
    return Torcedor(
      id: json['id'] as String,
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      nascimento: DateTime.parse(json['nascimento'] as String),
      equipeId: json['equipe_id'] as String,
      planoId: json['plano_id'] as String,
      equipe: json['equipes'] != null
          ? Equipe.fromJson(json['equipes'])
          : null,
      plano: json['planos'] != null
          ? Plano.fromJson(json['planos'])
          : null,
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

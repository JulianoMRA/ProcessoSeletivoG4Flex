class Jogo {
  final String? id;
  final DateTime data;
  final String hora;
  final String equipeAId;
  final String equipeBId;
  final String? equipeANome;
  final String? equipeBNome;
  final int golsEquipeA;
  final int golsEquipeB;
  final String vencedor;

  Jogo({
    this.id,
    required this.data,
    required this.hora,
    required this.equipeAId,
    required this.equipeBId,
    this.equipeANome,
    this.equipeBNome,
    required this.golsEquipeA,
    required this.golsEquipeB,
    this.vencedor = 'empate',
  });

  factory Jogo.fromJson(Map<String, dynamic> json) {
    return Jogo(
      id: json['id'] as String,
      data: DateTime.parse(json['data'] as String),
      hora: (json['hora'] as String).substring(0, 5),
      equipeAId: json['equipe_a_id'] as String,
      equipeBId: json['equipe_b_id'] as String,
      equipeANome: json['equipe_a_nome'] as String?,
      equipeBNome: json['equipe_b_nome'] as String?,
      golsEquipeA: json['gols_equipe_a'] as int,
      golsEquipeB: json['gols_equipe_b'] as int,
      vencedor: json['vencedor'] as String? ?? 'empate',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data':
          '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}',
      'hora': hora,
      'equipe_a_id': equipeAId,
      'equipe_b_id': equipeBId,
      'gols_equipe_a': golsEquipeA,
      'gols_equipe_b': golsEquipeB,
    };
  }

  String get placar => '$golsEquipeA x $golsEquipeB';
}

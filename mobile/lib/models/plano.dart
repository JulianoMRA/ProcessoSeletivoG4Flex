class Plano {
  final String? id;
  final String? equipeId;
  final String nome;
  final double valor;
  final String? equipeNome;
  final String? equipeSerie;

  Plano({
    this.id,
    this.equipeId,
    required this.nome,
    required this.valor,
    this.equipeNome,
    this.equipeSerie,
  });

  factory Plano.fromJson(Map<String, dynamic> json) {
    return Plano(
      id: json['id'] as String,
      equipeId: json['equipe_id'] as String?,
      nome: json['nome'] as String,
      valor: (json['valor'] is String)
          ? double.parse(json['valor'])
          : (json['valor'] as num).toDouble(),
      equipeNome: json['equipe_nome'] as String?,
      equipeSerie: json['equipe_serie'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'equipe_id': equipeId, 'nome': nome, 'valor': valor};
  }
}

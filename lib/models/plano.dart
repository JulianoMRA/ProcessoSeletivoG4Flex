class Plano {
  final String? id;
  final String? equipeId;
  final String nome;

  Plano({
    this.id,
    this.equipeId,
    required this.nome,
  });

  factory Plano.fromJson(Map<String, dynamic> json) {
    return Plano(
      id: json['id'] as String,
      equipeId: json['equipe_id'] as String?,
      nome: json['nome'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipe_id': equipeId,
      'nome': nome,
    };
  }
}

class Plano {
  final String? id;
  final String nome;
  final double valor;

  Plano({this.id, required this.nome, required this.valor});

  factory Plano.fromJson(Map<String, dynamic> json) {
    return Plano(
      id: json['id'] as String,
      nome: json['nome'] as String,
      valor: (json['valor'] is String)
          ? double.parse(json['valor'])
          : (json['valor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nome': nome, 'valor': valor};
  }
}

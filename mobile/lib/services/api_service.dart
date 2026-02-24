import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/models/plano.dart';
import 'package:fala_torcedor/models/torcedor.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    return 'http://10.0.2.2:3000/api';
  }

  // EQUIPES

  Future<List<Equipe>> getEquipes() async {
    final response = await http.get(Uri.parse('$baseUrl/equipes'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Equipe.fromJson(json)).toList();
    }
    throw Exception('Erro ao carregar equipes');
  }

  Future<Equipe> getEquipeById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/equipes/$id'));
    if (response.statusCode == 200) {
      return Equipe.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao buscar equipe');
  }

  Future<Equipe> createEquipe(Equipe equipe, List<String> planoIds) async {
    final body = {
      'nome': equipe.nome,
      'serie': equipe.serie,
      'plano_ids': planoIds,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/equipes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      return Equipe.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao criar equipe');
  }

  Future<Equipe> updateEquipe(
    String id,
    Equipe equipe,
    List<String> planoIds,
  ) async {
    final body = {
      'nome': equipe.nome,
      'serie': equipe.serie,
      'plano_ids': planoIds,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/equipes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return Equipe.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao atualizar equipe');
  }

  Future<void> deleteEquipe(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/equipes/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir equipe');
    }
  }

  // PLANOS

  Future<List<Plano>> getPlanos() async {
    final response = await http.get(Uri.parse('$baseUrl/planos'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Plano.fromJson(json)).toList();
    }
    throw Exception('Erro ao carregar planos');
  }

  Future<List<Plano>> getPlanosByEquipe(String equipeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/planos?equipe_id=$equipeId'),
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Plano.fromJson(json)).toList();
    }
    throw Exception('Erro ao carregar planos');
  }

  Future<Plano> getPlanoById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/planos/$id'));
    if (response.statusCode == 200) {
      return Plano.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao buscar plano');
  }

  Future<Plano> createPlano(Plano plano) async {
    final response = await http.post(
      Uri.parse('$baseUrl/planos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(plano.toJson()),
    );

    if (response.statusCode == 201) {
      return Plano.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao criar plano');
  }

  Future<Plano> updatePlano(String id, Plano plano) async {
    final response = await http.put(
      Uri.parse('$baseUrl/planos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nome': plano.nome, 'valor': plano.valor}),
    );

    if (response.statusCode == 200) {
      return Plano.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao atualizar plano');
  }

  Future<void> deletePlano(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/planos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir plano');
    }
  }

  // TORCEDORES

  Future<List<Torcedor>> getTorcedores() async {
    final response = await http.get(Uri.parse('$baseUrl/torcedores'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Torcedor.fromJson(json)).toList();
    }
    throw Exception('Erro ao carregar torcedores');
  }

  Future<Torcedor> getTorcedorById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/torcedores/$id'));
    if (response.statusCode == 200) {
      return Torcedor.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao buscar torcedor');
  }

  Future<Torcedor> createTorcedor(Torcedor torcedor) async {
    final response = await http.post(
      Uri.parse('$baseUrl/torcedores'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(torcedor.toJson()),
    );

    if (response.statusCode == 201) {
      return Torcedor.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('CPF já cadastrado');
    }
    throw Exception('Erro ao criar torcedor');
  }

  Future<Torcedor> updateTorcedor(String id, Torcedor torcedor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/torcedores/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(torcedor.toJson()),
    );

    if (response.statusCode == 200) {
      return Torcedor.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('CPF já cadastrado');
    }
    throw Exception('Erro ao atualizar torcedor');
  }

  Future<void> deleteTorcedor(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/torcedores/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir torcedor');
    }
  }

  Future<bool> cpfJaExiste(String cpf, {String? ignorarId}) async {
    String url = '$baseUrl/torcedores/verificar-cpf?cpf=$cpf';
    if (ignorarId != null) {
      url += '&ignorar_id=$ignorarId';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['existe'] as bool;
    }
    return false;
  }
}

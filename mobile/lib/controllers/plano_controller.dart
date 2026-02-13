import 'package:flutter/material.dart';
import 'package:fala_torcedor/models/plano.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/services/api_service.dart';

class PlanoController extends ChangeNotifier {
  final _service = ApiService();

  List<Plano> planos = [];
  List<Equipe> equipes = [];
  bool isLoading = false;
  String? erro;

  Future<void> carregarPlanos() async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      planos = await _service.getPlanos();
    } catch (e) {
      erro = 'Erro ao carregar planos: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> carregarEquipes() async {
    try {
      equipes = await _service.getEquipes();
    } catch (e) {
      erro = 'Erro ao carregar equipes: $e';
    }
    notifyListeners();
  }

  Future<bool> criarPlano(Plano plano) async {
    try {
      await _service.createPlano(plano);
      await carregarPlanos();
      return true;
    } catch (e) {
      erro = 'Erro ao criar plano: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> atualizarPlano(String id, Plano plano) async {
    try {
      await _service.updatePlano(id, plano);
      await carregarPlanos();
      return true;
    } catch (e) {
      erro = 'Erro ao atualizar plano: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> excluirPlano(String id) async {
    try {
      await _service.deletePlano(id);
      await carregarPlanos();
      return true;
    } catch (e) {
      erro = 'Erro ao excluir plano: $e';
      notifyListeners();
      return false;
    }
  }
}

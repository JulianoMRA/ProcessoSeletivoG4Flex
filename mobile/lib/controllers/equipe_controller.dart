import 'package:flutter/material.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/services/api_service.dart';

class EquipeController extends ChangeNotifier {
  final _service = ApiService();

  List<Equipe> equipes = [];
  bool isLoading = false;
  String? erro;

  Future<void> carregarEquipes() async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      equipes = await _service.getEquipes();
    } catch (e) {
      erro = 'Erro ao carregar equipes: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> criarEquipe(Equipe equipe, List<String> planoIds) async {
    try {
      await _service.createEquipe(equipe, planoIds);
      await carregarEquipes();
      return true;
    } catch (e) {
      erro = 'Erro ao criar equipe: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> atualizarEquipe(
    String id,
    Equipe equipe,
    List<String> planoIds,
  ) async {
    try {
      await _service.updateEquipe(id, equipe, planoIds);
      await carregarEquipes();
      return true;
    } catch (e) {
      erro = 'Erro ao atualizar equipe: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> excluirEquipe(String id) async {
    try {
      await _service.deleteEquipe(id);
      await carregarEquipes();
      return true;
    } catch (e) {
      erro = 'Erro ao excluir equipe: $e';
      notifyListeners();
      return false;
    }
  }
}

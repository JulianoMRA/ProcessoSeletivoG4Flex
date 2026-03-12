import 'package:flutter/material.dart';
import 'package:fala_torcedor/models/campeonato.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/services/api_service.dart';

class CampeonatoController extends ChangeNotifier {
  final _service = ApiService();

  List<Campeonato> campeonatos = [];
  List<Equipe> equipes = [];
  bool isLoading = false;
  String? erro;

  Future<void> carregarCampeonatos() async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      campeonatos = await _service.getCampeonatos();
    } catch (e) {
      erro = 'Erro ao carregar campeonatos: $e';
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

  Future<bool> criarCampeonato(Campeonato campeonato, List<String> equipeIds) async {
    try {
      await _service.createCampeonato(campeonato, equipeIds);
      await carregarCampeonatos();
      return true;
    } catch (e) {
      erro = 'Erro ao criar campeonato: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> atualizarCampeonato(
    String id,
    Campeonato campeonato,
    List<String> equipeIds,
  ) async {
    try {
      await _service.updateCampeonato(id, campeonato, equipeIds);
      await carregarCampeonatos();
      return true;
    } catch (e) {
      erro = 'Erro ao atualizar campeonato: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> excluirCampeonato(String id) async {
    try {
      await _service.deleteCampeonato(id);
      await carregarCampeonatos();
      return true;
    } catch (e) {
      erro = 'Erro ao excluir campeonato: $e';
      notifyListeners();
      return false;
    }
  }
}

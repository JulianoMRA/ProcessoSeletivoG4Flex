import 'package:flutter/material.dart';
import 'package:fala_torcedor/models/jogo.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/models/campeonato.dart';
import 'package:fala_torcedor/services/api_service.dart';

class JogoController extends ChangeNotifier {
  final _service = ApiService();

  List<Jogo> jogos = [];
  List<Equipe> equipes = [];
  List<Campeonato> campeonatos = [];
  bool isLoading = false;
  String? erro;

  Future<void> carregarJogos() async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      jogos = await _service.getJogos();
    } catch (e) {
      erro = 'Erro ao carregar jogos: $e';
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

  Future<void> carregarCampeonatos() async {
    try {
      campeonatos = await _service.getCampeonatos();
    } catch (e) {
      erro = 'Erro ao carregar campeonatos: $e';
    }
    notifyListeners();
  }

  // Retorna equipes que pertencem ao campeonato selecionado
  List<Equipe> equipesDoCampeonato(String campeonatoId) {
    final campeonato = campeonatos
        .where((c) => c.id == campeonatoId)
        .firstOrNull;
    if (campeonato == null) return [];
    return campeonato.equipes;
  }

  Future<bool> criarJogo(Jogo jogo) async {
    try {
      await _service.createJogo(jogo);
      await carregarJogos();
      return true;
    } catch (e) {
      erro = 'Erro ao criar jogo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> atualizarJogo(String id, Jogo jogo) async {
    try {
      await _service.updateJogo(id, jogo);
      await carregarJogos();
      return true;
    } catch (e) {
      erro = 'Erro ao atualizar jogo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> excluirJogo(String id) async {
    try {
      await _service.deleteJogo(id);
      await carregarJogos();
      return true;
    } catch (e) {
      erro = 'Erro ao excluir jogo: $e';
      notifyListeners();
      return false;
    }
  }
}

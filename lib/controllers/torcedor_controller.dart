import 'package:flutter/material.dart';
import 'package:fala_torcedor/models/torcedor.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/models/plano.dart';
import 'package:fala_torcedor/services/supabase_service.dart';

class TorcedorController extends ChangeNotifier {
  final _service = SupabaseService();

  List<Torcedor> torcedores = [];
  List<Equipe> equipes = [];
  List<Plano> planosDisponiveis = [];
  bool isLoading = false;
  String? erro;

  Future<void> carregarTorcedores() async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      torcedores = await _service.getTorcedores();
    } catch (e) {
      erro = 'Erro ao carregar torcedores: $e';
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

  Future<void> carregarPlanos(String equipeId) async {
    try {
      planosDisponiveis = await _service.getPlanosByEquipe(equipeId);
    } catch (e) {
      erro = 'Erro ao carregar planos: $e';
      planosDisponiveis = [];
    }
    notifyListeners();
  }

  Future<bool> criarTorcedor(Torcedor torcedor) async {
    try {
      await _service.createTorcedor(torcedor);
      await carregarTorcedores();
      return true;
    } catch (e) {
      erro = 'Erro ao criar torcedor: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> atualizarTorcedor(String id, Torcedor torcedor) async {
    try {
      await _service.updateTorcedor(id, torcedor);
      await carregarTorcedores();
      return true;
    } catch (e) {
      erro = 'Erro ao atualizar torcedor: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> excluirTorcedor(String id) async {
    try {
      await _service.deleteTorcedor(id);
      await carregarTorcedores();
      return true;
    } catch (e) {
      erro = 'Erro ao excluir torcedor: $e';
      notifyListeners();
      return false;
    }
  }
}

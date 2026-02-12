import 'package:fala_torcedor/main.dart';
import 'package:fala_torcedor/models/equipe.dart';
import 'package:fala_torcedor/models/plano.dart';
import 'package:fala_torcedor/models/torcedor.dart';

class SupabaseService {
  // EQUIPES

  Future<List<Equipe>> getEquipes() async {
    final response = await supabase
        .from('equipes')
        .select('*, planos(*)')
        .order('nome', ascending: true);

    return (response as List)
        .map((json) => Equipe.fromJson(json))
        .toList();
  }

  Future<Equipe> getEquipeById(String id) async {
    final response = await supabase
        .from('equipes')
        .select('*, planos(*)')
        .eq('id', id)
        .single();

    return Equipe.fromJson(response);
  }

  Future<Equipe> createEquipe(Equipe equipe, List<String> nomesPlanos) async {
    final equipeResponse = await supabase
        .from('equipes')
        .insert(equipe.toJson())
        .select()
        .single();

    final equipeId = equipeResponse['id'] as String;

    final planosJson = nomesPlanos
        .map((nome) => Plano(equipeId: equipeId, nome: nome).toJson())
        .toList();

    await supabase.from('planos').insert(planosJson);

    return getEquipeById(equipeId);
  }

  Future<Equipe> updateEquipe(
    String id,
    Equipe equipe,
    List<String> nomesPlanos,
  ) async {
    await supabase
        .from('equipes')
        .update(equipe.toJson())
        .eq('id', id);

    await supabase.from('planos').delete().eq('equipe_id', id);

    final planosJson = nomesPlanos
        .map((nome) => Plano(equipeId: id, nome: nome).toJson())
        .toList();

    await supabase.from('planos').insert(planosJson);

    return getEquipeById(id);
  }

  Future<void> deleteEquipe(String id) async {
    await supabase.from('equipes').delete().eq('id', id);
  }

  // TORCEDORES

  Future<List<Torcedor>> getTorcedores() async {
    final response = await supabase
        .from('torcedores')
        .select('*, equipes(*), planos(*)')
        .order('nome', ascending: true);

    return (response as List)
        .map((json) => Torcedor.fromJson(json))
        .toList();
  }

  Future<Torcedor> getTorcedorById(String id) async {
    final response = await supabase
        .from('torcedores')
        .select('*, equipes(*), planos(*)')
        .eq('id', id)
        .single();

    return Torcedor.fromJson(response);
  }

  Future<Torcedor> createTorcedor(Torcedor torcedor) async {
    final response = await supabase
        .from('torcedores')
        .insert(torcedor.toJson())
        .select()
        .single();

    return getTorcedorById(response['id'] as String);
  }

  Future<Torcedor> updateTorcedor(String id, Torcedor torcedor) async {
    await supabase
        .from('torcedores')
        .update(torcedor.toJson())
        .eq('id', id);

    return getTorcedorById(id);
  }

  Future<void> deleteTorcedor(String id) async {
    await supabase.from('torcedores').delete().eq('id', id);
  }

  Future<bool> cpfJaExiste(String cpf, {String? ignorarId}) async {
    var query = supabase.from('torcedores').select('id').eq('cpf', cpf);
    if (ignorarId != null) {
      query = query.neq('id', ignorarId);
    }
    final response = await query;
    return (response as List).isNotEmpty;
  }

  Future<void> atualizarQtdSocios(String equipeId, int incremento) async {
    final equipe = await getEquipeById(equipeId);
    final novaQtd = equipe.qtdSocios + incremento;
    await supabase
        .from('equipes')
        .update({'qtd_socios': novaQtd})
        .eq('id', equipeId);
  }

  // PLANOS

  Future<List<Plano>> getPlanosByEquipe(String equipeId) async {
    final response = await supabase
        .from('planos')
        .select()
        .eq('equipe_id', equipeId)
        .order('nome', ascending: true);

    return (response as List)
        .map((json) => Plano.fromJson(json))
        .toList();
  }
}

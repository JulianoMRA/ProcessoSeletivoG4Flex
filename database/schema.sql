-- Equipes
CREATE TABLE equipes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  serie TEXT NOT NULL CHECK (serie IN ('Série A', 'Série B', 'Série C', 'Série D')),
  qtd_socios INTEGER NOT NULL DEFAULT 0
);

-- Planos
CREATE TABLE planos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  equipe_id UUID NOT NULL REFERENCES equipes(id) ON DELETE CASCADE,
  nome TEXT NOT NULL
);

-- Torcedores
CREATE TABLE torcedores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  cpf TEXT NOT NULL,
  nascimento DATE NOT NULL,
  equipe_id UUID NOT NULL REFERENCES equipes(id) ON DELETE CASCADE,
  plano_id UUID NOT NULL REFERENCES planos(id) ON DELETE CASCADE
);

-- Desabilitar RLS para as tabelas
ALTER TABLE equipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE planos ENABLE ROW LEVEL SECURITY;
ALTER TABLE torcedores ENABLE ROW LEVEL SECURITY;

-- Políticas de acesso
CREATE POLICY "Acesso total equipes" ON equipes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acesso total planos" ON planos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acesso total torcedores" ON torcedores FOR ALL USING (true) WITH CHECK (true);
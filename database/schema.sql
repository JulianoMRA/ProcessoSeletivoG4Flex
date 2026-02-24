-- Equipes
CREATE TABLE equipes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  serie TEXT NOT NULL CHECK (
    serie IN ('Série A', 'Série B', 'Série C', 'Série D')
  ),
  qtd_socios INTEGER NOT NULL DEFAULT 0
);
-- Planos
CREATE TABLE planos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  valor DECIMAL(8, 2) NOT NULL
);
-- Relacionamento N:N entre equipes e planos
CREATE TABLE equipe_planos (
  equipe_id UUID NOT NULL REFERENCES equipes(id) ON DELETE CASCADE,
  plano_id UUID NOT NULL REFERENCES planos(id) ON DELETE CASCADE,
  PRIMARY KEY (equipe_id, plano_id)
);
-- Torcedores
CREATE TABLE torcedores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  cpf TEXT NOT NULL UNIQUE,
  nascimento DATE NOT NULL,
  equipe_id UUID NOT NULL REFERENCES equipes(id) ON DELETE CASCADE,
  plano_id UUID NOT NULL REFERENCES planos(id) ON DELETE CASCADE
);
-- Jogos
CREATE TABLE jogos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  data DATE NOT NULL,
  hora TIME NOT NULL,
  equipe_a_id UUID NOT NULL REFERENCES equipes(id) ON DELETE CASCADE,
  equipe_b_id UUID NOT NULL REFERENCES equipes(id) ON DELETE CASCADE,
  gols_equipe_a INTEGER NOT NULL DEFAULT 0,
  gols_equipe_b INTEGER NOT NULL DEFAULT 0,
  CHECK (equipe_a_id != equipe_b_id)
);
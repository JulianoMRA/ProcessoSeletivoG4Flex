-- =============================================================
-- SEED DATA — Fala, Torcedor!
-- =============================================================

-- 1. EQUIPES (8 equipes)
INSERT INTO equipes (nome, qtd_socios) VALUES
  ('Flamengo', 0),
  ('Palmeiras', 0),
  ('São Paulo', 0),
  ('Corinthians', 0),
  ('Sport Recife', 0),
  ('Remo', 0),
  ('Aparecidense', 0),
  ('Fortaleza', 0);

-- 2. PLANOS (5 planos)
INSERT INTO planos (nome, valor) VALUES
  ('Bronze', 19.90),
  ('Prata', 39.90),
  ('Ouro', 79.90),
  ('Platina', 109.90),
  ('Diamante', 149.90);

-- 3. VÍNCULOS EQUIPE-PLANO
INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id, p.id FROM equipes e, planos p
WHERE e.nome = 'Flamengo' AND p.nome IN ('Bronze', 'Prata', 'Ouro', 'Platina', 'Diamante');

INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id, p.id FROM equipes e, planos p
WHERE e.nome = 'Palmeiras' AND p.nome IN ('Bronze', 'Prata', 'Ouro', 'Diamante');

INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id, p.id FROM equipes e, planos p
WHERE e.nome = 'São Paulo' AND p.nome IN ('Bronze', 'Prata', 'Ouro', 'Platina');

INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id, p.id FROM equipes e, planos p
WHERE e.nome = 'Corinthians' AND p.nome IN ('Bronze', 'Prata', 'Ouro', 'Platina');

INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id, p.id FROM equipes e, planos p
WHERE e.nome = 'Sport Recife' AND p.nome IN ('Bronze', 'Prata', 'Ouro');

INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id, p.id FROM equipes e, planos p
WHERE e.nome = 'Remo' AND p.nome IN ('Bronze', 'Prata');

INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id, p.id FROM equipes e, planos p
WHERE e.nome = 'Aparecidense' AND p.nome IN ('Bronze', 'Prata', 'Ouro');

INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id, p.id FROM equipes e, planos p
WHERE e.nome = 'Fortaleza' AND p.nome IN ('Bronze', 'Prata', 'Ouro', 'Platina');

-- 4. TORCEDORES (25 torcedores — mix de jovens, adultos e idosos)

-- === JOVENS (< 20 anos — nascidos após 2006-03-17) ===
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Matheus Oliveira', '11111111111', '2008-06-12', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Flamengo' AND p.nome = 'Bronze';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Larissa Santos', '22222222222', '2009-01-20', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Palmeiras' AND p.nome = 'Bronze';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Gabriel Ferreira', '33333333333', '2007-09-05', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Corinthians' AND p.nome = 'Prata';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Isabela Costa', '44444444444', '2010-03-15', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'São Paulo' AND p.nome = 'Bronze';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Lucas Mendes', '55555555555', '2008-11-28', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Fortaleza' AND p.nome = 'Prata';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Rafaela Lima', '66666666666', '2007-04-10', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Sport Recife' AND p.nome = 'Bronze';

-- === ADULTOS (20–59 anos — nascidos 1967–2006) ===
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'João Silva', '12345678901', '1990-05-15', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Flamengo' AND p.nome = 'Ouro';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Maria Oliveira', '23456789012', '1985-11-22', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Flamengo' AND p.nome = 'Platina';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Pedro Santos', '34567890123', '2000-03-10', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Flamengo' AND p.nome = 'Prata';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Ana Costa', '45678901234', '1995-07-30', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Palmeiras' AND p.nome = 'Diamante';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Lucas Ferreira', '56789012345', '1988-01-18', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Palmeiras' AND p.nome = 'Ouro';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Carlos Almeida', '67890123456', '1992-09-05', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Sport Recife' AND p.nome = 'Ouro';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Fernanda Lima', '78901234567', '1998-12-25', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'São Paulo' AND p.nome = 'Platina';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Roberto Souza', '89012345678', '1983-06-14', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Remo' AND p.nome = 'Prata';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Juliana Martins', '90123456789', '2001-04-08', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Aparecidense' AND p.nome = 'Prata';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Ricardo Barbosa', '01234567890', '1996-08-20', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Aparecidense' AND p.nome = 'Ouro';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Thiago Nascimento', '10101010101', '1978-02-14', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Corinthians' AND p.nome = 'Ouro';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Camila Rodrigues', '20202020202', '1991-10-30', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Fortaleza' AND p.nome = 'Ouro';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Bruno Carvalho', '30303030303', '1975-07-22', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Fortaleza' AND p.nome = 'Platina';

-- === IDOSOS (≥ 60 anos — nascidos antes de 1966) ===
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Antônio Pereira', '40404040404', '1955-03-08', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Flamengo' AND p.nome = 'Diamante';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Maria das Graças', '50505050505', '1950-12-01', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Palmeiras' AND p.nome = 'Prata';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'José de Souza', '60606060606', '1958-08-25', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'São Paulo' AND p.nome = 'Ouro';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Francisca Moreira', '70707070707', '1948-05-17', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Corinthians' AND p.nome = 'Platina';

INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Sebastião Nunes', '80808080808', '1960-11-03', e.id, p.id
FROM equipes e, planos p WHERE e.nome = 'Sport Recife' AND p.nome = 'Prata';

-- Atualizar qtd_socios
UPDATE equipes SET qtd_socios = (
  SELECT COUNT(*) FROM torcedores WHERE torcedores.equipe_id = equipes.id
);

-- 5. CAMPEONATOS (4 campeonatos)
INSERT INTO campeonatos (nome, temporada) VALUES
  ('Brasileirão Série A', '2025'),
  ('Brasileirão Série B', '2025'),
  ('Copa do Brasil', '2025'),
  ('Copa do Nordeste', '2025');

-- 6. VÍNCULOS CAMPEONATO-EQUIPE
-- Série A: Flamengo, Palmeiras, São Paulo, Corinthians, Fortaleza
INSERT INTO campeonato_equipes (campeonato_id, equipe_id)
SELECT c.id, e.id FROM campeonatos c, equipes e
WHERE c.nome = 'Brasileirão Série A'
  AND e.nome IN ('Flamengo', 'Palmeiras', 'São Paulo', 'Corinthians', 'Fortaleza');

-- Série B: Sport Recife, Remo, Aparecidense
INSERT INTO campeonato_equipes (campeonato_id, equipe_id)
SELECT c.id, e.id FROM campeonatos c, equipes e
WHERE c.nome = 'Brasileirão Série B'
  AND e.nome IN ('Sport Recife', 'Remo', 'Aparecidense');

-- Copa do Brasil: Flamengo, Palmeiras, São Paulo, Sport Recife, Fortaleza
INSERT INTO campeonato_equipes (campeonato_id, equipe_id)
SELECT c.id, e.id FROM campeonatos c, equipes e
WHERE c.nome = 'Copa do Brasil'
  AND e.nome IN ('Flamengo', 'Palmeiras', 'São Paulo', 'Sport Recife', 'Fortaleza');

-- Copa do Nordeste: Sport Recife, Remo, Fortaleza
INSERT INTO campeonato_equipes (campeonato_id, equipe_id)
SELECT c.id, e.id FROM campeonatos c, equipes e
WHERE c.nome = 'Copa do Nordeste'
  AND e.nome IN ('Sport Recife', 'Remo', 'Fortaleza');

-- 7. JOGOS (15 jogos distribuídos entre os campeonatos)

-- === Brasileirão Série A (6 jogos) ===
INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-03-15', '16:00', c.id, a.id, b.id, 2, 1
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Brasileirão Série A' AND a.nome = 'Flamengo' AND b.nome = 'Palmeiras';

INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-03-22', '18:30', c.id, a.id, b.id, 0, 0
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Brasileirão Série A' AND a.nome = 'São Paulo' AND b.nome = 'Corinthians';

INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-04-05', '20:00', c.id, a.id, b.id, 3, 2
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Brasileirão Série A' AND a.nome = 'Fortaleza' AND b.nome = 'Flamengo';

INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-04-12', '16:00', c.id, a.id, b.id, 1, 1
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Brasileirão Série A' AND a.nome = 'Palmeiras' AND b.nome = 'São Paulo';

INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-04-19', '19:00', c.id, a.id, b.id, 4, 0
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Brasileirão Série A' AND a.nome = 'Corinthians' AND b.nome = 'Fortaleza';

INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-05-03', '21:00', c.id, a.id, b.id, 2, 2
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Brasileirão Série A' AND a.nome = 'Flamengo' AND b.nome = 'São Paulo';

-- === Brasileirão Série B (4 jogos) ===
INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-04-10', '19:00', c.id, a.id, b.id, 0, 0
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Brasileirão Série B' AND a.nome = 'Sport Recife' AND b.nome = 'Remo';

INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-05-01', '15:30', c.id, a.id, b.id, 4, 0
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Brasileirão Série B' AND a.nome = 'Remo' AND b.nome = 'Aparecidense';

INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-05-15', '20:00', c.id, a.id, b.id, 2, 3
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Brasileirão Série B' AND a.nome = 'Aparecidense' AND b.nome = 'Sport Recife';

INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-06-01', '16:00', c.id, a.id, b.id, 1, 0
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Brasileirão Série B' AND a.nome = 'Sport Recife' AND b.nome = 'Aparecidense';

-- === Copa do Brasil (3 jogos) ===
INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-06-08', '21:00', c.id, a.id, b.id, 1, 2
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Copa do Brasil' AND a.nome = 'Flamengo' AND b.nome = 'Sport Recife';

INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-06-15', '20:30', c.id, a.id, b.id, 3, 1
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Copa do Brasil' AND a.nome = 'Palmeiras' AND b.nome = 'Fortaleza';

INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-07-02', '19:00', c.id, a.id, b.id, 0, 1
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Copa do Brasil' AND a.nome = 'São Paulo' AND b.nome = 'Palmeiras';

-- === Copa do Nordeste (2 jogos) ===
INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-02-20', '20:00', c.id, a.id, b.id, 2, 1
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Copa do Nordeste' AND a.nome = 'Fortaleza' AND b.nome = 'Sport Recife';

INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
SELECT '2025-03-06', '19:30', c.id, a.id, b.id, 1, 1
FROM campeonatos c, equipes a, equipes b
WHERE c.nome = 'Copa do Nordeste' AND a.nome = 'Remo' AND b.nome = 'Fortaleza';
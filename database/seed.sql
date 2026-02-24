-- 1. EQUIPES
INSERT INTO equipes (nome, serie, qtd_socios)
VALUES ('Flamengo', 'Série A', 3),
  ('Palmeiras', 'Série A', 2),
  ('Sport Recife', 'Série B', 2),
  ('Remo', 'Série C', 1),
  ('Aparecidense', 'Série D', 2);
-- 2. PLANOS (independentes)
INSERT INTO planos (nome, valor)
VALUES ('Bronze', 19.90),
  ('Prata', 39.90),
  ('Ouro', 79.90),
  ('Platina', 109.90),
  ('Diamante', 149.90);
-- 3. VINCULOS EQUIPE-PLANO (N:N)
-- Flamengo: Bronze, Prata, Ouro, Platina
INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Flamengo'
  AND p.nome IN ('Bronze', 'Prata', 'Ouro', 'Platina');
-- Palmeiras: Bronze, Prata, Ouro, Diamante
INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Palmeiras'
  AND p.nome IN ('Bronze', 'Prata', 'Ouro', 'Diamante');
-- Sport Recife: Bronze, Prata, Ouro
INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Sport Recife'
  AND p.nome IN ('Bronze', 'Prata', 'Ouro');
-- Remo: Bronze, Prata
INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Remo'
  AND p.nome IN ('Bronze', 'Prata');
-- Aparecidense: Bronze, Prata, Ouro
INSERT INTO equipe_planos (equipe_id, plano_id)
SELECT e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Aparecidense'
  AND p.nome IN ('Bronze', 'Prata', 'Ouro');
-- 4. TORCEDORES
-- Flamengo
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'João Silva',
  '12345678901',
  '1990-05-15',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Flamengo'
  AND p.nome = 'Bronze';
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Maria Oliveira',
  '23456789012',
  '1985-11-22',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Flamengo'
  AND p.nome = 'Ouro';
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Pedro Santos',
  '34567890123',
  '2000-03-10',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Flamengo'
  AND p.nome = 'Prata';
-- Palmeiras
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Ana Costa',
  '45678901234',
  '1995-07-30',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Palmeiras'
  AND p.nome = 'Bronze';
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Lucas Ferreira',
  '56789012345',
  '1988-01-18',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Palmeiras'
  AND p.nome = 'Diamante';
-- Sport Recife
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Carlos Almeida',
  '67890123456',
  '1992-09-05',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Sport Recife'
  AND p.nome = 'Ouro';
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Fernanda Lima',
  '78901234567',
  '1998-12-25',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Sport Recife'
  AND p.nome = 'Bronze';
-- Remo
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Roberto Souza',
  '89012345678',
  '1983-06-14',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Remo'
  AND p.nome = 'Prata';
-- Aparecidense
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Juliana Martins',
  '90123456789',
  '2001-04-08',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Aparecidense'
  AND p.nome = 'Prata';
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Ricardo Barbosa',
  '01234567890',
  '1996-08-20',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Aparecidense'
  AND p.nome = 'Ouro';
-- 5. JOGOS
-- Flamengo 2x1 Palmeiras
INSERT INTO jogos (
    data,
    hora,
    equipe_a_id,
    equipe_b_id,
    gols_equipe_a,
    gols_equipe_b
  )
SELECT '2025-03-15',
  '16:00',
  a.id,
  b.id,
  2,
  1
FROM equipes a,
  equipes b
WHERE a.nome = 'Flamengo'
  AND b.nome = 'Palmeiras';
-- Sport Recife 0x0 Remo (empate)
INSERT INTO jogos (
    data,
    hora,
    equipe_a_id,
    equipe_b_id,
    gols_equipe_a,
    gols_equipe_b
  )
SELECT '2025-04-10',
  '19:00',
  a.id,
  b.id,
  0,
  0
FROM equipes a,
  equipes b
WHERE a.nome = 'Sport Recife'
  AND b.nome = 'Remo';
-- Palmeiras 3x1 Aparecidense
INSERT INTO jogos (
    data,
    hora,
    equipe_a_id,
    equipe_b_id,
    gols_equipe_a,
    gols_equipe_b
  )
SELECT '2025-05-22',
  '20:30',
  a.id,
  b.id,
  3,
  1
FROM equipes a,
  equipes b
WHERE a.nome = 'Palmeiras'
  AND b.nome = 'Aparecidense';
-- Flamengo 1x2 Sport Recife
INSERT INTO jogos (
    data,
    hora,
    equipe_a_id,
    equipe_b_id,
    gols_equipe_a,
    gols_equipe_b
  )
SELECT '2025-06-08',
  '21:00',
  a.id,
  b.id,
  1,
  2
FROM equipes a,
  equipes b
WHERE a.nome = 'Flamengo'
  AND b.nome = 'Sport Recife';
-- Remo 4x0 Aparecidense
INSERT INTO jogos (
    data,
    hora,
    equipe_a_id,
    equipe_b_id,
    gols_equipe_a,
    gols_equipe_b
  )
SELECT '2025-07-01',
  '15:30',
  a.id,
  b.id,
  4,
  0
FROM equipes a,
  equipes b
WHERE a.nome = 'Remo'
  AND b.nome = 'Aparecidense';
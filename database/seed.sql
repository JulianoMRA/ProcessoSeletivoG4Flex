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
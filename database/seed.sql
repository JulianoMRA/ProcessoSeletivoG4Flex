-- 1. EQUIPES
INSERT INTO equipes (nome, serie, qtd_socios)
VALUES ('Flamengo', 'Série A', 3),
  ('Palmeiras', 'Série A', 2),
  ('Sport Recife', 'Série B', 2),
  ('Remo', 'Série C', 1),
  ('Aparecidense', 'Série D', 2);
-- 2. PLANOS (3 por equipe, com valor mensal)
-- Flamengo
INSERT INTO planos (equipe_id, nome, valor)
SELECT id,
  'Raça',
  29.90
FROM equipes
WHERE nome = 'Flamengo'
UNION ALL
SELECT id,
  'Paixão',
  59.90
FROM equipes
WHERE nome = 'Flamengo'
UNION ALL
SELECT id,
  'Nação',
  99.90
FROM equipes
WHERE nome = 'Flamengo';
-- Palmeiras
INSERT INTO planos (equipe_id, nome, valor)
SELECT id,
  'Avanti',
  35.00
FROM equipes
WHERE nome = 'Palmeiras'
UNION ALL
SELECT id,
  'Avanti Família',
  69.90
FROM equipes
WHERE nome = 'Palmeiras'
UNION ALL
SELECT id,
  'Avanti Premium',
  109.90
FROM equipes
WHERE nome = 'Palmeiras';
-- Sport Recife
INSERT INTO planos (equipe_id, nome, valor)
SELECT id,
  'Leão Bronze',
  19.90
FROM equipes
WHERE nome = 'Sport Recife'
UNION ALL
SELECT id,
  'Leão Prata',
  39.90
FROM equipes
WHERE nome = 'Sport Recife'
UNION ALL
SELECT id,
  'Leão Ouro',
  79.90
FROM equipes
WHERE nome = 'Sport Recife';
-- Remo
INSERT INTO planos (equipe_id, nome, valor)
SELECT id,
  'Azulino',
  15.00
FROM equipes
WHERE nome = 'Remo'
UNION ALL
SELECT id,
  'Azulão',
  35.00
FROM equipes
WHERE nome = 'Remo'
UNION ALL
SELECT id,
  'Fenômeno Azul',
  65.00
FROM equipes
WHERE nome = 'Remo';
-- Aparecidense
INSERT INTO planos (equipe_id, nome, valor)
SELECT id,
  'Camaleão',
  10.00
FROM equipes
WHERE nome = 'Aparecidense'
UNION ALL
SELECT id,
  'Camaleão Plus',
  25.00
FROM equipes
WHERE nome = 'Aparecidense'
UNION ALL
SELECT id,
  'Camaleão VIP',
  50.00
FROM equipes
WHERE nome = 'Aparecidense';
-- 3. TORCEDORES
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
  AND p.nome = 'Raça'
  AND p.equipe_id = e.id;
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Maria Oliveira',
  '23456789012',
  '1985-11-22',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Flamengo'
  AND p.nome = 'Nação'
  AND p.equipe_id = e.id;
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Pedro Santos',
  '34567890123',
  '2000-03-10',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Flamengo'
  AND p.nome = 'Paixão'
  AND p.equipe_id = e.id;
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
  AND p.nome = 'Avanti'
  AND p.equipe_id = e.id;
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Lucas Ferreira',
  '56789012345',
  '1988-01-18',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Palmeiras'
  AND p.nome = 'Avanti Premium'
  AND p.equipe_id = e.id;
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
  AND p.nome = 'Leão Ouro'
  AND p.equipe_id = e.id;
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Fernanda Lima',
  '78901234567',
  '1998-12-25',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Sport Recife'
  AND p.nome = 'Leão Bronze'
  AND p.equipe_id = e.id;
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
  AND p.nome = 'Azulão'
  AND p.equipe_id = e.id;
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
  AND p.nome = 'Camaleão Plus'
  AND p.equipe_id = e.id;
INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id)
SELECT 'Ricardo Barbosa',
  '01234567890',
  '1996-08-20',
  e.id,
  p.id
FROM equipes e,
  planos p
WHERE e.nome = 'Aparecidense'
  AND p.nome = 'Camaleão VIP'
  AND p.equipe_id = e.id;
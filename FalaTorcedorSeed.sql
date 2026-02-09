-- 1. EQUIPES

INSERT INTO equipes (nome, serie, qtd_socios)
VALUES ('Flamengo', 'Série A', 3),
  ('Palmeiras', 'Série A', 2),
  ('Sport Recife', 'Série B', 2),
  ('Remo', 'Série C', 1),
  ('Aparecidense', 'Série D', 2);

-- 2. PLANOS (3 por equipe)

-- Flamengo
INSERT INTO planos (equipe_id, nome)
SELECT id,
  'Raça'
FROM equipes
WHERE nome = 'Flamengo'
UNION ALL
SELECT id,
  'Paixão'
FROM equipes
WHERE nome = 'Flamengo'
UNION ALL
SELECT id,
  'Nação'
FROM equipes
WHERE nome = 'Flamengo';
-- Palmeiras
INSERT INTO planos (equipe_id, nome)
SELECT id,
  'Avanti'
FROM equipes
WHERE nome = 'Palmeiras'
UNION ALL
SELECT id,
  'Avanti Família'
FROM equipes
WHERE nome = 'Palmeiras'
UNION ALL
SELECT id,
  'Avanti Premium'
FROM equipes
WHERE nome = 'Palmeiras';
-- Sport Recife
INSERT INTO planos (equipe_id, nome)
SELECT id,
  'Leão Bronze'
FROM equipes
WHERE nome = 'Sport Recife'
UNION ALL
SELECT id,
  'Leão Prata'
FROM equipes
WHERE nome = 'Sport Recife'
UNION ALL
SELECT id,
  'Leão Ouro'
FROM equipes
WHERE nome = 'Sport Recife';
-- Remo
INSERT INTO planos (equipe_id, nome)
SELECT id,
  'Azulino'
FROM equipes
WHERE nome = 'Remo'
UNION ALL
SELECT id,
  'Azulão'
FROM equipes
WHERE nome = 'Remo'
UNION ALL
SELECT id,
  'Fenômeno Azul'
FROM equipes
WHERE nome = 'Remo';
-- Aparecidense
INSERT INTO planos (equipe_id, nome)
SELECT id,
  'Camaleão'
FROM equipes
WHERE nome = 'Aparecidense'
UNION ALL
SELECT id,
  'Camaleão Plus'
FROM equipes
WHERE nome = 'Aparecidense'
UNION ALL
SELECT id,
  'Camaleão VIP'
FROM equipes
WHERE nome = 'Aparecidense';

-- 3. TORCEDORES

-- Torcedores do Flamengo
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
-- Torcedores do Palmeiras
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
-- Torcedores do Sport
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
-- Torcedores do Remo
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
-- Torcedores da Aparecidense
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
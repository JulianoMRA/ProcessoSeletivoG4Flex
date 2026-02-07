-- Seeds: Dados iniciais para testes
-- Execute este arquivo após criar o schema
\ c fala_torcedor;
-- Inserir equipes de exemplo
INSERT INTO equipes (nome, serie, quantidade_socios)
VALUES ('Flamengo', 'Série A', 45000),
    ('Corinthians', 'Série A', 38000),
    ('Palmeiras', 'Série A', 42000),
    ('São Paulo', 'Série A', 35000),
    ('Vasco da Gama', 'Série B', 28000);
-- Inserir torcedores de exemplo
INSERT INTO torcedores (
        nome,
        cpf,
        data_nascimento,
        equipe_id,
        plano_socio
    )
VALUES (
        'Carlos Silva',
        '12345678901',
        '1990-05-15',
        1,
        'Diamante'
    ),
    (
        'Maria Santos',
        '23456789012',
        '1985-08-22',
        1,
        'Ouro'
    ),
    (
        'João Oliveira',
        '34567890123',
        '1992-03-10',
        2,
        'Prata'
    ),
    (
        'Ana Costa',
        '45678901234',
        '1988-11-30',
        2,
        'Ouro'
    ),
    (
        'Pedro Souza',
        '56789012345',
        '1995-07-18',
        3,
        'Diamante'
    ),
    (
        'Juliana Lima',
        '67890123456',
        '1991-02-25',
        3,
        'Prata'
    ),
    (
        'Fernando Alves',
        '78901234567',
        '1987-09-14',
        4,
        'Ouro'
    ),
    (
        'Beatriz Rocha',
        '89012345678',
        '1993-12-05',
        5,
        'Prata'
    );
-- Verificar inserções
SELECT 'Equipes cadastradas:' AS info;
SELECT id,
    nome,
    serie,
    quantidade_socios
FROM equipes
ORDER BY id;
SELECT 'Torcedores cadastrados:' AS info;
SELECT t.id,
    t.nome,
    t.cpf,
    t.plano_socio,
    e.nome AS equipe
FROM torcedores t
    JOIN equipes e ON t.equipe_id = e.id
ORDER BY t.id;
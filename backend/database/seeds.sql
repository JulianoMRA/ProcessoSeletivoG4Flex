-- Seeds: Dados iniciais para testes
INSERT INTO equipes (nome, serie, quantidade_socios)
VALUES ('Flamengo', 'Série A', 45000),
    ('Corinthians', 'Série A', 38000),
    ('Palmeiras', 'Série A', 42000),
    ('São Paulo', 'Série A', 35000),
    ('Vasco da Gama', 'Série B', 28000);
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
        'Sócio Diamante'::plano_socio
    ),
    (
        'Maria Santos',
        '23456789012',
        '1985-08-22',
        1,
        'Sócio Ouro'::plano_socio
    ),
    (
        'João Oliveira',
        '34567890123',
        '1992-03-10',
        2,
        'Sócio Prata'::plano_socio
    ),
    (
        'Ana Costa',
        '45678901234',
        '1988-11-30',
        2,
        'Sócio Ouro'::plano_socio
    ),
    (
        'Pedro Souza',
        '56789012345',
        '1995-07-18',
        3,
        'Sócio Diamante'::plano_socio
    ),
    (
        'Juliana Lima',
        '67890123456',
        '1991-02-25',
        3,
        'Sócio Prata'::plano_socio
    ),
    (
        'Fernando Alves',
        '78901234567',
        '1987-09-14',
        4,
        'Sócio Ouro'::plano_socio
    ),
    (
        'Beatriz Rocha',
        '89012345678',
        '1993-12-05',
        5,
        'Sócio Prata'::plano_socio
    );
SELECT 'Equipes cadastradas:' AS info;
SELECT id,
    nome,
    serie,
    quantidade_socios,
    planos_socio
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
const pool = require('../config/database');

exports.obterRelatorios = async (req, res) => {
    try {
        const [etaria, equipesCamp, jogosCamp] = await Promise.all([
            pool.query(`
                SELECT
                    COUNT(*) FILTER (
                        WHERE EXTRACT(YEAR FROM age(CURRENT_DATE, nascimento)) < 20
                    )::int AS jovens,
                    COUNT(*) FILTER (
                        WHERE EXTRACT(YEAR FROM age(CURRENT_DATE, nascimento)) >= 20
                          AND EXTRACT(YEAR FROM age(CURRENT_DATE, nascimento)) < 60
                    )::int AS adultos,
                    COUNT(*) FILTER (
                        WHERE EXTRACT(YEAR FROM age(CURRENT_DATE, nascimento)) >= 60
                    )::int AS idosos
                FROM torcedores
            `),
            pool.query(`
                SELECT c.nome || ' ' || c.temporada AS campeonato,
                       COUNT(ce.equipe_id)::int AS total
                FROM campeonatos c
                LEFT JOIN campeonato_equipes ce ON c.id = ce.campeonato_id
                GROUP BY c.id, c.nome, c.temporada
                ORDER BY c.temporada DESC, c.nome
            `),
            pool.query(`
                SELECT c.nome || ' ' || c.temporada AS campeonato,
                       COUNT(j.id)::int AS total
                FROM campeonatos c
                LEFT JOIN jogos j ON c.id = j.campeonato_id
                GROUP BY c.id, c.nome, c.temporada
                ORDER BY c.temporada DESC, c.nome
            `),
        ]);

        res.json({
            distribuicao_etaria: etaria.rows[0],
            equipes_por_campeonato: equipesCamp.rows,
            jogos_por_campeonato: jogosCamp.rows,
        });
    } catch (err) {
        console.error('Erro ao gerar relatórios:', err.message);
        res.status(500).json({ erro: 'Erro ao gerar relatórios' });
    }
};

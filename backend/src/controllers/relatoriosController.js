const pool = require('../config/database');

exports.obterRelatorios = async (req, res) => {
    try {
        const [etaria, equipesCamp, jogosCamp, kpis, desempenho] = await Promise.all([
            // 1. Distribuição etária
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

            // 2. Equipes por campeonato (com nomes das equipes)
            pool.query(`
                SELECT c.nome || ' ' || c.temporada AS campeonato,
                       COUNT(ce.equipe_id)::int AS total,
                       COALESCE(
                           json_agg(e.nome ORDER BY e.nome) FILTER (WHERE e.nome IS NOT NULL),
                           '[]'::json
                       ) AS equipes
                FROM campeonatos c
                LEFT JOIN campeonato_equipes ce ON c.id = ce.campeonato_id
                LEFT JOIN equipes e ON ce.equipe_id = e.id
                GROUP BY c.id, c.nome, c.temporada
                ORDER BY c.temporada DESC, c.nome
            `),

            // 3. Jogos por campeonato
            pool.query(`
                SELECT c.nome || ' ' || c.temporada AS campeonato,
                       COUNT(j.id)::int AS total,
                       COALESCE(SUM(j.gols_equipe_a + j.gols_equipe_b), 0)::int AS total_gols
                FROM campeonatos c
                LEFT JOIN jogos j ON c.id = j.campeonato_id
                GROUP BY c.id, c.nome, c.temporada
                ORDER BY c.temporada DESC, c.nome
            `),

            // 4. KPIs gerais
            pool.query(`
                SELECT
                    (SELECT COUNT(*)::int FROM torcedores) AS total_torcedores,
                    (SELECT ROUND(AVG(EXTRACT(YEAR FROM age(CURRENT_DATE, nascimento))))::int FROM torcedores) AS media_idade,
                    (SELECT COALESCE(SUM(gols_equipe_a + gols_equipe_b), 0)::int FROM jogos) AS total_gols,
                    (SELECT COUNT(*)::int FROM jogos) AS total_jogos
            `),

            // 5. Desempenho por equipe (V/E/D)
            pool.query(`
                SELECT e.nome AS equipe,
                    COUNT(j.id)::int AS jogos,
                    COUNT(*) FILTER (
                        WHERE (j.equipe_a_id = e.id AND j.gols_equipe_a > j.gols_equipe_b)
                           OR (j.equipe_b_id = e.id AND j.gols_equipe_b > j.gols_equipe_a)
                    )::int AS vitorias,
                    COUNT(*) FILTER (
                        WHERE j.gols_equipe_a = j.gols_equipe_b AND j.id IS NOT NULL
                    )::int AS empates,
                    COUNT(*) FILTER (
                        WHERE (j.equipe_a_id = e.id AND j.gols_equipe_a < j.gols_equipe_b)
                           OR (j.equipe_b_id = e.id AND j.gols_equipe_b < j.gols_equipe_a)
                    )::int AS derrotas,
                    COALESCE(SUM(
                        CASE WHEN j.equipe_a_id = e.id THEN j.gols_equipe_a
                             WHEN j.equipe_b_id = e.id THEN j.gols_equipe_b
                             ELSE 0 END
                    ), 0)::int AS gols_pro,
                    COALESCE(SUM(
                        CASE WHEN j.equipe_a_id = e.id THEN j.gols_equipe_b
                             WHEN j.equipe_b_id = e.id THEN j.gols_equipe_a
                             ELSE 0 END
                    ), 0)::int AS gols_contra
                FROM equipes e
                LEFT JOIN jogos j ON e.id = j.equipe_a_id OR e.id = j.equipe_b_id
                GROUP BY e.id, e.nome
                HAVING COUNT(j.id) > 0
                ORDER BY
                    COUNT(*) FILTER (
                        WHERE (j.equipe_a_id = e.id AND j.gols_equipe_a > j.gols_equipe_b)
                           OR (j.equipe_b_id = e.id AND j.gols_equipe_b > j.gols_equipe_a)
                    ) DESC,
                    e.nome
            `),
        ]);

        res.json({
            kpis: kpis.rows[0],
            distribuicao_etaria: etaria.rows[0],
            equipes_por_campeonato: equipesCamp.rows,
            jogos_por_campeonato: jogosCamp.rows,
            desempenho_equipes: desempenho.rows,
        });
    } catch (err) {
        console.error('Erro ao gerar relatórios:', err.message);
        res.status(500).json({ erro: 'Erro ao gerar relatórios' });
    }
};

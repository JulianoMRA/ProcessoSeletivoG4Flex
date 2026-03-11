const pool = require('../config/database');

const DATA_REGEX = /^\d{4}-\d{2}-\d{2}$/;
const HORA_REGEX = /^\d{2}:\d{2}$/;

const queryBase = `
    SELECT j.id, j.data, j.hora,
        j.campeonato_id, c.nome AS campeonato_nome,
        j.equipe_a_id, ea.nome AS equipe_a_nome,
        j.equipe_b_id, eb.nome AS equipe_b_nome,
        j.gols_equipe_a, j.gols_equipe_b,
        CASE
            WHEN j.gols_equipe_a > j.gols_equipe_b THEN 'equipe_a'
            WHEN j.gols_equipe_b > j.gols_equipe_a THEN 'equipe_b'
            ELSE 'empate'
        END AS vencedor
    FROM jogos j
    JOIN campeonatos c ON j.campeonato_id = c.id
    JOIN equipes ea ON j.equipe_a_id = ea.id
    JOIN equipes eb ON j.equipe_b_id = eb.id
`;

async function validarEquipesNoCampeonato(campeonatoId, equipeAId, equipeBId) {
    const result = await pool.query(
        `SELECT equipe_id FROM campeonato_equipes
         WHERE campeonato_id = $1 AND equipe_id IN ($2, $3)`,
        [campeonatoId, equipeAId, equipeBId]
    );
    const idsEncontrados = result.rows.map(r => r.equipe_id);
    const erros = [];
    if (!idsEncontrados.includes(equipeAId)) erros.push('Equipe A não pertence ao campeonato');
    if (!idsEncontrados.includes(equipeBId)) erros.push('Equipe B não pertence ao campeonato');
    return erros;
}

exports.listar = async (req, res) => {
    try {
        const { equipe_id, campeonato_id, page, limit } = req.query;

        if (campeonato_id) {
            const result = await pool.query(
                `${queryBase} WHERE j.campeonato_id = $1 ORDER BY j.data DESC, j.hora DESC`,
                [campeonato_id]
            );
            return res.json(result.rows);
        }

        if (equipe_id) {
            const result = await pool.query(
                `${queryBase} WHERE j.equipe_a_id = $1 OR j.equipe_b_id = $1 ORDER BY j.data DESC, j.hora DESC`,
                [equipe_id]
            );
            return res.json(result.rows);
        }

        if (page && limit) {
            const pagina = Math.max(1, parseInt(page) || 1);
            const limite = Math.min(100, Math.max(1, parseInt(limit) || 20));
            const offset = (pagina - 1) * limite;

            const countResult = await pool.query('SELECT COUNT(*) FROM jogos');
            const total = parseInt(countResult.rows[0].count);

            const result = await pool.query(
                `${queryBase} ORDER BY j.data DESC, j.hora DESC LIMIT $1 OFFSET $2`,
                [limite, offset]
            );

            return res.json({ dados: result.rows, total, pagina, limite });
        }

        const result = await pool.query(`${queryBase} ORDER BY j.data DESC, j.hora DESC`);
        res.json(result.rows);
    } catch (err) {
        console.error('Erro ao listar jogos:', err.message);
        res.status(500).json({ erro: 'Erro ao listar jogos' });
    }
};

exports.buscarPorId = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(`${queryBase} WHERE j.id = $1`, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Jogo não encontrado' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        console.error('Erro ao buscar jogo:', err.message);
        res.status(500).json({ erro: 'Erro ao buscar jogo' });
    }
};

exports.criar = async (req, res) => {
    try {
        const { data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b } = req.body;

        if (!campeonato_id) {
            return res.status(400).json({ erro: 'Campeonato é obrigatório' });
        }
        if (!data || !DATA_REGEX.test(data)) {
            return res.status(400).json({ erro: 'Data é obrigatória (formato: YYYY-MM-DD)' });
        }
        if (!hora || !HORA_REGEX.test(hora)) {
            return res.status(400).json({ erro: 'Hora é obrigatória (formato: HH:MM)' });
        }
        if (!equipe_a_id) {
            return res.status(400).json({ erro: 'Equipe A é obrigatória' });
        }
        if (!equipe_b_id) {
            return res.status(400).json({ erro: 'Equipe B é obrigatória' });
        }
        if (equipe_a_id === equipe_b_id) {
            return res.status(400).json({ erro: 'Equipe A e Equipe B devem ser diferentes' });
        }

        const golsA = parseInt(gols_equipe_a) || 0;
        const golsB = parseInt(gols_equipe_b) || 0;

        if (golsA < 0 || golsB < 0) {
            return res.status(400).json({ erro: 'Gols não podem ser negativos' });
        }

        const errosEquipe = await validarEquipesNoCampeonato(campeonato_id, equipe_a_id, equipe_b_id);
        if (errosEquipe.length > 0) {
            return res.status(400).json({ erro: errosEquipe.join('; ') });
        }

        const result = await pool.query(
            `INSERT INTO jogos (data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
            [data, hora, campeonato_id, equipe_a_id, equipe_b_id, golsA, golsB]
        );

        const jogo = await pool.query(`${queryBase} WHERE j.id = $1`, [result.rows[0].id]);
        res.status(201).json(jogo.rows[0]);
    } catch (err) {
        if (err.code === '23503') {
            return res.status(400).json({ erro: 'Campeonato ou equipe informada não existe' });
        }
        console.error('Erro ao criar jogo:', err.message);
        res.status(500).json({ erro: 'Erro ao criar jogo' });
    }
};

exports.atualizar = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, hora, campeonato_id, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b } = req.body;

        if (!campeonato_id) {
            return res.status(400).json({ erro: 'Campeonato é obrigatório' });
        }
        if (!data || !DATA_REGEX.test(data)) {
            return res.status(400).json({ erro: 'Data é obrigatória (formato: YYYY-MM-DD)' });
        }
        if (!hora || !HORA_REGEX.test(hora)) {
            return res.status(400).json({ erro: 'Hora é obrigatória (formato: HH:MM)' });
        }
        if (!equipe_a_id) {
            return res.status(400).json({ erro: 'Equipe A é obrigatória' });
        }
        if (!equipe_b_id) {
            return res.status(400).json({ erro: 'Equipe B é obrigatória' });
        }
        if (equipe_a_id === equipe_b_id) {
            return res.status(400).json({ erro: 'Equipe A e Equipe B devem ser diferentes' });
        }

        const golsA = parseInt(gols_equipe_a) || 0;
        const golsB = parseInt(gols_equipe_b) || 0;

        if (golsA < 0 || golsB < 0) {
            return res.status(400).json({ erro: 'Gols não podem ser negativos' });
        }

        const errosEquipe = await validarEquipesNoCampeonato(campeonato_id, equipe_a_id, equipe_b_id);
        if (errosEquipe.length > 0) {
            return res.status(400).json({ erro: errosEquipe.join('; ') });
        }

        const result = await pool.query(
            `UPDATE jogos SET data = $1, hora = $2, campeonato_id = $3, equipe_a_id = $4, equipe_b_id = $5,
             gols_equipe_a = $6, gols_equipe_b = $7 WHERE id = $8 RETURNING id`,
            [data, hora, campeonato_id, equipe_a_id, equipe_b_id, golsA, golsB, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Jogo não encontrado' });
        }

        const jogo = await pool.query(`${queryBase} WHERE j.id = $1`, [id]);
        res.json(jogo.rows[0]);
    } catch (err) {
        if (err.code === '23503') {
            return res.status(400).json({ erro: 'Campeonato ou equipe informada não existe' });
        }
        console.error('Erro ao atualizar jogo:', err.message);
        res.status(500).json({ erro: 'Erro ao atualizar jogo' });
    }
};

exports.excluir = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM jogos WHERE id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Jogo não encontrado' });
        }

        res.json({ mensagem: 'Jogo excluído com sucesso', id });
    } catch (err) {
        console.error('Erro ao excluir jogo:', err.message);
        res.status(500).json({ erro: 'Erro ao excluir jogo' });
    }
};

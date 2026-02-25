const pool = require('../config/database');

const queryBase = `
    SELECT j.id, j.data, j.hora,
        j.equipe_a_id, ea.nome AS equipe_a_nome,
        j.equipe_b_id, eb.nome AS equipe_b_nome,
        j.gols_equipe_a, j.gols_equipe_b,
        CASE
            WHEN j.gols_equipe_a > j.gols_equipe_b THEN 'equipe_a'
            WHEN j.gols_equipe_b > j.gols_equipe_a THEN 'equipe_b'
            ELSE 'empate'
        END AS vencedor
    FROM jogos j
    JOIN equipes ea ON j.equipe_a_id = ea.id
    JOIN equipes eb ON j.equipe_b_id = eb.id
`;

exports.listar = async (req, res) => {
    try {
        const { equipe_id, page, limit } = req.query;

        if (equipe_id) {
            const result = await pool.query(
                `${queryBase} WHERE j.equipe_a_id = $1 OR j.equipe_b_id = $1 ORDER BY j.data DESC, j.hora DESC`,
                [equipe_id]
            );
            return res.json(result.rows);
        }

        if (page && limit) {
            const pagina = Math.max(1, parseInt(page));
            const limite = Math.min(100, Math.max(1, parseInt(limit)));
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
        res.status(500).json({ erro: 'Erro ao buscar jogo' });
    }
};

exports.criar = async (req, res) => {
    try {
        const { data, hora, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b } = req.body;

        if (!data) {
            return res.status(400).json({ erro: 'Data é obrigatória' });
        }
        if (!hora) {
            return res.status(400).json({ erro: 'Hora é obrigatória' });
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

        const result = await pool.query(
            `INSERT INTO jogos (data, hora, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b)
             VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
            [data, hora, equipe_a_id, equipe_b_id, gols_equipe_a || 0, gols_equipe_b || 0]
        );

        const jogo = await pool.query(`${queryBase} WHERE j.id = $1`, [result.rows[0].id]);
        res.status(201).json(jogo.rows[0]);
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao criar jogo' });
    }
};

exports.atualizar = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, hora, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b } = req.body;

        if (!data) {
            return res.status(400).json({ erro: 'Data é obrigatória' });
        }
        if (!hora) {
            return res.status(400).json({ erro: 'Hora é obrigatória' });
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

        const result = await pool.query(
            `UPDATE jogos SET data = $1, hora = $2, equipe_a_id = $3, equipe_b_id = $4,
             gols_equipe_a = $5, gols_equipe_b = $6 WHERE id = $7 RETURNING id`,
            [data, hora, equipe_a_id, equipe_b_id, gols_equipe_a, gols_equipe_b, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Jogo não encontrado' });
        }

        const jogo = await pool.query(`${queryBase} WHERE j.id = $1`, [id]);
        res.json(jogo.rows[0]);
    } catch (err) {
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

        res.json({ mensagem: 'Jogo excluído com sucesso' });
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao excluir jogo' });
    }
};

const pool = require('../config/database');

exports.listar = async (req, res) => {
    try {
        const { page, limit } = req.query;

        if (page && limit) {
            const pagina = Math.max(1, parseInt(page));
            const limite = Math.min(100, Math.max(1, parseInt(limit)));
            const offset = (pagina - 1) * limite;

            const countResult = await pool.query('SELECT COUNT(*) FROM equipes');
            const total = parseInt(countResult.rows[0].count);

            const result = await pool.query(
                'SELECT * FROM equipes ORDER BY nome LIMIT $1 OFFSET $2',
                [limite, offset]
            );

            return res.json({ dados: result.rows, total, pagina, limite });
        }

        const result = await pool.query(
            'SELECT * FROM equipes ORDER BY nome'
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao listar equipes' });
    }
};

exports.buscarPorId = async (req, res) => {
    try {
        const { id } = req.params;

        const equipe = await pool.query(
            'SELECT * FROM equipes WHERE id = $1', [id]
        );

        if (equipe.rows.length === 0) {
            return res.status(404).json({ erro: 'Equipe não encontrada' });
        }

        const planos = await pool.query(
            `SELECT p.* FROM planos p
             JOIN equipe_planos ep ON p.id = ep.plano_id
             WHERE ep.equipe_id = $1
             ORDER BY p.valor`, [id]
        );

        res.json({ ...equipe.rows[0], planos: planos.rows });
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao buscar equipe' });
    }
};

exports.criar = async (req, res) => {
    try {
        const { nome, serie, plano_ids } = req.body;

        if (!nome || !nome.trim()) {
            return res.status(400).json({ erro: 'Nome é obrigatório' });
        }
        if (!serie || !serie.trim()) {
            return res.status(400).json({ erro: 'Série é obrigatória' });
        }
        if (!plano_ids || plano_ids.length === 0) {
            return res.status(400).json({ erro: 'Selecione pelo menos um plano' });
        }

        const equipe = await pool.query(
            'INSERT INTO equipes (nome, serie) VALUES ($1, $2) RETURNING *',
            [nome, serie]
        );

        const equipeId = equipe.rows[0].id;

        if (plano_ids && plano_ids.length > 0) {
            for (const planoId of plano_ids) {
                await pool.query(
                    'INSERT INTO equipe_planos (equipe_id, plano_id) VALUES ($1, $2)',
                    [equipeId, planoId]
                );
            }
        }

        const planos = await pool.query(
            `SELECT p.* FROM planos p
             JOIN equipe_planos ep ON p.id = ep.plano_id
             WHERE ep.equipe_id = $1
             ORDER BY p.valor`, [equipeId]
        );

        res.status(201).json({ ...equipe.rows[0], planos: planos.rows });
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao criar equipe' });
    }
};

exports.atualizar = async (req, res) => {
    try {
        const { id } = req.params;
        const { nome, serie, plano_ids } = req.body;

        if (!nome || !nome.trim()) {
            return res.status(400).json({ erro: 'Nome é obrigatório' });
        }
        if (!serie || !serie.trim()) {
            return res.status(400).json({ erro: 'Série é obrigatória' });
        }

        await pool.query(
            'UPDATE equipes SET nome = $1, serie = $2 WHERE id = $3',
            [nome, serie, id]
        );

        if (plano_ids) {
            await pool.query('DELETE FROM equipe_planos WHERE equipe_id = $1', [id]);

            for (const planoId of plano_ids) {
                await pool.query(
                    'INSERT INTO equipe_planos (equipe_id, plano_id) VALUES ($1, $2)',
                    [id, planoId]
                );
            }
        }

        const resultado = await pool.query(
            'SELECT * FROM equipes WHERE id = $1', [id]
        );
        const planos = await pool.query(
            `SELECT p.* FROM planos p
             JOIN equipe_planos ep ON p.id = ep.plano_id
             WHERE ep.equipe_id = $1
             ORDER BY p.valor`, [id]
        );

        res.json({ ...resultado.rows[0], planos: planos.rows });
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao atualizar equipe' });
    }
};

exports.excluir = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            'DELETE FROM equipes WHERE id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Equipe não encontrada' });
        }

        res.json({ mensagem: 'Equipe excluída com sucesso' });
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao excluir equipe' });
    }
};

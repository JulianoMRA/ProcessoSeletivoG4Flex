const pool = require('../config/database');

exports.listar = async (req, res) => {
    try {
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
            'SELECT * FROM planos WHERE equipe_id = $1 ORDER BY valor', [id]
        );

        res.json({ ...equipe.rows[0], planos: planos.rows });
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao buscar equipe' });
    }
};

exports.criar = async (req, res) => {
    try {
        const { nome, serie, planos } = req.body;

        const equipe = await pool.query(
            'INSERT INTO equipes (nome, serie) VALUES ($1, $2) RETURNING *',
            [nome, serie]
        );

        const equipeId = equipe.rows[0].id;

        if (planos && planos.length > 0) {
            for (const plano of planos) {
                await pool.query(
                    'INSERT INTO planos (equipe_id, nome, valor) VALUES ($1, $2, $3)',
                    [equipeId, plano.nome, plano.valor]
                );
            }
        }

        const resultado = await pool.query(
            'SELECT * FROM equipes WHERE id = $1', [equipeId]
        );
        const planosResult = await pool.query(
            'SELECT * FROM planos WHERE equipe_id = $1 ORDER BY valor', [equipeId]
        );

        res.status(201).json({ ...resultado.rows[0], planos: planosResult.rows });
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao criar equipe' });
    }
};

exports.atualizar = async (req, res) => {
    try {
        const { id } = req.params;
        const { nome, serie, planos } = req.body;

        await pool.query(
            'UPDATE equipes SET nome = $1, serie = $2 WHERE id = $3',
            [nome, serie, id]
        );

        if (planos) {
            await pool.query('DELETE FROM planos WHERE equipe_id = $1', [id]);

            for (const plano of planos) {
                await pool.query(
                    'INSERT INTO planos (equipe_id, nome, valor) VALUES ($1, $2, $3)',
                    [id, plano.nome, plano.valor]
                );
            }
        }

        const resultado = await pool.query(
            'SELECT * FROM equipes WHERE id = $1', [id]
        );
        const planosResult = await pool.query(
            'SELECT * FROM planos WHERE equipe_id = $1 ORDER BY valor', [id]
        );

        res.json({ ...resultado.rows[0], planos: planosResult.rows });
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

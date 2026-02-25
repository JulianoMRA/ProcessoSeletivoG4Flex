const pool = require('../config/database');

exports.listar = async (req, res) => {
    try {
        const { equipe_id, page, limit } = req.query;

        if (equipe_id) {
            const result = await pool.query(
                `SELECT p.* FROM planos p
                 JOIN equipe_planos ep ON p.id = ep.plano_id
                 WHERE ep.equipe_id = $1
                 ORDER BY p.valor`,
                [equipe_id]
            );
            return res.json(result.rows);
        }

        if (page && limit) {
            const pagina = Math.max(1, parseInt(page));
            const limite = Math.min(100, Math.max(1, parseInt(limit)));
            const offset = (pagina - 1) * limite;

            const countResult = await pool.query('SELECT COUNT(*) FROM planos');
            const total = parseInt(countResult.rows[0].count);

            const result = await pool.query(
                'SELECT * FROM planos ORDER BY nome, valor LIMIT $1 OFFSET $2',
                [limite, offset]
            );

            return res.json({ dados: result.rows, total, pagina, limite });
        }

        const result = await pool.query('SELECT * FROM planos ORDER BY nome, valor');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao listar planos' });
    }
};

exports.buscarPorId = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            'SELECT * FROM planos WHERE id = $1', [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Plano não encontrado' });
        }

        const equipes = await pool.query(
            `SELECT e.id, e.nome, e.serie FROM equipes e
             JOIN equipe_planos ep ON e.id = ep.equipe_id
             WHERE ep.plano_id = $1
             ORDER BY e.nome`, [id]
        );

        res.json({ ...result.rows[0], equipes: equipes.rows });
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao buscar plano' });
    }
};

exports.criar = async (req, res) => {
    try {
        const { nome, valor } = req.body;

        if (!nome || !nome.trim()) {
            return res.status(400).json({ erro: 'Nome é obrigatório' });
        }
        if (valor === undefined || valor === null || isNaN(valor) || valor < 0) {
            return res.status(400).json({ erro: 'Valor inválido' });
        }

        const result = await pool.query(
            'INSERT INTO planos (nome, valor) VALUES ($1, $2) RETURNING *',
            [nome, valor]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao criar plano' });
    }
};

exports.atualizar = async (req, res) => {
    try {
        const { id } = req.params;
        const { nome, valor } = req.body;

        if (!nome || !nome.trim()) {
            return res.status(400).json({ erro: 'Nome é obrigatório' });
        }
        if (valor === undefined || valor === null || isNaN(valor) || valor < 0) {
            return res.status(400).json({ erro: 'Valor inválido' });
        }

        const result = await pool.query(
            'UPDATE planos SET nome = $1, valor = $2 WHERE id = $3 RETURNING *',
            [nome, valor, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Plano não encontrado' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao atualizar plano' });
    }
};

exports.excluir = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            'DELETE FROM planos WHERE id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Plano não encontrado' });
        }

        res.json({ mensagem: 'Plano excluído com sucesso' });
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao excluir plano' });
    }
};

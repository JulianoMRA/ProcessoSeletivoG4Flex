const pool = require('../config/database');

exports.listar = async (req, res) => {
    try {
        const { equipe_id } = req.query;

        let query = `
      SELECT p.*, e.nome AS equipe_nome, e.serie AS equipe_serie
      FROM planos p
      JOIN equipes e ON p.equipe_id = e.id
    `;
        const params = [];

        if (equipe_id) {
            query += ' WHERE p.equipe_id = $1';
            params.push(equipe_id);
        }

        query += ' ORDER BY e.nome, p.valor';

        const result = await pool.query(query, params);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao listar planos' });
    }
};

exports.buscarPorId = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(`
      SELECT p.*, e.nome AS equipe_nome, e.serie AS equipe_serie
      FROM planos p
      JOIN equipes e ON p.equipe_id = e.id
      WHERE p.id = $1
    `, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Plano não encontrado' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao buscar plano' });
    }
};

exports.criar = async (req, res) => {
    try {
        const { equipe_id, nome, valor } = req.body;

        const result = await pool.query(
            'INSERT INTO planos (equipe_id, nome, valor) VALUES ($1, $2, $3) RETURNING *',
            [equipe_id, nome, valor]
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

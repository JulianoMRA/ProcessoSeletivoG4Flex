const pool = require('../config/database');

const MAX_NOME = 200;

exports.listar = async (req, res) => {
    try {
        const { page, limit } = req.query;

        if (page && limit) {
            const pagina = Math.max(1, parseInt(page) || 1);
            const limite = Math.min(100, Math.max(1, parseInt(limit) || 20));
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
        console.error('Erro ao listar equipes:', err.message);
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

        const campeonatos = await pool.query(
            `SELECT c.* FROM campeonatos c
             JOIN campeonato_equipes ce ON c.id = ce.campeonato_id
             WHERE ce.equipe_id = $1
             ORDER BY c.temporada DESC, c.nome`, [id]
        );

        res.json({ ...equipe.rows[0], planos: planos.rows, campeonatos: campeonatos.rows });
    } catch (err) {
        console.error('Erro ao buscar equipe:', err.message);
        res.status(500).json({ erro: 'Erro ao buscar equipe' });
    }
};

exports.criar = async (req, res) => {
    const { nome, plano_ids } = req.body;

    const nomeTrimmed = (nome || '').trim();

    if (!nomeTrimmed) {
        return res.status(400).json({ erro: 'Nome é obrigatório' });
    }
    if (nomeTrimmed.length > MAX_NOME) {
        return res.status(400).json({ erro: `Nome não pode exceder ${MAX_NOME} caracteres` });
    }
    if (!Array.isArray(plano_ids) || plano_ids.length === 0) {
        return res.status(400).json({ erro: 'Selecione pelo menos um plano' });
    }

    const campeonato_ids = req.body.campeonato_ids;

    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const equipe = await client.query(
            'INSERT INTO equipes (nome) VALUES ($1) RETURNING *',
            [nomeTrimmed]
        );

        const equipeId = equipe.rows[0].id;

        for (const planoId of plano_ids) {
            await client.query(
                'INSERT INTO equipe_planos (equipe_id, plano_id) VALUES ($1, $2)',
                [equipeId, planoId]
            );
        }

        if (Array.isArray(campeonato_ids) && campeonato_ids.length > 0) {
            for (const campId of campeonato_ids) {
                await client.query(
                    'INSERT INTO campeonato_equipes (campeonato_id, equipe_id) VALUES ($1, $2)',
                    [campId, equipeId]
                );
            }
        }

        await client.query('COMMIT');

        const planos = await pool.query(
            `SELECT p.* FROM planos p
             JOIN equipe_planos ep ON p.id = ep.plano_id
             WHERE ep.equipe_id = $1
             ORDER BY p.valor`, [equipeId]
        );

        const campeonatos = await pool.query(
            `SELECT c.* FROM campeonatos c
             JOIN campeonato_equipes ce ON c.id = ce.campeonato_id
             WHERE ce.equipe_id = $1
             ORDER BY c.temporada DESC, c.nome`, [equipeId]
        );

        res.status(201).json({ ...equipe.rows[0], planos: planos.rows, campeonatos: campeonatos.rows });
    } catch (err) {
        await client.query('ROLLBACK');
        if (err.code === '23503') {
            return res.status(400).json({ erro: 'Plano ou campeonato informado não existe' });
        }
        console.error('Erro ao criar equipe:', err.message);
        res.status(500).json({ erro: 'Erro ao criar equipe' });
    } finally {
        client.release();
    }
};

exports.atualizar = async (req, res) => {
    const { id } = req.params;
    const { nome, plano_ids, campeonato_ids } = req.body;

    const nomeTrimmed = (nome || '').trim();

    if (!nomeTrimmed) {
        return res.status(400).json({ erro: 'Nome é obrigatório' });
    }
    if (nomeTrimmed.length > MAX_NOME) {
        return res.status(400).json({ erro: `Nome não pode exceder ${MAX_NOME} caracteres` });
    }

    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const resultado = await client.query(
            'UPDATE equipes SET nome = $1 WHERE id = $2 RETURNING *',
            [nomeTrimmed, id]
        );

        if (resultado.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ erro: 'Equipe não encontrada' });
        }

        if (Array.isArray(plano_ids)) {
            await client.query('DELETE FROM equipe_planos WHERE equipe_id = $1', [id]);

            for (const planoId of plano_ids) {
                await client.query(
                    'INSERT INTO equipe_planos (equipe_id, plano_id) VALUES ($1, $2)',
                    [id, planoId]
                );
            }
        }

        if (Array.isArray(campeonato_ids)) {
            await client.query('DELETE FROM campeonato_equipes WHERE equipe_id = $1', [id]);

            for (const campId of campeonato_ids) {
                await client.query(
                    'INSERT INTO campeonato_equipes (campeonato_id, equipe_id) VALUES ($1, $2)',
                    [campId, id]
                );
            }
        }

        await client.query('COMMIT');

        const planos = await pool.query(
            `SELECT p.* FROM planos p
             JOIN equipe_planos ep ON p.id = ep.plano_id
             WHERE ep.equipe_id = $1
             ORDER BY p.valor`, [id]
        );

        const campeonatos = await pool.query(
            `SELECT c.* FROM campeonatos c
             JOIN campeonato_equipes ce ON c.id = ce.campeonato_id
             WHERE ce.equipe_id = $1
             ORDER BY c.temporada DESC, c.nome`, [id]
        );

        res.json({ ...resultado.rows[0], planos: planos.rows, campeonatos: campeonatos.rows });
    } catch (err) {
        await client.query('ROLLBACK');
        if (err.code === '23503') {
            return res.status(400).json({ erro: 'Plano ou campeonato informado não existe' });
        }
        console.error('Erro ao atualizar equipe:', err.message);
        res.status(500).json({ erro: 'Erro ao atualizar equipe' });
    } finally {
        client.release();
    }
};

exports.excluir = async (req, res) => {
    try {
        const { id } = req.params;

        const torcedores = await pool.query(
            'SELECT COUNT(*) FROM torcedores WHERE equipe_id = $1', [id]
        );
        if (parseInt(torcedores.rows[0].count) > 0) {
            return res.status(409).json({
                erro: 'Não é possível excluir: equipe possui torcedores vinculados'
            });
        }

        const jogos = await pool.query(
            'SELECT COUNT(*) FROM jogos WHERE equipe_a_id = $1 OR equipe_b_id = $1', [id]
        );
        if (parseInt(jogos.rows[0].count) > 0) {
            return res.status(409).json({
                erro: 'Não é possível excluir: equipe possui jogos vinculados'
            });
        }

        const result = await pool.query(
            'DELETE FROM equipes WHERE id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Equipe não encontrada' });
        }

        res.json({ mensagem: 'Equipe excluída com sucesso', id });
    } catch (err) {
        console.error('Erro ao excluir equipe:', err.message);
        res.status(500).json({ erro: 'Erro ao excluir equipe' });
    }
};

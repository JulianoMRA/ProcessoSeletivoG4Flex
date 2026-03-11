const pool = require('../config/database');

const MAX_NOME = 200;

exports.listar = async (req, res) => {
    try {
        const { page, limit } = req.query;

        if (page && limit) {
            const pagina = Math.max(1, parseInt(page) || 1);
            const limite = Math.min(100, Math.max(1, parseInt(limit) || 20));
            const offset = (pagina - 1) * limite;

            const countResult = await pool.query('SELECT COUNT(*) FROM campeonatos');
            const total = parseInt(countResult.rows[0].count);

            const result = await pool.query(
                'SELECT * FROM campeonatos ORDER BY temporada DESC, nome LIMIT $1 OFFSET $2',
                [limite, offset]
            );

            return res.json({ dados: result.rows, total, pagina, limite });
        }

        const result = await pool.query(
            'SELECT * FROM campeonatos ORDER BY temporada DESC, nome'
        );
        res.json(result.rows);
    } catch (err) {
        console.error('Erro ao listar campeonatos:', err.message);
        res.status(500).json({ erro: 'Erro ao listar campeonatos' });
    }
};

exports.buscarPorId = async (req, res) => {
    try {
        const { id } = req.params;

        const campeonato = await pool.query(
            'SELECT * FROM campeonatos WHERE id = $1', [id]
        );

        if (campeonato.rows.length === 0) {
            return res.status(404).json({ erro: 'Campeonato não encontrado' });
        }

        const equipes = await pool.query(
            `SELECT e.* FROM equipes e
             JOIN campeonato_equipes ce ON e.id = ce.equipe_id
             WHERE ce.campeonato_id = $1
             ORDER BY e.nome`, [id]
        );

        res.json({ ...campeonato.rows[0], equipes: equipes.rows });
    } catch (err) {
        console.error('Erro ao buscar campeonato:', err.message);
        res.status(500).json({ erro: 'Erro ao buscar campeonato' });
    }
};

exports.criar = async (req, res) => {
    const { nome, temporada, equipe_ids } = req.body;

    const nomeTrimmed = (nome || '').trim();
    const temporadaTrimmed = (temporada || '').trim();

    if (!nomeTrimmed) {
        return res.status(400).json({ erro: 'Nome é obrigatório' });
    }
    if (nomeTrimmed.length > MAX_NOME) {
        return res.status(400).json({ erro: `Nome não pode exceder ${MAX_NOME} caracteres` });
    }
    if (!temporadaTrimmed) {
        return res.status(400).json({ erro: 'Temporada é obrigatória' });
    }
    if (!Array.isArray(equipe_ids) || equipe_ids.length < 2) {
        return res.status(400).json({ erro: 'Selecione pelo menos duas equipes' });
    }

    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const campeonato = await client.query(
            'INSERT INTO campeonatos (nome, temporada) VALUES ($1, $2) RETURNING *',
            [nomeTrimmed, temporadaTrimmed]
        );

        const campeonatoId = campeonato.rows[0].id;

        for (const equipeId of equipe_ids) {
            await client.query(
                'INSERT INTO campeonato_equipes (campeonato_id, equipe_id) VALUES ($1, $2)',
                [campeonatoId, equipeId]
            );
        }

        await client.query('COMMIT');

        const equipes = await pool.query(
            `SELECT e.* FROM equipes e
             JOIN campeonato_equipes ce ON e.id = ce.equipe_id
             WHERE ce.campeonato_id = $1
             ORDER BY e.nome`, [campeonatoId]
        );

        res.status(201).json({ ...campeonato.rows[0], equipes: equipes.rows });
    } catch (err) {
        await client.query('ROLLBACK');
        if (err.code === '23503') {
            return res.status(400).json({ erro: 'Equipe informada não existe' });
        }
        console.error('Erro ao criar campeonato:', err.message);
        res.status(500).json({ erro: 'Erro ao criar campeonato' });
    } finally {
        client.release();
    }
};

exports.atualizar = async (req, res) => {
    const { id } = req.params;
    const { nome, temporada, equipe_ids } = req.body;

    const nomeTrimmed = (nome || '').trim();
    const temporadaTrimmed = (temporada || '').trim();

    if (!nomeTrimmed) {
        return res.status(400).json({ erro: 'Nome é obrigatório' });
    }
    if (nomeTrimmed.length > MAX_NOME) {
        return res.status(400).json({ erro: `Nome não pode exceder ${MAX_NOME} caracteres` });
    }
    if (!temporadaTrimmed) {
        return res.status(400).json({ erro: 'Temporada é obrigatória' });
    }

    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const resultado = await client.query(
            'UPDATE campeonatos SET nome = $1, temporada = $2 WHERE id = $3 RETURNING *',
            [nomeTrimmed, temporadaTrimmed, id]
        );

        if (resultado.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ erro: 'Campeonato não encontrado' });
        }

        if (Array.isArray(equipe_ids)) {
            if (equipe_ids.length < 2) {
                await client.query('ROLLBACK');
                return res.status(400).json({ erro: 'Selecione pelo menos duas equipes' });
            }

            await client.query('DELETE FROM campeonato_equipes WHERE campeonato_id = $1', [id]);

            for (const equipeId of equipe_ids) {
                await client.query(
                    'INSERT INTO campeonato_equipes (campeonato_id, equipe_id) VALUES ($1, $2)',
                    [id, equipeId]
                );
            }
        }

        await client.query('COMMIT');

        const equipes = await pool.query(
            `SELECT e.* FROM equipes e
             JOIN campeonato_equipes ce ON e.id = ce.equipe_id
             WHERE ce.campeonato_id = $1
             ORDER BY e.nome`, [id]
        );

        res.json({ ...resultado.rows[0], equipes: equipes.rows });
    } catch (err) {
        await client.query('ROLLBACK');
        if (err.code === '23503') {
            return res.status(400).json({ erro: 'Equipe informada não existe' });
        }
        console.error('Erro ao atualizar campeonato:', err.message);
        res.status(500).json({ erro: 'Erro ao atualizar campeonato' });
    } finally {
        client.release();
    }
};

exports.excluir = async (req, res) => {
    try {
        const { id } = req.params;

        const jogos = await pool.query(
            'SELECT COUNT(*) FROM jogos WHERE campeonato_id = $1', [id]
        );
        if (parseInt(jogos.rows[0].count) > 0) {
            return res.status(409).json({
                erro: 'Não é possível excluir: campeonato possui jogos vinculados'
            });
        }

        const result = await pool.query(
            'DELETE FROM campeonatos WHERE id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Campeonato não encontrado' });
        }

        res.json({ mensagem: 'Campeonato excluído com sucesso', id });
    } catch (err) {
        console.error('Erro ao excluir campeonato:', err.message);
        res.status(500).json({ erro: 'Erro ao excluir campeonato' });
    }
};

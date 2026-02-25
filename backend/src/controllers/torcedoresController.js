const pool = require('../config/database');

exports.listar = async (req, res) => {
    try {
        const { page, limit } = req.query;

        const baseQuery = `
      SELECT t.*, 
             e.nome AS equipe_nome, e.serie AS equipe_serie,
             p.nome AS plano_nome, p.valor AS plano_valor
      FROM torcedores t
      JOIN equipes e ON t.equipe_id = e.id
      JOIN planos p ON t.plano_id = p.id`;

        if (page && limit) {
            const pagina = Math.max(1, parseInt(page) || 1);
            const limite = Math.min(100, Math.max(1, parseInt(limit) || 20));
            const offset = (pagina - 1) * limite;

            const countResult = await pool.query('SELECT COUNT(*) FROM torcedores');
            const total = parseInt(countResult.rows[0].count);

            const result = await pool.query(
                `${baseQuery} ORDER BY t.nome LIMIT $1 OFFSET $2`,
                [limite, offset]
            );

            return res.json({ dados: result.rows, total, pagina, limite });
        }

        const result = await pool.query(`${baseQuery} ORDER BY t.nome`);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao listar torcedores' });
    }
};

exports.buscarPorId = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(`
      SELECT t.*, 
             e.nome AS equipe_nome, e.serie AS equipe_serie,
             p.nome AS plano_nome, p.valor AS plano_valor
      FROM torcedores t
      JOIN equipes e ON t.equipe_id = e.id
      JOIN planos p ON t.plano_id = p.id
      WHERE t.id = $1
    `, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ erro: 'Torcedor não encontrado' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao buscar torcedor' });
    }
};

exports.criar = async (req, res) => {
    const client = await pool.connect();
    try {
        const { nome, cpf, nascimento, equipe_id, plano_id } = req.body;

        const nomeTrimmed = (nome || '').trim();
        const cpfLimpo = (cpf || '').replace(/\D/g, '');

        if (!nomeTrimmed) {
            return res.status(400).json({ erro: 'Nome é obrigatório' });
        }
        if (!cpfLimpo || cpfLimpo.length !== 11) {
            return res.status(400).json({ erro: 'CPF deve conter 11 dígitos' });
        }
        if (!nascimento) {
            return res.status(400).json({ erro: 'Data de nascimento é obrigatória' });
        }
        if (!equipe_id) {
            return res.status(400).json({ erro: 'Equipe é obrigatória' });
        }
        if (!plano_id) {
            return res.status(400).json({ erro: 'Plano é obrigatório' });
        }

        await client.query('BEGIN');

        const result = await client.query(
            'INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [nomeTrimmed, cpfLimpo, nascimento, equipe_id, plano_id]
        );

        await client.query(
            'UPDATE equipes SET qtd_socios = qtd_socios + 1 WHERE id = $1',
            [equipe_id]
        );

        await client.query('COMMIT');

        res.status(201).json(result.rows[0]);
    } catch (err) {
        await client.query('ROLLBACK');
        if (err.code === '23505') {
            return res.status(409).json({ erro: 'CPF já cadastrado' });
        }
        if (err.code === '23503') {
            return res.status(400).json({ erro: 'Equipe ou plano informado não existe' });
        }
        res.status(500).json({ erro: 'Erro ao criar torcedor' });
    } finally {
        client.release();
    }
};

exports.atualizar = async (req, res) => {
    const client = await pool.connect();
    try {
        const { id } = req.params;
        const { nome, cpf, nascimento, equipe_id, plano_id } = req.body;

        const nomeTrimmed = (nome || '').trim();
        const cpfLimpo = (cpf || '').replace(/\D/g, '');

        if (!nomeTrimmed) {
            return res.status(400).json({ erro: 'Nome é obrigatório' });
        }
        if (!cpfLimpo || cpfLimpo.length !== 11) {
            return res.status(400).json({ erro: 'CPF deve conter 11 dígitos' });
        }
        if (!nascimento) {
            return res.status(400).json({ erro: 'Data de nascimento é obrigatória' });
        }
        if (!equipe_id) {
            return res.status(400).json({ erro: 'Equipe é obrigatória' });
        }
        if (!plano_id) {
            return res.status(400).json({ erro: 'Plano é obrigatório' });
        }

        await client.query('BEGIN');

        const anterior = await client.query(
            'SELECT equipe_id FROM torcedores WHERE id = $1', [id]
        );

        if (anterior.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ erro: 'Torcedor não encontrado' });
        }

        const equipeAnteriorId = anterior.rows[0].equipe_id;

        const result = await client.query(
            'UPDATE torcedores SET nome = $1, cpf = $2, nascimento = $3, equipe_id = $4, plano_id = $5 WHERE id = $6 RETURNING *',
            [nomeTrimmed, cpfLimpo, nascimento, equipe_id, plano_id, id]
        );

        if (equipeAnteriorId !== equipe_id) {
            await client.query(
                'UPDATE equipes SET qtd_socios = qtd_socios - 1 WHERE id = $1',
                [equipeAnteriorId]
            );
            await client.query(
                'UPDATE equipes SET qtd_socios = qtd_socios + 1 WHERE id = $1',
                [equipe_id]
            );
        }

        await client.query('COMMIT');

        res.json(result.rows[0]);
    } catch (err) {
        await client.query('ROLLBACK');
        if (err.code === '23505') {
            return res.status(409).json({ erro: 'CPF já cadastrado' });
        }
        if (err.code === '23503') {
            return res.status(400).json({ erro: 'Equipe ou plano informado não existe' });
        }
        res.status(500).json({ erro: 'Erro ao atualizar torcedor' });
    } finally {
        client.release();
    }
};

exports.excluir = async (req, res) => {
    const client = await pool.connect();
    try {
        const { id } = req.params;

        const torcedor = await client.query(
            'SELECT equipe_id FROM torcedores WHERE id = $1', [id]
        );

        if (torcedor.rows.length === 0) {
            return res.status(404).json({ erro: 'Torcedor não encontrado' });
        }

        await client.query('BEGIN');

        await client.query('DELETE FROM torcedores WHERE id = $1', [id]);

        await client.query(
            'UPDATE equipes SET qtd_socios = qtd_socios - 1 WHERE id = $1',
            [torcedor.rows[0].equipe_id]
        );

        await client.query('COMMIT');

        res.json({ mensagem: 'Torcedor excluído com sucesso' });
    } catch (err) {
        await client.query('ROLLBACK');
        res.status(500).json({ erro: 'Erro ao excluir torcedor' });
    } finally {
        client.release();
    }
};

exports.verificarCpf = async (req, res) => {
    try {
        const { cpf, ignorar_id } = req.query;

        const cpfLimpo = (cpf || '').replace(/\D/g, '');

        let query = 'SELECT id FROM torcedores WHERE cpf = $1';
        const params = [cpfLimpo];

        if (ignorar_id) {
            query += ' AND id != $2';
            params.push(ignorar_id);
        }

        const result = await pool.query(query, params);
        res.json({ existe: result.rows.length > 0 });
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao verificar CPF' });
    }
};

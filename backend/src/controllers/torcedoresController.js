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
            const pagina = Math.max(1, parseInt(page));
            const limite = Math.min(100, Math.max(1, parseInt(limit)));
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
    try {
        const { nome, cpf, nascimento, equipe_id, plano_id } = req.body;

        if (!nome || !nome.trim()) {
            return res.status(400).json({ erro: 'Nome é obrigatório' });
        }
        if (!cpf || !cpf.trim()) {
            return res.status(400).json({ erro: 'CPF é obrigatório' });
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

        const result = await pool.query(
            'INSERT INTO torcedores (nome, cpf, nascimento, equipe_id, plano_id) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [nome, cpf, nascimento, equipe_id, plano_id]
        );

        await pool.query(
            'UPDATE equipes SET qtd_socios = qtd_socios + 1 WHERE id = $1',
            [equipe_id]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        if (err.code === '23505') {
            return res.status(409).json({ erro: 'CPF já cadastrado' });
        }
        res.status(500).json({ erro: 'Erro ao criar torcedor' });
    }
};

exports.atualizar = async (req, res) => {
    try {
        const { id } = req.params;
        const { nome, cpf, nascimento, equipe_id, plano_id } = req.body;

        if (!nome || !nome.trim()) {
            return res.status(400).json({ erro: 'Nome é obrigatório' });
        }
        if (!cpf || !cpf.trim()) {
            return res.status(400).json({ erro: 'CPF é obrigatório' });
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

        const anterior = await pool.query(
            'SELECT equipe_id FROM torcedores WHERE id = $1', [id]
        );

        if (anterior.rows.length === 0) {
            return res.status(404).json({ erro: 'Torcedor não encontrado' });
        }

        const equipeAnteriorId = anterior.rows[0].equipe_id;

        const result = await pool.query(
            'UPDATE torcedores SET nome = $1, cpf = $2, nascimento = $3, equipe_id = $4, plano_id = $5 WHERE id = $6 RETURNING *',
            [nome, cpf, nascimento, equipe_id, plano_id, id]
        );

        if (equipeAnteriorId !== equipe_id) {
            await pool.query(
                'UPDATE equipes SET qtd_socios = qtd_socios - 1 WHERE id = $1',
                [equipeAnteriorId]
            );
            await pool.query(
                'UPDATE equipes SET qtd_socios = qtd_socios + 1 WHERE id = $1',
                [equipe_id]
            );
        }

        res.json(result.rows[0]);
    } catch (err) {
        if (err.code === '23505') {
            return res.status(409).json({ erro: 'CPF já cadastrado' });
        }
        res.status(500).json({ erro: 'Erro ao atualizar torcedor' });
    }
};

exports.excluir = async (req, res) => {
    try {
        const { id } = req.params;

        const torcedor = await pool.query(
            'SELECT equipe_id FROM torcedores WHERE id = $1', [id]
        );

        if (torcedor.rows.length === 0) {
            return res.status(404).json({ erro: 'Torcedor não encontrado' });
        }

        await pool.query('DELETE FROM torcedores WHERE id = $1', [id]);

        await pool.query(
            'UPDATE equipes SET qtd_socios = qtd_socios - 1 WHERE id = $1',
            [torcedor.rows[0].equipe_id]
        );

        res.json({ mensagem: 'Torcedor excluído com sucesso' });
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao excluir torcedor' });
    }
};

exports.verificarCpf = async (req, res) => {
    try {
        const { cpf, ignorar_id } = req.query;

        let query = 'SELECT id FROM torcedores WHERE cpf = $1';
        const params = [cpf];

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

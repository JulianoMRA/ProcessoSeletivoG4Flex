const express = require('express');
const cors = require('cors');
require('dotenv').config();

const equipesRoutes = require('./routes/equipes');
const planosRoutes = require('./routes/planos');
const torcedoresRoutes = require('./routes/torcedores');
const jogosRoutes = require('./routes/jogos');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/equipes', equipesRoutes);
app.use('/api/planos', planosRoutes);
app.use('/api/torcedores', torcedoresRoutes);
app.use('/api/jogos', jogosRoutes);

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/contadores', async (req, res) => {
    try {
        const pool = require('./config/database');
        const result = await pool.query(`
            SELECT
                (SELECT COUNT(*) FROM equipes) AS equipes,
                (SELECT COUNT(*) FROM torcedores) AS torcedores,
                (SELECT COUNT(*) FROM jogos) AS jogos,
                (SELECT COUNT(*) FROM planos) AS planos
        `);
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ erro: 'Erro ao buscar contadores' });
    }
});

app.listen(PORT, () => {
    console.log(`API rodando em http://localhost:${PORT}`);
});

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const pool = require('./config/database');

const equipesRoutes = require('./routes/equipes');
const planosRoutes = require('./routes/planos');
const torcedoresRoutes = require('./routes/torcedores');
const jogosRoutes = require('./routes/jogos');
const campeonatosRoutes = require('./routes/campeonatos');
const relatoriosRoutes = require('./routes/relatorios');

const app = express();
const PORT = process.env.PORT || 3000;

// Segurança
app.use(helmet());
app.use(cors({
    origin: /^http:\/\/localhost(:\d+)?$/,
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
}));
app.use(express.json({ limit: '1mb' }));

// Forçar charset UTF-8 em todas as respostas JSON
app.use((req, res, next) => {
    const originalJson = res.json.bind(res);
    res.json = (body) => {
        res.set('Content-Type', 'application/json; charset=utf-8');
        return originalJson(body);
    };
    next();
});

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 500,
    standardHeaders: true,
    legacyHeaders: false,
    message: { erro: 'Muitas requisições, tente novamente em 15 minutos' },
});
app.use(limiter);


// Rotas
app.use('/api/equipes', equipesRoutes);
app.use('/api/planos', planosRoutes);
app.use('/api/torcedores', torcedoresRoutes);
app.use('/api/jogos', jogosRoutes);
app.use('/api/campeonatos', campeonatosRoutes);
app.use('/api/relatorios', relatoriosRoutes);

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/contadores', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT
                (SELECT COUNT(*) FROM equipes) AS equipes,
                (SELECT COUNT(*) FROM torcedores) AS torcedores,
                (SELECT COUNT(*) FROM jogos) AS jogos,
                (SELECT COUNT(*) FROM planos) AS planos,
                (SELECT COUNT(*) FROM campeonatos) AS campeonatos
        `);
        res.json(result.rows[0]);
    } catch (err) {
        console.error('Erro ao buscar contadores:', err.message);
        res.status(500).json({ erro: 'Erro ao buscar contadores' });
    }
});

// Middleware global de tratamento de erros
app.use((err, req, res, _next) => {
    console.error('Erro não tratado:', err.message);
    res.status(500).json({ erro: 'Erro interno do servidor' });
});

if (process.env.NODE_ENV !== 'test') {
    app.listen(PORT, () => {
        console.log(`API rodando em http://localhost:${PORT}`);
    });
}

module.exports = app;


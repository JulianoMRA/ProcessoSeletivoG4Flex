const express = require('express');
const cors = require('cors');
require('dotenv').config();

const equipesRoutes = require('./routes/equipes');
const planosRoutes = require('./routes/planos');
const torcedoresRoutes = require('./routes/torcedores');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/equipes', equipesRoutes);
app.use('/api/planos', planosRoutes);
app.use('/api/torcedores', torcedoresRoutes);

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
    console.log(`🚀 API rodando em http://localhost:${PORT}`);
});

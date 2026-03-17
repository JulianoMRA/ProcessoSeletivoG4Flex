const express = require('express');
const router = express.Router();
const controller = require('../controllers/relatoriosController');

router.get('/', controller.obterRelatorios);

module.exports = router;

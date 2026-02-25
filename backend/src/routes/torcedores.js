const express = require('express');
const router = express.Router();
const controller = require('../controllers/torcedoresController');
const validarUUID = require('../middleware/validarUUID');

router.param('id', validarUUID);

router.get('/', controller.listar);
router.get('/verificar-cpf', controller.verificarCpf);
router.get('/:id', controller.buscarPorId);
router.post('/', controller.criar);
router.put('/:id', controller.atualizar);
router.delete('/:id', controller.excluir);

module.exports = router;

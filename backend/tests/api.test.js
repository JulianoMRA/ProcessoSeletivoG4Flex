const request = require('supertest');
const app = require('../src/server');
const pool = require('../src/config/database');

// IDs criados durante os testes para cleanup
const criados = {
    planos: [],
    equipes: [],
    torcedores: [],
    jogos: [],
};

afterAll(async () => {
    // Limpar na ordem correta (dependências primeiro)
    for (const id of criados.jogos) {
        await pool.query('DELETE FROM jogos WHERE id = $1', [id]).catch(() => { });
    }
    for (const id of criados.torcedores) {
        await pool.query('DELETE FROM torcedores WHERE id = $1', [id]).catch(() => { });
    }
    for (const id of criados.equipes) {
        await pool.query('DELETE FROM equipe_planos WHERE equipe_id = $1', [id]).catch(() => { });
        await pool.query('DELETE FROM equipes WHERE id = $1', [id]).catch(() => { });
    }
    for (const id of criados.planos) {
        await pool.query('DELETE FROM equipe_planos WHERE plano_id = $1', [id]).catch(() => { });
        await pool.query('DELETE FROM planos WHERE id = $1', [id]).catch(() => { });
    }
    await pool.end();
});

// ============================================================
// HEALTH
// ============================================================
describe('GET /api/health', () => {
    it('deve retornar status ok', async () => {
        const res = await request(app).get('/api/health');
        expect(res.statusCode).toBe(200);
        expect(res.body.status).toBe('ok');
        expect(res.body.timestamp).toBeDefined();
    });
});

// ============================================================
// CONTADORES
// ============================================================
describe('GET /api/contadores', () => {
    it('deve retornar contadores numéricos', async () => {
        const res = await request(app).get('/api/contadores');
        expect(res.statusCode).toBe(200);
        expect(res.body).toHaveProperty('equipes');
        expect(res.body).toHaveProperty('torcedores');
        expect(res.body).toHaveProperty('jogos');
        expect(res.body).toHaveProperty('planos');
    });
});

// ============================================================
// VALIDAÇÃO DE UUID
// ============================================================
describe('Validação de UUID', () => {
    it('deve rejeitar ID inválido', async () => {
        const res = await request(app).get('/api/equipes/abc-invalido');
        expect(res.statusCode).toBe(400);
        expect(res.body.erro).toBe('ID inválido');
    });

    it('deve retornar 404 para UUID válido inexistente', async () => {
        const res = await request(app).get('/api/equipes/00000000-0000-0000-0000-000000000000');
        expect(res.statusCode).toBe(404);
    });
});

// ============================================================
// PLANOS
// ============================================================
describe('PLANOS', () => {
    describe('POST /api/planos', () => {
        it('deve criar um plano válido', async () => {
            const res = await request(app)
                .post('/api/planos')
                .send({ nome: 'Teste Bronze', valor: 29.90 });
            expect(res.statusCode).toBe(201);
            expect(res.body.nome).toBe('Teste Bronze');
            criados.planos.push(res.body.id);
        });

        it('deve criar segundo plano para testes', async () => {
            const res = await request(app)
                .post('/api/planos')
                .send({ nome: 'Teste Prata', valor: 59.90 });
            expect(res.statusCode).toBe(201);
            criados.planos.push(res.body.id);
        });

        it('deve rejeitar nome vazio', async () => {
            const res = await request(app)
                .post('/api/planos')
                .send({ nome: '', valor: 10 });
            expect(res.statusCode).toBe(400);
        });

        it('deve rejeitar nome só com espaços', async () => {
            const res = await request(app)
                .post('/api/planos')
                .send({ nome: '   ', valor: 10 });
            expect(res.statusCode).toBe(400);
        });

        it('deve rejeitar valor negativo', async () => {
            const res = await request(app)
                .post('/api/planos')
                .send({ nome: 'Invalido', valor: -10 });
            expect(res.statusCode).toBe(400);
        });

        it('deve rejeitar valor excessivo', async () => {
            const res = await request(app)
                .post('/api/planos')
                .send({ nome: 'Caro', valor: 100000 });
            expect(res.statusCode).toBe(400);
        });

        it('deve aceitar valor zero', async () => {
            const res = await request(app)
                .post('/api/planos')
                .send({ nome: 'Gratuito', valor: 0 });
            expect(res.statusCode).toBe(201);
            criados.planos.push(res.body.id);
        });

        it('deve aceitar nome com acentos', async () => {
            const res = await request(app)
                .post('/api/planos')
                .send({ nome: 'Platéia Especial', valor: 100 });
            expect(res.statusCode).toBe(201);
            expect(res.body.nome).toBe('Platéia Especial');
            criados.planos.push(res.body.id);
        });
    });

    describe('GET /api/planos', () => {
        it('deve listar planos', async () => {
            const res = await request(app).get('/api/planos');
            expect(res.statusCode).toBe(200);
            expect(Array.isArray(res.body)).toBe(true);
        });
    });

    describe('GET /api/planos/:id', () => {
        it('deve buscar plano por id', async () => {
            const res = await request(app).get(`/api/planos/${criados.planos[0]}`);
            expect(res.statusCode).toBe(200);
            expect(res.body.nome).toBe('Teste Bronze');
        });
    });

    describe('PUT /api/planos/:id', () => {
        it('deve atualizar plano', async () => {
            const res = await request(app)
                .put(`/api/planos/${criados.planos[0]}`)
                .send({ nome: 'Teste Bronze Atualizado', valor: 39.90 });
            expect(res.statusCode).toBe(200);
            expect(res.body.nome).toBe('Teste Bronze Atualizado');
        });

        it('deve retornar 404 para plano inexistente', async () => {
            const res = await request(app)
                .put('/api/planos/00000000-0000-0000-0000-000000000000')
                .send({ nome: 'X', valor: 10 });
            expect(res.statusCode).toBe(404);
        });
    });
});

// ============================================================
// EQUIPES
// ============================================================
describe('EQUIPES', () => {
    describe('POST /api/equipes', () => {
        it('deve criar equipe válida', async () => {
            const res = await request(app)
                .post('/api/equipes')
                .send({
                    nome: 'Equipe Teste A',
                    serie: 'Série A',
                    plano_ids: [criados.planos[0]],
                });
            expect(res.statusCode).toBe(201);
            expect(res.body.nome).toBe('Equipe Teste A');
            expect(res.body.planos.length).toBeGreaterThanOrEqual(1);
            criados.equipes.push(res.body.id);
        });

        it('deve criar segunda equipe para testes de jogos', async () => {
            const res = await request(app)
                .post('/api/equipes')
                .send({
                    nome: 'Equipe Teste B',
                    serie: 'Série B',
                    plano_ids: [criados.planos[1]],
                });
            expect(res.statusCode).toBe(201);
            criados.equipes.push(res.body.id);
        });

        it('deve rejeitar sem nome', async () => {
            const res = await request(app)
                .post('/api/equipes')
                .send({ nome: '', serie: 'A', plano_ids: [criados.planos[0]] });
            expect(res.statusCode).toBe(400);
        });

        it('deve rejeitar sem série', async () => {
            const res = await request(app)
                .post('/api/equipes')
                .send({ nome: 'X', serie: '', plano_ids: [criados.planos[0]] });
            expect(res.statusCode).toBe(400);
        });

        it('deve rejeitar sem planos', async () => {
            const res = await request(app)
                .post('/api/equipes')
                .send({ nome: 'X', serie: 'A', plano_ids: [] });
            expect(res.statusCode).toBe(400);
        });

        it('deve aceitar nome com acentos', async () => {
            const res = await request(app)
                .post('/api/equipes')
                .send({
                    nome: 'São Paulo FC',
                    serie: 'Série A',
                    plano_ids: [criados.planos[0]],
                });
            expect(res.statusCode).toBe(201);
            expect(res.body.nome).toBe('São Paulo FC');
            criados.equipes.push(res.body.id);
        });

        it('deve fazer trim no nome', async () => {
            const res = await request(app)
                .post('/api/equipes')
                .send({
                    nome: '  Equipe Trimmed  ',
                    serie: 'Série A',
                    plano_ids: [criados.planos[0]],
                });
            expect(res.statusCode).toBe(201);
            expect(res.body.nome).toBe('Equipe Trimmed');
            criados.equipes.push(res.body.id);
        });
    });

    describe('GET /api/equipes', () => {
        it('deve listar equipes', async () => {
            const res = await request(app).get('/api/equipes');
            expect(res.statusCode).toBe(200);
            expect(Array.isArray(res.body)).toBe(true);
        });

        it('deve suportar paginação', async () => {
            const res = await request(app).get('/api/equipes?page=1&limit=2');
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('dados');
            expect(res.body).toHaveProperty('total');
            expect(res.body).toHaveProperty('pagina');
            expect(res.body).toHaveProperty('limite');
        });

        it('deve tratar page/limit inválidos', async () => {
            const res = await request(app).get('/api/equipes?page=-1&limit=abc');
            expect(res.statusCode).toBe(200);
            expect(res.body.pagina).toBe(1);
        });
    });

    describe('GET /api/equipes/:id', () => {
        it('deve buscar equipe com planos', async () => {
            const res = await request(app).get(`/api/equipes/${criados.equipes[0]}`);
            expect(res.statusCode).toBe(200);
            expect(res.body.planos).toBeDefined();
        });
    });

    describe('PUT /api/equipes/:id', () => {
        it('deve atualizar equipe', async () => {
            const res = await request(app)
                .put(`/api/equipes/${criados.equipes[0]}`)
                .send({
                    nome: 'Equipe A Atualizada',
                    serie: 'Série B',
                    plano_ids: [criados.planos[0], criados.planos[1]],
                });
            expect(res.statusCode).toBe(200);
            expect(res.body.nome).toBe('Equipe A Atualizada');
        });
    });
});

// ============================================================
// TORCEDORES
// ============================================================
describe('TORCEDORES', () => {
    describe('POST /api/torcedores', () => {
        it('deve criar torcedor válido', async () => {
            const res = await request(app)
                .post('/api/torcedores')
                .send({
                    nome: 'João da Silva',
                    cpf: '111.111.111-11',
                    nascimento: '1990-05-15',
                    equipe_id: criados.equipes[0],
                    plano_id: criados.planos[0],
                });
            expect(res.statusCode).toBe(201);
            expect(res.body.nome).toBe('João da Silva');
            expect(res.body.cpf).toBe('11111111111');
            criados.torcedores.push(res.body.id);
        });

        it('deve rejeitar CPF duplicado', async () => {
            const res = await request(app)
                .post('/api/torcedores')
                .send({
                    nome: 'Outro João',
                    cpf: '11111111111',
                    nascimento: '1990-05-15',
                    equipe_id: criados.equipes[0],
                    plano_id: criados.planos[0],
                });
            expect(res.statusCode).toBe(409);
            expect(res.body.erro).toContain('CPF');
        });

        it('deve rejeitar CPF curto', async () => {
            const res = await request(app)
                .post('/api/torcedores')
                .send({
                    nome: 'Teste',
                    cpf: '123',
                    nascimento: '1990-01-01',
                    equipe_id: criados.equipes[0],
                    plano_id: criados.planos[0],
                });
            expect(res.statusCode).toBe(400);
            expect(res.body.erro).toContain('11 dígitos');
        });

        it('deve rejeitar sem nome', async () => {
            const res = await request(app)
                .post('/api/torcedores')
                .send({
                    nome: '',
                    cpf: '22222222222',
                    nascimento: '1990-01-01',
                    equipe_id: criados.equipes[0],
                    plano_id: criados.planos[0],
                });
            expect(res.statusCode).toBe(400);
        });

        it('deve rejeitar sem equipe', async () => {
            const res = await request(app)
                .post('/api/torcedores')
                .send({
                    nome: 'Teste',
                    cpf: '22222222222',
                    nascimento: '1990-01-01',
                    plano_id: criados.planos[0],
                });
            expect(res.statusCode).toBe(400);
        });

        it('deve rejeitar equipe_id inexistente', async () => {
            const res = await request(app)
                .post('/api/torcedores')
                .send({
                    nome: 'Teste FK',
                    cpf: '33333333333',
                    nascimento: '1990-01-01',
                    equipe_id: '00000000-0000-0000-0000-000000000000',
                    plano_id: criados.planos[0],
                });
            expect(res.statusCode).toBe(400);
            expect(res.body.erro).toContain('não existe');
        });

        it('deve aceitar nome com acentos', async () => {
            const res = await request(app)
                .post('/api/torcedores')
                .send({
                    nome: 'José André da Conceição',
                    cpf: '44444444444',
                    nascimento: '1985-03-20',
                    equipe_id: criados.equipes[0],
                    plano_id: criados.planos[0],
                });
            expect(res.statusCode).toBe(201);
            expect(res.body.nome).toBe('José André da Conceição');
            criados.torcedores.push(res.body.id);
        });

        it('deve limpar formatação do CPF', async () => {
            const res = await request(app)
                .post('/api/torcedores')
                .send({
                    nome: 'Maria CPF Formatado',
                    cpf: '555.555.555-55',
                    nascimento: '1995-07-10',
                    equipe_id: criados.equipes[0],
                    plano_id: criados.planos[0],
                });
            expect(res.statusCode).toBe(201);
            expect(res.body.cpf).toBe('55555555555');
            criados.torcedores.push(res.body.id);
        });
    });

    describe('GET /api/torcedores/verificar-cpf', () => {
        it('deve retornar true para CPF existente', async () => {
            const res = await request(app).get('/api/torcedores/verificar-cpf?cpf=11111111111');
            expect(res.statusCode).toBe(200);
            expect(res.body.existe).toBe(true);
        });

        it('deve retornar false para CPF inexistente', async () => {
            const res = await request(app).get('/api/torcedores/verificar-cpf?cpf=99999999999');
            expect(res.statusCode).toBe(200);
            expect(res.body.existe).toBe(false);
        });

        it('deve ignorar o próprio torcedor', async () => {
            const res = await request(app)
                .get(`/api/torcedores/verificar-cpf?cpf=11111111111&ignorar_id=${criados.torcedores[0]}`);
            expect(res.statusCode).toBe(200);
            expect(res.body.existe).toBe(false);
        });
    });

    describe('GET /api/torcedores', () => {
        it('deve listar torcedores com dados de equipe e plano', async () => {
            const res = await request(app).get('/api/torcedores');
            expect(res.statusCode).toBe(200);
            expect(Array.isArray(res.body)).toBe(true);
            if (res.body.length > 0) {
                expect(res.body[0]).toHaveProperty('equipe_nome');
                expect(res.body[0]).toHaveProperty('plano_nome');
            }
        });
    });

    describe('PUT /api/torcedores/:id', () => {
        it('deve atualizar torcedor', async () => {
            const res = await request(app)
                .put(`/api/torcedores/${criados.torcedores[0]}`)
                .send({
                    nome: 'João Atualizado',
                    cpf: '11111111111',
                    nascimento: '1990-05-15',
                    equipe_id: criados.equipes[0],
                    plano_id: criados.planos[0],
                });
            expect(res.statusCode).toBe(200);
            expect(res.body.nome).toBe('João Atualizado');
        });

        it('deve retornar 404 para torcedor inexistente', async () => {
            const res = await request(app)
                .put('/api/torcedores/00000000-0000-0000-0000-000000000000')
                .send({
                    nome: 'X',
                    cpf: '99999999999',
                    nascimento: '1990-01-01',
                    equipe_id: criados.equipes[0],
                    plano_id: criados.planos[0],
                });
            expect(res.statusCode).toBe(404);
        });
    });
});

// ============================================================
// JOGOS
// ============================================================
describe('JOGOS', () => {
    describe('POST /api/jogos', () => {
        it('deve criar jogo válido', async () => {
            const res = await request(app)
                .post('/api/jogos')
                .send({
                    data: '2025-06-15',
                    hora: '16:00',
                    equipe_a_id: criados.equipes[0],
                    equipe_b_id: criados.equipes[1],
                    gols_equipe_a: 2,
                    gols_equipe_b: 1,
                });
            expect(res.statusCode).toBe(201);
            expect(res.body.vencedor).toBe('equipe_a');
            criados.jogos.push(res.body.id);
        });

        it('deve rejeitar mesma equipe', async () => {
            const res = await request(app)
                .post('/api/jogos')
                .send({
                    data: '2025-06-15',
                    hora: '16:00',
                    equipe_a_id: criados.equipes[0],
                    equipe_b_id: criados.equipes[0],
                    gols_equipe_a: 0,
                    gols_equipe_b: 0,
                });
            expect(res.statusCode).toBe(400);
            expect(res.body.erro).toContain('diferentes');
        });

        it('deve rejeitar gols negativos', async () => {
            const res = await request(app)
                .post('/api/jogos')
                .send({
                    data: '2025-06-15',
                    hora: '16:00',
                    equipe_a_id: criados.equipes[0],
                    equipe_b_id: criados.equipes[1],
                    gols_equipe_a: -1,
                    gols_equipe_b: 0,
                });
            expect(res.statusCode).toBe(400);
            expect(res.body.erro).toContain('negativos');
        });

        it('deve rejeitar sem data', async () => {
            const res = await request(app)
                .post('/api/jogos')
                .send({
                    hora: '16:00',
                    equipe_a_id: criados.equipes[0],
                    equipe_b_id: criados.equipes[1],
                });
            expect(res.statusCode).toBe(400);
        });

        it('deve tratar empate', async () => {
            const res = await request(app)
                .post('/api/jogos')
                .send({
                    data: '2025-07-20',
                    hora: '20:00',
                    equipe_a_id: criados.equipes[0],
                    equipe_b_id: criados.equipes[1],
                    gols_equipe_a: 1,
                    gols_equipe_b: 1,
                });
            expect(res.statusCode).toBe(201);
            expect(res.body.vencedor).toBe('empate');
            criados.jogos.push(res.body.id);
        });

        it('deve rejeitar equipe inexistente', async () => {
            const res = await request(app)
                .post('/api/jogos')
                .send({
                    data: '2025-06-15',
                    hora: '16:00',
                    equipe_a_id: '00000000-0000-0000-0000-000000000000',
                    equipe_b_id: criados.equipes[1],
                    gols_equipe_a: 0,
                    gols_equipe_b: 0,
                });
            expect(res.statusCode).toBe(400);
            expect(res.body.erro).toContain('não existe');
        });
    });

    describe('GET /api/jogos', () => {
        it('deve listar jogos', async () => {
            const res = await request(app).get('/api/jogos');
            expect(res.statusCode).toBe(200);
            expect(Array.isArray(res.body)).toBe(true);
        });

        it('deve filtrar por equipe', async () => {
            const res = await request(app).get(`/api/jogos?equipe_id=${criados.equipes[0]}`);
            expect(res.statusCode).toBe(200);
            expect(Array.isArray(res.body)).toBe(true);
        });
    });

    describe('PUT /api/jogos/:id', () => {
        it('deve atualizar jogo', async () => {
            const res = await request(app)
                .put(`/api/jogos/${criados.jogos[0]}`)
                .send({
                    data: '2025-06-15',
                    hora: '18:00',
                    equipe_a_id: criados.equipes[0],
                    equipe_b_id: criados.equipes[1],
                    gols_equipe_a: 3,
                    gols_equipe_b: 0,
                });
            expect(res.statusCode).toBe(200);
            expect(res.body.gols_equipe_a).toBe(3);
        });
    });
});

// ============================================================
// EXCLUSÃO EM CASCATA
// ============================================================
describe('EXCLUSÃO EM CASCATA', () => {
    it('não deve excluir equipe com torcedores', async () => {
        const res = await request(app).delete(`/api/equipes/${criados.equipes[0]}`);
        expect(res.statusCode).toBe(409);
        expect(res.body.erro).toContain('torcedores');
    });

    it('não deve excluir equipe com jogos', async () => {
        // equipes[1] tem jogos mas não torcedores
        const res = await request(app).delete(`/api/equipes/${criados.equipes[1]}`);
        expect(res.statusCode).toBe(409);
        expect(res.body.erro).toContain('jogos');
    });
});

// ============================================================
// EXCLUSÃO (ordem certa: jogos -> torcedores -> equipes -> planos)
// ============================================================
describe('EXCLUSÃO', () => {
    it('deve excluir jogo', async () => {
        for (const id of criados.jogos) {
            const res = await request(app).delete(`/api/jogos/${id}`);
            expect(res.statusCode).toBe(200);
        }
        criados.jogos = [];
    });

    it('deve excluir torcedor e decrementar qtd_socios', async () => {
        const antesRes = await request(app).get(`/api/equipes/${criados.equipes[0]}`);
        const sociosAntes = antesRes.body.qtd_socios;

        for (const id of criados.torcedores) {
            const res = await request(app).delete(`/api/torcedores/${id}`);
            expect(res.statusCode).toBe(200);
        }

        const depoisRes = await request(app).get(`/api/equipes/${criados.equipes[0]}`);
        expect(depoisRes.body.qtd_socios).toBeLessThan(sociosAntes);
        criados.torcedores = [];
    });

    it('deve excluir equipe sem dependências', async () => {
        for (const id of criados.equipes) {
            const res = await request(app).delete(`/api/equipes/${id}`);
            expect(res.statusCode).toBe(200);
        }
        criados.equipes = [];
    });

    it('deve excluir plano sem dependências', async () => {
        for (const id of criados.planos) {
            const res = await request(app).delete(`/api/planos/${id}`);
            expect(res.statusCode).toBe(200);
        }
        criados.planos = [];
    });

    it('deve retornar 404 para exclusão de recurso inexistente', async () => {
        const uuid = '00000000-0000-0000-0000-000000000000';
        const resEquipe = await request(app).delete(`/api/equipes/${uuid}`);
        expect(resEquipe.statusCode).toBe(404);

        const resTorcedor = await request(app).delete(`/api/torcedores/${uuid}`);
        expect(resTorcedor.statusCode).toBe(404);

        const resJogo = await request(app).delete(`/api/jogos/${uuid}`);
        expect(resJogo.statusCode).toBe(404);

        const resPlano = await request(app).delete(`/api/planos/${uuid}`);
        expect(resPlano.statusCode).toBe(404);
    });
});

# Fala, Torcedor!

Sistema para cadastrar equipes, planos de associação, torcedores, campeonatos e jogos, e visualizar relatórios agregados sobre essa base. Projeto feito como parte de um processo seletivo da G4Flex.

## Stack

O backend é Node.js com Express porque a API é um CRUD direto sobre PostgreSQL e não justificava um framework mais opinativo. Uso `pg` com queries parametrizadas em vez de um ORM — o schema é pequeno o bastante para que SQL escrito à mão seja mais legível do que configurar relações em código. `helmet`, `cors` restrito a `localhost` e `express-rate-limit` entram como camadas básicas de proteção. PostgreSQL foi escolhido pelas relações N:M (equipes × campeonatos, equipes × planos) e pelo suporte nativo a `UUID`.

O app é Flutter para sair com um único código-base rodando em Web e Android. Estado é gerenciado com `ChangeNotifier` — não há fluxo assíncrono complexo que justifique Bloc ou Riverpod. `fl_chart` cuida dos gráficos dos relatórios, `google_fonts` carrega Inter, e `mask_text_input_formatter` formata CPF e datas nos formulários.

Os testes do backend usam Jest com Supertest, rodando contra o banco real (não há mocks do `pg`) — a ideia é pegar regressões em constraints, transações e queries, que é onde a maior parte dos bugs aparece.

## Estrutura

```
.
├── backend/
│   ├── src/
│   │   ├── config/        # pool do PostgreSQL (UTF-8 forçado)
│   │   ├── controllers/   # um por entidade
│   │   ├── middleware/    # validação de UUID
│   │   ├── routes/        # equipes, planos, torcedores, campeonatos, jogos, relatórios
│   │   └── server.js
│   ├── tests/
│   └── .env.example
├── mobile/
│   └── lib/
│       ├── controllers/   # ChangeNotifier por entidade
│       ├── core/          # tema, cores, componentes compartilhados
│       ├── models/
│       ├── services/      # cliente HTTP
│       └── views/         # home, splash e uma pasta por entidade
└── database/
    ├── schema.sql
    ├── seed.sql
    └── reset.sql
```

## Rodando localmente

Pré-requisitos: Node.js 20+, PostgreSQL 14+ e Flutter 3.x.

Banco:

```bash
createdb fala_torcedor
psql -d fala_torcedor -f database/schema.sql
psql -d fala_torcedor -f database/seed.sql
```

Backend:

```bash
cd backend
cp .env.example .env   # preencha DB_PASSWORD
npm install
npm run dev            # http://localhost:3000
```

App:

```bash
cd mobile
flutter pub get
flutter run -d chrome  # ou: flutter run (Android)
```

Testes do backend rodam com `npm test` dentro de `backend/` — exigem o banco populado pelo seed.

## API

Base: `http://localhost:3000/api`.

Há seis grupos de rotas — `/equipes`, `/planos`, `/torcedores`, `/campeonatos`, `/jogos` e `/relatorios` — além de `/health` e `/contadores`. Cada entidade expõe CRUD completo; filtros por query string estão disponíveis em `/planos?equipe_id=…`, `/jogos?equipe_id=…` e `/jogos?campeonato_id=…`. `/torcedores/verificar-cpf?cpf=…` responde se um CPF já está cadastrado. `/relatorios` devolve os sete agregados consumidos pela tela de relatórios do app, todos calculados em paralelo.

Exclusões são bloqueadas com `409 Conflict` quando há dependências (equipe com torcedores ou jogos, plano com torcedores, campeonato com jogos). IDs malformados são rejeitados com `400` antes de chegar ao controller.

## Manutenção

**Adicionar uma entidade nova no backend** implica um arquivo em cada uma das pastas `controllers/`, `routes/` e `tests/`, e registrar a rota em [backend/src/server.js](backend/src/server.js). O schema vai em [database/schema.sql](database/schema.sql); se a entidade tem relação com outras, atualize também [database/seed.sql](database/seed.sql) para os testes continuarem passando.

**Adicionar uma entidade nova no app** segue o mesmo padrão: um `model`, um `controller` (`ChangeNotifier`), métodos no `services/api_service.dart`, e uma pasta em `views/` com as telas de lista, formulário e detalhe. A navegação principal está em [mobile/lib/views/home_view.dart](mobile/lib/views/home_view.dart) — é lá que o card novo entra.

**Relatórios** são definidos em [backend/src/routes/relatorios.js](backend/src/routes/relatorios.js) (uma query SQL por item) e consumidos em [mobile/lib/views/relatorios](mobile/lib/views/relatorios). Novo gráfico = nova query no backend + novo widget `fl_chart` no app.

**Cores, tema e componentes compartilhados** do app ficam em [mobile/lib/core](mobile/lib/core). Qualquer ajuste visual global começa por ali.

Não há pipeline de deploy configurado — o projeto roda localmente. A `URL` da API usada pelo app está em [mobile/lib/services](mobile/lib/services) e é o ponto a alterar caso o backend passe a rodar em outro host.

# Fala, Torcedor!

Sistema de gestão de sócios-torcedores para clubes de futebol. Permite cadastrar equipes, planos de associação, torcedores, campeonatos e jogos, além de exibir relatórios estatísticos com gráficos interativos.

---

## Tecnologias

| Camada    | Stack                                                         |
|-----------|---------------------------------------------------------------|
| Backend   | Node.js 20+, Express 4, PostgreSQL 14+                        |
| Frontend  | Flutter 3.x, Material Design 3, Inter (Google Fonts)          |
| Testes    | Jest + Supertest — 87 testes automatizados                    |

---

## Estrutura do Projeto

```
ProcessoSeletivoG4Flex/
├── backend/
│   ├── src/
│   │   ├── config/        # Conexão com o banco de dados (pool UTF-8)
│   │   ├── controllers/   # Lógica de negócio (6 controllers)
│   │   ├── middleware/    # Validação de UUID
│   │   ├── routes/        # Rotas da API (6 entidades)
│   │   └── server.js      # Entry point — middlewares de segurança e rotas
│   ├── tests/             # Testes automatizados (Jest + Supertest)
│   └── .env.example       # Template de variáveis de ambiente
├── mobile/
│   └── lib/
│       ├── controllers/   # Gerenciamento de estado (ChangeNotifier)
│       ├── core/          # Design system — cores, tema, componentes globais
│       ├── models/        # Entidades: Equipe, Plano, Torcedor, Campeonato, Jogo
│       ├── services/      # Cliente HTTP centralizado
│       └── views/         # Telas — home, formulários, detalhes, relatórios
└── database/
    ├── schema.sql          # Criação de tabelas e constraints
    ├── seed.sql            # Dados de exemplo (equipes, torcedores, jogos...)
    └── reset.sql           # Drop e recriação do schema
```

---

## Pré-requisitos

- [Node.js 20+](https://nodejs.org)
- [PostgreSQL 14+](https://www.postgresql.org)
- [Flutter 3.x](https://flutter.dev) (com suporte a Web ou Android)

---

## Como Executar

### 1. Banco de Dados

```bash
createdb fala_torcedor
psql -d fala_torcedor -f database/schema.sql
psql -d fala_torcedor -f database/seed.sql
```

### 2. Backend

```bash
cd backend
cp .env.example .env   # preencha DB_PASSWORD com sua senha do PostgreSQL
npm install
npm run dev            # API disponível em http://localhost:3000
```

### 3. Frontend

```bash
cd mobile
flutter pub get        # instala dependências, incluindo google_fonts (Inter)
flutter run -d chrome  # Web — ou: flutter run (Android)
```

### 4. Testes

```bash
cd backend
npm test               # executa os 87 testes automatizados
```

---

## API

**Base URL:** `http://localhost:3000/api`

### Equipes

| Método   | Rota           | Descrição                                      |
|----------|----------------|------------------------------------------------|
| `GET`    | `/equipes`     | Listar todas (suporta paginação)               |
| `GET`    | `/equipes/:id` | Buscar por ID — inclui planos e campeonatos    |
| `POST`   | `/equipes`     | Criar — aceita `plano_ids` e `campeonato_ids`  |
| `PUT`    | `/equipes/:id` | Atualizar — aceita `plano_ids` e `campeonato_ids` |
| `DELETE` | `/equipes/:id` | Excluir — bloqueado se houver torcedores ou jogos |

### Planos

| Método   | Rota                       | Descrição                       |
|----------|----------------------------|---------------------------------|
| `GET`    | `/planos`                  | Listar todos                    |
| `GET`    | `/planos?equipe_id=<uuid>` | Filtrar por equipe              |
| `GET`    | `/planos/:id`              | Buscar por ID                   |
| `POST`   | `/planos`                  | Criar                           |
| `PUT`    | `/planos/:id`              | Atualizar                       |
| `DELETE` | `/planos/:id`              | Excluir — bloqueado se houver torcedores |

### Torcedores

| Método   | Rota                                  | Descrição                          |
|----------|---------------------------------------|------------------------------------|
| `GET`    | `/torcedores`                         | Listar todos — inclui equipe e plano via JOIN |
| `GET`    | `/torcedores/:id`                     | Buscar por ID                      |
| `GET`    | `/torcedores/verificar-cpf?cpf=<cpf>` | Verificar unicidade do CPF         |
| `POST`   | `/torcedores`                         | Criar — valida formato do CPF      |
| `PUT`    | `/torcedores/:id`                     | Atualizar                          |
| `DELETE` | `/torcedores/:id`                     | Excluir — decrementa `qtd_socios`  |

### Campeonatos

| Método   | Rota               | Descrição                                        |
|----------|--------------------|--------------------------------------------------|
| `GET`    | `/campeonatos`     | Listar todos (suporta paginação)                 |
| `GET`    | `/campeonatos/:id` | Buscar por ID — inclui equipes participantes (N:M) |
| `POST`   | `/campeonatos`     | Criar — requer ao menos 2 `equipe_ids`           |
| `PUT`    | `/campeonatos/:id` | Atualizar — aceita `equipe_ids`                  |
| `DELETE` | `/campeonatos/:id` | Excluir — bloqueado se houver jogos              |

### Jogos

| Método   | Rota                          | Descrição                         |
|----------|-------------------------------|-----------------------------------|
| `GET`    | `/jogos`                      | Listar todos                      |
| `GET`    | `/jogos?equipe_id=<uuid>`     | Filtrar por equipe                |
| `GET`    | `/jogos?campeonato_id=<uuid>` | Filtrar por campeonato            |
| `GET`    | `/jogos/:id`                  | Buscar por ID                     |
| `POST`   | `/jogos`                      | Criar — valida gols ≥ 0 e equipes no campeonato |
| `PUT`    | `/jogos/:id`                  | Atualizar                         |
| `DELETE` | `/jogos/:id`                  | Excluir                           |

### Utilitários

| Método | Rota          | Descrição                                                   |
|--------|---------------|-------------------------------------------------------------|
| `GET`  | `/health`     | Status da API                                               |
| `GET`  | `/contadores` | Total de registros por entidade                             |
| `GET`  | `/relatorios` | 7 relatórios agregados em paralelo (distribuição etária, desempenho por equipe, jogos e equipes por campeonato, torcedores por equipe e por plano, KPIs gerais) |

---

## Testes Automatizados

87 testes organizados em 11 categorias, cobrindo CRUD completo, relacionamentos N:M, validações de entrada, integridade referencial, proteções de exclusão em cascata, paginação, suporte a UTF-8 e relatórios agregados.

| Categoria              | Testes |
|------------------------|--------|
| Health + Contadores    | 2      |
| Validação UUID         | 2      |
| CRUD Planos            | 14     |
| CRUD Equipes           | 12     |
| CRUD Torcedores        | 18     |
| CRUD Campeonatos       | 10     |
| Equipes + Campeonatos  | 3      |
| CRUD Jogos             | 16     |
| Relatórios             | 1      |
| Exclusão em Cascata    | 3      |
| Exclusão + Cleanup     | 6      |
| **Total**              | **87** |

---

## Segurança

| Medida              | Descrição                                                   |
|---------------------|-------------------------------------------------------------|
| Helmet              | Headers de segurança HTTP (CSP, X-Content-Type-Options etc.)|
| CORS                | Restrito a origens `localhost`                              |
| Rate Limiting       | 500 requisições por IP a cada 15 minutos                    |
| Body Size Limit     | Máximo de 1 MB por requisição                               |
| UUID Validation     | Middleware rejeita IDs malformados com `400 Bad Request`    |
| Queries Parametrizadas | Eliminação de SQL Injection via `$1, $2...`              |
| Transações SQL      | `BEGIN / COMMIT / ROLLBACK` em operações multi-tabela       |
| Cascade Protection  | Exclusão bloqueada quando há dependências (`409 Conflict`)  |
| UTF-8 End-to-End    | `client_encoding` no PostgreSQL + `charset` nas respostas  |

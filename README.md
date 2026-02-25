# Fala, Torcedor!

Sistema de gestão de sócios-torcedores para clubes de futebol.

## Estrutura do Projeto

```
ProcessoSeletivoG4Flex/
├── backend/              # API Node.js + Express + PostgreSQL
│   └── src/
│       ├── config/       # Conexão com banco de dados (UTF-8)
│       ├── controllers/  # Lógica de negócio (4 controllers)
│       ├── middleware/    # Validação de UUID
│       ├── routes/       # Rotas da API (4 entidades)
│       └── server.js     # Entrada + middlewares de segurança
│   └── tests/            # Testes automatizados (Jest + Supertest)
├── mobile/               # App Flutter (Android/iOS/Web)
│   └── lib/
│       ├── controllers/  # Lógica de estado (ChangeNotifier)
│       ├── core/         # Cores, tema, snackbar
│       ├── models/       # Equipe, Plano, Torcedor, Jogo
│       ├── services/     # ApiService (HTTP + UTF-8)
│       └── views/        # Telas (home, equipes, planos, torcedores, jogos)
└── database/             # Scripts SQL (schema, seed, reset)
```

## Tecnologias

| Camada   | Stack                                            |
|----------|--------------------------------------------------|
| Backend  | Node.js, Express, PostgreSQL, `pg`, Helmet       |
| Mobile   | Flutter 3.x, Material Design 3, Dark Mode        |
| Database | PostgreSQL 14+, UUID como PK                     |
| Testes   | Jest, Supertest (58 testes automatizados)         |

## Segurança

| Medida                | Descrição                                          |
|-----------------------|----------------------------------------------------|
| Helmet                | Headers de segurança (X-Content-Type-Options, etc.)|
| Rate Limiting         | 500 requisições por 15 minutos                     |
| Body Size Limit       | Máximo 1MB por requisição                          |
| UUID Validation       | Rejeita IDs inválidos com erro 400                 |
| Transações            | BEGIN/COMMIT/ROLLBACK para integridade de dados     |
| Cascade Protection    | Impede exclusão de entidades com dependências      |
| Input Trimming        | Nomes e campos de texto são sanitizados            |
| CPF Validation        | 11 dígitos, verificação de unicidade               |
| UTF-8 End-to-End      | `client_encoding` no PG, charset em respostas      |

## Como Executar

### 1. Database
```bash
# Crie o banco de dados
createdb fala_torcedor

# Execute os scripts
psql -d fala_torcedor -f database/schema.sql
psql -d fala_torcedor -f database/seed.sql
```

### 2. Backend
```bash
cd backend
cp .env.example .env      # edite DB_PASSWORD
npm install
npm run dev               # http://localhost:3000
```

### 3. Mobile
```bash
cd mobile
flutter pub get
flutter run -d chrome     # ou flutter run (Android)
```

### 4. Testes
```bash
cd backend
npm test                  # 58 testes automatizados
```

## API Endpoints

Base URL: `http://localhost:3000/api`

### Equipes

| Método   | Rota              | Descrição                      |
|----------|--------------------|---------------------------------|
| `GET`    | `/equipes`         | Listar (suporta paginação)     |
| `GET`    | `/equipes/:id`     | Buscar por ID (+ planos)       |
| `POST`   | `/equipes`         | Criar (com plano_ids)          |
| `PUT`    | `/equipes/:id`     | Atualizar (com plano_ids)      |
| `DELETE` | `/equipes/:id`     | Excluir (protege dependências) |

### Planos

| Método   | Rota                          | Descrição                  |
|----------|-------------------------------|----------------------------|
| `GET`    | `/planos`                     | Listar todos               |
| `GET`    | `/planos?equipe_id=<uuid>`    | Filtrar por equipe         |
| `GET`    | `/planos/:id`                 | Buscar por ID              |
| `POST`   | `/planos`                     | Criar                      |
| `PUT`    | `/planos/:id`                 | Atualizar                  |
| `DELETE` | `/planos/:id`                 | Excluir (protege dependências) |

### Torcedores

| Método   | Rota                                    | Descrição               |
|----------|-----------------------------------------|--------------------------|
| `GET`    | `/torcedores`                           | Listar (com JOINs)      |
| `GET`    | `/torcedores/:id`                       | Buscar por ID            |
| `GET`    | `/torcedores/verificar-cpf?cpf=<cpf>`   | Verificar CPF único      |
| `POST`   | `/torcedores`                           | Criar (valida CPF)       |
| `PUT`    | `/torcedores/:id`                       | Atualizar                |
| `DELETE` | `/torcedores/:id`                       | Excluir (-1 qtd_socios)  |

### Jogos

| Método   | Rota                          | Descrição                   |
|----------|-------------------------------|-----------------------------|
| `GET`    | `/jogos`                      | Listar todos                |
| `GET`    | `/jogos?equipe_id=<uuid>`     | Filtrar por equipe          |
| `GET`    | `/jogos/:id`                  | Buscar por ID               |
| `POST`   | `/jogos`                      | Criar (valida gols ≥ 0)    |
| `PUT`    | `/jogos/:id`                  | Atualizar                   |
| `DELETE` | `/jogos/:id`                  | Excluir                     |

### Utilitários

| Método | Rota            | Descrição               |
|--------|-----------------|--------------------------|
| `GET`  | `/health`       | Status da API            |
| `GET`  | `/contadores`   | Total de cada entidade   |

## Testes Automatizados

58 testes organizados em 8 categorias:

| Categoria               | Testes |
|--------------------------|--------|
| Health + Contadores      | 2      |
| Validação UUID           | 2      |
| CRUD Planos              | 10     |
| CRUD Equipes             | 11     |
| CRUD Torcedores          | 13     |
| CRUD Jogos               | 9      |
| Exclusão em Cascata      | 2      |
| Exclusão + Cleanup       | 5      |
| **Total**                | **58** |

Cobertura: CRUD completo, validação de inputs, integridade referencial, paginação, acentos UTF-8, CPF duplicado/formatação, e edge cases.

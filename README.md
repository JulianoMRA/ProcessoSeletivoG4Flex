# Fala, Torcedor!

Sistema de gestão de sócios-torcedores para clubes de futebol.

## Estrutura do Projeto

```
ProcessoSeletivoG4Flex/
├── backend/              # API Node.js + Express + PostgreSQL
│   └── src/
│       ├── config/       # Conexão com banco de dados
│       ├── controllers/  # Lógica de negócio
│       ├── routes/       # Rotas da API
│       └── server.js     # Entrada da aplicação
├── mobile/               # App Flutter (Android/iOS/Web)
│   └── lib/
│       ├── controllers/  # Lógica de estado (ChangeNotifier)
│       ├── core/         # Cores, tema
│       ├── models/       # Equipe, Plano, Torcedor
│       ├── services/     # ApiService (HTTP)
│       └── views/        # Telas (home, equipes, planos, torcedores)
└── database/             # Scripts SQL (schema, seed, reset)
```

## Tecnologias

| Camada   | Stack                              |
|----------|------------------------------------|
| Backend  | Node.js, Express, PostgreSQL, `pg` |
| Mobile   | Flutter 3.x, Material Design 3     |
| Database | PostgreSQL 14+, UUID como PK       |

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

## API Endpoints

Base URL: `http://localhost:3000/api`

### Equipes

| Método   | Rota              | Descrição                |
|----------|--------------------|--------------------------|
| `GET`    | `/equipes`         | Listar todas             |
| `GET`    | `/equipes/:id`     | Buscar por ID (+ planos) |
| `POST`   | `/equipes`         | Criar (com planos)       |
| `PUT`    | `/equipes/:id`     | Atualizar (com planos)   |
| `DELETE` | `/equipes/:id`     | Excluir (cascade)        |

### Planos

| Método   | Rota                          | Descrição                  |
|----------|-------------------------------|----------------------------|
| `GET`    | `/planos`                     | Listar todos               |
| `GET`    | `/planos?equipe_id=<uuid>`    | Filtrar por equipe         |
| `GET`    | `/planos/:id`                 | Buscar por ID              |
| `POST`   | `/planos`                     | Criar                      |
| `PUT`    | `/planos/:id`                 | Atualizar                  |
| `DELETE` | `/planos/:id`                 | Excluir                    |

### Torcedores

| Método   | Rota                                    | Descrição           |
|----------|-----------------------------------------|----------------------|
| `GET`    | `/torcedores`                           | Listar todos         |
| `GET`    | `/torcedores/:id`                       | Buscar por ID        |
| `GET`    | `/torcedores/verificar-cpf?cpf=<cpf>`   | Verificar CPF único  |
| `POST`   | `/torcedores`                           | Criar                |
| `PUT`    | `/torcedores/:id`                       | Atualizar            |
| `DELETE` | `/torcedores/:id`                       | Excluir              |

### Health Check

| Método | Rota      | Descrição         |
|--------|-----------|-------------------|
| `GET`  | `/health` | Status da API     |


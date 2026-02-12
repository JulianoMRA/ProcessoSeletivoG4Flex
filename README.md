# Fala, Torcedor! ⚽

Sistema de gestão de sócios-torcedores para clubes de futebol.

## Estrutura do Projeto

```
ProcessoSeletivoG4Flex/
├── backend/              # API Node.js + Express + PostgreSQL
├── mobile/               # App Flutter (Android/iOS)
└── database/             # Scripts SQL (schema, seed, reset)
```

## Tecnologias

### Backend
- **Node.js** + Express
- **PostgreSQL** (nativo)
- API RESTful

### Mobile
- **Flutter** 3.x
- Material Design 3
- Arquitetura MVC

### Database
- **PostgreSQL** 14+
- UUID como PK
- Row Level Security (RLS)

## Como Executar

### Backend (em desenvolvimento)
```bash
cd backend
npm install
npm run dev
```

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

### Database
Execute os scripts na ordem:
1. `database/schema.sql` - Cria tabelas
2. `database/seed.sql` - Popula dados
3. `database/reset.sql` - Limpa banco (quando necessário)

## Funcionalidades

- ✅ CRUD de Equipes (Série A, B, C, D)
- ✅ CRUD de Torcedores (CPF, data nascimento)
- ✅ CRUD de Planos (com valor mensal)
- ✅ Filtros e ordenação avançados
- ✅ Validação de CPF único
- ✅ UI moderna e minimalista

## Entidades

- **Equipes**: Clubes de futebol com séries
- **Planos**: 3 planos de sócio por equipe (com valor R$)
- **Torcedores**: Sócios vinculados a equipe e plano

## Fase Atual

**Fase 2**: Migração de Supabase para backend próprio ✨

# Banco de Dados - Fala Torcedor!

## Estrutura

### Tabela: equipes
Armazena informações das equipes de futebol.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | SERIAL | Identificador único |
| nome | VARCHAR(100) | Nome da equipe |
| serie | VARCHAR(10) | Divisão do clube (Série A, B, C ou D) |
| quantidade_socios | INTEGER | Quantidade de sócios-torcedores |
| planos_socio | plano_socio[] | Array com os planos oferecidos (padrão: todos os 3) |

### Tabela: torcedores
Armazena informações dos torcedores cadastrados.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | SERIAL | Identificador único |
| nome | VARCHAR(100) | Nome do torcedor (obrigatório) |
| cpf | VARCHAR(11) | CPF (apenas números, único) |
| data_nascimento | DATE | Data de nascimento |
| equipe_id | INTEGER | Referência para equipes.id |
| plano_socio | plano_socio | Plano assinado (ENUM: Sócio Prata, Sócio Ouro ou Sócio Diamante) |

## Tipo ENUM: plano_socio

Definido como tipo personalizado no PostgreSQL para garantir consistência:

```sql
CREATE TYPE plano_socio AS ENUM ('Sócio Prata', 'Sócio Ouro', 'Sócio Diamante');
```

**Vantagens**:
- Validação automática dos valores
- Melhor performance que VARCHAR
- Impossível inserir valores inválidos

## Planos de Sócio

Os planos disponíveis são:
- **Sócio Prata** (cor: #C0C0C0 - Cinza)
- **Sócio Ouro** (cor: #FFD700 - Dourado)
- **Sócio Diamante** (cor: #4169E1 - Azul)

Cada equipe, por padrão, oferece os 3 planos. O torcedor escolhe um ao se cadastrar.


## Como Executar

### 1. Criar o banco de dados e tabelas
```bash
psql -U postgres -f schema.sql
```

### 2. Popular com dados de teste
```bash
psql -U postgres -d fala_torcedor -f seeds.sql
```

### 3. Conectar ao banco
```bash
psql -U postgres -d fala_torcedor
```

### 4. Comandos úteis no psql
```sql
-- Listar tabelas
\dt

-- Descrever estrutura de uma tabela
\d equipes
\d torcedores

-- Consultar dados
SELECT * FROM equipes;
SELECT * FROM torcedores;

-- Sair do psql
\q
```

## Validações

### Tabela equipes
- `nome`: obrigatório
- `serie`: deve ser 'Série A', 'Série B', 'Série C' ou 'Série D'
- `quantidade_socios`: não pode ser negativo

### Tabela torcedores
- `nome`: obrigatório
- `cpf`: obrigatório, único, deve ter exatamente 11 caracteres
- `data_nascimento`: deve ser anterior à data atual
- `equipe_id`: deve existir na tabela equipes
- `plano_socio`: deve ser um dos valores do ENUM ('Sócio Prata', 'Sócio Ouro', 'Sócio Diamante')

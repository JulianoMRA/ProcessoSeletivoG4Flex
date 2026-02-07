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
| planos_socio | JSONB | Array com 3 planos: Prata, Ouro, Diamante |
| criado_em | TIMESTAMP | Data/hora de criação |
| atualizado_em | TIMESTAMP | Data/hora da última atualização |

### Tabela: torcedores
Armazena informações dos torcedores cadastrados.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | SERIAL | Identificador único |
| nome | VARCHAR(100) | Nome do torcedor |
| cpf | VARCHAR(11) | CPF (apenas números, único) |
| data_nascimento | DATE | Data de nascimento |
| equipe_id | INTEGER | Referência para equipes.id |
| plano_socio | VARCHAR(50) | Plano assinado (Prata, Ouro ou Diamante) |
| criado_em | TIMESTAMP | Data/hora de criação |
| atualizado_em | TIMESTAMP | Data/hora da última atualização |

## Planos de Sócio

| Plano | Cor | Benefícios |
|-------|-----|------------|
| Prata | Cinza (#C0C0C0) | Desconto de 10%, Prioridade na compra de ingressos |
| Ouro | Dourado (#FFD700) | Desconto de 20%, Acesso prioritário, Brinde exclusivo |
| Diamante | Azul (#4169E1) | Desconto de 30%, Acesso VIP, Meet & Greet |

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

## Relacionamentos

- Um torcedor pertence a **uma** equipe (equipe_id)
- Uma equipe pode ter **vários** torcedores
- Se uma equipe for excluída, seus torcedores também são excluídos (CASCADE)

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
- `plano_socio`: deve ser 'Prata', 'Ouro' ou 'Diamante'

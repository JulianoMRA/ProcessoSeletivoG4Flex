-- Database: fala_torcedor
-- Criação das tabelas para o sistema CRUD
-- Remover database se já existir (cuidado em produção!)
DROP DATABASE IF EXISTS fala_torcedor;
-- Criar database
CREATE DATABASE fala_torcedor WITH ENCODING = 'UTF8' LC_COLLATE = 'Portuguese_Brazil.1252' LC_CTYPE = 'Portuguese_Brazil.1252';
-- Conectar ao database
\ c fala_torcedor;
-- Tabela: equipes
CREATE TABLE equipes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    serie VARCHAR(10) NOT NULL CHECK (
        serie IN ('Série A', 'Série B', 'Série C', 'Série D')
    ),
    quantidade_socios INTEGER DEFAULT 0 CHECK (quantidade_socios >= 0),
    planos_socio JSONB NOT NULL DEFAULT '[
        {"nome": "Prata", "cor": "#C0C0C0", "beneficios": ["Desconto de 10% em produtos", "Prioridade na compra de ingressos"]},
        {"nome": "Ouro", "cor": "#FFD700", "beneficios": ["Desconto de 20% em produtos", "Acesso prioritário ao estádio", "Brinde exclusivo"]},
        {"nome": "Diamante", "cor": "#4169E1", "beneficios": ["Desconto de 30% em produtos", "Acesso VIP", "Meet & Greet com jogadores"]}
    ]'::jsonb,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Tabela: torcedores
CREATE TABLE torcedores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL CHECK (LENGTH(cpf) = 11),
    data_nascimento DATE NOT NULL CHECK (data_nascimento < CURRENT_DATE),
    equipe_id INTEGER NOT NULL REFERENCES equipes(id) ON DELETE CASCADE,
    plano_socio VARCHAR(50) NOT NULL CHECK (plano_socio IN ('Prata', 'Ouro', 'Diamante')),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Índices para melhorar performance
CREATE INDEX idx_torcedores_equipe_id ON torcedores(equipe_id);
CREATE INDEX idx_torcedores_cpf ON torcedores(cpf);
-- Função para atualizar automaticamente o campo atualizado_em
CREATE OR REPLACE FUNCTION atualizar_timestamp() RETURNS TRIGGER AS $$ BEGIN NEW.atualizado_em = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Triggers para atualizar timestamp
CREATE TRIGGER trigger_atualizar_equipes BEFORE
UPDATE ON equipes FOR EACH ROW EXECUTE FUNCTION atualizar_timestamp();
CREATE TRIGGER trigger_atualizar_torcedores BEFORE
UPDATE ON torcedores FOR EACH ROW EXECUTE FUNCTION atualizar_timestamp();
-- Comentários nas tabelas
COMMENT ON TABLE equipes IS 'Armazena informações das equipes de futebol';
COMMENT ON TABLE torcedores IS 'Armazena informações dos torcedores cadastrados';
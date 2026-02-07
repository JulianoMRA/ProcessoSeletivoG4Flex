-- Database: fala_torcedor
-- Criação das tabelas para o sistema CRUD
DROP TABLE IF EXISTS torcedores CASCADE;
DROP TABLE IF EXISTS equipes CASCADE;
DROP TYPE IF EXISTS plano_socio CASCADE;
-- Tipo ENUM para planos de sócio
CREATE TYPE plano_socio AS ENUM ('Sócio Prata', 'Sócio Ouro', 'Sócio Diamante');
-- Tabela: equipes
CREATE TABLE equipes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    serie VARCHAR(10) NOT NULL CHECK (
        serie IN ('Série A', 'Série B', 'Série C', 'Série D')
    ),
    quantidade_socios INTEGER DEFAULT 0 CHECK (quantidade_socios >= 0),
    planos_socio plano_socio [] NOT NULL DEFAULT ARRAY ['Sócio Prata'::plano_socio, 'Sócio Ouro'::plano_socio, 'Sócio Diamante'::plano_socio]
);
-- Tabela: torcedores
CREATE TABLE torcedores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL CHECK (LENGTH(cpf) = 11),
    data_nascimento DATE NOT NULL CHECK (data_nascimento < CURRENT_DATE),
    equipe_id INTEGER NOT NULL REFERENCES equipes(id) ON DELETE CASCADE,
    plano_socio plano_socio NOT NULL
);
-- Índices para melhorar performance
CREATE INDEX idx_torcedores_equipe_id ON torcedores(equipe_id);
CREATE INDEX idx_torcedores_cpf ON torcedores(cpf);
-- Comentários nas tabelas
COMMENT ON TABLE equipes IS 'Armazena informações das equipes de futebol';
COMMENT ON TABLE torcedores IS 'Armazena informações dos torcedores cadastrados';
COMMENT ON TYPE plano_socio IS 'Tipos de planos de sócio disponíveis';
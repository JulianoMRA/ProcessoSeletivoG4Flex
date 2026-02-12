-- ============================================
-- RESET: Limpar todo o banco "Fala, Torcedor!"
-- Executar no Supabase SQL Editor
-- ============================================
-- Deletar dados (ordem inversa por causa das FKs)
DELETE FROM torcedores;
DELETE FROM planos;
DELETE FROM equipes;
-- ============================================
-- ALTERNATIVA: Dropar e recriar tabelas
-- (Use apenas se quiser resetar estrutura também)
-- ============================================
-- DROP TABLE IF EXISTS torcedores CASCADE;
-- DROP TABLE IF EXISTS planos CASCADE;
-- DROP TABLE IF EXISTS equipes CASCADE;
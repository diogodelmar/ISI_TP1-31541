-- 1. Criação do Esquema e Tabela de Auditoria 
-- Tabela: auditoria_frota na base de dados isi_frota

-- 2. Consulta da Tabela de Auditoria
SELECT 
  data, 
  matricula, 
  marca, 
  modelo, 
  km_percorridos, 
  litros, 
  valor_total, 
  ROUND(preco_litro::numeric, 2) AS preco_litro, 
  ROUND(consumo_real::numeric, 2) AS consumo_real, 
  consumo_fabrica, 
  ROUND(desvio_consumo_pct::numeric, 2) AS desvio_pct
FROM auditoria_frota
ORDER BY data DESC;

-- 3. Análise de Desvios Operacionais face ao Consumo Homologado
SELECT 
  matricula || ' (' || modelo || ')' AS viatura, 
  ROUND(desvio_consumo_pct::numeric, 2) AS desvio_consumo_pct
FROM auditoria_frota
ORDER BY desvio_consumo_pct DESC;

-- 4. Métricas de Topo da Frota 
-- Gasto Total em Combustível (€)
SELECT SUM(valor_total) AS total_gasto_eur 
FROM auditoria_frota;

-- Quilómetros Totais 
SELECT SUM(km_percorridos) AS total_km 
FROM auditoria_frota;

-- Média de Consumo Real da Frota (L/100 km)
SELECT ROUND(AVG(consumo_real)::numeric, 2) AS consumo_medio_frota 
FROM auditoria_frota;
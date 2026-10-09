-- 1. Queries utilizadas no Grafana

-- 2. Auditoria de Custos
SELECT
  TO_CHAR(data::date, 'DD/MM/YYYY') AS data,
  matricula,
  combustivel,
  litros,
  ROUND(valor_total::numeric, 2) AS valor_pago,
  ROUND(preco_litro::numeric, 3) AS preco_pago_litro,
  ROUND(avg_price_eurs::numeric, 3) AS referencia_api_litro,
  ROUND(diferenca_custo::numeric, 2) AS diferenca_eur
FROM public.auditoria_frota
ORDER BY data::date DESC, id_abastecimento DESC;


-- 3. Auditoria de Consumos
SELECT
  TO_CHAR(data::date, 'DD/MM/YYYY') AS data,
  matricula,
  modelo,
  km_percorridos,
  litros,
  ROUND(consumo_real::numeric, 2) AS consumo_real,
  ROUND(consumo_fabrica::numeric, 2) AS consumo_fabrica,
  ROUND(desvio_consumo_pct::numeric, 2) AS desvio_pct
FROM public.auditoria_frota
ORDER BY data::date DESC, id_abastecimento DESC;


-- 4. Gráfico de Desvios de Consumo por Abastecimento
SELECT
  matricula || ' | ' ||
  TO_CHAR(data::date, 'DD/MM') ||
  ' | ' || modelo AS metric,
  ROUND(desvio_consumo_pct::numeric, 2) AS desvio_pct
FROM public.auditoria_frota
ORDER BY data::date, matricula;


-- 5. Gráfico de Diferenças de Custo face à Referência da API
SELECT
  matricula || ' | ' ||
  TO_CHAR(data::date, 'DD/MM') AS abastecimento,
  ROUND(diferenca_custo::numeric, 2) AS diferenca_eur
FROM public.auditoria_frota
ORDER BY data::date, id_abastecimento;


-- 6. Gasto Total em Combustível (€)
SELECT
  ROUND(SUM(valor_total)::numeric, 2) AS total_gasto_eur
FROM public.auditoria_frota;


-- 7. Quilómetros Totais
SELECT
  SUM(km_percorridos) AS total_km
FROM public.auditoria_frota;


-- 8. Consumo Global da Frota (L/100 km)
SELECT
  ROUND(
    (100.0 * SUM(litros) /
      NULLIF(SUM(km_percorridos), 0))::numeric,
    2
  ) AS consumo_global
FROM public.auditoria_frota;


-- 9. Abastecimentos com Desvio Superior a 30%
SELECT
  COUNT(*) FILTER (
    WHERE desvio_consumo_pct > 30
  ) AS abastecimentos_em_alerta
FROM public.auditoria_frota;


-- 10. Referência de Mercado — API
SELECT DISTINCT
  TO_CHAR(data_referencia_api::date, 'DD/MM/YYYY')
    AS "Data da cotação",
  combustivel AS "Combustível",
  ROUND(avg_price_eurs::numeric, 3)
    AS "Referência (€/L)"
FROM public.auditoria_frota
ORDER BY "Combustível";


-- 11. Resumo por Marca e Combustível
SELECT
  marca,
  combustivel,
  ROUND(SUM(litros)::numeric, 2) AS total_litros,
  ROUND(SUM(valor_total)::numeric, 2) AS total_gasto_eur
FROM public.auditoria_frota
GROUP BY marca, combustivel
ORDER BY marca, combustivel;
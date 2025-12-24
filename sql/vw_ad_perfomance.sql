CREATE OR REPLACE VIEW `marklt_bi_analysis.vw_ad_performance` AS
SELECT
  ad.ad_id,
  ad.category,
  ad.title,
  ad.price,
  ad.posted_date,
  ad.sold_date,
  -- Cálculo automático de dias para venda (Business Logic)
  DATE_DIFF(ad.sold_date, ad.posted_date, DAY) as days_to_sell,
  -- Categorização simples para o gráfico
  CASE 
    WHEN DATE_DIFF(ad.sold_date, ad.posted_date, DAY) <= 7 THEN 'Venda Rápida (1 semana)'
    WHEN DATE_DIFF(ad.sold_date, ad.posted_date, DAY) <= 30 THEN 'Venda Mensal (1 mês)'
    ELSE 'Venda Lenta (> 1 mês)'
  END as sales_speed_bucket
FROM
  `marklt_bi_analysis.ads` as ad
WHERE
  ad.status = 'Sold' -- Trazemos apenas o que foi vendido para calcular tempo médio real
  AND ad.sold_date IS NOT NULL;
CREATE OR REPLACE VIEW `marklt_bi_analysis.vw_search_conversion` AS
WITH UserSearches AS (
  -- Conta quantas pesquisas cada usuário fez
  SELECT 
    user_id, 
    COUNT(search_id) as total_searches,
    COUNT(DISTINCT search_query) as unique_terms_searched
  FROM `marklt_bi_analysis.searches`
  GROUP BY user_id
),
UserSales AS (
  -- Conta quantas compras cada usuário fez e o valor total gasto
  SELECT 
    buyer_id as user_id,
    COUNT(transaction_id) as total_purchases,
    SUM(amount) as total_spend
  FROM `marklt_bi_analysis.sales`
  GROUP BY buyer_id
)

SELECT
  u.user_id,
  -- Trazemos dados demográficos apenas se necessário (LGPD Compliance: sem nomes aqui)
  COALESCE(s.total_searches, 0) as num_searches,
  COALESCE(v.total_purchases, 0) as num_purchases,
  COALESCE(v.total_spend, 0) as total_spend,
  -- Cria uma flag para facilitar o gráfico no Power BI: "Comprou ou Só Olhou?"
  CASE 
    WHEN v.total_purchases > 0 THEN 'Comprador' 
    ELSE 'Apenas Visitante' 
  END as user_segment
FROM
  `marklt_bi_analysis.users` u
LEFT JOIN UserSearches s ON u.user_id = s.user_id
LEFT JOIN UserSales v ON u.user_id = v.user_id
WHERE s.total_searches > 0 OR v.total_purchases > 0; -- Remove usuários inativos
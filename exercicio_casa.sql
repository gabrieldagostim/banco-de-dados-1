--| Tabela                                          | Descrição                                               |
--| ----------------------------------------------- | ------------------------------------------------------- |
--| **Employees**                                   | Funcionários da empresa (nome, cargo, chefe, etc.)      |
--| **Categories**                                  | CategoriAS de produtos (ex: bebidAS, condimentos, etc.) |
--| **Customers**                                   | Clientes que fazem pedidos                              |
--| **Shippers**                                    | TransportadorAS que entregam os pedidos                 |
--| **Suppliers**                                   | Fornecedores dos produtos                               |
--| **Orders**                                      | Pedidos realizados pelos clientes                       |
--| **Order Details**                               | Itens de cada pedido (quantidade, preço, desconto)      |
--| **Products**                                    | Produtos vendidos                                       |
--| **Region**                                      | Regiões comerciais                                      |
--| **Territories**                                 | Territórios de vendAS                                   |
--| **EmployeeTerritories**                         | Relação entre funcionários e territórios                |
--| **CustomerDemographics / CustomerCustomerDemo** | Segmentação de clientes                                 |


-- ============================================
-- EXERCÍCIOS NORTHWIND - JOINS E FUNÇÕES
-- ============================================




-- 🧩 Nível 1 — JOINs básicos
--1) Liste o nome do cliente e o número do pedido de todos os pedidos realizados. (Customers + Orders)

-- Solução 1 
-- Todos os pedidos por cliente
SELECT
    c.CompanyName,
    count(OrderID)
FROM
    Orders o
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP BY
    c.CompanyName
ORDER BY 
    count(OrderID) DESC


-- Solução 2
-- Cliente e todos pedidos por numero
SELECT
    c.CompanyName,
    OrderID
FROM
    Orders o
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
ORDER BY
    CompanyName



--2) Mostre o nome do funcionário e a data do pedido de cada venda. (Employees + Orders)


SELECT
    concat(e.FirstName, ' ' , e.LAStName) AS nome_funcionario,
    o.OrderDate AS data_pedido_venda
FROM 
    Orders o
INNER JOIN Employees e
ON o.EmployeeID = e.EmployeeID
ORDER BY 
    concat(e.FirstName, ' ' , e.LAStName),o.OrderDate


--3) Exiba o nome do produto, o nome da categoria e o preço unitário. (Products + Categories)


SELECT
    p.ProductName,
    c.CategoryName
FROM
    Products p
INNER JOIN Categories c
ON c.CategoryID = p.CategoryID
ORDER BY
    c.CategoryName, p.ProductName
    


-- ==============================================================
-- EXERCÍCIOS AVANÇADOS - NORTHWIND
-- Objetivo: praticar CTEs, WINDOW FUNCTIONS, subqueries correlacionadAS,
-- agregações condicionais, PIVOT/UNPIVOT, rolling windows, e estratégiAS de JOIN.
-- Cole e rode um por vez no SSMS (USE Northwind;).
-- ==============================================================


-- 1) Por cliente, liste o total de pedidos, soma do valor total (OrderDetails) e a média do ticket.
-- Ordene pelo valor total decrescente e traga apenAS clientes com pelo menos 5 pedidos.
WITH 
tot_pedido AS (
    SELECT ord.OrderID,
           SUM(
                (ord.UnitPrice * ord.Quantity) - ((ord.UnitPrice * ord.Quantity) * ord.discount)
              ) AS tot_order,
           AVG(
                (ord.UnitPrice * ord.Quantity) - ((ord.UnitPrice * ord.Quantity) * ord.discount)
              ) AS med_ticket
      FROM orderdetails ord
     GROUP BY ord.OrderID

),
tot_cli AS (
    SELECT o.CustomerID, 
           ROUND(SUM(tot_order),2) AS total_pedido,
           ROUND(AVG(med_ticket),2) AS ticket_medio,
           COUNT(DISTINCT tp.OrderID) AS qty_ped
      FROM tot_pedido AS tp
     INNER JOIN orders o
        ON tp.OrderID = o.OrderID
     GROUP BY o.CustomerID
    HAVING COUNT(DISTINCT tp.OrderID) >= 5
     
)
SELECT *
  FROM tot_cli
 ORDER BY total_pedido DESC
 





-- 2) Para cada funcionário (Employee), calcule o faturamento mensal dos últimos 12 meses.
-- Exiba EmployeeID, YearMonth (YYYYMM), soma_valor, e preencher meses sem vendAS com 0
-- (use CTE de datas ou tabela auxiliar de calendário).

WITH
meses_pedd AS (
    SELECT DISTINCT TOP 12 FORMAT(o.orderdate, 'yyyyMM') AS a_m_ped
      FROM orders o
     ORDER BY FORMAT(o.orderdate, 'yyyyMM') DESC
),
meses_func AS (
    SELECT a_m_ped,
           employeeid AS func,
           CONCAT(e.titleofcourtesy,e.firstname,' ', e.lastname) AS nfunc
      FROM employees e
     CROSS JOIN meses_pedd
),
tot_pedido AS (
    SELECT mf.func,
           mf.a_m_ped AS ano_mes,
           CASE 
                WHEN ROUND(SUM((ord.unitprice * ord.quantity) - ((ord.unitprice * ord.quantity) * ord.discount)),2) IS NULL THEN 0 
                ELSE ROUND(SUM((ord.unitprice * ord.quantity) - ((ord.unitprice * ord.quantity) * ord.discount)),2)
           END AS tot_order
      FROM meses_func mf
      LEFT JOIN orders o
        ON mf.func = o.employeeid and FORMAT(o.orderdate, 'yyyyMM') = mf.a_m_ped
      LEFT JOIN orderdetails ord
        ON o.orderid = ord.orderid
     GROUP BY mf.func, mf.a_m_ped
)
SELECT *
  FROM tot_pedido
 ORDER BY ano_mes ASC





-- 3) Encontre os 3 produtos com maior crescimento percentual de vendas em quantidade:
-- compare soma(Qty) nos últimos 90 dias vs 90-180 dias (periodo rolling). Exibir produto, qtd_ult90, qtd_prev90, pct_crescimento.


SELECT od.productid as codigo,
       p.ProductName as descricao,
       CONCAT(c.categoryid,' - ',c.categoryname) as categoria,
       MAX(p.unitsinstock) as saldo,
       SUM(CASE WHEN o.orderdate >= DATEADD(day, -30, '1998-05-06') THEN od.quantity ELSE 0 END) AS vd_30,
       SUM(CASE WHEN o.orderdate >= DATEADD(day, -60, '1998-05-06') THEN od.quantity ELSE 0 END) AS vd_60,
       SUM(CASE WHEN o.orderdate >= DATEADD(day, -90, '1998-05-06') THEN od.quantity ELSE 0 END) AS vd_90,
       (
           (
                ((SUM(CASE WHEN o.orderdate >= DATEADD(day, -60, '1998-05-06') THEN od.quantity ELSE 0 END) * 1.0) / 60) / 
                NULLIF(((SUM(CASE WHEN o.orderdate >= DATEADD(day, -90, '1998-05-06') THEN od.quantity ELSE 0 END) * 1.0) / 90), 0 )
           ) - 1
       ) AS pct_cresc

  FROM orders o 
 INNER JOIN orderdetails od
    ON o.orderid = od.orderid
 INNER JOIN products p
    ON od.productid = p.productid
 INNER JOIN categories c
    ON p.categoryid = c.categoryid
 WHERE p.discontinued = 0
 GROUP BY od.productid, p.ProductName, CONCAT(c.categoryid,' - ',c.categoryname)
 ORDER BY (
           (
                ((SUM(CASE WHEN o.orderdate >= DATEADD(day, -60, '1998-05-06') THEN od.quantity ELSE 0 END) * 1.0) / 60) / 
                NULLIF(((SUM(CASE WHEN o.orderdate >= DATEADD(day, -90, '1998-05-06') THEN od.quantity ELSE 0 END) * 1.0) / 90), 0 )
           ) - 1
       ) DESC
 

-- 4) Para cada categoria, liste o produto que mais contribuiu para a receita da categoria
-- (Revenue = UnitPriceQuantity(1-Discount)). Mostre CategoryID, CategoryName, ProductID, ProductName, revenue_produto, pct_part_categoria.



SELECT * FROM products
SELECT * FROM categories
SELECT * FROM orderdetails
SELECT * FROM orders o
SELECT * FROM employees



-- 5) Detecte "clientes inativos": clientes que compraram no período 2018-2019 mAS não compraram em 2020.
-- Retorne CustomerID, Nome, data_ultima_compra_2019.




-- 6) Calcule LIFETIME VALUE estimado por cliente: soma de todos os pagamentos / número de anos ativos (ano primeira compra → ano última compra + 1).
-- Exiba top 10 clientes por LTV.




-- 7) ABC de produtos por receita (A = top 70% acumulado, B = 70-90%, C = restante).
-- Use SUM + PARTITION ORDER BY revenue DESC e cálculo de acumulado/percentual. Traga a clASse ABC para cada produto.




-- 8) Para cada order, liste os itens e a posição do item no pedido (ordenado por UnitPrice desc).
-- Use ROW_NUMBER() OVER(PARTITION BY OrderID ORDER BY UnitPrice DESC).




-- 9) Calcule a taxa de desconto média por fornecedor (Supplier). Considere o desconto ponderado por quantidade:
-- SUM(Discount * Quantity * UnitPrice) / SUM(Quantity * UnitPrice).




-- 10) Crie uma CTE que retorne, por mês, quantos produtos ficaram sem vendAS naquele mês (zero vendAS).
-- Use calendar CTE e LEFT JOIN em OrderDetails/Orders.




-- 11) Para cada cliente, determine o tempo médio entre pedidos (em diAS) usando LAG() e média dAS diferençAS.
-- Exiba CustomerID, avg_diAS_entre_pedidos, total_pedidos.




-- 12) Identifique produtos com vendAS altamente sazonais:
-- calcule coeficiente de variação (STDEV/AVG) da venda mensal (últimos 24 meses) e liste top 10 produtos com maior CV.




-- 13) Para cada região (ShipRegion ou Country), calcule regressão linear simples (slope) de faturamento mensal nos últimos 24 meses.
-- (Se não houver função de regressão, calcule cov(X,Y)/var(X) com X = mês_numérico, Y = faturamento).




-- 14) Reescreva a seguinte necessidade como consulta: "Para cada cliente, encontre o produto que foi comprado com menor frequência mAS com maior ticket médio."
-- Resultado: CustomerID, ProductID, comprAS_qtd, ticket_medio, rank_por_cliente (ROW_NUMBER over order by comprAS_qtd ASc, ticket_medio desc).




-- 15) Pivot de vendAS por trimestre por categoria:
-- colunAS: CategoryName, Q1_YYYY, Q2_YYYY, Q3_YYYY, Q4_YYYY (para um ano especificado). Use PIVOT.




-- 16) Identifique anomaliAS de preço: produtos cujo UnitPrice médio em um mês varia mais de 3 desvios padrão do preço médio histórico.
-- Exiba ProductID, MesAno, avg_mes, avg_historico, stdev_historico, zscore.




-- 17) Monte um relatório por pedido que apresenta:
-- OrderID, CustomerID, OrderDate, total_order, rank_item_mais_caro_por_pedido, percentual_do_item_mais_caro_no_pedido.




-- 18) Realize um JOIN entre Orders e uma subquery que retorna, por cliente, o valor médio do ticket dos últimos 6 meses;
-- em seguida, calcule quantos pedidos de cada cliente no último mês estão acima de 120% do ticket médio dele.




-- 19) Utilize APPLY (CROSS APPLY / OUTER APPLY) para, por Order, trazer AS 2 últimAS entregAS (Orders shipped) da mesma CustomerID ordenadAS por ShippedDate DESC.




-- 20) Crie uma CTE "Rolling30" que calcula a soma móvel de vendAS (quantidade) dos últimos 30 diAS por produto, para cada dia do calendário.
-- Em seguida, encontre os diAS em que a soma_movel aumentou mais de 50% em relação ao dia anterior (sinal de spike).




-- 21) (Bônus ETL dentro do SQL) Simule deduplicação: a partir de uma tabela staging (Orders_Staging) com possíveis duplicatAS (mesmo CustomerID, OrderDate, ShipAddress),
-- escreva query que identifique duplicatAS e gere um conjunto de INSERTs para Orders (apenAS registros únicos), preservando o maior OrderID da staging como chave.




-- 22) (Bônus Performance) Indique quais colunAS seriam indexadAS e por quê para otimizar a query do exercício 3 (crescimento percentual dos últimos 90 diAS).
-- Escreva o comando CREATE INDEX sugerido (apenAS sintaxe).




-- ==============================================================
-- Observação: cada exercício exige pensar em:
-- - qual CTE criar (aggregação, calendar, ranking),
-- - quais funções de janela usar (ROW_NUMBER, RANK, LAG, LEAD, SUM() OVER),
-- - como evitar duplicidade por JOINs (usar keys clarAS),
-- - como tratar meses sem dados (calendar/cte de datAS),
-- - e quando usar índices / temp tables para performance.
-- ==============================================================
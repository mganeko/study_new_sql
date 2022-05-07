

-- products --
CREATE TABLE Product (
  id INTEGER NOT NULL,
  name VARCHAR(20) NOT NULL,
  price INTEGER,
  PRIMARY KEY (id)
);

-- daily sales ---
CREATE TABLE Sales (
  sales_date DATE NOT NULL,
  product_id INTEGER NOT NULL,
  amount INTEGER NOT NULL,
  PRIMARY KEY (sales_date, amount)
);


-- init data --
INSERT INTO Product (id, name, price) VALUES
  (1, 'テーブル', 98000),
  (2, '椅子', 49000),
  (3, 'スツール', 19000),
  (4, '棚', 78000)
;

INSERT INTO Sales (sales_date, product_id, amount) VALUES
  ('2022-04-01', 1, 1),
  ('2022-04-01', 2, 2),

  ('2022-04-05', 4, 1),

  ('2022-04-10', 1, 1),
  ('2022-04-10', 3, 4)
;

-- JOIN --
SELECT * FROM Sales AS s JOIN Product AS p ON s.product_id = p.id;

-- SUB QUERY --
SELECT sales_date, SUM(price) AS daily_sales FROM (
  SELECT * FROM Sales AS s JOIN Product AS p ON s.product_id = p.id
) AS daily_sales
GROUP BY sales_date;

-- VIEW --
CREATE VIEW daily_view (sales_date, product_name, price, amout) AS
  SELECT s.sales_date, p.name, p.price, s.amount FROM Sales AS s JOIN Product AS p ON s.product_id = p.id
;

SELECT * from daily_view;

SELECT sales_date, SUM(price) AS daily_sales FROM daily_view
 GROUP BY sales_date;


-- WITH --
WITH day_sales AS (
  SELECT s.sales_date, p.name, p.price, s.amount FROM Sales AS s JOIN Product AS p ON s.product_id = p.id
)
SELECT * FROM day_sales;

WITH day_sales AS (
  SELECT s.sales_date, p.name, p.price, s.amount FROM Sales AS s JOIN Product AS p ON s.product_id = p.id
)
SELECT sales_date, SUM(price) AS daily_sales FROM day_sales
 GROUP BY sales_date;



WITH day_sales(sales_date, name, price, amount) AS (
  SELECT s.sales_date, p.name, p.price, s.amount FROM Sales AS s JOIN Product AS p ON s.product_id = p.id
)
SELECT sales_date, SUM(price) AS daily_sales FROM day_sales
 GROUP BY sales_date;
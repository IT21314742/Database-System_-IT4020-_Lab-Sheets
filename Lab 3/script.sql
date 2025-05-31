-- Address type
CREATE TYPE address_t AS OBJECT (
  street_no    VARCHAR2(10),
  street_name  VARCHAR2(50),
  suburb       VARCHAR2(30),
  state        CHAR(3),
  pin          VARCHAR2(10)
);
/

-- Investment type
CREATE TYPE investment_t AS OBJECT (
  company      VARCHAR2(20),
  purchase_price NUMBER(8,2),
  purchase_date DATE,
  qty          NUMBER(6)
);
/


-- Investments nested table type
CREATE TYPE investments_nt AS TABLE OF investment_t;
/

-- Client type
CREATE TYPE client_t AS OBJECT (
  firstname    VARCHAR2(20),
  lastname     VARCHAR2(20),
  address      address_t,
  investments  investments_nt
);
/

-- Clients table
CREATE TABLE clients_tab OF client_t (
  PRIMARY KEY (firstname, lastname)  -- or you could use client_no if needed
) NESTED TABLE investments STORE AS investments_store;
/

-- VARRAY for exchanges
CREATE TYPE exchanges_varray AS VARRAY(3) OF VARCHAR2(20);
/

-- Stock type
CREATE TYPE stock_t AS OBJECT (
  company       VARCHAR2(20),
  current_price NUMBER(8,2),
  exchanges     exchanges_varray,
  last_dividend NUMBER(8,2),
  earnings_per_share NUMBER(8,2)
);
/

-- Stocks table
CREATE TABLE stocks_tab OF stock_t (
  PRIMARY KEY (company)
);
/


--DATA INSERT

-- John Smith
INSERT INTO clients_tab VALUES (
  'John', 
  'Smith', 
  address_t('3', 'East Av', 'Bentley', 'WA', '6102'), 
  investments_nt(
    investment_t('BHP', 12.00, TO_DATE('02/10/2001','DD/MM/YYYY'), 1000),
    investment_t('BHP', 10.50, TO_DATE('08/06/2002','DD/MM/YYYY'), 2000),
    investment_t('IBM', 58.00, TO_DATE('12/02/2000','DD/MM/YYYY'), 500),
    investment_t('IBM', 65.00, TO_DATE('10/04/2001','DD/MM/YYYY'), 1200),
    investment_t('INFOSYS', 64.00, TO_DATE('11/08/2001','DD/MM/YYYY'), 1000)
  )
);
/

-- Jill Brody
INSERT INTO clients_tab VALUES (
  'Jill', 
  'Brody', 
  address_t('42', 'Bent St', 'Perth', 'WA', '6001'), 
  investments_nt(
    investment_t('INTEL', 35.00, TO_DATE('30/01/2000','DD/MM/YYYY'), 300),
    investment_t('INTEL', 54.00, TO_DATE('30/01/2001','DD/MM/YYYY'), 400),
    investment_t('INTEL', 60.00, TO_DATE('02/10/2001','DD/MM/YYYY'), 200),
    investment_t('FORD', 40.00, TO_DATE('05/10/1999','DD/MM/YYYY'), 300),
    investment_t('GM', 55.50, TO_DATE('12/12/2000','DD/MM/YYYY'), 500)
  )
);
/

--Insert into stocks_tab

-- BHP
INSERT INTO stocks_tab VALUES ('BHP', 10.50, exchanges_varray('Sydney','New York'), 1.50, 3.20);
/

-- IBM
INSERT INTO stocks_tab VALUES ('IBM', 70.00, exchanges_varray('New York','London','Tokyo'), 4.25, 10.00);
/

-- INTEL
INSERT INTO stocks_tab VALUES ('INTEL', 76.50, exchanges_varray('New York','London'), 5.00, 12.40);
/

-- FORD
INSERT INTO stocks_tab VALUES ('FORD', 40.00, exchanges_varray('New York'), 2.00, 8.50);
/

-- GM
INSERT INTO stocks_tab VALUES ('GM', 60.00, exchanges_varray('New York'), 2.50, 9.20);
/

-- INFOSYS
INSERT INTO stocks_tab VALUES ('INFOSYS', 45.00, exchanges_varray('New York'), 3.00, 7.80);
/

--3

--(a) For each client, get the client’s name, and the list of the client’s investments with stock name, current price, last dividend and earnings per share.

SELECT c.firstname || ' ' || c.lastname AS client_name,
       i.company AS stock_name,
       s.current_price,
       s.last_dividend,
       s.earnings_per_share
FROM clients_tab c,
     TABLE(c.investments) i,
     stocks_tab s
WHERE i.company = s.company
ORDER BY client_name
/

--(b) Get the list of all clients and their share investments, showing the client name, and for each stock held by the client, the name of the stock, total number of shares held, and the average purchase price paid by the client for the stock. Average price is the total purchase value paid by a client for a given stock (value=qty*price) divided by the total quantity held by the client.

SELECT c.firstname || ' ' || c.lastname AS client_name,
       i.company AS stock_name,
       SUM(i.qty) AS total_shares,
       ROUND(SUM(i.qty * i.purchase_price) / SUM(i.qty), 2) AS avg_purchase_price
FROM clients_tab c,
     TABLE(c.investments) i
GROUP BY c.firstname, c.lastname, i.company
ORDER BY client_name, stock_name
/

--(c) For each stock traded in New York, find the quantity held by each client, and its current value (value=qty*price). Display stock (company) name, client name, number of shares held, and the current value of the shares.

SELECT s.company AS stock_name,
       c.firstname || ' ' || c.lastname AS client_name,
       i.qty AS number_of_shares,
       ROUND(i.qty * s.current_price, 2) AS current_value
FROM clients_tab c,
     TABLE(c.investments) i,
     stocks_tab s
WHERE i.company = s.company
  AND 'New York' MEMBER OF (s.exchanges)
ORDER BY stock_name, client_name
/

--(d) Find the total purchase value of investments for all clients. Display client name and total purchase value of the client’s portfolio.

SELECT c.firstname || ' ' || c.lastname AS client_name,
       SUM(i.qty * i.purchase_price) AS total_purchase_value
FROM clients_tab c,
     TABLE(c.investments) i
GROUP BY c.firstname, c.lastname
ORDER BY client_name
/

--(e) For each client, list the book profit (or loss) on the total share investment. Book profit is the total value of all stocks based on the current prices less the total amount paid for purchasing them. 

SELECT c.firstname || ' ' || c.lastname AS client_name,
       ROUND(SUM(i.qty * s.current_price) - SUM(i.qty * i.purchase_price), 2) AS book_profit_or_loss
FROM clients_tab c,
     TABLE(c.investments) i,
     stocks_tab s
WHERE i.company = s.company
GROUP BY c.firstname, c.lastname
ORDER BY client_name
/


--4

--Remove INFOSYS investment from John

DELETE FROM TABLE (
  SELECT c.investments
  FROM clients_tab c
  WHERE c.firstname = 'John' AND c.lastname = 'Smith'
)
WHERE company = 'INFOSYS'
/


--Remove GM investment from Jill

DELETE FROM TABLE (
  SELECT c.investments
  FROM clients_tab c
  WHERE c.firstname = 'Jill' AND c.lastname = 'Brody'
)
WHERE company = 'GM'
/

--Insert INFOSYS investment to Jill

INSERT INTO TABLE (
  SELECT c.investments
  FROM clients_tab c
  WHERE c.firstname = 'Jill' AND c.lastname = 'Brody'
)
SELECT investment_t(
  'INFOSYS',
  (SELECT current_price FROM stocks_tab WHERE company = 'INFOSYS'),
  SYSDATE,   -- today's date
  1000       -- quantity
)
FROM dual
/


--Insert GM investment to John

INSERT INTO TABLE (
  SELECT c.investments
  FROM clients_tab c
  WHERE c.firstname = 'John' AND c.lastname = 'Smith'
)
SELECT investment_t(
  'GM',
  (SELECT current_price FROM stocks_tab WHERE company = 'GM'),
  SYSDATE,   -- today's date
  500        -- quantity
)
FROM dual
/
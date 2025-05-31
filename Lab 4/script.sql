-- drop existing stock_t
DROP TYPE stock_t FORCE;
/

-- Recreate stock_t with methods
CREATE OR REPLACE TYPE stock_t AS OBJECT (
  company              VARCHAR2(20),
  current_price        NUMBER(8,2),
  exchanges            exchanges_varray,
  last_dividend        NUMBER(8,2),
  earnings_per_share   NUMBER(8,2),

   -- Methods
  MEMBER FUNCTION get_yield RETURN NUMBER,
  MEMBER FUNCTION get_price_usd(rate NUMBER) RETURN NUMBER,
  MEMBER FUNCTION get_num_exchanges RETURN NUMBER
);




--  Implement the Methods

CREATE OR REPLACE TYPE BODY stock_t AS 
  MEMBER FUNCTION get_yield RETURN NUMBER IS
  BEGIN
    RETURN (last_dividend / current_price) * 100;
  END;

  MEMBER FUNCTION get_price_usd(rate NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN current_price * rate;
  END;

  MEMBER FUNCTION get_num_exchanges RETURN NUMBER IS
  BEGIN
    RETURN exchanges.COUNT;
  END;
END;
/


--  Modify client_t Type to Add Methods

DROP TYPE client_t FORCE;
/

-- Now recreate client_t with methods
CREATE OR REPLACE TYPE client_t AS OBJECT (
  firstname    VARCHAR2(20),
  lastname     VARCHAR2(20),
  address      address_t,
  investments  investments_nt,
  
  -- Methods
  MEMBER FUNCTION get_purchase_value RETURN NUMBER,
  MEMBER FUNCTION get_total_profit RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY client_t AS 
  MEMBER FUNCTION get_purchase_value RETURN NUMBER IS
    total NUMBER := 0;
  BEGIN
    FOR i IN 1 .. investments.COUNT LOOP
      total := total + (investments(i).purchase_price * investments(i).qty);
    END LOOP;
    RETURN total;
  END;

  MEMBER FUNCTION get_total_profit RETURN NUMBER IS
    total_profit NUMBER := 0;
    cp NUMBER;
  BEGIN
    FOR i IN 1 .. investments.COUNT LOOP
      SELECT s.current_price INTO cp
      FROM stocks_tab s
      WHERE s.company = investments(i).company;
      
      total_profit := total_profit + (cp - investments(i).purchase_price) * investments(i).qty;
    END LOOP;
    RETURN total_profit;
  END;
END;
/


CREATE OR REPLACE TYPE BODY client_t AS 
  MEMBER FUNCTION get_purchase_value RETURN NUMBER IS
    total NUMBER := 0;
  BEGIN
    FOR i IN 1 .. investments.COUNT LOOP
      total := total + (investments(i).purchase_price * investments(i).qty);
    END LOOP;
    RETURN total;
  END;

  MEMBER FUNCTION get_total_profit RETURN NUMBER IS
    total_profit NUMBER := 0;
    cp NUMBER;
  BEGIN
    FOR i IN 1 .. investments.COUNT LOOP
      SELECT s.current_price INTO cp
      FROM stocks_tab s
      WHERE s.company = investments(i).company;
      
      total_profit := total_profit + (cp - investments(i).purchase_price) * investments(i).qty;
    END LOOP;
    RETURN total_profit;
  END;
END;
/


--2

-- (a)

SELECT s.company,
       s.exchanges,
       s.get_yield() AS yield_percentage,
       s.get_price_usd(0.74) AS price_in_usd
FROM stocks_tab s
/


-- (b) 

SELECT s.company,
       s.current_price,
       s.get_num_exchanges() AS number_of_exchanges
FROM stocks_tab s
WHERE s.get_num_exchanges() > 1
/

-- (c)

SELECT c.firstname || ' ' || c.lastname AS client_name,
       i.company,
       s.get_yield() AS yield_percentage,
       s.current_price,
       s.earnings_per_share
FROM clients_tab c,
     TABLE(c.investments) i,
     stocks_tab s
WHERE i.company = s.company
ORDER BY client_name
/

-- (d)

SELECT c.firstname || ' ' || c.lastname AS client_name,
       c.get_purchase_value() AS total_purchase_value
FROM clients_tab c
/

-- (e)

SELECT c.firstname || ' ' || c.lastname AS client_name,
       c.get_total_profit() AS book_profit_or_loss
FROM clients_tab c
/
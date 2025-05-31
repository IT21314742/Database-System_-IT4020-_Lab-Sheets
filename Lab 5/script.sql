--Exercise 01

--  PL/SQL block to get the current price of IBM stock.

SET SERVEROUTPUT ON
/

DECLARE
  v_company_name VARCHAR2(20) := 'IBM';
  v_current_price NUMBER(8,2);
BEGIN
  SELECT s.current_price INTO v_current_price
  FROM stocks_tab s
  WHERE s.company = v_company_name;

  DBMS_OUTPUT.PUT_LINE('Current Price of ' || v_company_name || ' is ' || v_current_price);
END;
/

-- Exercise 02

-- Display a message for IBM current price based on given price ranges.


SET SERVEROUTPUT ON
/

DECLARE
  v_company_name VARCHAR2(20) := 'IBM';
  v_current_price NUMBER(8,2);
BEGIN
  SELECT s.current_price INTO v_current_price
  FROM stocks_tab s
  WHERE s.company = v_company_name;

  IF v_current_price < 45 THEN
    DBMS_OUTPUT.PUT_LINE('Current price is very low!');
  ELSIF v_current_price >= 45 AND v_current_price < 55 THEN
    DBMS_OUTPUT.PUT_LINE('Current price is low!');
  ELSIF v_current_price >= 55 AND v_current_price < 65 THEN
    DBMS_OUTPUT.PUT_LINE('Current price is medium!');
  ELSIF v_current_price >= 65 AND v_current_price < 75 THEN
    DBMS_OUTPUT.PUT_LINE('Current price is medium high!');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Current price is high!');
  END IF;
END;
/



-- Exercise 03

--Simplpe Loop

SET SERVEROUTPUT ON
/

DECLARE
  i NUMBER := 1;
BEGIN
  LOOP
    DBMS_OUTPUT.PUT_LINE(LPAD('*', i, '*'));
    i := i + 1;
    EXIT WHEN i > 5;
  END LOOP;
END;
/


-- While Loop

SET SERVEROUTPUT ON
/

DECLARE
  i NUMBER := 1;
BEGIN
  WHILE i <= 5 LOOP
    DBMS_OUTPUT.PUT_LINE(LPAD('*', i, '*'));
    i := i + 1;
  END LOOP;
END;
/


-- For Loop

SET SERVEROUTPUT ON
/

BEGIN
  FOR i IN 1..5 LOOP
    DBMS_OUTPUT.PUT_LINE(LPAD('*', i, '*'));
  END LOOP;
END;
/




-- Exercise 04

--Update purchase quantity bonus

SET SERVEROUTPUT ON
/

BEGIN
  FOR purchase_rec IN (
    SELECT p.company, p.purchase_date, p.qty
    FROM TABLE (
      SELECT c.investments
      FROM clients_tab c
    ) p
  ) LOOP
    IF purchase_rec.purchase_date < TO_DATE('01-JAN-2000', 'DD-MON-YYYY') THEN
      UPDATE TABLE (
        SELECT c.investments FROM clients_tab c
      ) p
      SET p.qty = p.qty + 150
      WHERE p.company = purchase_rec.company AND p.purchase_date = purchase_rec.purchase_date;
      
    ELSIF purchase_rec.purchase_date < TO_DATE('01-JAN-2001', 'DD-MON-YYYY') THEN
      UPDATE TABLE (
        SELECT c.investments FROM clients_tab c
      ) p
      SET p.qty = p.qty + 100
      WHERE p.company = purchase_rec.company AND p.purchase_date = purchase_rec.purchase_date;

    ELSIF purchase_rec.purchase_date < TO_DATE('01-JAN-2002', 'DD-MON-YYYY') THEN
      UPDATE TABLE (
        SELECT c.investments FROM clients_tab c
      ) p
      SET p.qty = p.qty + 50
      WHERE p.company = purchase_rec.company AND p.purchase_date = purchase_rec.purchase_date;
    END IF;
  END LOOP;
END;
/





-- Exercise 05

SET SERVEROUTPUT ON
/

DECLARE
  CURSOR purchase_cur IS
    SELECT p.company, p.purchase_date, p.qty
    FROM TABLE (
      SELECT c.investments
      FROM clients_tab c
    ) p;

  purchase_rec purchase_cur%ROWTYPE;
BEGIN
  OPEN purchase_cur;
  LOOP
    FETCH purchase_cur INTO purchase_rec;
    EXIT WHEN purchase_cur%NOTFOUND;

    IF purchase_rec.purchase_date < TO_DATE('01-JAN-2000', 'DD-MON-YYYY') THEN
      UPDATE TABLE (
        SELECT c.investments FROM clients_tab c
      ) p
      SET p.qty = p.qty + 150
      WHERE p.company = purchase_rec.company AND p.purchase_date = purchase_rec.purchase_date;

    ELSIF purchase_rec.purchase_date < TO_DATE('01-JAN-2001', 'DD-MON-YYYY') THEN
      UPDATE TABLE (
        SELECT c.investments FROM clients_tab c
      ) p
      SET p.qty = p.qty + 100
      WHERE p.company = purchase_rec.company AND p.purchase_date = purchase_rec.purchase_date;

    ELSIF purchase_rec.purchase_date < TO_DATE('01-JAN-2002', 'DD-MON-YYYY') THEN
      UPDATE TABLE (
        SELECT c.investments FROM clients_tab c
      ) p
      SET p.qty = p.qty + 50
      WHERE p.company = purchase_rec.company AND p.purchase_date = purchase_rec.purchase_date;
    END IF;

  END LOOP;
  CLOSE purchase_cur;
END;
/



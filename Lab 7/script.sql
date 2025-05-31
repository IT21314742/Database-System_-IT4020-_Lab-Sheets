-- Set the Optimizer Mode

ALTER SESSION SET OPTIMIZER_MODE = ALL_ROWS;
ALTER SESSION SET "_optimizer_cost_model" = CPU;


-- Create Tables and Load Sample Data

@Downloads/Prac07_supportfiles/SampleDB.sql


-- Create PLAN_TABLE

@Downloads/Prac07_supportfiles/UTLXPLAN.SQL


-- Execute the EXPLAIN PLAN

EXPLAIN PLAN FOR
SELECT c.clno, c.name
FROM client c, purch p
WHERE c.clno = p.clno
AND p.qty > 1000;


-- View the Query Plan

@Downloads/Prac07_supportfiles/utlxpls.sql


-- Create Indexes

-- Index on purchase (qty, clno)
CREATE INDEX idx_purch_qty_clno ON purch(qty, clno);

-- Index on client (clno, name)
CREATE INDEX idx_client_clno_name ON client(clno, name);


-- Rerun EXPLAIN PLAN

EXPLAIN PLAN FOR
SELECT c.clno, c.name
FROM client c, purch p
WHERE c.clno = p.clno
AND p.qty > 1000;


@Downloads/Prac07_supportfiles/utlxpls.sql



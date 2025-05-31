-- Create Table with XML Type

CREATE TABLE AdminDocs (
  id INT PRIMARY KEY,
  xDoc XMLTYPE NOT NULL
);
/


-- Insert XML Data

INSERT INTO AdminDocs VALUES (1, 
  XMLTYPE('
<catalog>
  <product dept="WMN">
    <number>557</number>
    <name language="en">Fleece Pullover</name>
    <colorChoices>navy black</colorChoices>
  </product>
  <product dept="ACC">
    <number>563</number>
    <name language="en">Floppy Sun Hat</name>
  </product>
  <product dept="ACC">
    <number>443</number>
    <name language="en">Deluxe Travel Bag</name>
  </product>
  <product dept="MEN">
    <number>784</number>
    <name language="en">Cotton Dress Shirt</name>
    <colorChoices>white gray</colorChoices>
    <desc>Our <i>favorite</i> shirt!</desc>
  </product>
</catalog>')
);
/

INSERT INTO AdminDocs VALUES (2, 
  XMLTYPE('
<doc id="123">
  <sections>
    <section num="1"><title>XML Schema</title></section>
    <section num="3"><title>Benefits</title></section>
    <section num="4"><title>Features</title></section>
  </sections>
</doc>')
);
/



-- XPath Queries

-- Get all products
SELECT id, xDoc.extract('/catalog/product') AS Products
FROM AdminDocs;
/

-- Get all products (anywhere)
SELECT id, xDoc.extract('//product') AS Products
FROM AdminDocs;
/

-- Get all products directly under root
SELECT id, xDoc.extract('/*/product') AS Products
FROM AdminDocs;
/

-- Get products from WMN department
SELECT id, xDoc.extract('/*/product[@dept="WMN"]') AS WMN_Products
FROM AdminDocs;
/

-- Using child and attribute
SELECT id, xDoc.extract('/*/child::product[attribute::dept="WMN"]') AS WMN_Products
FROM AdminDocs;
/

-- Products where number > 500
SELECT id, xDoc.extract('//product[number > 500]') AS ProductsOver500
FROM AdminDocs
WHERE id = 1;
/


-- Get the 4th product
SELECT id, xDoc.extract('/catalog/product[4]') AS FourthProduct
FROM AdminDocs
WHERE id = 1;
/



-- Step 3

-- Practice XQuery

-- List all product numbers
SELECT xDoc.query('
  for $prod in //product
  let $x := $prod/number
  return $x
') AS ProductNumbers
FROM AdminDocs
WHERE id = 1;
/

-- List product numbers > 500
SELECT xDoc.query('
  for $prod in //product
  let $x := $prod/number
  where $x > 500
  return $x
') AS ProductsAbove500
FROM AdminDocs
WHERE id = 1;
/

-- Return product numbers as <Item> tags
SELECT xDoc.query('
  for $prod in //product[number > 500]
  let $x := $prod/number
  return (<Item>{data($x)}</Item>)
') AS ProductItems
FROM AdminDocs
WHERE id = 1;
/

-- Conditional return (if-else)
SELECT xDoc.query('
  for $prod in //product
  let $x := $prod/number
  return if ($x > 500)
    then <book>{data($x)}</book>
    else <paper>{data($x)}</paper>
') AS ConditionalItems
FROM AdminDocs
WHERE id = 1;
/


-- Step 4

-- XML DML

UPDATE AdminDocs
SET xDoc = XMLQuery('
  copy $doc := $d
  modify insert <section num="2"><title>Background</title></section> after $doc//section[@num="1"][1]
  return $doc
' PASSING xDoc AS "d" RETURNING CONTENT)
WHERE id = 2;
/


-- Delete

UPDATE AdminDocs
SET xDoc = XMLQuery('
  copy $doc := $d
  modify delete $doc//section[@num="2"]
  return $doc
' PASSING xDoc AS "d" RETURNING CONTENT)
WHERE id = 2;
/

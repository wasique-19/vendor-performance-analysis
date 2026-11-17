-- Q1 - VERSION CHECK
SELECT @@VERSION;

-- Q2 - Task 1: Database banao
CREATE DATABASE vendor_performance;
GO
USE vendor_performance;
GO

-- Q3 - Task 2: Tables banao
CREATE TABLE vendors (
    vendor_id            VARCHAR(10)  PRIMARY KEY,
    vendor_name          VARCHAR(100) NOT NULL,
    category             VARCHAR(50)  NOT NULL,
    city                 VARCHAR(50)  NULL,
    payment_terms_days   INT          NOT NULL,
    contract_start_date  DATE         NOT NULL,
    status               VARCHAR(10)  NOT NULL
);

CREATE TABLE products (
    product_id    VARCHAR(10)  PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(50)  NOT NULL,
    base_price    INT          NOT NULL
);

CREATE TABLE purchase_orders (
    po_id                   VARCHAR(12)   PRIMARY KEY,
    vendor_id               VARCHAR(10)   NOT NULL,
    product_id              VARCHAR(10)   NOT NULL,
    order_date              DATE          NOT NULL,
    expected_delivery_date  DATE          NOT NULL,
    quantity_ordered        INT           NOT NULL,
    unit_price              DECIMAL(10,2) NOT NULL,
    total_amount            DECIMAL(14,2) NOT NULL,
    po_status               VARCHAR(15)   NOT NULL,
    is_large_order          BIT           NOT NULL,
    FOREIGN KEY (vendor_id)  REFERENCES vendors(vendor_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE deliveries (
    delivery_id            VARCHAR(12) PRIMARY KEY,
    po_id                  VARCHAR(12) NOT NULL UNIQUE,
    actual_delivery_date   DATE        NULL,
    quantity_received      INT         NOT NULL,
    quantity_defective     INT         NULL,
    delivery_date_missing  BIT         NOT NULL,
    defect_data_invalid    BIT         NOT NULL,
    FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id)
);

-- Q4 - Verify:
SELECT name FROM sys.tables;
EXEC sp_help 'purchase_orders';

-- Q5 - Task 3: CSV import karo
BULK INSERT vendors
FROM 'C:\sql_import\vendors.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', KEEPNULLS);

BULK INSERT products
FROM 'C:\sql_import\products.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', KEEPNULLS);

BULK INSERT purchase_orders
FROM 'C:\sql_import\purchase_orders.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', KEEPNULLS);

BULK INSERT deliveries
FROM 'C:\sql_import\deliveries.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', KEEPNULLS);

-- Q6 - Task 4: Import verify karo
SELECT 'vendors' AS table_name, COUNT(*) AS row_count FROM vendors
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'purchase_orders', COUNT(*) FROM purchase_orders
UNION ALL SELECT 'deliveries', COUNT(*) FROM deliveries;

-- Q7 - TEST
SELECT COUNT(*) AS missing_delivery_dates FROM deliveries WHERE actual_delivery_date IS NULL;
SELECT COUNT(*) AS missing_defective FROM deliveries WHERE quantity_defective IS NULL;

SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order FROM purchase_orders;
SELECT COUNT(*) AS cancelled_orders FROM purchase_orders WHERE po_status = 'Cancelled';
SELECT ROUND(SUM(total_amount), 2) AS spend_all_orders FROM purchase_orders;
SELECT ROUND(SUM(total_amount), 2) AS spend_delivered
FROM purchase_orders WHERE po_status = 'Delivered';

-- Q8 - Task 5: Foreign key test
INSERT INTO purchase_orders
VALUES ('PO999999', 'V999', 'P001', '2025-01-01', '2025-01-10', 10, 100.00, 1000.00, 'Delivered', 0);
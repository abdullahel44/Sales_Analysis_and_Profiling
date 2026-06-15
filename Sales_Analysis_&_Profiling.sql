
CREATE DATABASE DIM_DB;
SELECT * FROM  fact_table;
SELECT * FROM store_dim;
SELECT * FROM time_dim

KPIS
SELECT
    SUM(total_price) AS TotalPrice,
	AVG (total_price) AS AvgTotel,
	STDEV(total_price) AS STDEV_Price,
	MIN(total_price) AS MIN_Price,
	MAX(total_price) AS MAXPrice,
	SUM(quantity) AS TotalQuantity,
	AVG (quantity) AS AvgQuantity	
FROM fact_table;

-- Review a detailed sample of data (20 sales movements) after linking the movement table to all dimensional tables
SELECT TOP 20 
    f.quantity,
    f.total_price,
    i.item_key,     
    s.division,      
    tr.trans_type,  
    t.year,          
    t.month          
FROM fact_table f
JOIN item_dim i ON f.item_key = i.item_key
JOIN store_dim s ON f.store_key = s.store_key
JOIN Trans_dim tr ON f.payment_key = tr.payment_key
JOIN time_dim t ON f.time_key = t.time_key;

-- Aggregate Test: Calculate total sales for each geographic region (Division) to ensure the numbers match
SELECT 
s.division,
SUM(f.total_price) AS PriceByDivision
FROM fact_table f
JOIN store_dim s ON f.store_key = s.store_key
GROUP BY s.division
ORDER BY PriceByDivision DESC;

--Annual Total Sales & Unique Customers Analysis.
SELECT 
SUM(F.total_price) AS total_price,
COUNT(DISTINCT F.coustomer_key) AS Unique_Customers_Count,
T.year
FROM fact_table F
JOIN time_dim T ON F.time_key = T.time_key
JOIN customer_dim C ON F.coustomer_key = C.coustomer_key
GROUP BY T.year
ORDER BY T.year ASC;

--Customer Segmentation by Total Sales (Grouped by Name).
SELECT C.name,
SUM(total_price) AS Totel_sales,
CASE 
    WHEN SUM(F.total_price) < 15000 THEN 'Budget'
    WHEN SUM(F.total_price) BETWEEN 15000 AND 50000 THEN 'Mid-Range'
    ELSE 'Premium'
END AS Product_Class
FROM fact_table F
JOIN customer_dim C ON F.coustomer_key = C.coustomer_key
GROUP BY C.name
ORDER BY Totel_sales DESC ;

--Advanced Customer Segmentation Using Unique Key and Name ***
SELECT C.name,
SUM(total_price) AS Totel_sales,
CASE 
    WHEN SUM(F.total_price) < 10000 THEN 'Budget'
    WHEN SUM(F.total_price) BETWEEN 10000 AND 15000 THEN 'Mid-Range'
    ELSE 'Premium'
END AS Product_Class
FROM fact_table F
JOIN customer_dim C ON F.coustomer_key = C.coustomer_key
GROUP BY C.coustomer_key, C.name
ORDER BY Totel_sales DESC ;

--***
SELECT * FROM fact_table ;
SELECT * FROM customer_dim

-- Title: Investigating Fact Table NULL Units vs Dimension Table Units
SELECT DISTINCT
    f.item_key,
    i.item_name,
    i.unit AS ItemDim_Unit,
    f.unit AS Fact_Unit
FROM fact_table f
JOIN item_dim i ON f.item_key = i.item_key
WHERE f.unit IS NULL;

-- Title: Data Imputation: Updating Missing Units from Dimension Table
UPDATE f
SET f.unit = i.unit
FROM fact_table f
JOIN item_dim i ON f.item_key = i.item_key
WHERE f.unit IS NULL;



-- Title: Final Verification for Zero NULLs in Unit Column
SELECT * FROM fact_table
WHERE unit IS NULL;


-- =================================================================================
-- ADVANCED DATA PROFILING: AUTOMATED NULL VALUE DETECTOR
-- =================================================================================
-- OBJECTIVE:
-- This script automates data quality auditing across the entire database. 
-- By using a cursor and dynamic SQL, it systematically scans every user-defined 
-- table and column to detect, count, and rank missing (NULL) values without 
-- hardcoding table names. This is essential for pre-load data cleaning.
-- =================================================================================

-- 1) Structure Setup: Creating the temporary storage for profiling results
CREATE TABLE #NullReport (
    TableName NVARCHAR(256),
    ColumnName NVARCHAR(256),
    NullCount INT
);

-- Declaring core system variables for dynamic execution
DECLARE @TableName NVARCHAR(256);
DECLARE @ColumnName NVARCHAR(256);
DECLARE @DynamicSQL NVARCHAR(MAX);


-- 2) Database Iteration: Defining the metadata cursor for all user tables
DECLARE col_cursor CURSOR FOR
SELECT 
    t.name AS TableName, 
    c.name AS ColumnName
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
WHERE t.is_ms_shipped = 0; -- Filters out internal system tables (User tables only)

OPEN col_cursor;
FETCH NEXT FROM col_cursor INTO @TableName, @ColumnName;


-- 3) Dynamic Scan Engine: Looping through columns and executing quality checks
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Constructing dynamic SQL execution block for the targeted column
    SET @DynamicSQL = '
        INSERT INTO #NullReport (TableName, ColumnName, NullCount)
        SELECT ''' + @TableName + ''', ''' + @ColumnName + ''', COUNT(*)
        FROM [' + @TableName + ']
        WHERE [' + @ColumnName + '] IS NULL';
    
    -- Executing the generated query string safely
    EXEC sp_executesql @DynamicSQL;

    FETCH NEXT FROM col_cursor INTO @TableName, @ColumnName;
END;

-- Closing and freeing server memory resources from the cursor
CLOSE col_cursor;
DEALLOCATE col_cursor;


-- 4) Reporting: Retrieving and ranking columns with data gaps
SELECT 
    TableName, 
    ColumnName, 
    NullCount
FROM #NullReport
WHERE NullCount > 0
ORDER BY NullCount DESC;


-- 5) Environment Cleanup: Dropping the temporary session table
DROP TABLE #NullReport;


-- =================================================================================
-- PHASE 4: DATA AGGREGATION & OPTIMIZATION LAYER
-- =================================================================================
-- OBJECTIVE:
-- This script creates an optimized, aggregated database VIEW. Instead of importing 
-- raw, granular transactional rows into Power BI, it pre-aggregates total sales 
-- and quantities grouped by key dimensions. This drastically reduces data size, 
-- minimizes memory consumption, and accelerates DAX query performance in Power BI.
-- =================================================================================

-- Title: Creating the Aggregated Sales View for Power BI
CREATE VIEW v_Fact_Sales_Aggregated AS
SELECT 
    time_key,
    payment_key,
    store_key,
    coustomer_key,
    item_key,
    unit,
    SUM(quantity) AS Total_Quantity,
    SUM(total_price) AS Total_Sales
FROM fact_table
GROUP BY time_key, store_key, coustomer_key, item_key, unit;


-- Title: Testing and Verifying the View Output
SELECT * FROM v_Fact_Sales_Aggregated;





بص يا عبد الله، عشان تخلي شكل الـ README مبهر وأي حد يدخل يفهم المشروع من أول نظرة، هتحط **3 صور أساسية** لصفحات الـ Power BI بتاعتك.

بما إنك عامل الداشبورد متقسمة صح، فكل صفحة هتعبر عن سياق معين جوه الكلام:

### 1️⃣ الصورة الأولى: واجهة المشروع الرئيسية (Executive Sales Overview)

* **الصورة دي هي:** `Screenshot (791).png` (اللي فيها الرقم الكبير الـ **105.4M** وخريطة الفروع والـ Bar Chart).
* **مكانها فين؟** هتحطها في أول الـ README خالص، تحت العنوان الرئيسي مباشرة كواجهة للمشروع، أو تحت قسم الـ (Executive Sales Overview).

### 2️⃣ الصورة الثانية: تحليل سلوك العملاء (Customer & Payments Insights)

* **الصورة دي هي:** `Screenshot (792).jpg` (الصفحة اللي فيها الـ Donut Chart بتاع طرق الدفع ونسب البطاقات، وتحليل شرائح الـ Segments بعد ما اتصلحت).
* **مكانها فين؟** هتحطها تحت قسم الـ (Customer Segmentation Metrics).

### 3️⃣ الصورة الثالثة: أداء المنتجات والموردين (Product Performance)

* **الصورة دي هي:** `Screenshot (793).jpg` (الصفحة اللي فيها الـ Treemap الملون الكبير والـ Bar Charts اللي بتوضح الوحدات والأصناف الأكثر مبيعاً).
* **مكانها فين؟** هتحطها تحت قسم الـ (Transaction & Product Dynamics).

---

### 💡 الحركة الاحترافية عشان تضيفهم صح في ملف الـ README:

لما ترفع الصور دي في فولدر اسمه `images` على جيت هب، هتروح للملف وتكتب السطور دي في الأماكن اللي اتفقنا عليها عشان الصور تظهر تلقائي:

```markdown
![Sales Overview](images/Screenshot (791).png)

![Customer Insights](images/Screenshot (792).jpg)

![Product Performance](images/Screenshot (793).jpg)

```

*(تأكد بس إن أسماء الصور المكتوبة جوه الأقواس هي نفس أسماء ملفات الصور اللي هترفعها بالظبط).*

كده اللي هيدخل هيقرا الكلام، وتحت كل فقرة هيشوف الصورة اللي بتثبت الأرقام دي جوه لوحة التحكم! لو حابب تظبط الأكواد دي في الـ README قولي وأنا معاك.
-- 鳥豪族 Redshift データベース初期化用SQLスクリプト
-- データベース: toriguozoku
-- 日英対応改善版

-- 1. 店舗マスタテーブル
DROP TABLE IF EXISTS stores CASCADE;
CREATE TABLE stores (
    store_id INTEGER PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    store_name_en VARCHAR(100),
    region VARCHAR(50) NOT NULL,
    prefecture VARCHAR(50) NOT NULL,
    city VARCHAR(100),
    address VARCHAR(200),
    opening_date DATE NOT NULL,
    closing_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    phone_number VARCHAR(20),
    seat_count INTEGER,
    monthly_rent INTEGER,
    manager_name VARCHAR(50)
);

-- 2. 商品マスタテーブル（日英対応）
DROP TABLE IF EXISTS products CASCADE;
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name_ja VARCHAR(100) NOT NULL,
    product_name_en VARCHAR(100) NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    product_category_en VARCHAR(50) NOT NULL,
    unit_price INTEGER NOT NULL,
    cost_price INTEGER NOT NULL,
    description_ja TEXT,
    description_en TEXT,
    is_signature_dish BOOLEAN DEFAULT FALSE,
    is_seasonal BOOLEAN DEFAULT FALSE,
    calories INTEGER,
    allergens VARCHAR(200),
    created_date DATE DEFAULT CURRENT_DATE,
    discontinued_date DATE
);

-- 3. 売上トランザクションテーブル
DROP TABLE IF EXISTS sales_transactions CASCADE;
CREATE TABLE sales_transactions (
    transaction_id BIGINT PRIMARY KEY,
    store_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    sale_date DATE NOT NULL,
    sale_time TIME,
    quantity INTEGER NOT NULL,
    unit_price INTEGER NOT NULL,
    total_amount INTEGER NOT NULL,
    discount_amount INTEGER DEFAULT 0,
    payment_method VARCHAR(20),
    customer_type VARCHAR(20),
    weather VARCHAR(20),
    day_of_week VARCHAR(10),
    is_holiday BOOLEAN DEFAULT FALSE,
    staff_id VARCHAR(20),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 4. 日別売上サマリーテーブル（集計済みデータ）
DROP TABLE IF EXISTS daily_sales_summary CASCADE;
CREATE TABLE daily_sales_summary (
    summary_date DATE NOT NULL,
    store_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    total_quantity INTEGER NOT NULL,
    total_amount INTEGER NOT NULL,
    customer_count INTEGER,
    avg_unit_price DECIMAL(10,2),
    discount_total INTEGER DEFAULT 0,
    PRIMARY KEY (summary_date, store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 5. 月別売上サマリーテーブル
DROP TABLE IF EXISTS monthly_sales_summary CASCADE;
CREATE TABLE monthly_sales_summary (
    year_month VARCHAR(7) NOT NULL, -- YYYY-MM format
    store_id INTEGER NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    total_quantity INTEGER NOT NULL,
    total_amount INTEGER NOT NULL,
    customer_count INTEGER,
    avg_transaction_amount DECIMAL(10,2),
    growth_rate DECIMAL(5,2),
    PRIMARY KEY (year_month, store_id, product_category),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- ========================================
-- サンプルデータの投入
-- ========================================

-- 店舗データ
INSERT INTO stores (store_id, store_name, store_name_en, region, prefecture, city, address, opening_date, seat_count, monthly_rent, manager_name) VALUES
(1, '鳥豪族 渋谷本店', 'Toriguozoku Shibuya Main Store', '関東', '東京都', '渋谷区', '渋谷2-1-1', '2020-01-15', 45, 800000, '田中太郎'),
(2, '鳥豪族 新宿店', 'Toriguozoku Shinjuku Store', '関東', '東京都', '新宿区', '新宿3-2-1', '2020-06-01', 38, 750000, '佐藤花子'),
(3, '鳥豪族 梅田店', 'Toriguozoku Umeda Store', '関西', '大阪府', '大阪市', '梅田1-1-3', '2021-03-10', 42, 650000, '鈴木次郎'),
(4, '鳥豪族 京都店', 'Toriguozoku Kyoto Store', '関西', '京都府', '京都市', '四条通1-2-3', '2021-09-20', 35, 550000, '山田三郎'),
(5, '鳥豪族 名古屋店', 'Toriguozoku Nagoya Store', '中部', '愛知県', '名古屋市', '栄3-1-1', '2022-02-01', 40, 600000, '高橋美咲'),
(6, '鳥豪族 福岡店', 'Toriguozoku Fukuoka Store', '九州', '福岡県', '福岡市', '天神2-5-1', '2022-07-15', 36, 500000, '吉田健太'),
(7, '鳥豪族 札幌店', 'Toriguozoku Sapporo Store', '北海道', '北海道', '札幌市', 'すすきの1-1-1', '2023-01-20', 33, 450000, '小林由美'),
(8, '鳥豪族 仙台店', 'Toriguozoku Sendai Store', '東北', '宮城県', '仙台市', '一番町2-3-4', '2023-05-10', 38, 480000, '中村正男'),
(9, '鳥豪族 広島店', 'Toriguozoku Hiroshima Store', '中国', '広島県', '広島市', '紙屋町1-2-3', '2023-08-25', 35, 520000, '加藤智子'),
(10, '鳥豪族 沖縄店', 'Toriguozoku Okinawa Store', '沖縄', '沖縄県', '那覇市', '国際通り2-1-5', '2024-01-15', 30, 400000, '島袋太郎');

-- 商品データ（30商品）
INSERT INTO products (product_id, product_name_ja, product_name_en, product_category, product_category_en, unit_price, cost_price, is_signature_dish, calories) VALUES
-- 串焼き系
(1, 'もも豪族焼', 'Momo Gozoku Yaki', '串焼き', 'Grilled Skewers', 250, 100, TRUE, 180),
(2, 'ねぎま豪族焼', 'Negima Gozoku Yaki', '串焼き', 'Grilled Skewers', 230, 90, TRUE, 165),
(3, 'つくね豪族焼', 'Tsukune Gozoku Yaki', '串焼き', 'Grilled Skewers', 280, 110, TRUE, 200),
(4, 'せせり豪族焼', 'Seseri Gozoku Yaki', '串焼き', 'Grilled Skewers', 300, 120, TRUE, 185),
(5, '手羽先豪族焼', 'Tebasaki Gozoku Yaki', '串焼き', 'Grilled Skewers', 220, 85, FALSE, 195),
(6, 'ハツ塩焼き', 'Hatsu Shioyaki', '串焼き', 'Grilled Skewers', 270, 105, FALSE, 150),
(7, 'ぼんじり豪族焼', 'Bonjiri Gozoku Yaki', '串焼き', 'Grilled Skewers', 290, 115, FALSE, 210),
(8, 'かわ塩焼き', 'Kawa Shioyaki', '串焼き', 'Grilled Skewers', 240, 95, FALSE, 175),
(9, 'レバー塩焼き', 'Liver Shioyaki', '串焼き', 'Grilled Skewers', 260, 100, FALSE, 160),
(10, '砂肝塩焼き', 'Sunagimo Shioyaki', '串焼き', 'Grilled Skewers', 250, 95, FALSE, 140),

-- 揚げ物系
(11, 'ひざなんこつ唐揚げ', 'Hiza Nankotsu Karaage', '揚げ物', 'Fried Foods', 350, 140, FALSE, 280),
(12, '手羽先唐揚げ', 'Tebasaki Karaage', '揚げ物', 'Fried Foods', 320, 130, FALSE, 295),
(13, 'もも唐揚げ', 'Momo Karaage', '揚げ物', 'Fried Foods', 380, 150, FALSE, 320),
(14, '鶏皮せんべい', 'Torikawa Senbei', '揚げ物', 'Fried Foods', 280, 110, FALSE, 250),
(15, 'ささみ天ぷら', 'Sasami Tempura', '揚げ物', 'Fried Foods', 330, 135, FALSE, 275),

-- 一品料理
(16, '鶏皮餃子', 'Torikawa Gyoza', '一品料理', 'Side Dishes', 380, 150, FALSE, 290),
(17, '砂肝ポン酢', 'Sunagimo Ponzu', '一品料理', 'Side Dishes', 320, 130, FALSE, 120),
(18, '鶏刺し', 'Tori Sashi', '一品料理', 'Side Dishes', 450, 180, FALSE, 180),
(19, '鶏スープ', 'Tori Soup', '一品料理', 'Side Dishes', 200, 80, FALSE, 85),
(20, '親子丼', 'Oyako Don', '一品料理', 'Side Dishes', 650, 260, FALSE, 580),

-- サイドメニュー
(21, 'キャベツ', 'Cabbage', 'サイドメニュー', 'Side Menu', 150, 60, FALSE, 25),
(22, 'もやし炒め', 'Moyashi Itame', 'サイドメニュー', 'Side Menu', 180, 70, FALSE, 45),
(23, 'ポテトフライ', 'Potato Fries', 'サイドメニュー', 'Side Menu', 250, 100, FALSE, 320),
(24, '枝豆', 'Edamame', 'サイドメニュー', 'Side Menu', 200, 80, FALSE, 135),
(25, '冷奴', 'Hiyayakko', 'サイドメニュー', 'Side Menu', 220, 90, FALSE, 98),

-- ドリンク
(26, '生ビール', 'Draft Beer', 'ドリンク', 'Drinks', 300, 120, FALSE, 145),
(27, 'ハイボール', 'Highball', 'ドリンク', 'Drinks', 280, 110, FALSE, 95),
(28, 'チューハイ', 'Chuhai', 'ドリンク', 'Drinks', 250, 100, FALSE, 110),
(29, 'ウーロン茶', 'Oolong Tea', 'ドリンク', 'Drinks', 180, 70, FALSE, 0),
(30, 'コーラ', 'Cola', 'ドリンク', 'Drinks', 200, 80, FALSE, 150);

-- 売上トランザクションデータ（2025年5月分のサンプル）
-- 2025年5月1日-31日のデータを生成（Redshift対応版）

-- まず、5000件のサンプルデータを段階的に作成
INSERT INTO sales_transactions 
(transaction_id, store_id, product_id, sale_date, sale_time, quantity, unit_price, total_amount, payment_method, day_of_week) 
VALUES
-- 5月1日のデータ
(1, 1, 1, '2025-05-01', '11:30:00', 2, 250, 500, 'CASH', '木曜日'),
(2, 1, 26, '2025-05-01', '12:15:00', 1, 300, 300, 'CARD', '木曜日'),
(3, 2, 3, '2025-05-01', '13:20:00', 3, 280, 840, 'CASH', '木曜日'),
(4, 3, 15, '2025-05-01', '14:45:00', 1, 330, 330, 'QR_CODE', '木曜日'),
(5, 1, 21, '2025-05-01', '15:30:00', 2, 150, 300, 'CASH', '木曜日'),

-- 5月2日のデータ
(6, 2, 2, '2025-05-02', '11:45:00', 1, 230, 230, 'CARD', '金曜日'),
(7, 3, 27, '2025-05-02', '12:30:00', 2, 280, 560, 'CASH', '金曜日'),
(8, 4, 5, '2025-05-02', '13:15:00', 3, 220, 660, 'CARD', '金曜日'),
(9, 5, 11, '2025-05-02', '14:20:00', 1, 350, 350, 'QR_CODE', '金曜日'),
(10, 1, 16, '2025-05-02', '15:45:00', 2, 380, 760, 'CASH', '金曜日'),

-- 5月3日のデータ（土曜日）
(11, 6, 4, '2025-05-03', '11:20:00', 4, 300, 1200, 'CASH', '土曜日'),
(12, 7, 12, '2025-05-03', '12:10:00', 2, 320, 640, 'CARD', '土曜日'),
(13, 8, 20, '2025-05-03', '13:30:00', 1, 650, 650, 'CARD', '土曜日'),
(14, 9, 8, '2025-05-03', '14:15:00', 3, 240, 720, 'QR_CODE', '土曜日'),
(15, 10, 28, '2025-05-03', '15:20:00', 2, 250, 500, 'CASH', '土曜日'),

-- 5月4日のデータ（日曜日）
(16, 1, 13, '2025-05-04', '12:00:00', 2, 380, 760, 'CASH', '日曜日'),
(17, 2, 25, '2025-05-04', '13:30:00', 1, 220, 220, 'CARD', '日曜日'),
(18, 3, 7, '2025-05-04', '14:45:00', 4, 290, 1160, 'CASH', '日曜日'),
(19, 4, 19, '2025-05-04', '15:15:00', 1, 200, 200, 'QR_CODE', '日曜日'),
(20, 5, 30, '2025-05-04', '16:30:00', 3, 200, 600, 'CARD', '日曜日'),

-- 5月5日のデータ（月曜日・祝日）
(21, 6, 1, '2025-05-05', '11:45:00', 3, 250, 750, 'CASH', '月曜日'),
(22, 7, 14, '2025-05-05', '12:20:00', 2, 280, 560, 'CARD', '月曜日'),
(23, 8, 17, '2025-05-05', '13:40:00', 1, 320, 320, 'QR_CODE', '月曜日'),
(24, 9, 6, '2025-05-05', '14:30:00', 4, 270, 1080, 'CASH', '月曜日'),
(25, 10, 22, '2025-05-05', '15:50:00', 2, 180, 360, 'CARD', '月曜日');

-- より多くのサンプルデータを効率的に作成するため、既存データを基にランダムに生成
-- 日付を2025年5月の範囲でランダムに分散
INSERT INTO sales_transactions 
(transaction_id, store_id, product_id, sale_date, sale_time, quantity, unit_price, total_amount, payment_method, day_of_week)
WITH date_series AS (
    SELECT '2025-05-01'::date + (row_number() over() - 1) % 31 as sale_date,
           row_number() over() as rn
    FROM stores s1 
    CROSS JOIN stores s2 
    CROSS JOIN products p
    LIMIT 5000
),
random_data AS (
    SELECT 
        25 + row_number() over() as transaction_id,
        (rn % 10) + 1 as store_id,
        ((rn * 7) % 30) + 1 as product_id,
        sale_date,
        CASE 
            WHEN (rn % 12) = 0 THEN '11:00:00'::time
            WHEN (rn % 12) = 1 THEN '11:30:00'::time
            WHEN (rn % 12) = 2 THEN '12:00:00'::time
            WHEN (rn % 12) = 3 THEN '12:30:00'::time
            WHEN (rn % 12) = 4 THEN '13:00:00'::time
            WHEN (rn % 12) = 5 THEN '13:30:00'::time
            WHEN (rn % 12) = 6 THEN '14:00:00'::time
            WHEN (rn % 12) = 7 THEN '14:30:00'::time
            WHEN (rn % 12) = 8 THEN '15:00:00'::time
            WHEN (rn % 12) = 9 THEN '15:30:00'::time
            WHEN (rn % 12) = 10 THEN '16:00:00'::time
            ELSE '16:30:00'::time
        END as sale_time,
        (rn % 4) + 1 as quantity,
        CASE 
            WHEN rn % 3 = 0 THEN 'CASH'
            WHEN rn % 3 = 1 THEN 'CARD'
            ELSE 'QR_CODE'
        END as payment_method,
        CASE extract(dow from sale_date)
            WHEN 0 THEN '日曜日'
            WHEN 1 THEN '月曜日'
            WHEN 2 THEN '火曜日'
            WHEN 3 THEN '水曜日'
            WHEN 4 THEN '木曜日'
            WHEN 5 THEN '金曜日'
            WHEN 6 THEN '土曜日'
        END as day_of_week
    FROM date_series
)
SELECT 
    r.transaction_id,
    r.store_id,
    r.product_id,
    r.sale_date,
    r.sale_time,
    r.quantity,
    p.unit_price,
    r.quantity * p.unit_price as total_amount,
    r.payment_method,
    r.day_of_week
FROM random_data r
JOIN products p ON r.product_id = p.product_id;

-- 日別売上サマリーデータの作成
INSERT INTO daily_sales_summary (summary_date, store_id, product_id, total_quantity, total_amount, customer_count, avg_unit_price)
SELECT 
    sale_date,
    store_id,
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(total_amount) AS total_amount,
    COUNT(DISTINCT transaction_id) AS customer_count,
    AVG(unit_price) AS avg_unit_price
FROM sales_transactions
GROUP BY sale_date, store_id, product_id;

-- 月別売上サマリーデータの作成
INSERT INTO monthly_sales_summary (year_month, store_id, product_category, total_quantity, total_amount, customer_count, avg_transaction_amount)
SELECT 
    TO_CHAR(st.sale_date, 'YYYY-MM') AS year_month,
    st.store_id,
    p.product_category,
    SUM(st.quantity) AS total_quantity,
    SUM(st.total_amount) AS total_amount,
    COUNT(DISTINCT st.transaction_id) AS customer_count,
    AVG(st.total_amount) AS avg_transaction_amount
FROM sales_transactions st
JOIN products p ON st.product_id = p.product_id
GROUP BY TO_CHAR(st.sale_date, 'YYYY-MM'), st.store_id, p.product_category;

-- ========================================
-- 便利なビューの作成
-- ========================================

-- 売上分析用ビュー
CREATE OR REPLACE VIEW sales_analysis_view AS
SELECT 
    s.store_name,
    s.region,
    p.product_name_ja,
    p.product_category,
    st.sale_date,
    st.quantity,
    st.total_amount,
    st.day_of_week,
    p.unit_price,
    p.cost_price,
    (st.total_amount - (p.cost_price * st.quantity)) AS profit
FROM sales_transactions st
JOIN stores s ON st.store_id = s.store_id
JOIN products p ON st.product_id = p.product_id;

-- 人気商品ランキングビュー
CREATE OR REPLACE VIEW popular_products_view AS
SELECT 
    p.product_name_ja,
    p.product_name_en,
    p.product_category,
    SUM(st.quantity) AS total_quantity_sold,
    SUM(st.total_amount) AS total_revenue,
    COUNT(DISTINCT st.store_id) AS stores_selling,
    RANK() OVER (ORDER BY SUM(st.quantity) DESC) AS popularity_rank
FROM sales_transactions st
JOIN products p ON st.product_id = p.product_id
GROUP BY p.product_id, p.product_name_ja, p.product_name_en, p.product_category;

-- 店舗別パフォーマンスビュー
CREATE OR REPLACE VIEW store_performance_view AS
SELECT 
    s.store_name,
    s.region,
    s.prefecture,
    COUNT(DISTINCT st.sale_date) AS operating_days,
    SUM(st.total_amount) AS total_revenue,
    AVG(st.total_amount) AS avg_transaction_amount,
    SUM(st.quantity) AS total_items_sold,
    RANK() OVER (ORDER BY SUM(st.total_amount) DESC) AS revenue_rank
FROM sales_transactions st
JOIN stores s ON st.store_id = s.store_id
GROUP BY s.store_id, s.store_name, s.region, s.prefecture;

-- ========================================
-- 統計情報の更新
-- ========================================

-- テーブルの統計情報を更新（Redshift用）
ANALYZE stores;
ANALYZE products;
ANALYZE sales_transactions;
ANALYZE daily_sales_summary;
ANALYZE monthly_sales_summary;

-- ========================================
-- データ品質チェッククエリ
-- ========================================

-- データ品質確認用のクエリ例
SELECT 'Total Transactions' AS metric, COUNT(*)::VARCHAR AS value FROM sales_transactions
UNION ALL
SELECT 'Date Range', MIN(sale_date)::VARCHAR || ' to ' || MAX(sale_date)::VARCHAR FROM sales_transactions
UNION ALL
SELECT 'Total Revenue', SUM(total_amount)::VARCHAR FROM sales_transactions
UNION ALL
SELECT 'Active Stores', COUNT(DISTINCT store_id)::VARCHAR FROM sales_transactions
UNION ALL
SELECT 'Products Sold', COUNT(DISTINCT product_id)::VARCHAR FROM sales_transactions;



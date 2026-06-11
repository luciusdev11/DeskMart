/*
  DeskMart - Data Block 2 (RAM, SSD, Cooler, Case bo sung)
  Chay SAU DeskMart-DataBlock1.sql
*/
USE [DeskMartDb];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

DECLARE @Now DATETIME2 = SYSUTCDATETIME();

INSERT INTO dbo.Brands (Name, IsActive, CreatedAt)
SELECT v.Name, 1, @Now
FROM (VALUES
    (N'TeamGroup'), (N'Kingmax'), (N'Crucial'), (N'Lexar'), (N'Seagate'),
    (N'Somnambulist'), (N'Deepcool'), (N'Noctua'), (N'ID-Cooling'), (N'Montech')
) AS v(Name)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Brands b WHERE b.Name = v.Name);

DECLARE @Products TABLE (
    Slug              NVARCHAR(220)  NOT NULL PRIMARY KEY,
    Name              NVARCHAR(200)  NOT NULL,
    BrandName         NVARCHAR(100)  NOT NULL,
    CategoryName      NVARCHAR(100)  NOT NULL,
    Price             DECIMAL(18, 2) NOT NULL,
    StockQuantity     INT            NOT NULL,
    LowStockThreshold INT            NOT NULL,
    Description       NVARCHAR(MAX)  NULL
);

INSERT INTO @Products (Slug, Name, BrandName, CategoryName, Price, StockQuantity, LowStockThreshold, Description)
VALUES
    -- RAM
    (N'corsair-vengeance-rgb-ddr5-32gb', N'Corsair Vengeance RGB 32GB (2x16GB) DDR5 6000MHz', N'Corsair', N'RAM', 3200000, 80, 8, N'RAM DDR5 hieu nang cao dong bo iCUE.'),
    (N'kingston-fury-beast-rgb-16gb-d5', N'Kingston FURY Beast RGB 16GB (1x16GB) DDR5', N'Kingston', N'RAM', 1650000, 120, 10, N'RAM DDR5 pho thong tuong thich tot Intel/AMD.'),
    (N'teamgroup-tforce-delta-rgb-32gb-d5', N'TeamGroup T-Force Delta RGB 32GB (2x16GB) DDR5', N'TeamGroup', N'RAM', 2950000, 50, 5, N'Tan nhiet phong cach canh chim led RGB ruc ro.'),
    (N'kingmax-heatsink-8gb-ddr4-3200', N'Kingmax Heatsink 8GB DDR4 3200MHz', N'Kingmax', N'RAM', 450000, 400, 25, N'RAM co quoc dan tan nhiet nhom co ban.'),

    -- SSD
    (N'crucial-t700-pcie-gen5-1tb-ssd', N'Crucial T700 PCIe Gen 5 NVMe M.2 SSD 1TB', N'Crucial', N'SSD', 5200000, 15, 2, N'SSD Gen5 toc do doc ghi cuc cao 11700MB/s.'),
    (N'lexar-nm790-2tb-nvme-ssd', N'Lexar NM790 2TB M.2 NVMe SSD', N'Lexar', N'SSD', 3450000, 55, 5, N'SSD hieu nang cao khong can tan nhiet rieng.'),
    (N'seagate-barracuda-2tb-hdd-35', N'Seagate Barracuda 2TB 3.5 inch HDD', N'Seagate', N'SSD', 1450000, 250, 15, N'O cung co 7200RPM dung luong cao.'),
    (N'wd-ultrastar-8tb-enterprise-hdd', N'Western Digital Ultrastar 8TB Enterprise HDD', N'Western Digital', N'SSD', 6500000, 18, 2, N'O cung doanh nghiep chay server 24/7.'),
    (N'somnambulist-sata-iii-120gb-co', N'Somnambulist SATA III 120GB SSD', N'Somnambulist', N'SSD', 180000, 500, 30, N'SSD co sieu re cai Windows may van phong.'),

    -- Cooler
    (N'deepcool-mystique-360-aio-lcd', N'Deepcool Mystique 360 LCD ARGB', N'Deepcool', N'Cooler', 4350000, 22, 3, N'AIO 360mm man hinh LCD hien thi thong so CPU.'),
    (N'noctua-nh-d15-chromax-black', N'Noctua NH-D15 chromax.black', N'Noctua', N'Cooler', 2950000, 35, 4, N'Tan khi thap doi Silent Wings 140mm sieu ben.'),
    (N'id-cooling-se-214-xt-argb-white', N'ID-Cooling SE-214-XT ARGB White', N'ID-Cooling', N'Cooler', 270000, 280, 20, N'Tan khi thap don mau trang gia re.'),

    -- Case
    (N'nzxt-h9-flow-white-case', N'NZXT H9 Flow White Premium', N'NZXT', N'Case', 4450000, 25, 3, N'Case hai mat kinh mau trang thong thoang khi tot.'),
    (N'montech-air-903-max-black', N'Montech Air 903 Max Black', N'Montech', N'Case', 1350000, 90, 8, N'Case luoi airflow kem 4 quat ARGB.');

DECLARE @Specs TABLE (
    ProductSlug NVARCHAR(220) NOT NULL,
    SpecKey NVARCHAR(100) NOT NULL,
    SpecValue NVARCHAR(300) NOT NULL,
    DisplayOrder INT NOT NULL,
    PRIMARY KEY (ProductSlug, SpecKey)
);

INSERT INTO @Specs (ProductSlug, SpecKey, SpecValue, DisplayOrder)
VALUES
    (N'corsair-vengeance-rgb-ddr5-32gb', N'RAM Type', N'DDR5', 1),
    (N'corsair-vengeance-rgb-ddr5-32gb', N'Speed', N'6000MHz', 2),
    (N'corsair-vengeance-rgb-ddr5-32gb', N'Capacity', N'32GB (2x16GB)', 3),

    (N'kingston-fury-beast-rgb-16gb-d5', N'RAM Type', N'DDR5', 1),
    (N'kingston-fury-beast-rgb-16gb-d5', N'Capacity', N'16GB (1x16GB)', 2),

    (N'teamgroup-tforce-delta-rgb-32gb-d5', N'RAM Type', N'DDR5', 1),
    (N'teamgroup-tforce-delta-rgb-32gb-d5', N'Capacity', N'32GB (2x16GB)', 2),
    (N'teamgroup-tforce-delta-rgb-32gb-d5', N'Speed', N'6400MHz', 3),

    (N'kingmax-heatsink-8gb-ddr4-3200', N'RAM Type', N'DDR4', 1),
    (N'kingmax-heatsink-8gb-ddr4-3200', N'Capacity', N'8GB', 2),
    (N'kingmax-heatsink-8gb-ddr4-3200', N'Speed', N'3200MHz', 3),

    (N'crucial-t700-pcie-gen5-1tb-ssd', N'Interface', N'NVMe PCIe Gen 5.0', 1),
    (N'crucial-t700-pcie-gen5-1tb-ssd', N'Read Speed', N'11700 MB/s', 2),
    (N'crucial-t700-pcie-gen5-1tb-ssd', N'Capacity', N'1TB', 3),

    (N'lexar-nm790-2tb-nvme-ssd', N'Interface', N'NVMe PCIe Gen 4.0', 1),
    (N'lexar-nm790-2tb-nvme-ssd', N'Capacity', N'2TB', 2),

    (N'seagate-barracuda-2tb-hdd-35', N'Interface', N'SATA III', 1),
    (N'seagate-barracuda-2tb-hdd-35', N'Capacity', N'2TB', 2),

    (N'wd-ultrastar-8tb-enterprise-hdd', N'Interface', N'SATA III', 1),
    (N'wd-ultrastar-8tb-enterprise-hdd', N'Capacity', N'8TB', 2),

    (N'somnambulist-sata-iii-120gb-co', N'Interface', N'SATA III', 1),
    (N'somnambulist-sata-iii-120gb-co', N'Capacity', N'120GB', 2),

    (N'deepcool-mystique-360-aio-lcd', N'Type', N'Liquid AIO 360mm', 1),
    (N'deepcool-mystique-360-aio-lcd', N'Radiator', N'360mm', 2),

    (N'noctua-nh-d15-chromax-black', N'Type', N'Air Cooler', 1),
    (N'noctua-nh-d15-chromax-black', N'Fan Size', N'140mm', 2),

    (N'id-cooling-se-214-xt-argb-white', N'Type', N'Air Cooler', 1),
    (N'id-cooling-se-214-xt-argb-white', N'Fan Size', N'120mm', 2),

    (N'nzxt-h9-flow-white-case', N'Form Factor', N'ATX Mid-Tower', 1),
    (N'nzxt-h9-flow-white-case', N'Color', N'White', 2),

    (N'montech-air-903-max-black', N'Form Factor', N'ATX Mid-Tower', 1),
    (N'montech-air-903-max-black', N'GPU Clearance', N'390mm', 2);

INSERT INTO dbo.Products (Name, Slug, Description, Price, ImageUrl, CategoryId, BrandId, StockQuantity, LowStockThreshold, IsActive, CreatedAt)
SELECT p.Name, p.Slug, p.Description, p.Price, NULL, c.Id, b.Id, p.StockQuantity, p.LowStockThreshold, 1, @Now
FROM @Products p
INNER JOIN dbo.Brands b ON b.Name = p.BrandName
INNER JOIN dbo.Categories c ON c.Name = p.CategoryName
WHERE NOT EXISTS (SELECT 1 FROM dbo.Products existing WHERE existing.Slug = p.Slug);

INSERT INTO dbo.ProductSpecifications (ProductId, SpecKey, SpecValue, Unit, DisplayOrder)
SELECT pr.Id, s.SpecKey, s.SpecValue, NULL, s.DisplayOrder
FROM @Specs s
INNER JOIN dbo.Products pr ON pr.Slug = s.ProductSlug
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.ProductSpecifications existing
    WHERE existing.ProductId = pr.Id AND existing.SpecKey = s.SpecKey
);

COMMIT TRANSACTION;

PRINT N'--- Block 2 hoan tat ---';
SELECT COUNT(*) AS TotalProducts FROM dbo.Products WHERE IsActive = 1;

GO

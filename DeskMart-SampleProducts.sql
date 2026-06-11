/*
================================================================================
  DeskMart - SQL seed / bulk product import
  File: DeskMart-SampleProducts.sql (project root)

  Cach dung trong SSMS:
  1. Mo SSMS -> Connect Server (localhost hoac localhost\SQLEXPRESS)
  2. File -> Open -> chon file nay
  3. Dam bao da chay migration truoc:
       dotnet ef database update --project DeskMart\DeskMart.csproj
  4. Chon database DeskMartDb o dropdown (hoac de script tu USE ben duoi)
  5. Sua bang @Products va @Specs (them dong moi)
  6. Nhan F5 (Execute)

  Luu y:
  - Script idempotent: neu Slug da ton tai thi BO QUA (khong ghi de)
  - BrandName phai ton tai trong bang Brands (xem danh sach ben duoi)
  - CategoryName phai ton tai trong bang Categories
  - Slug phai unique, dang: intel-core-i5-14400
  - Gia Price tinh bang VND (so nguyen), vi du: 8990000
  - Spec quan trong cho PC Builder:
      CPU/GPU/MB  -> Socket, TDP
      Motherboard -> Socket, RAM Type, Form Factor
      RAM         -> RAM Type, Capacity, Speed
      PSU         -> Wattage, Efficiency
      Case        -> Form Factor, GPU Clearance
      Cooler      -> Type, Fan Size / Radiator
================================================================================
*/

USE [DeskMartDb];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

/* --------------------------------------------------------------------------
   1) Dam bao Brands / Categories co ban (bo qua neu da co)
-------------------------------------------------------------------------- */
DECLARE @Now DATETIME2 = SYSUTCDATETIME();

INSERT INTO dbo.Brands (Name, IsActive, CreatedAt)
SELECT v.Name, 1, @Now
FROM (VALUES
    (N'Intel'),
    (N'AMD'),
    (N'NVIDIA'),
    (N'ASUS'),
    (N'MSI'),
    (N'Corsair'),
    (N'Kingston'),
    (N'Samsung')
) AS v(Name)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Brands b WHERE b.Name = v.Name);

INSERT INTO dbo.Categories (Name, Slug, IconName, IsActive, CreatedAt)
SELECT v.Name, v.Slug, v.IconName, 1, @Now
FROM (VALUES
    (N'CPU',         N'cpu',         N'cpu'),
    (N'GPU',         N'gpu',         N'gpu'),
    (N'Motherboard', N'motherboard', N'motherboard'),
    (N'RAM',         N'ram',         N'ram'),
    (N'SSD',         N'ssd',         N'ssd'),
    (N'PSU',         N'psu',         N'psu'),
    (N'Case',        N'case',        N'case'),
    (N'Cooler',      N'cooler',      N'cooler')
) AS v(Name, Slug, IconName)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Categories c WHERE c.Slug = v.Slug);

/* --------------------------------------------------------------------------
   2) THEM / SUA DU LIEU SAN PHAM O DAY
      - Copy dong mau ben duoi de them nhieu san pham
      - Format: (Slug, Name, BrandName, CategoryName, Price, StockQty, LowStockThreshold, Description)
-------------------------------------------------------------------------- */
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
    -- CPU
    (N'intel-core-i5-14400',              N'Intel Core i5-14400',              N'Intel',    N'CPU',         4500000,  5, 3, NULL),
    (N'amd-ryzen-5-7600',                 N'AMD Ryzen 5 7600',                 N'AMD',      N'CPU',         5200000,  0, 3, NULL),

    -- GPU
    (N'nvidia-rtx-4060-8gb',              N'NVIDIA RTX 4060 8GB',              N'NVIDIA',   N'GPU',         8990000,  3, 2, NULL),
    (N'amd-rx-7600-xt-16gb',              N'AMD RX 7600 XT 16GB',              N'AMD',      N'GPU',         9500000,  1, 2, NULL),

    -- Motherboard
    (N'asus-b760-ddr5-motherboard',       N'ASUS B760 DDR5 Motherboard',       N'ASUS',     N'Motherboard', 3200000,  4, 2, NULL),
    (N'msi-b550-ddr4-motherboard',        N'MSI B550 DDR4 Motherboard',        N'MSI',      N'Motherboard', 2500000,  2, 2, NULL),

    -- RAM
    (N'kingston-fury-32gb-ddr5-5600',     N'Kingston Fury 32GB DDR5 5600',     N'Kingston', N'RAM',         2200000,  8, 3, NULL),
    (N'corsair-vengeance-16gb-ddr4-3200', N'Corsair Vengeance 16GB DDR4 3200', N'Corsair',  N'RAM',          900000,  0, 3, NULL),

    -- SSD
    (N'samsung-1tb-nvme-gen4-ssd',        N'Samsung 1TB NVMe Gen4 SSD',        N'Samsung',  N'SSD',         1800000,  6, 2, NULL),
    (N'kingston-500gb-sata-ssd',          N'Kingston 500GB SATA SSD',          N'Kingston', N'SSD',          750000,  2, 2, NULL),

    -- PSU
    (N'corsair-550w-80-plus-bronze-psu',  N'Corsair 550W 80+ Bronze PSU',      N'Corsair',  N'PSU',         1200000,  6, 2, NULL),
    (N'msi-450w-basic-psu',               N'MSI 450W Basic PSU',               N'MSI',      N'PSU',           750000,  2, 2, NULL),

    -- Case
    (N'asus-mid-tower-atx-case',          N'ASUS Mid Tower ATX Case',          N'ASUS',     N'Case',         1100000,  5, 2, NULL),
    (N'msi-mini-itx-case',                N'MSI Mini-ITX Case',                N'MSI',      N'Case',         1300000,  3, 2, NULL),

    -- Cooler
    (N'cooler-tower-air-cooler-120mm',    N'Cooler Tower Air Cooler 120mm',    N'Corsair',  N'Cooler',        650000,  4, 2, NULL),
    (N'corsair-240mm-aio-liquid-cooler',  N'Corsair 240mm AIO Liquid Cooler',  N'Corsair',  N'Cooler',       2200000,  1, 2, NULL);

    /*
    -- ===== MAU THEM SAN PHAM MOI (copy block nay) =====
    (N'slug-san-pham-moi',                N'Ten san pham',                     N'Brand',    N'Category',    9990000, 10, 2, N'Mo ta ngan neu can'),
    (N'intel-core-i7-14700',              N'Intel Core i7-14700',              N'Intel',    N'CPU',         8900000,  4, 2, NULL),
    (N'nvidia-rtx-4070-12gb',             N'NVIDIA RTX 4070 12GB',             N'NVIDIA',   N'GPU',        15900000,  2, 2, NULL),
    */

/* --------------------------------------------------------------------------
   3) THONG SO KY THUAT (Specs) - lien ket bang ProductSlug
      Format: (ProductSlug, SpecKey, SpecValue, DisplayOrder)
-------------------------------------------------------------------------- */
DECLARE @Specs TABLE (
    ProductSlug   NVARCHAR(220)  NOT NULL,
    SpecKey       NVARCHAR(100)  NOT NULL,
    SpecValue     NVARCHAR(300) NOT NULL,
    DisplayOrder  INT            NOT NULL,
    PRIMARY KEY (ProductSlug, SpecKey)
);

INSERT INTO @Specs (ProductSlug, SpecKey, SpecValue, DisplayOrder)
VALUES
    -- Intel Core i5-14400
    (N'intel-core-i5-14400', N'Socket',         N'LGA1700',              1),
    (N'intel-core-i5-14400', N'Cores/Threads',  N'10C/16T',              2),
    (N'intel-core-i5-14400', N'TDP',              N'65W',                  3),

    -- AMD Ryzen 5 7600
    (N'amd-ryzen-5-7600',    N'Socket',         N'AM5',                  1),
    (N'amd-ryzen-5-7600',    N'Cores/Threads',  N'6C/12T',               2),
    (N'amd-ryzen-5-7600',    N'TDP',              N'65W',                  3),

    -- NVIDIA RTX 4060
    (N'nvidia-rtx-4060-8gb', N'VRAM',             N'8GB GDDR6',            1),
    (N'nvidia-rtx-4060-8gb', N'TDP',              N'115W',                 2),
    (N'nvidia-rtx-4060-8gb', N'Recommended PSU',  N'550W',                 3),

    -- AMD RX 7600 XT
    (N'amd-rx-7600-xt-16gb', N'VRAM',             N'16GB GDDR6',           1),
    (N'amd-rx-7600-xt-16gb', N'TDP',              N'165W',                 2),
    (N'amd-rx-7600-xt-16gb', N'Recommended PSU',  N'600W',                 3),

    -- ASUS B760
    (N'asus-b760-ddr5-motherboard', N'Socket',     N'LGA1700',              1),
    (N'asus-b760-ddr5-motherboard', N'RAM Type',   N'DDR5',                 2),
    (N'asus-b760-ddr5-motherboard', N'Form Factor',N'ATX',                  3),

    -- MSI B550
    (N'msi-b550-ddr4-motherboard',  N'Socket',     N'AM4',                  1),
    (N'msi-b550-ddr4-motherboard',  N'RAM Type',   N'DDR4',                 2),
    (N'msi-b550-ddr4-motherboard',  N'Form Factor',N'ATX',                  3),

    -- Kingston DDR5
    (N'kingston-fury-32gb-ddr5-5600', N'Capacity', N'32GB',                 1),
    (N'kingston-fury-32gb-ddr5-5600', N'RAM Type', N'DDR5',                 2),
    (N'kingston-fury-32gb-ddr5-5600', N'Speed',    N'5600MHz',              3),

    -- Corsair DDR4
    (N'corsair-vengeance-16gb-ddr4-3200', N'Capacity', N'16GB',            1),
    (N'corsair-vengeance-16gb-ddr4-3200', N'RAM Type', N'DDR4',             2),
    (N'corsair-vengeance-16gb-ddr4-3200', N'Speed',    N'3200MHz',           3),

    -- Samsung SSD
    (N'samsung-1tb-nvme-gen4-ssd', N'Capacity',   N'1TB',                  1),
    (N'samsung-1tb-nvme-gen4-ssd', N'Interface',  N'M.2 NVMe PCIe Gen4',   2),

    -- Kingston SSD
    (N'kingston-500gb-sata-ssd',   N'Capacity',   N'500GB',                1),
    (N'kingston-500gb-sata-ssd',   N'Interface',  N'SATA III',             2),

    -- Corsair PSU
    (N'corsair-550w-80-plus-bronze-psu', N'Wattage',    N'550W',           1),
    (N'corsair-550w-80-plus-bronze-psu', N'Efficiency', N'80+ Bronze',     2),

    -- MSI PSU
    (N'msi-450w-basic-psu',        N'Wattage',    N'450W',                 1),
    (N'msi-450w-basic-psu',        N'Efficiency', N'Standard',             2),

    -- ASUS Case
    (N'asus-mid-tower-atx-case',   N'Form Factor',   N'ATX',               1),
    (N'asus-mid-tower-atx-case',   N'GPU Clearance', N'330mm',             2),

    -- MSI Case
    (N'msi-mini-itx-case',         N'Form Factor',   N'Mini-ITX',          1),
    (N'msi-mini-itx-case',         N'GPU Clearance', N'280mm',             2),

    -- Air Cooler
    (N'cooler-tower-air-cooler-120mm', N'Type',     N'Air Cooler',         1),
    (N'cooler-tower-air-cooler-120mm', N'Fan Size', N'120mm',              2),

    -- AIO Cooler
    (N'corsair-240mm-aio-liquid-cooler', N'Type',     N'Liquid AIO',       1),
    (N'corsair-240mm-aio-liquid-cooler', N'Radiator', N'240mm',            2);

    /*
    -- ===== MAU THEM SPECS CHO SAN PHAM MOI =====
    (N'intel-core-i7-14700', N'Socket',        N'LGA1700', 1),
    (N'intel-core-i7-14700', N'Cores/Threads', N'20C/28T', 2),
    (N'intel-core-i7-14700', N'TDP',           N'65W',     3),
    */

/* --------------------------------------------------------------------------
   4) Import vao bang that (bo qua Slug da ton tai)
-------------------------------------------------------------------------- */
INSERT INTO dbo.Products (
    Name, Slug, Description, Price, ImageUrl,
    CategoryId, BrandId,
    StockQuantity, LowStockThreshold, IsActive, CreatedAt
)
SELECT
    p.Name,
    p.Slug,
    p.Description,
    p.Price,
    NULL AS ImageUrl,
    c.Id AS CategoryId,
    b.Id AS BrandId,
    p.StockQuantity,
    p.LowStockThreshold,
    1 AS IsActive,
    @Now AS CreatedAt
FROM @Products p
INNER JOIN dbo.Brands b ON b.Name = p.BrandName
INNER JOIN dbo.Categories c ON c.Name = p.CategoryName
WHERE NOT EXISTS (SELECT 1 FROM dbo.Products existing WHERE existing.Slug = p.Slug);

INSERT INTO dbo.ProductSpecifications (ProductId, SpecKey, SpecValue, Unit, DisplayOrder)
SELECT
    pr.Id,
    s.SpecKey,
    s.SpecValue,
    NULL AS Unit,
    s.DisplayOrder
FROM @Specs s
INNER JOIN dbo.Products pr ON pr.Slug = s.ProductSlug
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.ProductSpecifications existing
    WHERE existing.ProductId = pr.Id
      AND existing.SpecKey = s.SpecKey
);

COMMIT TRANSACTION;

/* --------------------------------------------------------------------------
   5) Kiem tra sau khi import
-------------------------------------------------------------------------- */
PRINT N'--- Tong quan catalog ---';

SELECT
    c.Name AS Category,
    COUNT(*) AS ProductCount
FROM dbo.Products p
INNER JOIN dbo.Categories c ON c.Id = p.CategoryId
WHERE p.IsActive = 1
GROUP BY c.Name
ORDER BY c.Name;

SELECT
    p.Id,
    p.Slug,
    p.Name,
    b.Name AS Brand,
    c.Name AS Category,
    p.Price,
    p.StockQuantity,
    CASE
        WHEN p.StockQuantity <= 0 THEN N'Out of Stock'
        WHEN p.StockQuantity <= p.LowStockThreshold THEN N'Low Stock'
        ELSE N'In Stock'
    END AS StockStatus
FROM dbo.Products p
INNER JOIN dbo.Brands b ON b.Id = p.BrandId
INNER JOIN dbo.Categories c ON c.Id = p.CategoryId
ORDER BY c.Name, p.Name;

PRINT N'Done. Them san pham moi: sua @Products va @Specs roi chay lai script.';

GO

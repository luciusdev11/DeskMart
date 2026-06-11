/*
  DeskMart - Data Block 1 (CPU, GPU, MB, RAM, SSD, Cooler, PSU, Case)
  Chay file nay TRUOC Block 2 va Block 3.
  Schema: khop EF Core (KHONG co cot SKU).
*/
USE [DeskMartDb];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

DECLARE @Now DATETIME2 = SYSUTCDATETIME();

/* --- Brands (tat ca brand dung trong Block 1-3) --- */
INSERT INTO dbo.Brands (Name, IsActive, CreatedAt)
SELECT v.Name, 1, @Now
FROM (VALUES
    (N'Intel'), (N'AMD'), (N'NVIDIA'), (N'ASUS'), (N'MSI'), (N'Corsair'),
    (N'Kingston'), (N'Samsung'), (N'GIGABYTE'), (N'Yeston'), (N'AISURIX'),
    (N'Huananzhi'), (N'G.Skill'), (N'Western Digital'), (N'NZXT'),
    (N'Thermalright'), (N'Seasonic'), (N'Lian Li'), (N'TeamGroup'), (N'Kingmax'),
    (N'Crucial'), (N'Lexar'), (N'Seagate'), (N'Somnambulist'), (N'Deepcool'),
    (N'Noctua'), (N'ID-Cooling'), (N'Montech'), (N'Colorful'), (N'Peladn'),
    (N'Sapphire'), (N'Juhor'), (N'XrayDisk')
) AS v(Name)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Brands b WHERE b.Name = v.Name);

/* --- Categories --- */
INSERT INTO dbo.Categories (Name, Slug, IconName, IsActive, CreatedAt)
SELECT v.Name, v.Slug, v.IconName, 1, @Now
FROM (VALUES
    (N'CPU', N'cpu', N'cpu'),
    (N'GPU', N'gpu', N'gpu'),
    (N'Motherboard', N'motherboard', N'motherboard'),
    (N'RAM', N'ram', N'ram'),
    (N'SSD', N'ssd', N'ssd'),
    (N'PSU', N'psu', N'psu'),
    (N'Case', N'case', N'case'),
    (N'Cooler', N'cooler', N'cooler')
) AS v(Name, Slug, IconName)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Categories c WHERE c.Slug = v.Slug);

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
    (N'intel-core-ultra-9-285k', N'Intel Core Ultra 9 285K', N'Intel', N'CPU', 15500000, 25, 5, N'Vi xu ly the he moi Arrow Lake 24 nhan 24 luong xung nhip toi da 5.7GHz hieu nang dinh cao.'),
    (N'intel-core-ultra-7-265k', N'Intel Core Ultra 7 265K', N'Intel', N'CPU', 11200000, 30, 5, N'Vi xu ly Arrow Lake 20 nhan 20 luong ly tuong cho gaming va do hoa ban chuyen.'),
    (N'intel-core-ultra-5-245k', N'Intel Core Ultra 5 245K', N'Intel', N'CPU', 7900000, 45, 5, N'Bo vi xu ly phan khuc pho thong 14 nhan the he moi tiet kiem dien nang.'),
    (N'amd-ryzen-7-9800x3d', N'AMD Ryzen 7 9800X3D', N'AMD', N'CPU', 13500000, 15, 3, N'Vua gaming the he moi tich hop cong nghe 3D V-Cache dung luong sieu khung.'),
    (N'amd-ryzen-9-9950x', N'AMD Ryzen 9 9950X', N'AMD', N'CPU', 17500000, 20, 4, N'Quai vat do hoa da nhiem kien truc Zen 5 dinh cao voi 16 nhan 32 luong xu ly.'),
    (N'intel-xeon-e5-2678-v3', N'Intel Xeon E5-2678 v3', N'Intel', N'CPU', 950000, 150, 20, N'Dong CPU server cu chuyen dung cay nhieu tai khoan gia lap hoac tool MMO.'),

    -- GPU
    (N'asus-rog-strix-rtx-5090-oc', N'ASUS ROG Strix GeForce RTX 5090 OC', N'ASUS', N'GPU', 68000000, 8, 2, N'Sieu card do hoa kien truc Blackwell 32GB GDDR7 ban custom cao cap nhat.'),
    (N'msi-rtx-5080-suprim-x', N'MSI GeForce RTX 5080 SUPRIM X', N'MSI', N'GPU', 43500000, 12, 2, N'Card do hoa cao cap vo nhom phay xuoc sang trong hieu nang xu ly do hoa muot ma.'),
    (N'gigabyte-rtx-5090-aero-oc', N'GIGABYTE GeForce RTX 5090 AERO OC', N'GIGABYTE', N'GPU', 65000000, 10, 2, N'Phien ban card do hoa 32GB mau trang sang trong danh cho creator chuyen nghiep.'),
    (N'nvidia-blackwell-b200-enterprise', N'NVIDIA Blackwell B200 AI Enterprise', N'NVIDIA', N'GPU', 850000000, 2, 1, N'Sieu chip xu ly tri tue nhan tao va trung tam du lieu LLM cong nghiep.'),
    (N'yeston-rtx-4060-sakura-sugar', N'Yeston GeForce RTX 4060 Sakura Sugar', N'Yeston', N'GPU', 8900000, 25, 4, N'Card do hoa thiet ke phong cach hoa anh dao hong doc dao bat mat.'),
    (N'aisurix-rx-580-8gb-co', N'AISURIX Radeon RX 580 8GB', N'AISURIX', N'GPU', 1250000, 200, 15, N'Dong card do hoa tai che gia re phu hop hoc sinh choi game nhe esport.'),

    -- Motherboard
    (N'asus-rog-maximus-z890-hero', N'ASUS ROG MAXIMUS Z890 HERO', N'ASUS', N'Motherboard', 16500000, 14, 2, N'Bo mach chu toi cao cho CPU Intel Core Ultra ho tro PCIe 5.0.'),
    (N'msi-mag-b650-tomahawk-wifi', N'MSI MAG B650 TOMAHAWK WIFI', N'MSI', N'Motherboard', 5600000, 60, 5, N'Bo mach chu socket AM5 quoc dan thiet ke tan nhiet day dac ben bi.'),
    (N'huananzhi-x99-f8-co', N'Huananzhi X99-F8 Dual', N'Huananzhi', N'Motherboard', 2100000, 85, 10, N'Bo mach chu chay 2 CPU Xeon chuyen dung may tram.'),

    -- RAM
    (N'gskill-trident-z5-royal-gold-32gb', N'G.Skill Trident Z5 Royal Gold 32GB (2x16GB)', N'G.Skill', N'RAM', 6900000, 20, 3, N'RAM DDR5 bus 8000MHz bo vien vang luxury.'),
    (N'corsair-vengeance-lpx-16gb-3200', N'Corsair Vengeance LPX 16GB (2x8GB) DDR4', N'Corsair', N'RAM', 950000, 350, 30, N'RAM quoc dan thiet ke nhom den toi gian cuc ky on dinh.'),

    -- SSD
    (N'samsung-990-pro-heatsink-2tb', N'Samsung 990 PRO HeatSink 2TB NVMe', N'Samsung', N'SSD', 4950000, 40, 5, N'SSD toc do cao tich hop giap tan nhiet nhom cao cap.'),
    (N'wd-caviar-blue-1tb-hdd', N'Western Digital Caviar Blue 1TB HDD', N'Western Digital', N'SSD', 1050000, 180, 15, N'O cung co luu tru du lieu truyen thong dung luong cao ben bi.'),

    -- Cooler
    (N'nzxt-kraken-elite-360-rgb-black', N'NZXT Kraken Elite 360 RGB Black', N'NZXT', N'Cooler', 8200000, 18, 2, N'Tan nhiet nuoc AIO cao cap tich hop man hinh LCD tron sac net.'),
    (N'thermalright-peerless-assassin-120-se', N'Thermalright Peerless Assassin 120 SE', N'Thermalright', N'Cooler', 750000, 140, 10, N'Tan nhiet khi thap doi 6 ong dong hieu nang pha gia.'),

    -- PSU
    (N'seasonic-focus-gx-1000-gold', N'Seasonic Focus GX-1000 1000W 80 Plus Gold', N'Seasonic', N'PSU', 4200000, 35, 4, N'Bo nguon premium full modular do ben linh kien cao.'),

    -- Case
    (N'lian-li-o11-dynamic-evo', N'Lian Li O11 Dynamic EVO Black', N'Lian Li', N'Case', 4100000, 28, 3, N'Vo case hai mat kinh cuong luc sang trong dang cap modding.');

DECLARE @Specs TABLE (
    ProductSlug   NVARCHAR(220) NOT NULL,
    SpecKey       NVARCHAR(100) NOT NULL,
    SpecValue     NVARCHAR(300) NOT NULL,
    DisplayOrder  INT NOT NULL,
    PRIMARY KEY (ProductSlug, SpecKey)
);

INSERT INTO @Specs (ProductSlug, SpecKey, SpecValue, DisplayOrder)
VALUES
    (N'intel-core-ultra-9-285k', N'Socket', N'LGA1851', 1),
    (N'intel-core-ultra-9-285k', N'TDP', N'125W', 2),
    (N'intel-core-ultra-9-285k', N'Cores/Threads', N'24C/24T', 3),

    (N'intel-core-ultra-7-265k', N'Socket', N'LGA1851', 1),
    (N'intel-core-ultra-7-265k', N'TDP', N'125W', 2),
    (N'intel-core-ultra-7-265k', N'Cores/Threads', N'20C/20T', 3),

    (N'intel-core-ultra-5-245k', N'Socket', N'LGA1851', 1),
    (N'intel-core-ultra-5-245k', N'TDP', N'65W', 2),
    (N'intel-core-ultra-5-245k', N'Cores/Threads', N'14C', 3),

    (N'amd-ryzen-7-9800x3d', N'Socket', N'AM5', 1),
    (N'amd-ryzen-7-9800x3d', N'TDP', N'120W', 2),
    (N'amd-ryzen-7-9800x3d', N'Features', N'3D V-Cache', 3),

    (N'amd-ryzen-9-9950x', N'Socket', N'AM5', 1),
    (N'amd-ryzen-9-9950x', N'TDP', N'170W', 2),
    (N'amd-ryzen-9-9950x', N'Cores/Threads', N'16C/32T', 3),

    (N'intel-xeon-e5-2678-v3', N'Socket', N'LGA2011-3', 1),
    (N'intel-xeon-e5-2678-v3', N'TDP', N'120W', 2),
    (N'intel-xeon-e5-2678-v3', N'Cores/Threads', N'12C/24T', 3),

    (N'asus-rog-strix-rtx-5090-oc', N'VRAM', N'32GB GDDR7', 1),
    (N'asus-rog-strix-rtx-5090-oc', N'TDP', N'600W', 2),
    (N'asus-rog-strix-rtx-5090-oc', N'Interface', N'PCIe 5.0 x16', 3),

    (N'msi-rtx-5080-suprim-x', N'VRAM', N'16GB GDDR7', 1),
    (N'msi-rtx-5080-suprim-x', N'TDP', N'400W', 2),

    (N'gigabyte-rtx-5090-aero-oc', N'VRAM', N'32GB GDDR7', 1),
    (N'gigabyte-rtx-5090-aero-oc', N'TDP', N'575W', 2),

    (N'nvidia-blackwell-b200-enterprise', N'TDP', N'1000W', 1),
    (N'nvidia-blackwell-b200-enterprise', N'Memory', N'192GB HBM3e', 2),

    (N'yeston-rtx-4060-sakura-sugar', N'VRAM', N'8GB GDDR6', 1),
    (N'yeston-rtx-4060-sakura-sugar', N'TDP', N'115W', 2),

    (N'aisurix-rx-580-8gb-co', N'VRAM', N'8GB GDDR5', 1),
    (N'aisurix-rx-580-8gb-co', N'TDP', N'185W', 2),

    (N'asus-rog-maximus-z890-hero', N'Socket', N'LGA1851', 1),
    (N'asus-rog-maximus-z890-hero', N'RAM Type', N'DDR5', 2),
    (N'asus-rog-maximus-z890-hero', N'Form Factor', N'ATX', 3),

    (N'msi-mag-b650-tomahawk-wifi', N'Socket', N'AM5', 1),
    (N'msi-mag-b650-tomahawk-wifi', N'RAM Type', N'DDR5', 2),
    (N'msi-mag-b650-tomahawk-wifi', N'Form Factor', N'ATX', 3),

    (N'huananzhi-x99-f8-co', N'Socket', N'LGA2011-3', 1),
    (N'huananzhi-x99-f8-co', N'RAM Type', N'DDR4', 2),
    (N'huananzhi-x99-f8-co', N'Form Factor', N'ATX', 3),

    (N'gskill-trident-z5-royal-gold-32gb', N'RAM Type', N'DDR5', 1),
    (N'gskill-trident-z5-royal-gold-32gb', N'Capacity', N'32GB (2x16GB)', 2),
    (N'gskill-trident-z5-royal-gold-32gb', N'Speed', N'8000MHz', 3),

    (N'corsair-vengeance-lpx-16gb-3200', N'RAM Type', N'DDR4', 1),
    (N'corsair-vengeance-lpx-16gb-3200', N'Capacity', N'16GB (2x8GB)', 2),
    (N'corsair-vengeance-lpx-16gb-3200', N'Speed', N'3200MHz', 3),

    (N'samsung-990-pro-heatsink-2tb', N'Interface', N'NVMe PCIe Gen 4.0', 1),
    (N'samsung-990-pro-heatsink-2tb', N'Capacity', N'2TB', 2),

    (N'wd-caviar-blue-1tb-hdd', N'Interface', N'SATA III', 1),
    (N'wd-caviar-blue-1tb-hdd', N'Capacity', N'1TB', 2),

    (N'nzxt-kraken-elite-360-rgb-black', N'Type', N'Liquid AIO 360mm', 1),
    (N'nzxt-kraken-elite-360-rgb-black', N'Radiator', N'360mm', 2),

    (N'thermalright-peerless-assassin-120-se', N'Type', N'Air Cooler', 1),
    (N'thermalright-peerless-assassin-120-se', N'Fan Size', N'120mm', 2),

    (N'seasonic-focus-gx-1000-gold', N'Wattage', N'1000W', 1),
    (N'seasonic-focus-gx-1000-gold', N'Efficiency', N'80 Plus Gold', 2),

    (N'lian-li-o11-dynamic-evo', N'Form Factor', N'ATX/E-ATX', 1),
    (N'lian-li-o11-dynamic-evo', N'GPU Clearance', N'420mm', 2);

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

PRINT N'--- Block 1 hoan tat ---';
SELECT c.Name AS Category, COUNT(*) AS ProductCount
FROM dbo.Products p INNER JOIN dbo.Categories c ON c.Id = p.CategoryId
WHERE p.IsActive = 1 GROUP BY c.Name ORDER BY c.Name;

GO

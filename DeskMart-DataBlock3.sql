/*
  DeskMart - Data Block 3 (CPU, GPU, RAM, SSD, Cooler bo sung)
  Chay SAU DeskMart-DataBlock2.sql
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
    (N'Colorful'), (N'Peladn'), (N'Sapphire'), (N'Juhor'), (N'XrayDisk')
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
    -- CPU
    (N'intel-core-i9-14900ks-special', N'Intel Core i9-14900KS Special Edition', N'Intel', N'CPU', 18900000, 10, 2, N'Phien ban gioi han ep xung 6.2GHz.'),
    (N'intel-core-i7-14700f-no-gpu', N'Intel Core i7-14700F', N'Intel', N'CPU', 9200000, 45, 5, N'CPU hieu nang cao khong GPU tich hop.'),
    (N'intel-core-i5-13500-workstation', N'Intel Core i5-13500', N'Intel', N'CPU', 6150000, 75, 8, N'14 nhan 20 luong cho may tram.'),
    (N'intel-core-i3-14100f-budget', N'Intel Core i3-14100F', N'Intel', N'CPU', 2750000, 140, 15, N'CPU gia re cho gaming esport.'),
    (N'intel-core-i5-10400-office', N'Intel Core i5-10400', N'Intel', N'CPU', 3100000, 90, 10, N'CPU van phong socket 1200.'),
    (N'intel-core-i7-4790k-legend', N'Intel Core i7-4790K Devil''s Canyon', N'Intel', N'CPU', 1850000, 40, 5, N'CPU hoai co socket 1150.'),
    (N'intel-core-i5-3470-super-co', N'Intel Core i5-3470', N'Intel', N'CPU', 350000, 300, 20, N'CPU sieu re may tinh tien.'),
    (N'intel-xeon-e5-2683-v4-server', N'Intel Xeon E5-2683 v4', N'Intel', N'CPU', 1450000, 110, 12, N'CPU server 16 nhan 32 luong.'),
    (N'amd-ryzen-5-7500f-gaming-king', N'AMD Ryzen 5 7500F', N'AMD', N'CPU', 4100000, 130, 15, N'CPU AM5 gaming khong GPU tich hop.'),
    (N'amd-ryzen-5-5600g-apu', N'AMD Ryzen 5 5600G', N'AMD', N'CPU', 3350000, 95, 10, N'APU Radeon Vega 7 khong can card roi.'),
    (N'amd-ryzen-9-5950x-beast', N'AMD Ryzen 9 5950X', N'AMD', N'CPU', 11500000, 25, 3, N'16 nhan 32 luong socket AM4.'),

    -- GPU
    (N'asus-rog-strix-rtx-5080-oc', N'ASUS ROG Strix GeForce RTX 5080 OC', N'ASUS', N'GPU', 46500000, 15, 3, N'Card RTX 5080 custom cao cap.'),
    (N'msi-rtx-5090-gaming-x-trio', N'MSI GeForce RTX 5090 GAMING X TRIO', N'MSI', N'GPU', 69900000, 7, 2, N'RTX 5090 32GB GDDR7.'),
    (N'colorful-igame-rtx-5090-vulcan', N'Colorful iGame GeForce RTX 5090 Vulcan', N'Colorful', N'GPU', 71500000, 6, 2, N'RTX 5090 man hinh LCD tuy chinh GIF.'),
    (N'gigabyte-rtx-5070ti-aorus-master', N'GIGABYTE GeForce RTX 5070 Ti AORUS Master', N'GIGABYTE', N'GPU', 26500000, 20, 3, N'RTX 5070 Ti tan nhiet cao cap.'),
    (N'nvidia-blackwell-b100-datacenter', N'NVIDIA Blackwell B100 Tensor Core', N'NVIDIA', N'GPU', 690000000, 4, 1, N'Card AI doanh nghiep Blackwell.'),
    (N'nvidia-hopper-h100-pcie', N'NVIDIA Hopper H100 PCIe 80GB', N'NVIDIA', N'GPU', 780000000, 3, 1, N'Card H100 xu ly LLM.'),
    (N'nvidia-rtx-6000-ada-workstation', N'NVIDIA RTX 6000 Ada Generation', N'NVIDIA', N'GPU', 185000000, 5, 1, N'Workstation 48GB GDDR6.'),
    (N'msi-rtx-4070-super-ventus-3x', N'MSI GeForce RTX 4070 SUPER Ventus 3X OC', N'MSI', N'GPU', 18500000, 40, 4, N'RTX 4070 SUPER 3 quat.'),
    (N'sapphire-nitro-rx-7900-gre', N'Sapphire Nitro+ Radeon RX 7900 GRE', N'Sapphire', N'GPU', 16800000, 22, 3, N'RX 7900 GRE ban Nitro+ ARGB.'),
    (N'peladn-rtx-3070ti-gaming-co', N'Peladn GeForce RTX 3070 Ti Gaming', N'Peladn', N'GPU', 8500000, 65, 8, N'RTX 3070 Ti gia re.'),

    -- RAM
    (N'gskill-trident-z5-rgb-32gb-6800', N'G.Skill Trident Z5 RGB 32GB (2x16GB) 6800MHz', N'G.Skill', N'RAM', 3850000, 95, 10, N'DDR5 6800MHz led RGB.'),
    (N'gskill-trident-z-rgb-16gb-3200', N'G.Skill Trident Z RGB 16GB (2x8GB) DDR4', N'G.Skill', N'RAM', 1450000, 180, 15, N'DDR4 led RGB classic.'),
    (N'corsair-dominator-titanium-white-64gb', N'Corsair Dominator Titanium RGB White 64GB (2x32GB)', N'Corsair', N'RAM', 8900000, 15, 2, N'DDR5 64GB white luxury.'),
    (N'kingston-fury-beast-white-rgb-16gb', N'Kingston FURY Beast White RGB 16GB (2x8GB) DDR4', N'Kingston', N'RAM', 1150000, 140, 10, N'DDR4 white ARGB.'),
    (N'juhor-slayer-rgb-anime-16gb', N'Juhor Slayer RGB Anime 16GB (2x8GB) DDR4', N'Juhor', N'RAM', 1050000, 120, 12, N'RAM anime theme DDR4.'),
    (N'kingston-valueram-8gb-2666-co', N'Kingston ValueRAM 8GB DDR4 2666MHz', N'Kingston', N'RAM', 420000, 600, 50, N'RAM van phong gia re.'),

    -- SSD
    (N'samsung-980-pro-2tb-nvme', N'Samsung 980 PRO 2TB M.2 NVMe SSD', N'Samsung', N'SSD', 4100000, 50, 5, N'SSD Samsung 980 PRO 2TB.'),
    (N'crucial-t700-gen5-2tb-superspeed', N'Crucial T700 PCIe Gen 5 NVMe 2TB', N'Crucial', N'SSD', 9450000, 12, 2, N'SSD Gen5 doc 12400MB/s.'),
    (N'wd-black-sn770-1tb-gaming', N'Western Digital WD_BLACK SN770 1TB', N'Western Digital', N'SSD', 2150000, 110, 10, N'SSD gaming WD Black 1TB.'),
    (N'seagate-ironwolf-pro-16tb-nas', N'Seagate IronWolf Pro 16TB Enterprise NAS', N'Seagate', N'SSD', 12800000, 14, 2, N'HDD NAS 16TB enterprise.'),
    (N'xraydisk-nvme-256gb-sieu-co', N'XrayDisk M.2 NVMe 256GB', N'XrayDisk', N'SSD', 390000, 450, 40, N'SSD M.2 gia re.'),

    -- Cooler
    (N'deepcool-mystique-240-lcd', N'Deepcool Mystique 240 LCD', N'Deepcool', N'Cooler', 3250000, 30, 3, N'AIO 240mm man hinh TFT.'),
    (N'nzxt-kraken-elite-360-white', N'NZXT Kraken Elite 360 RGB White', N'NZXT', N'Cooler', 8500000, 16, 2, N'AIO 360 white man hinh LCD.'),
    (N'noctua-nh-u12a-chromax-black', N'Noctua NH-U12A chromax.black', N'Noctua', N'Cooler', 3150000, 40, 4, N'Tan khi U12A 7 ong dong.');

DECLARE @Specs TABLE (
    ProductSlug NVARCHAR(220) NOT NULL,
    SpecKey NVARCHAR(100) NOT NULL,
    SpecValue NVARCHAR(300) NOT NULL,
    DisplayOrder INT NOT NULL,
    PRIMARY KEY (ProductSlug, SpecKey)
);

INSERT INTO @Specs (ProductSlug, SpecKey, SpecValue, DisplayOrder)
VALUES
    (N'intel-core-i9-14900ks-special', N'Socket', N'LGA1700', 1),
    (N'intel-core-i9-14900ks-special', N'TDP', N'150W', 2),
    (N'intel-core-i9-14900ks-special', N'Boost Clock', N'6.2 GHz', 3),

    (N'intel-core-i7-14700f-no-gpu', N'Socket', N'LGA1700', 1),
    (N'intel-core-i7-14700f-no-gpu', N'TDP', N'65W', 2),
    (N'intel-core-i7-14700f-no-gpu', N'Cores/Threads', N'20C/28T', 3),

    (N'intel-core-i5-13500-workstation', N'Socket', N'LGA1700', 1),
    (N'intel-core-i5-13500-workstation', N'TDP', N'65W', 2),
    (N'intel-core-i5-13500-workstation', N'Cores/Threads', N'14C/20T', 3),

    (N'intel-core-i3-14100f-budget', N'Socket', N'LGA1700', 1),
    (N'intel-core-i3-14100f-budget', N'TDP', N'58W', 2),

    (N'intel-core-i5-10400-office', N'Socket', N'LGA1200', 1),
    (N'intel-core-i5-10400-office', N'TDP', N'65W', 2),

    (N'intel-core-i7-4790k-legend', N'Socket', N'LGA1150', 1),
    (N'intel-core-i7-4790k-legend', N'TDP', N'88W', 2),

    (N'intel-core-i5-3470-super-co', N'Socket', N'LGA1155', 1),
    (N'intel-core-i5-3470-super-co', N'TDP', N'77W', 2),

    (N'intel-xeon-e5-2683-v4-server', N'Socket', N'LGA2011-3', 1),
    (N'intel-xeon-e5-2683-v4-server', N'TDP', N'120W', 2),
    (N'intel-xeon-e5-2683-v4-server', N'Cores/Threads', N'16C/32T', 3),

    (N'amd-ryzen-5-7500f-gaming-king', N'Socket', N'AM5', 1),
    (N'amd-ryzen-5-7500f-gaming-king', N'RAM Type', N'DDR5', 2),
    (N'amd-ryzen-5-7500f-gaming-king', N'TDP', N'65W', 3),

    (N'amd-ryzen-5-5600g-apu', N'Socket', N'AM4', 1),
    (N'amd-ryzen-5-5600g-apu', N'RAM Type', N'DDR4', 2),
    (N'amd-ryzen-5-5600g-apu', N'TDP', N'65W', 3),

    (N'amd-ryzen-9-5950x-beast', N'Socket', N'AM4', 1),
    (N'amd-ryzen-9-5950x-beast', N'RAM Type', N'DDR4', 2),
    (N'amd-ryzen-9-5950x-beast', N'TDP', N'105W', 3),

    (N'asus-rog-strix-rtx-5080-oc', N'VRAM', N'16GB GDDR7', 1),
    (N'asus-rog-strix-rtx-5080-oc', N'TDP', N'400W', 2),

    (N'msi-rtx-5090-gaming-x-trio', N'VRAM', N'32GB GDDR7', 1),
    (N'msi-rtx-5090-gaming-x-trio', N'TDP', N'575W', 2),

    (N'colorful-igame-rtx-5090-vulcan', N'VRAM', N'32GB GDDR7', 1),
    (N'colorful-igame-rtx-5090-vulcan', N'TDP', N'575W', 2),

    (N'gigabyte-rtx-5070ti-aorus-master', N'VRAM', N'16GB GDDR7', 1),
    (N'gigabyte-rtx-5070ti-aorus-master', N'TDP', N'300W', 2),

    (N'nvidia-blackwell-b100-datacenter', N'Architecture', N'Blackwell AI', 1),
    (N'nvidia-blackwell-b100-datacenter', N'Memory', N'144GB HBM3e', 2),

    (N'nvidia-hopper-h100-pcie', N'Architecture', N'Hopper', 1),
    (N'nvidia-hopper-h100-pcie', N'Memory', N'80GB HBM3', 2),
    (N'nvidia-hopper-h100-pcie', N'TDP', N'350W', 3),

    (N'nvidia-rtx-6000-ada-workstation', N'VRAM', N'48GB GDDR6', 1),
    (N'nvidia-rtx-6000-ada-workstation', N'TDP', N'300W', 2),

    (N'msi-rtx-4070-super-ventus-3x', N'VRAM', N'12GB GDDR6X', 1),
    (N'msi-rtx-4070-super-ventus-3x', N'TDP', N'220W', 2),

    (N'sapphire-nitro-rx-7900-gre', N'VRAM', N'16GB GDDR6', 1),
    (N'sapphire-nitro-rx-7900-gre', N'TDP', N'260W', 2),

    (N'peladn-rtx-3070ti-gaming-co', N'VRAM', N'8GB GDDR6X', 1),
    (N'peladn-rtx-3070ti-gaming-co', N'TDP', N'290W', 2),

    (N'gskill-trident-z5-rgb-32gb-6800', N'RAM Type', N'DDR5', 1),
    (N'gskill-trident-z5-rgb-32gb-6800', N'Speed', N'6800MHz', 2),
    (N'gskill-trident-z5-rgb-32gb-6800', N'Capacity', N'32GB (2x16GB)', 3),

    (N'gskill-trident-z-rgb-16gb-3200', N'RAM Type', N'DDR4', 1),
    (N'gskill-trident-z-rgb-16gb-3200', N'Capacity', N'16GB (2x8GB)', 2),
    (N'gskill-trident-z-rgb-16gb-3200', N'Speed', N'3200MHz', 3),

    (N'corsair-dominator-titanium-white-64gb', N'RAM Type', N'DDR5', 1),
    (N'corsair-dominator-titanium-white-64gb', N'Capacity', N'64GB (2x32GB)', 2),

    (N'kingston-fury-beast-white-rgb-16gb', N'RAM Type', N'DDR4', 1),
    (N'kingston-fury-beast-white-rgb-16gb', N'Capacity', N'16GB (2x8GB)', 2),

    (N'juhor-slayer-rgb-anime-16gb', N'RAM Type', N'DDR4', 1),
    (N'juhor-slayer-rgb-anime-16gb', N'Capacity', N'16GB (2x8GB)', 2),

    (N'kingston-valueram-8gb-2666-co', N'RAM Type', N'DDR4', 1),
    (N'kingston-valueram-8gb-2666-co', N'Capacity', N'8GB', 2),

    (N'crucial-t700-gen5-2tb-superspeed', N'Interface', N'NVMe PCIe Gen 5.0 x4', 1),
    (N'crucial-t700-gen5-2tb-superspeed', N'Read Speed', N'12400 MB/s', 2),
    (N'crucial-t700-gen5-2tb-superspeed', N'Capacity', N'2TB', 3),

    (N'samsung-980-pro-2tb-nvme', N'Interface', N'NVMe PCIe Gen 4.0', 1),
    (N'samsung-980-pro-2tb-nvme', N'Capacity', N'2TB', 2),

    (N'wd-black-sn770-1tb-gaming', N'Interface', N'NVMe PCIe Gen 4.0', 1),
    (N'wd-black-sn770-1tb-gaming', N'Capacity', N'1TB', 2),

    (N'seagate-ironwolf-pro-16tb-nas', N'Interface', N'SATA III', 1),
    (N'seagate-ironwolf-pro-16tb-nas', N'Capacity', N'16TB', 2),

    (N'xraydisk-nvme-256gb-sieu-co', N'Interface', N'NVMe PCIe Gen 3.0', 1),
    (N'xraydisk-nvme-256gb-sieu-co', N'Capacity', N'256GB', 2),

    (N'deepcool-mystique-240-lcd', N'Type', N'Liquid AIO 240mm', 1),
    (N'deepcool-mystique-240-lcd', N'Radiator', N'240mm', 2),

    (N'nzxt-kraken-elite-360-white', N'Type', N'Liquid AIO 360mm', 1),
    (N'nzxt-kraken-elite-360-white', N'Radiator', N'360mm', 2),
    (N'nzxt-kraken-elite-360-white', N'Color', N'White', 3),

    (N'noctua-nh-u12a-chromax-black', N'Type', N'Air Cooler', 1),
    (N'noctua-nh-u12a-chromax-black', N'Fan Size', N'120mm', 2);

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

PRINT N'--- Block 3 hoan tat ---';

SELECT c.Name AS Category, COUNT(*) AS ProductCount
FROM dbo.Products p INNER JOIN dbo.Categories c ON c.Id = p.CategoryId
WHERE p.IsActive = 1 GROUP BY c.Name ORDER BY c.Name;

SELECT COUNT(*) AS TotalProducts FROM dbo.Products WHERE IsActive = 1;

GO

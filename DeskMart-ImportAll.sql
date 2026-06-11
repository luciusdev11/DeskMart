/*
================================================================================
  DeskMart - Import toan bo catalog (Block 1 -> 2 -> 3)

  Cach chay trong SSMS:
  1. Connect SQL Server (localhost hoac localhost\SQLEXPRESS)
  2. Chay migration truoc neu chua co DB:
       dotnet ef database update --project DeskMart\DeskMart.csproj
  3. Mo va Execute LAN LUOT tung file theo thu tu:
       a) DeskMart-DataBlock1.sql   (brands/categories + lo san pham dau)
       b) DeskMart-DataBlock2.sql
       c) DeskMart-DataBlock3.sql
  4. Hoac mo file nay, copy tung file vao cung cua so Query va F5 lan luot

  Luu y:
  - Script idempotent: Slug da ton tai -> bo qua
  - Khong ghi de san pham cu
  - CategoryName phai la: CPU, GPU, Motherboard, RAM, SSD, PSU, Case, Cooler
================================================================================
*/

USE [DeskMartDb];
GO

PRINT N'=== DeskMart Import All ===';
PRINT N'Buoc 1: Chay DeskMart-DataBlock1.sql';
PRINT N'Buoc 2: Chay DeskMart-DataBlock2.sql';
PRINT N'Buoc 3: Chay DeskMart-DataBlock3.sql';
PRINT N'Sau do chay query kiem tra o cuoi moi block.';

GO

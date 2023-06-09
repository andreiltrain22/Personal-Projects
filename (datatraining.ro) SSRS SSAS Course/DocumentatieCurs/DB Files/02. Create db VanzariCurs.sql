USE master;

-- Drop database
IF DB_ID('VanzariCurs') IS NOT NULL DROP DATABASE [VanzariCurs];

-- If database could not be created due to open connections, abort
IF @@ERROR = 3702 
   RAISERROR('Database cannot be dropped because there are still open connections.', 127, 127) WITH NOWAIT, LOG;

-- Create database
CREATE DATABASE [VanzariCurs];
GO

USE [VanzariCurs]
GO
/****** Object:  Table [dbo].[Categ_Produse]    Script Date: 11/3/2020 12:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categ_Produse](
	[idcategorie] [int] NOT NULL,
	[denumire] [nvarchar](255) NULL,
 CONSTRAINT [PK_idcategorie] PRIMARY KEY CLUSTERED 
(
	[idcategorie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Clienti]    Script Date: 11/3/2020 12:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clienti](
	[idclient] [int] NOT NULL,
	[nume] [nvarchar](255) NULL,
	[locatie] [nvarchar](255) NULL,
 CONSTRAINT [PK_idclient] PRIMARY KEY CLUSTERED 
(
	[idclient] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Depozite]    Script Date: 11/3/2020 12:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Depozite](
	[iddepozit] [int] NOT NULL,
	[denumire] [nvarchar](255) NULL,
	[locatie] [nvarchar](255) NULL,
	[idfurnizor] [int] NULL,
 CONSTRAINT [PK_iddepozit] PRIMARY KEY CLUSTERED 
(
	[iddepozit] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Facturi]    Script Date: 11/3/2020 12:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Facturi](
	[idfactura] [int] NOT NULL,
	[datafactura] [datetime] NULL,
	[idprodus] [int] NOT NULL,
	[cantitate] [decimal](18, 0) NULL,
	[pret] [decimal](18, 0) NULL,
	[idclient] [int] NULL,
	[valoare] [decimal](18, 0) NULL,
 CONSTRAINT [PK_facturi] PRIMARY KEY CLUSTERED 
(
	[idfactura] ASC,
	[idprodus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Furnizori]    Script Date: 11/3/2020 12:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Furnizori](
	[idfurnizor] [int] NOT NULL,
	[denumire] [nvarchar](255) NULL,
	[locatie] [nvarchar](255) NULL,
 CONSTRAINT [PK_idfurnizor] PRIMARY KEY CLUSTERED 
(
	[idfurnizor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Locatii]    Script Date: 11/3/2020 12:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Locatii](
	[idlocatie] [int] NULL,
	[locatie] [nvarchar](255) NULL,
	[cod_judet] [char](2) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Produse]    Script Date: 11/3/2020 12:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Produse](
	[idprodus] [int] NOT NULL,
	[denumire] [nvarchar](255) NULL,
	[idfurnizor] [int] NULL,
	[stoc] [decimal](18, 0) NULL,
	[dataachizitie] [datetime] NULL,
	[perioadaexpirare] [int] NULL,
	[categorieprodus] [int] NULL,
 CONSTRAINT [pk_idprodus] PRIMARY KEY CLUSTERED 
(
	[idprodus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[Categ_Produse] ([idcategorie], [denumire]) VALUES (100, N'papetarie')
INSERT [dbo].[Categ_Produse] ([idcategorie], [denumire]) VALUES (120, N'dulciuri')
INSERT [dbo].[Categ_Produse] ([idcategorie], [denumire]) VALUES (180, N'office birou')
GO
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (1000, N'ABC TRADE', N'Bucuresti')
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (1500, N'LibraKids', N'Bucuresti')
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (1800, N'SanoVert', N'Timisoara')
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (2000, N'IT Training', N'Bucuresti')
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (2500, N'Mak Trade', N'Timisoara')
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (2900, N'Evi Office', N'Ploiesti')
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (3100, N'Niko Trade', N'Bucuresti')
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (3200, N'Café Art', N'Bucuresti')
GO
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (1, N'A', N'bucuresti', 1000)
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (2, N'B', N'bucuresti', 2000)
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (3, N'C', N'timisoara', 3000)
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (4, N'D', N'timisoara', 3500)
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (5, N'E', N'bucuresti', 4200)
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (6, N'F', N'bucuresti', 4700)
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (7, N'G', N'timisoara', 5000)
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (8, N'H', N'bucuresti', 7000)
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (1, CAST(N'2009-02-15T00:00:00.000' AS DateTime), 1127, CAST(27 AS Decimal(18, 0)), CAST(19 AS Decimal(18, 0)), 1500, CAST(513 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (1, CAST(N'2009-02-15T00:00:00.000' AS DateTime), 1211, CAST(10 AS Decimal(18, 0)), CAST(3 AS Decimal(18, 0)), 1500, CAST(30 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (1, CAST(N'2009-02-15T00:00:00.000' AS DateTime), 1244, CAST(12 AS Decimal(18, 0)), CAST(7 AS Decimal(18, 0)), 1500, CAST(84 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (1, CAST(N'2009-02-15T00:00:00.000' AS DateTime), 1729, CAST(18 AS Decimal(18, 0)), CAST(15 AS Decimal(18, 0)), 1500, CAST(270 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (1, CAST(N'2009-02-15T00:00:00.000' AS DateTime), 7913, CAST(19 AS Decimal(18, 0)), CAST(12 AS Decimal(18, 0)), 1500, CAST(228 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (2, CAST(N'2010-03-17T00:00:00.000' AS DateTime), 8705, CAST(1 AS Decimal(18, 0)), CAST(200 AS Decimal(18, 0)), 2500, CAST(200 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (3, CAST(N'2010-04-27T00:00:00.000' AS DateTime), 1799, CAST(25 AS Decimal(18, 0)), CAST(8 AS Decimal(18, 0)), 1800, CAST(200 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (3, CAST(N'2010-04-27T00:00:00.000' AS DateTime), 2318, CAST(100 AS Decimal(18, 0)), CAST(9 AS Decimal(18, 0)), 1800, CAST(900 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (3, CAST(N'2010-04-27T00:00:00.000' AS DateTime), 3927, CAST(100 AS Decimal(18, 0)), CAST(5 AS Decimal(18, 0)), 1800, CAST(500 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (4, CAST(N'2010-05-15T00:00:00.000' AS DateTime), 8500, CAST(200 AS Decimal(18, 0)), CAST(12 AS Decimal(18, 0)), 1000, CAST(2400 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (4, CAST(N'2010-05-15T00:00:00.000' AS DateTime), 8501, CAST(400 AS Decimal(18, 0)), CAST(14 AS Decimal(18, 0)), 1000, CAST(5600 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (4, CAST(N'2010-05-15T00:00:00.000' AS DateTime), 8502, CAST(180 AS Decimal(18, 0)), CAST(12 AS Decimal(18, 0)), 1000, CAST(2160 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (4, CAST(N'2010-05-15T00:00:00.000' AS DateTime), 8503, CAST(600 AS Decimal(18, 0)), CAST(3 AS Decimal(18, 0)), 1000, CAST(1800 AS Decimal(18, 0)))
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (4, CAST(N'2010-05-15T00:00:00.000' AS DateTime), 8504, CAST(100 AS Decimal(18, 0)), CAST(5 AS Decimal(18, 0)), 1000, CAST(500 AS Decimal(18, 0)))
GO
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (1000, N'Atlas', N'Buzau')
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (2000, N'Bic', N'Targoviste')
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (3000, N'ColorAs', N'Timisoara')
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (3500, N'Milka', N'Brasov')
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (4200, N'Africana', N'Brasov')
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (4700, N'Kinder', N'Bucuresti')
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (5000, N'CarniProd', N'Tulcea')
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (7000, N'Ikea', N'Bucuresti')
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (8000, N'Kika', N'Bucuresti')
GO
INSERT [dbo].[Locatii] ([idlocatie], [locatie], [cod_judet]) VALUES (1, N'timisoara', N'TM')
INSERT [dbo].[Locatii] ([idlocatie], [locatie], [cod_judet]) VALUES (2, N'bucuresti', N'B ')
INSERT [dbo].[Locatii] ([idlocatie], [locatie], [cod_judet]) VALUES (3, N'buzau', N'BZ')
INSERT [dbo].[Locatii] ([idlocatie], [locatie], [cod_judet]) VALUES (4, N'ploiesti', N'PH')
INSERT [dbo].[Locatii] ([idlocatie], [locatie], [cod_judet]) VALUES (5, N'targoviste', N'DB')
INSERT [dbo].[Locatii] ([idlocatie], [locatie], [cod_judet]) VALUES (6, N'brasov', N'BV')
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1127, N'caiet dictando', 1000, CAST(2500 AS Decimal(18, 0)), CAST(N'2008-05-12T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1211, N'pix atlas', 1000, CAST(1700 AS Decimal(18, 0)), CAST(N'2008-05-12T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1244, N'creion mecanic', 1000, CAST(4800 AS Decimal(18, 0)), CAST(N'2008-05-12T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1729, N'stilou', 1000, CAST(5000 AS Decimal(18, 0)), CAST(N'2008-05-12T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1799, N'dosar hartie', 1000, CAST(8900 AS Decimal(18, 0)), CAST(N'2008-05-12T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1813, N'marker', 1000, CAST(1500 AS Decimal(18, 0)), CAST(N'2008-05-12T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1815, N'marker A', 2000, CAST(1500 AS Decimal(18, 0)), CAST(N'2008-06-07T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1918, N'stilou rezerva', 2000, CAST(240 AS Decimal(18, 0)), CAST(N'2008-06-07T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (2318, N'dosar sina', 2000, CAST(7800 AS Decimal(18, 0)), CAST(N'2008-06-07T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (3927, N'carte colorat', 3000, CAST(500 AS Decimal(18, 0)), CAST(N'2009-02-01T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (7500, N'carioci', 3000, CAST(800 AS Decimal(18, 0)), CAST(N'2009-02-01T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (7913, N'culori', 3000, CAST(950 AS Decimal(18, 0)), CAST(N'2009-02-01T00:00:00.000' AS DateTime), 1000, 100)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8500, N'milka alune', 3500, CAST(4500 AS Decimal(18, 0)), CAST(N'2010-02-02T00:00:00.000' AS DateTime), 300, 120)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8501, N'milka lapte', 3500, CAST(4500 AS Decimal(18, 0)), CAST(N'2010-02-02T00:00:00.000' AS DateTime), 300, 120)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8502, N'milka baton', 3500, CAST(4500 AS Decimal(18, 0)), CAST(N'2010-02-02T00:00:00.000' AS DateTime), 300, 120)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8503, N'africana', 4200, CAST(5000 AS Decimal(18, 0)), CAST(N'2010-02-02T00:00:00.000' AS DateTime), 300, 120)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8504, N'kinder', 4700, CAST(6000 AS Decimal(18, 0)), CAST(N'2010-02-02T00:00:00.000' AS DateTime), 300, 120)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8705, N'birou', 7000, CAST(50 AS Decimal(18, 0)), CAST(N'2010-01-10T00:00:00.000' AS DateTime), NULL, 180)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8706, N'scaun', 7000, CAST(100 AS Decimal(18, 0)), CAST(N'2010-01-10T00:00:00.000' AS DateTime), NULL, 180)
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8707, N'lampa', 7000, CAST(50 AS Decimal(18, 0)), CAST(N'2010-01-10T00:00:00.000' AS DateTime), NULL, 180)
GO
ALTER TABLE [dbo].[Depozite]  WITH CHECK ADD  CONSTRAINT [FK_Depozite_Furnizori] FOREIGN KEY([idfurnizor])
REFERENCES [dbo].[Furnizori] ([idfurnizor])
GO
ALTER TABLE [dbo].[Depozite] CHECK CONSTRAINT [FK_Depozite_Furnizori]
GO
ALTER TABLE [dbo].[Facturi]  WITH CHECK ADD  CONSTRAINT [FK_Facturi_Clienti] FOREIGN KEY([idclient])
REFERENCES [dbo].[Clienti] ([idclient])
GO
ALTER TABLE [dbo].[Facturi] CHECK CONSTRAINT [FK_Facturi_Clienti]
GO
ALTER TABLE [dbo].[Facturi]  WITH CHECK ADD  CONSTRAINT [FK_Facturi_Produse] FOREIGN KEY([idprodus])
REFERENCES [dbo].[Produse] ([idprodus])
GO
ALTER TABLE [dbo].[Facturi] CHECK CONSTRAINT [FK_Facturi_Produse]
GO
ALTER TABLE [dbo].[Produse]  WITH CHECK ADD  CONSTRAINT [FK_Produse_Categ_Produse] FOREIGN KEY([categorieprodus])
REFERENCES [dbo].[Categ_Produse] ([idcategorie])
GO
ALTER TABLE [dbo].[Produse] CHECK CONSTRAINT [FK_Produse_Categ_Produse]
GO
ALTER TABLE [dbo].[Produse]  WITH CHECK ADD  CONSTRAINT [FK_Produse_Furnizori] FOREIGN KEY([idfurnizor])
REFERENCES [dbo].[Furnizori] ([idfurnizor])
GO
ALTER TABLE [dbo].[Produse] CHECK CONSTRAINT [FK_Produse_Furnizori]
GO

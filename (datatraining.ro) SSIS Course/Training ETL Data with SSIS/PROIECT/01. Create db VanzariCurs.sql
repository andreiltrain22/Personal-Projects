USE [master]
GO
/****** Object:  Database [VanzariCurs]    Script Date: 11/21/2019 9:51:23 PM ******/
CREATE DATABASE [VanzariCurs]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'VanzariCurs_Data', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\VanzariCurs_Data.mdf' , SIZE = 10112KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'VanzariCurs_Log', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\VanzariCurs_Log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 1024KB )
GO
ALTER DATABASE [VanzariCurs] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [VanzariCurs].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [VanzariCurs] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [VanzariCurs] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [VanzariCurs] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [VanzariCurs] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [VanzariCurs] SET ARITHABORT OFF 
GO
ALTER DATABASE [VanzariCurs] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [VanzariCurs] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [VanzariCurs] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [VanzariCurs] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [VanzariCurs] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [VanzariCurs] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [VanzariCurs] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [VanzariCurs] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [VanzariCurs] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [VanzariCurs] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [VanzariCurs] SET  ENABLE_BROKER 
GO
ALTER DATABASE [VanzariCurs] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [VanzariCurs] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [VanzariCurs] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [VanzariCurs] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [VanzariCurs] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [VanzariCurs] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [VanzariCurs] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [VanzariCurs] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [VanzariCurs] SET  MULTI_USER 
GO
ALTER DATABASE [VanzariCurs] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [VanzariCurs] SET DB_CHAINING OFF 
GO
ALTER DATABASE [VanzariCurs] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [VanzariCurs] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [VanzariCurs]
GO
/****** Object:  Table [dbo].[Categ_Produse]    Script Date: 11/21/2019 9:51:23 PM ******/
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
/****** Object:  Table [dbo].[Clienti]    Script Date: 11/21/2019 9:51:23 PM ******/
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
/****** Object:  Table [dbo].[Depozite]    Script Date: 11/21/2019 9:51:23 PM ******/
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
/****** Object:  Table [dbo].[Facturi]    Script Date: 11/21/2019 9:51:23 PM ******/
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
/****** Object:  Table [dbo].[Furnizori]    Script Date: 11/21/2019 9:51:23 PM ******/
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
/****** Object:  Table [dbo].[Locatii]    Script Date: 11/21/2019 9:51:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Locatii](
	[locatie] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Produse]    Script Date: 11/21/2019 9:51:23 PM ******/
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
GO
INSERT [dbo].[Categ_Produse] ([idcategorie], [denumire]) VALUES (120, N'dulciuri')
GO
INSERT [dbo].[Categ_Produse] ([idcategorie], [denumire]) VALUES (180, N'office birou')
GO
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (1000, N'ABC TRADE', N'Bucuresti')
GO
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (1500, N'LibraKids', N'Bucuresti')
GO
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (1800, N'SanoVert', N'Timisoara')
GO
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (2000, N'IT Training', N'Bucuresti')
GO
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (2500, N'Mak Trade', N'Timisoara')
GO
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (2900, N'Evi Office', N'Ploiesti')
GO
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (3100, N'Niko Trade', N'Bucuresti')
GO
INSERT [dbo].[Clienti] ([idclient], [nume], [locatie]) VALUES (3200, N'Café Art', N'Bucuresti')
GO
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (1, N'A', N'bucuresti', 1000)
GO
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (2, N'B', N'bucuresti', 2000)
GO
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (3, N'C', N'timisoara', 3000)
GO
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (4, N'D', N'timisoara', 3500)
GO
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (5, N'E', N'bucuresti', 4200)
GO
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (6, N'F', N'bucuresti', 4700)
GO
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (7, N'G', N'timisoara', 5000)
GO
INSERT [dbo].[Depozite] ([iddepozit], [denumire], [locatie], [idfurnizor]) VALUES (8, N'H', N'bucuresti', 7000)
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (1, CAST(N'2009-02-15 00:00:00.000' AS DateTime), 1127, CAST(27 AS Decimal(18, 0)), CAST(19 AS Decimal(18, 0)), 1500, CAST(513 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (1, CAST(N'2009-02-15 00:00:00.000' AS DateTime), 1211, CAST(10 AS Decimal(18, 0)), CAST(3 AS Decimal(18, 0)), 1500, CAST(30 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (1, CAST(N'2009-02-15 00:00:00.000' AS DateTime), 1244, CAST(12 AS Decimal(18, 0)), CAST(7 AS Decimal(18, 0)), 1500, CAST(84 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (1, CAST(N'2009-02-15 00:00:00.000' AS DateTime), 1729, CAST(18 AS Decimal(18, 0)), CAST(15 AS Decimal(18, 0)), 1500, CAST(270 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (1, CAST(N'2009-02-15 00:00:00.000' AS DateTime), 7913, CAST(19 AS Decimal(18, 0)), CAST(12 AS Decimal(18, 0)), 1500, CAST(228 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (2, CAST(N'2010-03-17 00:00:00.000' AS DateTime), 8705, CAST(1 AS Decimal(18, 0)), CAST(200 AS Decimal(18, 0)), 2500, CAST(200 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (3, CAST(N'2010-04-27 00:00:00.000' AS DateTime), 1799, CAST(25 AS Decimal(18, 0)), CAST(8 AS Decimal(18, 0)), 1800, CAST(200 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (3, CAST(N'2010-04-27 00:00:00.000' AS DateTime), 2318, CAST(100 AS Decimal(18, 0)), CAST(9 AS Decimal(18, 0)), 1800, CAST(900 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (3, CAST(N'2010-04-27 00:00:00.000' AS DateTime), 3927, CAST(100 AS Decimal(18, 0)), CAST(5 AS Decimal(18, 0)), 1800, CAST(500 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (4, CAST(N'2010-05-15 00:00:00.000' AS DateTime), 8500, CAST(200 AS Decimal(18, 0)), CAST(12 AS Decimal(18, 0)), 1000, CAST(2400 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (4, CAST(N'2010-05-15 00:00:00.000' AS DateTime), 8501, CAST(400 AS Decimal(18, 0)), CAST(14 AS Decimal(18, 0)), 1000, CAST(5600 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (4, CAST(N'2010-05-15 00:00:00.000' AS DateTime), 8502, CAST(180 AS Decimal(18, 0)), CAST(12 AS Decimal(18, 0)), 1000, CAST(2160 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (4, CAST(N'2010-05-15 00:00:00.000' AS DateTime), 8503, CAST(600 AS Decimal(18, 0)), CAST(3 AS Decimal(18, 0)), 1000, CAST(1800 AS Decimal(18, 0)))
GO
INSERT [dbo].[Facturi] ([idfactura], [datafactura], [idprodus], [cantitate], [pret], [idclient], [valoare]) VALUES (4, CAST(N'2010-05-15 00:00:00.000' AS DateTime), 8504, CAST(100 AS Decimal(18, 0)), CAST(5 AS Decimal(18, 0)), 1000, CAST(500 AS Decimal(18, 0)))
GO
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (1000, N'Atlas', N'Buzau')
GO
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (2000, N'Bic', N'Targoviste')
GO
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (3000, N'ColorAs', N'Timisoara')
GO
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (3500, N'Milka', N'Brasov')
GO
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (4200, N'Africana', N'Brasov')
GO
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (4700, N'Kinder', N'Bucuresti')
GO
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (5000, N'CarniProd', N'Tulcea')
GO
INSERT [dbo].[Furnizori] ([idfurnizor], [denumire], [locatie]) VALUES (7000, N'Ikea', N'Bucuresti')
GO
INSERT [dbo].[Locatii] ([locatie]) VALUES (N'timisoara')
GO
INSERT [dbo].[Locatii] ([locatie]) VALUES (N'bucuresti')
GO
INSERT [dbo].[Locatii] ([locatie]) VALUES (N'buzau')
GO
INSERT [dbo].[Locatii] ([locatie]) VALUES (N'ploiesti')
GO
INSERT [dbo].[Locatii] ([locatie]) VALUES (N'targoviste')
GO
INSERT [dbo].[Locatii] ([locatie]) VALUES (N'brasov')
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1127, N'caiet dictando', 1000, CAST(2500 AS Decimal(18, 0)), CAST(N'2008-05-12 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1211, N'pix atlas', 1000, CAST(1700 AS Decimal(18, 0)), CAST(N'2008-05-12 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1244, N'creion mecanic', 1000, CAST(4800 AS Decimal(18, 0)), CAST(N'2008-05-12 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1729, N'stilou', 1000, CAST(5000 AS Decimal(18, 0)), CAST(N'2008-05-12 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1799, N'dosar hartie', 1000, CAST(8900 AS Decimal(18, 0)), CAST(N'2008-05-12 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1813, N'marker', 1000, CAST(1500 AS Decimal(18, 0)), CAST(N'2008-05-12 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1815, N'marker A', 2000, CAST(1500 AS Decimal(18, 0)), CAST(N'2008-06-07 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (1918, N'stilou rezerva', 2000, CAST(240 AS Decimal(18, 0)), CAST(N'2008-06-07 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (2318, N'dosar sina', 2000, CAST(7800 AS Decimal(18, 0)), CAST(N'2008-06-07 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (3927, N'carte colorat', 3000, CAST(500 AS Decimal(18, 0)), CAST(N'2009-02-01 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (7500, N'carioci', 3000, CAST(800 AS Decimal(18, 0)), CAST(N'2009-02-01 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (7913, N'culori', 3000, CAST(950 AS Decimal(18, 0)), CAST(N'2009-02-01 00:00:00.000' AS DateTime), 1000, 100)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8500, N'milka alune', 3500, CAST(4500 AS Decimal(18, 0)), CAST(N'2010-02-02 00:00:00.000' AS DateTime), 300, 120)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8501, N'milka lapte', 3500, CAST(4500 AS Decimal(18, 0)), CAST(N'2010-02-02 00:00:00.000' AS DateTime), 300, 120)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8502, N'milka baton', 3500, CAST(4500 AS Decimal(18, 0)), CAST(N'2010-02-02 00:00:00.000' AS DateTime), 300, 120)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8503, N'africana', 4200, CAST(5000 AS Decimal(18, 0)), CAST(N'2010-02-02 00:00:00.000' AS DateTime), 300, 120)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8504, N'kinder', 4700, CAST(6000 AS Decimal(18, 0)), CAST(N'2010-02-02 00:00:00.000' AS DateTime), 300, 120)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8705, N'birou', 7000, CAST(50 AS Decimal(18, 0)), CAST(N'2010-01-10 00:00:00.000' AS DateTime), NULL, 180)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8706, N'scaun', 7000, CAST(100 AS Decimal(18, 0)), CAST(N'2010-01-10 00:00:00.000' AS DateTime), NULL, 180)
GO
INSERT [dbo].[Produse] ([idprodus], [denumire], [idfurnizor], [stoc], [dataachizitie], [perioadaexpirare], [categorieprodus]) VALUES (8707, N'lampa', 7000, CAST(50 AS Decimal(18, 0)), CAST(N'2010-01-10 00:00:00.000' AS DateTime), NULL, 180)
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
USE [master]
GO
ALTER DATABASE [VanzariCurs] SET  READ_WRITE 
GO

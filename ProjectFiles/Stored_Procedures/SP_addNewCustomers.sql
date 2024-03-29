USE [TelephoneCompany]
GO
/****** Object:  StoredProcedure [dbo].[addNewCustomers]    Script Date: 11/17/2019 10:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amit, Jim, James, Thomas
-- Create date: 2019/11/17
-- Description:	Add new customers
-- =============================================
CREATE PROCEDURE [dbo].[addNewCustomers] 
	@filePath varchar(MAX)
AS
BEGIN
	DECLARE @sqlString VARCHAR(MAX);
	
	CREATE TABLE #customers(
		[telephone] [float] NOT NULL,
		[name] [varchar](50) NULL,
		[address] [varchar](MAX) NULL,
		[serviceName] [varchar](50) NULL,
		[salesRepId] [int] NULL,
		[commission] [int] NULL
		Primary Key (telephone)
	)

	SET @sqlString = 
	'INSERT INTO #customers(telephone,name,address,serviceName,salesRepID,commission)
	SELECT telephone as telephone,name as name,address as address,serviceName as serviceName,salesRepID as salesRepID,commission as commission
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'',''Excel 12.0;Database=' + @filePath + ';HDR=YES''
	,''SELECT * FROM [Sheet1$]'')';	

	Exec(@sqlString)

	DECLARE @telephone float;
	DECLARE @name varchar(500);
	DECLARE @address varchar(500);
	DECLARE @serviceId int;
	DECLARE @serviceName VARCHAR(50);
	DECLARE @salesRepId int;
	DECLARE @commission float;

	SELECT @telephone = min(telephone) FROM #customers;

	WHILE @telephone IS NOT NULL
		BEGIN
			SELECT @serviceName = (SELECT serviceName FROM #customers WHERE telephone = @telephone);
			SELECT @serviceId = (SELECT serviceId FROM service WHERE service.serviceName = @serviceName);
			SELECT @name = (SELECT name FROM #customers WHERE telephone = @telephone);
			SELECT @address = (SELECT address FROM #customers WHERE telephone = @telephone);
			SELECT @salesRepId = (SELECT salesRepId FROM #customers WHERE telephone = @telephone);
			SELECT @commission = (SELECT commission FROM #customers WHERE telephone = @telephone);
			INSERT INTO customer(telephone, name, address, serviceId, salesRepId,commission)
			VALUES (@telephone, @name, @address, @serviceId, @salesRepId,@commission);

			SELECT @telephone = min(telephone) FROM #customers WHERE telephone > @telephone;
		END
END

DROP TABLE #customers

SELECT * FROM customer

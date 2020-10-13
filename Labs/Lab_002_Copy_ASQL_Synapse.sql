--===========================================================================================================================
-- Lab 2 : Copy multiple tables in bulk by using Azure Data Factory in the Azure portal
--===========================================================================================================================
1. Link : https://docs.microsoft.com/en-us/azure/data-factory/tutorial-bulk-copy-portal

2. Scenario
	- This tutorial demonstrates copying a number of tables from Azure SQL Database to Azure Synapse Analytics (formerly SQL DW)
	- You can apply the same pattern in other copy scenarios as well
	- For example, copying tables from SQL Server/Oracle to Azure SQL Database/Azure Synapse Analytics (formerly SQL DW)/Azure Blob,
		copying different paths from Blob to Azure SQL Database tables
	- The first pipeline passes the list of tables as a value for the parameter

3. Steps
	- Pipeline : 013_PL_COPY_IterateSQLTables
		- Look up SQL DB to get table list
		- Feed to and execute pipeline IterateAndCopySQLTables

	- Pipeline : 013_PL_COPY_GetTableListAndTriggerCopy
		- For each table in the table list
		- Copy data from the SQL table to corresponding SQL DW table
			using staged copy + polybase

4. Linked services
	- LS_ASQL0319	: Source
	- LS_ABLB_KV	: Staging storage
	- LS_SYNPSE0318	: Target, DW

5. Dataset
	- DS_ASQL0319_Table : LS_ASQL0319
		- Edit 			: dbo.dummyName
	- DS_SYNPSE0318		: LS_SYNPSE0318
		- Parameter
			DWTableName
			DWSchema
		- Connection
			@dataset().DWSchema
			@dataset().DWTableName

6. Pipeline
	- Name	: 013_PL_COPY_IterateSQLTables
		- Parameter	: tableList (Array)

	- Add ForEach activity
		- Name	: IterateSQLTables
		- Items	: @pipeline().parameters.tableList
	
		- Add Copy activity
			- Name : CopyDataToDW
			- Source
				- Dataset 	: DS_ASQL0319_Table
				- Query 	:
					SQL>
					SELECT * FROM [@{item().TABLE_SCHEMA}].[@{item().TABLE_NAME}]
			- Sink
				- Dataset 	: DS_SYNPSE0318
					- DWTableName	: @item().TABLE_NAME
					- DWSchema		: @item().TABLE_SCHEMA
				- Polybase
			
	- Name	: 013_PL_COPY_GetTableListAndTriggerCopy
		- Add Lookup activity
			- Name	: LookupTableList
			- Setting
				- Dataset	: DS_ASQL0319_Table
				- Query		:
					SQL>
					SELECT TABLE_SCHEMA, TABLE_NAME FROM information_schema.TABLES \
					WHERE TABLE_TYPE = 'BASE TABLE' and TABLE_SCHEMA = 'SalesLT'
					and TABLE_NAME in ('Customer','Address')
				- First row only : unchecked
		
		- Add Execute pipeline
			- Name	: TriggerCopy
			- Invoked pipeline 	: 013_PL_COPY_IterateSQLTables
				- tableList 	: @activity('LookupTableList').output.value

7. Create tables in Synapse0318 DB

create schema SalesLT;

-- drop table [SalesLT].[Customer]
;

CREATE TABLE [SalesLT].[Customer]
(
	[CustomerID] [int] NOT NULL,
	[NameStyle] bit NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] nvarchar(50) NOT NULL,
	[MiddleName] nvarchar(50) NULL,
	[LastName] nvarchar(50) NOT NULL,
	[Suffix] [nvarchar](10) NULL,
	[CompanyName] [nvarchar](128) NULL,
	[SalesPerson] [nvarchar](256) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[Phone] nvarchar(25) NULL,
	[PasswordHash] [varchar](128) NOT NULL,
	[PasswordSalt] [varchar](10) NOT NULL,
	[rowguid] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
)
;

select	*
from	[SalesLT].[Customer]
;

-- drop table [SalesLT].[Address]

CREATE TABLE [SalesLT].[Address](
	[AddressID] [int] NOT NULL,
	[AddressLine1] [nvarchar](60) NOT NULL,
	[AddressLine2] [nvarchar](60) NULL,
	[City] [nvarchar](30) NOT NULL,
	[StateProvince] nvarchar(50) NOT NULL,
	[CountryRegion] nvarchar(50) NOT NULL,
	[PostalCode] [nvarchar](15) NOT NULL,
	[rowguid] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
)
;

select	*
from	saleslt.address
			
--(End)----------------------------------------------------------------------------------------------------------------------

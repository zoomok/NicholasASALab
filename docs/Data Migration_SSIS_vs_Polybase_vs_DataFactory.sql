--===========================================================================================================================
-- Lab 1 : Load DimBigProduct in On-premises to Azure DW using SSIS
-- Dimension table is light (count = 30,300)
--===========================================================================================================================
1. Source table :
	- Local Database (DESKTOP-E7F3VBA\SQLEXPRESS)
	- Table		: DimBigProduct

2. Target table	:
	- Create table in Azure DW
	- Schema	: Prod
	- Table 	: DimBigProduct
	
3. Create SSIS package
	- Visual Studio 2019 : Integration Service Project
	- Project	: DataLoadToAzureSQLDW
	- Location	: S:\My_ASA\SSIS
	- Package	: DF Migrate DimBigProduct to Azure
	- Run

4. Copy dimension table data to Azure SQL DW

--===========================================================================================================================
-- Lab 2 : Polybase 6 step process
--===========================================================================================================================
1. Create a master key
2. Create a database scoped credential with the storage key
3. Create an external data source
4. Create external file format
5. Create an external table
6. Load from the external table

--===========================================================================================================================
-- Lab 3 : Load FactTransactionHistory in On-premises to Azure DW using Polybase
-- Fact table is heavy (count = 37,605,696)
--===========================================================================================================================
1. Export table to flat file
	- Local database	: SSMS
	- Task	-> Export data
	- Destination		: Flat File destination
	- File name			: s:\My_ASA\FactTransactionHistory.txt
	- Column names in the first data row : Unchecked
	- Source transaction : FactTransactionHistory
	- Run immediately
	- File created		: 1 GB

2. Create blob storage account
	- data lake storage	: datalake0318
	
3. Upload flat file to blog storage
	- upload to container(demo)/(folder)FTH

4. Run Polybase 6 steps process
	- PolybaseDemo.sql

5. Monitor and confirm successful migration
	- MonitoringThePolybaseLoad.sql

6. Confirm 60 distributions in destination table
	- DBCC PDW_SHOWSPACEUSED('prod.FactTransactionHistory');

--===========================================================================================================================
-- Lab 4 : Load FactTransactionHistory in On-premises to Azure DW using Azure Data Factory
-- Fact table is heavy (count = 37,605,696)
--===========================================================================================================================
1. Export table to flat file
--> Lab 3

2. Create blob storage account
--> Lab 3

3. Upload flat file to blog storage
--> Lab 3

4. Create Data Factory account
	- datafactory-0318
	- Pipeline : [prod].[FactTransactionHistoryADF]

5. Create destination table
SQL>
CREATE TABLE [prod].[FactTransactionHistoryADF]
(
	[TransactionID] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[OrderDate] [datetime] NULL,
	[Quantity] [int] NULL,
	[ActualCost] [money] NULL
)

6. Ccreate and run Data factory pipeline to move data
--> Run ADF pipeline

7. Monitor and verify destination table
	--> Monitor pipeline
	- SQL>
	select	count(1)
	from	[prod].[FactTransactionHistoryADF]
	- DBCC PDW_SHOWSPACEUSED('prod.FactTransactionHistory');


























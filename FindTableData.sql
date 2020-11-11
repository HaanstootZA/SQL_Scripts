USE Merlin

SELECT
	[schema].name as [SchemaName],
	[table].name as [TableName],
	[column].name as [Column]
	,CONCAT('SELECT TOP 10 * FROM [',[schema].name,'].[',[table].name,'] WITH (NOLOCK) WHERE ' + [column].name + ' = ''7EF6A91E-2ECA-4D01-B6DC-E7EEDA888419''') as [SelectQuery]
	--,CONCAT('SELECT TOP 10 [',[column].name,'] FROM [',[schema].name,'].[',[table].name,'] WITH (NOLOCK)') as [SelectQuery]
	--,CONCAT('SELECT TOP 10 [',[column].name,'] FROM [',[schema].name,'].[',[table].name,'] WITH (NOLOCK)') as [SelectQuery]
FROM sys.tables [table] WITH(NOLOCK)
INNER JOIN sys.[schemas] [schema] WITH(NOLOCK)
	ON [table].[schema_id] = [schema].[schema_id]

INNER JOIN sys.[columns] [column] WITH(NOLOCK)
	ON [column].[object_id] = [table].[object_id]

----CHECK IF THE COLUMN HAS A FOREIGN KEY CONSTRAINT
INNER JOIN sys.[foreign_key_columns] fkCol
	ON [fkCol].[parent_column_id] = [column].[column_id]
	AND [fkCol].[parent_object_id] = [table].[object_id]

----GET REFERENCE FOREIGN KEY TABLE REFERENCE DETAILS
INNER JOIN sys.tables [fkRefTable]
	ON [fkRefTable].[object_id] = [fkCol].[referenced_object_id]

------GET REFERENCE FOREIGN KEY COLUMN DETAILS
INNER JOIN sys.[columns] [fkRefColumn] WITH(NOLOCK)
	ON
		[fkRefColumn].[column_id] = [fkCol].[referenced_column_id]
	AND [fkRefColumn].[object_id] = [fkRefTable].[object_id]

------GET REFERENCE FOREIGN KEY SCHEMA DETAILS
INNER JOIN sys.[schemas] [fkRefSchema] WITH(NOLOCK)
	ON [fkRefSchema].[schema_id] = [fkRefTable].[schema_id]

----CHECK IF THE COLUMN IS A PRIMARY KEY
--INNER JOIN sys.[index_columns] idxCol
--	ON
--		idxCol.[column_id] = [column].[column_id]
--	AND idxCol.[object_id] = [table].[object_id]
--INNER JOIN sys.[indexes] idx
--	ON
--		idx.[object_id] = [table].[object_id]
--	AND idx.[index_id] = idxCol.[index_id]

WHERE 
--[schema].name LIKE 'dbo'
--[table].name LIKE '%%'
--AND
	[fkRefTable].name LIKE 'Account'
AND [fkRefColumn].name LIKE 'AccountId'
AND [fkRefSchema].name LIKE 'dbo'
--AND idx.is_primary_key = 1
ORDER BY [table].name

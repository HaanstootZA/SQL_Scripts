USE OTIS
--USE CDS

DECLARE @SearchText varchar(1000) = '%V2%',
		@Schema varchar(1000) = '%blue%';

WITH CTE as
(
    SELECT ROUTINE_NAME as [StoredProcedure], ROUTINE_SCHEMA as [Schema], ROUTINE_DEFINITION as [Script]
        FROM INFORMATION_SCHEMA.ROUTINES WITH(NOLOCK)
        WHERE
			ROUTINE_TYPE='PROCEDURE'
        AND ROUTINE_DEFINITION LIKE @SearchText ESCAPE '!'

    UNION ALL
    
	SELECT OBJECT_NAME(id) as [StoredProcedure], OBJECT_SCHEMA_NAME(id) as [Schema], [text] as [Script]
        FROM SYSCOMMENTS WITH(NOLOCK)
        WHERE
			OBJECTPROPERTY(id, 'IsProcedure') = 1
		AND [text] LIKE @SearchText ESCAPE '!'

        GROUP BY OBJECT_NAME(id), OBJECT_SCHEMA_NAME(id), [text]

    UNION ALL
    
	SELECT OBJECT_NAME(object_id) as [StoredProcedure], OBJECT_SCHEMA_NAME(object_id) as [Schema], [definition] as [Script]
        FROM sys.sql_modules WITH(NOLOCK)
        WHERE
			OBJECTPROPERTY(object_id, 'IsProcedure') = 1
        AND [definition] LIKE @SearchText ESCAPE '!'
)

SELECT DISTINCT t.[StoredProcedure], t.[Script], t.[Schema], t.[Schema] + '.' + t.[StoredProcedure]
FROM CTE t
WHERE t.[Schema] LIKE (@Schema)
ORDER BY T.[Schema], T.[StoredProcedure]

DECLARE @SearchText varchar(1000) = '%SBTech_Account%',
		@Schema varchar(1000) = '';

WITH CTE as
(
    SELECT ROUTINE_NAME as [ROUTINE_NAME], ROUTINE_SCHEMA as [Schema], ROUTINE_DEFINITION as [Script]
        FROM INFORMATION_SCHEMA.ROUTINES WITH(NOLOCK)
        WHERE
			ROUTINE_TYPE IN ('PROCEDURE', 'TRIGGER', 'FUNCTION')
        AND ROUTINE_DEFINITION LIKE @SearchText

    UNION ALL
    
	SELECT OBJECT_NAME(id) as [ROUTINE_NAME], OBJECT_SCHEMA_NAME(id) as [Schema], [text] as [Script]
        FROM SYSCOMMENTS WITH(NOLOCK)
        WHERE ( OBJECTPROPERTY(id, 'IsTrigger') = 1 OR OBJECTPROPERTY(id, 'IsProcedure') = 1 OR OBJECTPROPERTY(id, 'IsFunction') = 1)
		AND [text] LIKE @SearchText

        GROUP BY OBJECT_NAME(id), OBJECT_SCHEMA_NAME(id), [text]

    UNION ALL
    
	SELECT OBJECT_NAME(object_id) as [ROUTINE_NAME], OBJECT_SCHEMA_NAME(object_id) as [Schema], [definition] as [Script]
        FROM sys.sql_modules WITH(NOLOCK)
        WHERE ( OBJECTPROPERTY(object_id, 'IsTrigger') = 1 OR OBJECTPROPERTY(object_id, 'IsProcedure') = 1 OR OBJECTPROPERTY(object_id, 'IsFunction') = 1)
        AND [definition] LIKE @SearchText
)

SELECT DISTINCT t.[ROUTINE_NAME], t.[Script], t.[Schema]
FROM CTE t
--WHERE t.[Schema] = @Schema
ORDER BY T.[Schema], T.[ROUTINE_NAME]

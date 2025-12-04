USE Formula1;
GO

DROP PROCEDURE raw.union_tables_by_pattern;
GO

CREATE PROCEDURE raw.union_tables_by_pattern
	@pattern NVARCHAR(100),
	@OutputSQL NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX) = '';
	DECLARE @tableName NVARCHAR(256);
	DECLARE table_cursor CURSOR FOR
    SELECT TABLE_SCHEMA + '.' + TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME LIKE '%' + @pattern + '%_20%';
	OPEN table_cursor;
	FETCH NEXT FROM table_cursor INTO @tableName;
	WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql += 'SELECT * FROM ' + @tableName + ' UNION ALL ';
        FETCH NEXT FROM table_cursor INTO @tableName;
    END
	CLOSE table_cursor;
	DEALLOCATE table_cursor;
	IF LEN(@sql) > 0
		SET @sql = LEFT(@sql, LEN(@sql) - 10);
	PRINT @sql;
	SET @OutputSQL = @sql;
END;
GO

--EXEC raw.union_tables_by_pattern @pattern = 'sessions';
--EXEC raw.union_tables_by_pattern @pattern = 'meetings';

-- Ejecutar esta consulta y copiar/pegar el resultado
--SELECT 
--    'SELECT * FROM ' + TABLE_SCHEMA + '.' + TABLE_NAME + ' UNION ALL ' AS UnionStatement
--FROM 
--    INFORMATION_SCHEMA.TABLES
--WHERE 
--    TABLE_TYPE = 'BASE TABLE' 
--    AND TABLE_NAME LIKE 'sessions_20%' -- Filtra por el patrón deseado
--ORDER BY 
--    TABLE_NAME;

CREATE OR ALTER PROCEDURE dbo.usp_Create_Union_View
    @pattern NVARCHAR(100) --'sessions', 'meetings', 'drivers', 'laps', 'cars_data
AS
BEGIN
    SET NOCOUNT ON; --para que no imprima resultados en la ejecucion del procedure

    -- 1. Declarar variables para la lógica interna
    DECLARE @GeneratedSQL NVARCHAR(MAX);
    DECLARE @create_view_sql NVARCHAR(MAX);
    DECLARE @view_name NVARCHAR(100);

    -- 2. Ejecutar el procedimiento 'raw.union_tables_by_pattern'
    --    y capturar el SQL de UNION ALL en @GeneratedSQL
    EXEC raw.union_tables_by_pattern
        @pattern = @pattern,
        @OutputSQL = @GeneratedSQL OUTPUT;

    -- 3. Verificar si el SQL se generó correctamente
    IF @GeneratedSQL IS NULL OR @GeneratedSQL = ''
    BEGIN
        PRINT 'ERROR: No se pudo generar la sentencia UNION ALL para el patrón: ' + @pattern;
        RETURN;
    END

    -- 4. Construir el nombre de la vista final (ej: dbo.vw_all_sessions)
    --    Nota: Aquí asumo que la vista final va en el esquema 'dbo'.
    SET @view_name = 'raw.vw_all_' + @pattern;

    -- 5. Construir el comando completo para crear/alterar la vista
    SET @create_view_sql = '
        CREATE OR ALTER VIEW ' + @view_name + ' 
        AS 
        ' + @GeneratedSQL;

    -- 6. Imprimir el comando para auditoría o depuración
    PRINT 'Comando SQL Generado: ' + @create_view_sql;

    -- 7. Ejecutar el comando dinámicamente para crear/actualizar la vista
    EXECUTE sp_executesql @create_view_sql;

    -- Confirmación
    PRINT '---';
    PRINT 'Vista ' + @view_name + ' creada/actualizada exitosamente.';
 
END;
GO

EXEC dbo.usp_Create_Union_View @pattern = 'sessions';
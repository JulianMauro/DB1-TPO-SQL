-- Creacion de la base de datos

CREATE DATABASE TP;
GO

USE TP;
GO

CREATE TABLE Alumno(
    legajo INT IDENTITY (64000,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    dni INT NOT NULL UNIQUE,
    CONSTRAINT check_dni CHECK (dni > 0),
    email VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE Profesor(
    id_profesor INT IDENTITY (12000,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(60) NOT NULL UNIQUE,
    categoria VARCHAR(50) NOT NULL,
    sueldo INT NOT NULL,
    CONSTRAINT check_sueldo CHECK (sueldo > 0)
);

CREATE TABLE Materia(
    id_materia INT IDENTITY PRIMARY KEY,
    nombre_materia VARCHAR(50) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    fecha_inicio DATE NOT NULL,
    id_profesor INT NOT NULL,
    CONSTRAINT fk_id_profesor FOREIGN KEY (id_profesor) REFERENCES Profesor(id_profesor),
    cupos INT NOT NULL,
    CONSTRAINT check_cupos CHECK(cupos >= 0),
    precio INT NOT NULL,
    CONSTRAINT check_precio CHECK (precio > 0)
);

CREATE TABLE Inscripcion(
    id_inscripcion INT IDENTITY PRIMARY KEY,
    id_alumno INT NOT NULL,
    CONSTRAINT fk_legajo FOREIGN KEY (id_alumno) REFERENCES Alumno(legajo),
    fecha_inscripcion DATE NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    CONSTRAINT check_metodo CHECK (metodo_pago IN ('CREDITO','DEBITO','TRANSFERENCIA','EFECTIVO')),
    cantidad_materias INT NOT NULL,
    CONSTRAINT check_cantidad_insc CHECK (cantidad_materias > 0),
    total INT NOT NULL,
    CONSTRAINT check_total_inscripcion CHECK (total > 0)
);

CREATE TABLE Detalle_Inscripcion(
    id_detalle INT IDENTITY PRIMARY KEY,
    id_inscripcion INT NOT NULL,
    CONSTRAINT fk_id_inscripcion FOREIGN KEY (id_inscripcion) REFERENCES Inscripcion(id_inscripcion),
    id_materia INT NOT NULL,
    CONSTRAINT fk_id_materia_detalle FOREIGN KEY (id_materia) REFERENCES Materia(id_materia),
    precio_unitario INT NOT NULL,
    CONSTRAINT check_precio_uni CHECK (precio_unitario > 0)
);


-- ============================================================
-- CARGA DE DATOS MEDIANTE PROCEDIMIENTOS ALMACENADOS
--
-- En lugar de cargar los datos con sentencias INSERT directas, toda la
-- carga inicial se realiza a traves de procedimientos almacenados de alta.
-- Ventajas frente al INSERT directo:
--   * Centralizan las validaciones (DNI/email duplicados, existencia del
--     profesor, montos > 0, metodo de pago valido).
--   * Calculan automaticamente datos derivados: en la inscripcion el total
--     y la cantidad de materias se calculan solos a partir de las materias.
--   * Son reutilizables: el mismo SP sirve para la carga inicial y para el
--     alta de nuevos registros desde la aplicacion.
--   * Insertan de a una fila, por lo que conviven correctamente con los
--     triggers de validacion (Etapa 8).
-- ============================================================
GO

-- Alta de profesor: valida sueldo > 0 y email no repetido.
CREATE PROCEDURE SP_Alta_Profesor
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @email VARCHAR(60),
    @categoria VARCHAR(50),
    @sueldo INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @sueldo <= 0
            RAISERROR('El sueldo debe ser mayor a 0', 16, 1);

        IF EXISTS (SELECT 1 FROM Profesor WHERE email = @email)
            RAISERROR('Ya existe un profesor con ese email', 16, 1);

        INSERT INTO Profesor (nombre, apellido, email, categoria, sueldo)
        VALUES (@nombre, @apellido, @email, @categoria, @sueldo);

        PRINT 'Profesor dado de alta correctamente. Nuevo id: ' + CAST(SCOPE_IDENTITY() AS VARCHAR(10));
    END TRY
    BEGIN CATCH
        PRINT 'Error al dar de alta el profesor: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Alta de alumno: valida dni > 0 y que no exista otro alumno con el mismo dni o email.
CREATE PROCEDURE SP_Alta_Alumno
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni INT,
    @email VARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @dni <= 0
            RAISERROR('El DNI debe ser mayor a 0', 16, 1);

        IF EXISTS (SELECT 1 FROM Alumno WHERE dni = @dni)
            RAISERROR('Ya existe un alumno con ese DNI', 16, 1);

        IF EXISTS (SELECT 1 FROM Alumno WHERE email = @email)
            RAISERROR('Ya existe un alumno con ese email', 16, 1);

        INSERT INTO Alumno (nombre, apellido, dni, email)
        VALUES (@nombre, @apellido, @dni, @email);

        PRINT 'Alumno dado de alta correctamente. Nuevo legajo: ' + CAST(SCOPE_IDENTITY() AS VARCHAR(10));
    END TRY
    BEGIN CATCH
        PRINT 'Error al dar de alta el alumno: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Alta de materia: valida que el profesor exista y que los montos/cupos sean validos.
CREATE PROCEDURE SP_Alta_Materia
    @nombre_materia VARCHAR(50),
    @categoria VARCHAR(50),
    @fecha_inicio DATE,
    @id_profesor INT,
    @cupos INT,
    @precio INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Profesor WHERE id_profesor = @id_profesor)
            RAISERROR('El profesor indicado no existe', 16, 1);

        IF @cupos < 0
            RAISERROR('Los cupos no pueden ser negativos', 16, 1);

        IF @precio <= 0
            RAISERROR('El precio debe ser mayor a 0', 16, 1);

        INSERT INTO Materia (nombre_materia, categoria, fecha_inicio, id_profesor, cupos, precio)
        VALUES (@nombre_materia, @categoria, @fecha_inicio, @id_profesor, @cupos, @precio);

        PRINT 'Materia dada de alta correctamente. Nuevo id: ' + CAST(SCOPE_IDENTITY() AS VARCHAR(10));
    END TRY
    BEGIN CATCH
        PRINT 'Error al dar de alta la materia: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Alta de inscripcion completa (cabecera + detalle) con hasta 3 materias.
-- Calcula el total y la cantidad automaticamente, y usa una transaccion para
-- que la inscripcion nunca quede a medias. El parametro @fecha_inscripcion es
-- opcional: si no se indica, toma la fecha actual (GETDATE()).
CREATE PROCEDURE SP_Alta_Inscripcion
    @id_alumno INT,
    @metodo_pago VARCHAR(50),
    @id_materia1 INT,
    @id_materia2 INT = NULL,
    @id_materia3 INT = NULL,
    @fecha_inscripcion DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables para ir acumulando el total y la cantidad de materias
    DECLARE @total INT = 0;
    DECLARE @cantidad INT = 0;
    DECLARE @precio INT;

    -- Si no se indica fecha, se usa la fecha actual
    IF @fecha_inscripcion IS NULL
        SET @fecha_inscripcion = CAST(GETDATE() AS DATE);

    BEGIN TRY
        -- Validaciones previas
        IF NOT EXISTS (SELECT 1 FROM Alumno WHERE legajo = @id_alumno)
            RAISERROR('El alumno no existe', 16, 1);

        IF @metodo_pago NOT IN ('CREDITO','DEBITO','TRANSFERENCIA','EFECTIVO')
            RAISERROR('Metodo de pago invalido', 16, 1);

        -- Materia 1 (obligatoria): busco su precio. Si no existe, @precio queda NULL.
        SELECT @precio = precio FROM Materia WHERE id_materia = @id_materia1;
        IF @precio IS NULL
            RAISERROR('La materia 1 no existe', 16, 1);
        SET @total = @total + @precio;
        SET @cantidad = @cantidad + 1;

        -- Materia 2 (opcional)
        IF @id_materia2 IS NOT NULL
        BEGIN
            SET @precio = NULL;
            SELECT @precio = precio FROM Materia WHERE id_materia = @id_materia2;
            IF @precio IS NULL
                RAISERROR('La materia 2 no existe', 16, 1);
            SET @total = @total + @precio;
            SET @cantidad = @cantidad + 1;
        END

        -- Materia 3 (opcional)
        IF @id_materia3 IS NOT NULL
        BEGIN
            SET @precio = NULL;
            SELECT @precio = precio FROM Materia WHERE id_materia = @id_materia3;
            IF @precio IS NULL
                RAISERROR('La materia 3 no existe', 16, 1);
            SET @total = @total + @precio;
            SET @cantidad = @cantidad + 1;
        END

        BEGIN TRANSACTION;

            INSERT INTO Inscripcion (id_alumno, fecha_inscripcion, metodo_pago, cantidad_materias, total)
            VALUES (@id_alumno, @fecha_inscripcion, @metodo_pago, @cantidad, @total);

            -- SCOPE_IDENTITY() devuelve el id (IDENTITY) que se acaba de generar en
            -- Inscripcion, para usarlo como FK en los detalles. NOTA: si no llegamos a
            -- ver esta funcion en clase, se puede reemplazar por:
            --     SET @id_inscripcion = (SELECT MAX(id_inscripcion) FROM Inscripcion);
            DECLARE @id_inscripcion INT;
            SET @id_inscripcion = SCOPE_IDENTITY();

            -- Detalle de la materia 1
            INSERT INTO Detalle_Inscripcion (id_inscripcion, id_materia, precio_unitario)
            SELECT @id_inscripcion, id_materia, precio FROM Materia WHERE id_materia = @id_materia1;

            -- Detalle de la materia 2 (si corresponde)
            IF @id_materia2 IS NOT NULL
                INSERT INTO Detalle_Inscripcion (id_inscripcion, id_materia, precio_unitario)
                SELECT @id_inscripcion, id_materia, precio FROM Materia WHERE id_materia = @id_materia2;

            -- Detalle de la materia 3 (si corresponde)
            IF @id_materia3 IS NOT NULL
                INSERT INTO Detalle_Inscripcion (id_inscripcion, id_materia, precio_unitario)
                SELECT @id_inscripcion, id_materia, precio FROM Materia WHERE id_materia = @id_materia3;

        COMMIT TRANSACTION;

        PRINT 'Inscripcion creada correctamente. Id: ' + CAST(@id_inscripcion AS VARCHAR(10));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        PRINT 'Error al crear la inscripcion: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- ------------------------------------------------------------
-- Carga de los datos de prueba ejecutando los procedimientos
-- ------------------------------------------------------------

-- Profesores (se generan los id 12000 a 12007 en este orden de insercion)
EXEC SP_Alta_Profesor 'Juan', 'Montero', 'juan.montero@gmail.com', 'Base de Datos', 1200000;
EXEC SP_Alta_Profesor 'Gustavo', 'Escandell', 'gustavo.escandell@gmail.com', 'Programacion', 1500000;
EXEC SP_Alta_Profesor 'Horacio', 'Perez', 'horacio.perez@gmail.com', 'Matematica', 1100000;
EXEC SP_Alta_Profesor 'Marina', 'Lopez', 'marina.lopez@hotmail.com', 'Economia', 1000000;
EXEC SP_Alta_Profesor 'Carlos', 'Diaz', 'carlos.diaz@gmail.com', 'Sistemas', 1300000;
EXEC SP_Alta_Profesor 'Julieta', 'Ruiz', 'julieta.ruiz@hotmail.com', 'Estadistica', 1150000;
EXEC SP_Alta_Profesor 'Martin', 'Sosa', 'martin.sosa@hotmail.com', 'Arquitectura', 1400000;
EXEC SP_Alta_Profesor 'Paula', 'Gimenez', 'paula.gimenez@hotmail.com', 'Administracion', 1050000;
GO

-- Alumnos (se generan los legajos 64000 a 64008 en este orden de insercion)
EXEC SP_Alta_Alumno 'Tobias', 'Martinez', 43123456, 'tobias.martinez@gmail.com';
EXEC SP_Alta_Alumno 'Jeremias', 'Borda', 44234567, 'jeremias.borda@gmail.com';
EXEC SP_Alta_Alumno 'Guadalupe', 'Miguens', 45345678, 'guadalupe.miguens@gmail.com';
EXEC SP_Alta_Alumno 'Lucia', 'Fernandez', 46456789, 'lucia.fernandez@hotmail.com';
EXEC SP_Alta_Alumno 'Mateo', 'Lopez', 47567890, 'mateo.lopez@gmail.com';
EXEC SP_Alta_Alumno 'Camila', 'Suarez', 48678901, 'camila.suarez@hotmail.com';
EXEC SP_Alta_Alumno 'Benjamin', 'Prat', 49789012, 'benjamin.prat@hotmail.com';
EXEC SP_Alta_Alumno 'Sofia', 'Gomez', 40890123, 'sofia.gomez@gmail.com';
-- Alumno sin inscripcion, para probar LEFT JOIN
EXEC SP_Alta_Alumno 'Nicolas', 'Aguirre', 42111222, 'nicolas.aguirre@gmail.com';
GO

-- Materias (se generan los id 1 a 9 en este orden de insercion)
EXEC SP_Alta_Materia 'Base de Datos I', 'Informatica', '2026-08-10', 12000, 30, 300000;
EXEC SP_Alta_Materia 'Programacion I', 'Programacion', '2026-08-12', 12001, 25, 300000;
EXEC SP_Alta_Materia 'Estadistica', 'Matematica', '2026-08-15', 12002, 35, 300000;
EXEC SP_Alta_Materia 'Economia', 'Economia', '2026-08-18', 12003, 40, 300000;
EXEC SP_Alta_Materia 'Sistemas', 'Informatica', '2026-08-20', 12004, 30, 300000;
EXEC SP_Alta_Materia 'Algebra', 'Matematica', '2026-08-22', 12005, 35, 300000;
EXEC SP_Alta_Materia 'Arquitectura', 'Informatica', '2026-08-25', 12006, 20, 300000;
EXEC SP_Alta_Materia 'Administracion', 'Administracion', '2026-08-28', 12007, 45, 300000;
-- Materia nueva sin inscriptos y con un profesor ya existente (12000),
-- para que haya un profesor con mas de una materia
EXEC SP_Alta_Materia 'Modelado de Datos', 'Informatica', '2026-09-05', 12000, 20, 280000;
GO

-- Inscripciones (cabecera + detalle). El SP calcula total y cantidad solos.
-- Se pasa la fecha por parametro nombrado para conservar las fechas de prueba.
EXEC SP_Alta_Inscripcion @id_alumno = 64000, @metodo_pago = 'TRANSFERENCIA', @id_materia1 = 1, @id_materia2 = 2, @fecha_inscripcion = '2026-04-01';
EXEC SP_Alta_Inscripcion @id_alumno = 64001, @metodo_pago = 'EFECTIVO', @id_materia1 = 3, @fecha_inscripcion = '2026-04-02';
EXEC SP_Alta_Inscripcion @id_alumno = 64002, @metodo_pago = 'CREDITO', @id_materia1 = 1, @id_materia2 = 4, @id_materia3 = 5, @fecha_inscripcion = '2026-04-03';
EXEC SP_Alta_Inscripcion @id_alumno = 64003, @metodo_pago = 'DEBITO', @id_materia1 = 6, @fecha_inscripcion = '2026-04-04';
EXEC SP_Alta_Inscripcion @id_alumno = 64004, @metodo_pago = 'TRANSFERENCIA', @id_materia1 = 2, @id_materia2 = 7, @fecha_inscripcion = '2026-04-05';
EXEC SP_Alta_Inscripcion @id_alumno = 64005, @metodo_pago = 'EFECTIVO', @id_materia1 = 8, @fecha_inscripcion = '2026-04-06';
EXEC SP_Alta_Inscripcion @id_alumno = 64006, @metodo_pago = 'CREDITO', @id_materia1 = 3, @id_materia2 = 5, @fecha_inscripcion = '2026-04-07';
EXEC SP_Alta_Inscripcion @id_alumno = 64007, @metodo_pago = 'DEBITO', @id_materia1 = 4, @fecha_inscripcion = '2026-04-08';
-- Segunda inscripcion para el alumno 64000 (materia distinta a las que ya tiene),
-- para que la consulta HAVING de alumnos con mas de una inscripcion devuelva resultado
EXEC SP_Alta_Inscripcion @id_alumno = 64000, @metodo_pago = 'DEBITO', @id_materia1 = 3, @fecha_inscripcion = '2026-04-10';
GO


-----------------------------------------------------------------------
-- ETAPA 5
-- CONSULTAS SQL

-- Consultas

-- CONSULTAS BASICAS

--1) Mostrar todos los alumnos registrados indicando nombre, apellido y email
SELECT nombre, apellido, email
FROM Alumno;

--2) Mostrar todos los alumnos ordenados por apellido
SELECT * FROM Alumno
ORDER BY apellido;

--3) Mostrar los distintos métodos de pago utilizados
SELECT DISTINCT metodo_pago FROM Inscripcion;

--4) Listar las materias pertenecientes a la categoría "Informatica"
SELECT nombre_materia, categoria
FROM Materia
WHERE categoria = 'Informatica';

--5) Mostrar los profesores cuyo sueldo sea mayor a $1.200.000
SELECT nombre, apellido, sueldo
FROM Profesor
WHERE sueldo > 1200000;

--6) Obtener las materias que comienzan después del 15/08/2026
SELECT nombre_materia, fecha_inicio
FROM Materia
WHERE fecha_inicio > '2026-08-15';

--7) Listar los profesores que su apellido contiene la letra "e"
SELECT * FROM Profesor
WHERE apellido LIKE '%e%';

--8) Listar los alumnos cuyo email contenga "gmail"
SELECT legajo, nombre, apellido, email
FROM Alumno
WHERE email LIKE '%gmail%';


-- CONSULTAS CON JOIN

--9) Mostrar cada materia junto con el nombre y apellido de su profesor
SELECT m.nombre_materia, p.nombre, p.apellido
FROM Materia as m
JOIN Profesor as p
ON m.id_profesor = p.id_profesor;

--10) Listar las inscripciones realizadas indicando nombre del alumno y fecha de inscripción
SELECT a.nombre, a.apellido, i.fecha_inscripcion
FROM Inscripcion as i
JOIN Alumno as a
ON a.legajo = i.id_alumno;

--11) Mostrar el detalle de inscripción indicando alumno, materia y precio unitario
SELECT a.nombre, a.apellido, m.nombre_materia, d.precio_unitario
FROM Detalle_Inscripcion as d
JOIN Inscripcion as i
ON d.id_inscripcion = i.id_inscripcion
JOIN Alumno as a
ON i.id_alumno = a.legajo
JOIN Materia as m
ON d.id_materia = m.id_materia;

--12) Listar todas las materias junto con la cantidad de alumnos inscriptos
SELECT m.id_materia, m.nombre_materia, COUNT(DISTINCT i.id_alumno) as cantidad_alumnos_inscriptos
FROM Materia as m
LEFT JOIN Detalle_Inscripcion as d 
ON m.id_materia = d.id_materia
LEFT JOIN Inscripcion as i 
ON d.id_inscripcion = i.id_inscripcion
GROUP BY m.id_materia, m.nombre_materia;

--13) Mostrar las inscripciones junto con el método de pago utilizado
SELECT id_inscripcion, id_alumno, fecha_inscripcion, metodo_pago, cantidad_materias, total
FROM Inscripcion;


-- CONSULTAS CON GROUP BY

--14) Obtener la cantidad de materias por categoría
SELECT categoria, COUNT(*) as cantidad_materias
FROM Materia
GROUP BY categoria;

--15) Mostrar la cantidad de materias dictadas por cada profesor
SELECT p.id_profesor, p.nombre, p.apellido, COUNT(m.id_materia) as cantidad_materias
FROM Profesor as p
LEFT JOIN Materia as m 
ON p.id_profesor = m.id_profesor
GROUP BY p.id_profesor, p.nombre, p.apellido;

--16) Calcular el total gastado por cada alumno
SELECT a.legajo, a.nombre, a.apellido, (SUM(i.total)) as total_gastado
FROM Alumno as a
LEFT JOIN Inscripcion as i 
ON a.legajo = i.id_alumno
GROUP BY a.legajo, a.nombre, a.apellido;

--17) Obtener el promedio de importe de las inscripciones según método de pago
SELECT metodo_pago, AVG(total) as promedio_importe
FROM Inscripcion
GROUP BY metodo_pago;

--18) Mostrar la cantidad de inscripciones realizadas por cada alumno
SELECT a.legajo, a.nombre, a.apellido, COUNT(i.id_inscripcion) as cantidad_inscripciones
FROM Alumno as a
LEFT JOIN Inscripcion as i ON a.legajo = i.id_alumno
GROUP BY a.legajo, a.nombre, a.apellido;

-- CONSULTAS CON HAVING

--19) Mostrar los alumnos que realizaron más de una inscripción
SELECT a.legajo, a.nombre, a.apellido, COUNT(i.id_inscripcion) as cantidad_inscripciones
FROM Alumno as a
JOIN Inscripcion as i ON a.legajo = i.id_alumno
GROUP BY a.legajo, a.nombre, a.apellido
HAVING COUNT(i.id_inscripcion) > 1;

--20) Listar los profesores que dictan más de una materia
SELECT p.id_profesor, p.nombre, p.apellido, COUNT(m.id_materia) as cantidad_materias
FROM Profesor as p
JOIN Materia as m ON p.id_profesor = m.id_profesor
GROUP BY p.id_profesor, p.nombre, p.apellido
HAVING COUNT(m.id_materia) > 1;

--21) Mostrar las categorías que tengan más de una materia registrada
SELECT categoria, COUNT(*) as cantidad_materias
FROM Materia
GROUP BY categoria
HAVING COUNT(*) > 1;


-- CONSULTAS CON LEFT JOIN

--22) Mostrar todos los alumnos junto con sus inscripciones, incluso aquellos que no tienen ninguna
SELECT a.legajo, a.nombre, a.apellido, i.id_inscripcion, i.fecha_inscripcion, i.metodo_pago, i.total
FROM Alumno as a
LEFT JOIN Inscripcion as i 
ON a.legajo = i.id_alumno;

--23) Mostrar todas las materias junto con sus detalles de inscripción, incluso aquellas que nunca fueron elegidas
SELECT m.id_materia, m.nombre_materia, d.id_detalle, d.id_inscripcion, d.precio_unitario
FROM Materia as m
LEFT JOIN Detalle_Inscripcion as d 
ON m.id_materia = d.id_materia;


-- SUBCONSULTAS

--24) Mostrar alumnos cuyo total gastado sea mayor al promedio general de inscripciones (ESCALAR)
SELECT a.legajo, a.nombre, a.apellido, SUM(i.total) as total_gastado
FROM Alumno as a
JOIN Inscripcion as i 
ON a.legajo = i.id_alumno
GROUP BY a.legajo, a.nombre, a.apellido
HAVING SUM(i.total) > (SELECT AVG(total)
FROM Inscripcion
);

--25) Mostrar alumnos que realizaron al menos una inscripción (IN)
SELECT legajo, nombre, apellido, email
FROM Alumno
WHERE legajo IN ( SELECT id_alumno
FROM Inscripcion
);

--26) Mostrar alumnos que tienen inscripciones registradas (EXISTS)
SELECT a.legajo, a.nombre, a.apellido
FROM Alumno as a
WHERE EXISTS (SELECT 1
FROM Inscripcion as i
WHERE i.id_alumno = a.legajo
);

--27) Mostrar materias que tienen al menos un detalle de inscripción (EXISTS)
SELECT m.id_materia, m.nombre_materia, m.categoria
FROM Materia as m
WHERE EXISTS (SELECT 1
FROM Detalle_Inscripcion as d
WHERE d.id_materia = m.id_materia
);

--28) Mostrar alumnos cuyo total gastado sea mayor a $200.000 (CORRELACIONADA)
SELECT a.legajo, a.nombre, a.apellido
FROM Alumno as a
WHERE (SELECT SUM(i.total)
FROM Inscripcion as i
WHERE i.id_alumno = a.legajo
) > 200000;

--29) Muestra los alumnos que se inscribieron a la materia 'Base de Datos I' y también a 'Programacion I'
SELECT CONCAT(apellido, ' ', nombre) AS 'alumno' FROM Alumno
WHERE legajo IN (
    SELECT id_alumno FROM Inscripcion
    WHERE id_inscripcion IN (
        SELECT id_inscripcion FROM Detalle_Inscripcion
        WHERE id_materia IN (
            SELECT id_materia FROM Materia
            WHERE nombre_materia = 'Base de Datos I'
        )
    )
)
INTERSECT
SELECT CONCAT(apellido, ' ', nombre) AS 'alumno' FROM Alumno
WHERE legajo IN (
    SELECT id_alumno FROM Inscripcion
    WHERE id_inscripcion IN (
        SELECT id_inscripcion FROM Detalle_Inscripcion
        WHERE id_materia IN (
            SELECT id_materia FROM Materia
            WHERE nombre_materia = 'Programacion I'
        )
    )
)

--30) Mostrar alumnos sin inscripción
SELECT a.legajo, a.nombre, a.apellido, a.email
FROM Alumno a
LEFT JOIN Inscripcion i
ON a.legajo = i.id_alumno
WHERE i.id_inscripcion IS NULL;

--31) Mostrar materias sin alumnos inscriptos
SELECT m.id_materia, m.nombre_materia, m.categoria
FROM Materia m
LEFT JOIN Detalle_Inscripcion d
ON m.id_materia = d.id_materia
WHERE d.id_detalle IS NULL;

--31) Recaudación total por categoría de materia
SELECT 
    m.categoria,
    SUM(d.precio_unitario) AS recaudacion_total
FROM Detalle_Inscripcion d
JOIN Materia m
ON d.id_materia = m.id_materia
GROUP BY m.categoria
ORDER BY recaudacion_total DESC;


-------------------------------------------------------------------------
-- ETAPA 6
-- VISTAS

GO

--1) Vista de alumnos con sus inscripciones
CREATE VIEW vista_alumnos_inscripciones as
SELECT a.legajo, a.nombre, a.apellido, i.id_inscripcion, i.fecha_inscripcion, i.metodo_pago, i.cantidad_materias, i.total
FROM Alumno as a
JOIN Inscripcion as i
ON a.legajo = i.id_alumno;
GO

--2) Vista de detalle completo de inscripciones
CREATE VIEW vista_detalle_inscripciones_completo AS
SELECT i.id_inscripcion, a.legajo, a.nombre, a.apellido, m.nombre_materia, m.categoria, d.precio_unitario, i.fecha_inscripcion, i.metodo_pago
FROM Detalle_Inscripcion as d
JOIN Inscripcion as i 
ON d.id_inscripcion = i.id_inscripcion
JOIN Alumno as a 
ON i.id_alumno = a.legajo
JOIN Materia as m
ON d.id_materia = m.id_materia;
GO

--3) Vista de materias con profesor
CREATE VIEW vista_materias_profesor as
SELECT m.id_materia, m.nombre_materia, m.categoria, m.fecha_inicio, m.cupos, m.precio, p.nombre, p.apellido
FROM Materia as m
JOIN Profesor as p
ON m.id_profesor = p.id_profesor;
GO

--4) Vista del total gastado por alumno
CREATE VIEW vista_total_gastado_alumno as
SELECT a.legajo, a.nombre, a.apellido, SUM(i.total) as total_gastado
FROM Alumno as a
LEFT JOIN Inscripcion as i 
ON a.legajo = i.id_alumno
GROUP BY a.legajo, a.nombre, a.apellido;
GO

--5) Vista de cantidad de inscriptos por materia
CREATE VIEW vista_inscriptos_por_materia as
SELECT m.id_materia, m.nombre_materia, COUNT(DISTINCT i.id_alumno) as cantidad_alumnos_inscriptos
FROM Materia as m
LEFT JOIN Detalle_Inscripcion as d 
ON m.id_materia = d.id_materia
LEFT JOIN Inscripcion as i 
ON d.id_inscripcion = i.id_inscripcion
GROUP BY m.id_materia, m.nombre_materia;
GO

--6) Vista de inscripciones por metodo de pago
CREATE VIEW vista_ventas_por_metodo_pago as
SELECT metodo_pago, COUNT(id_inscripcion) as cantidad_inscripciones, SUM(total) as total_recaudado, AVG(total) as promedio_por_inscripcion
FROM Inscripcion
GROUP BY metodo_pago;
GO

--7) Vista de cupos disponibles por materia (cupos menos inscriptos)
CREATE VIEW vista_cupos_disponibles AS
SELECT m.id_materia, m.nombre_materia, m.cupos,
       COUNT(d.id_detalle) as inscriptos,
       m.cupos - COUNT(d.id_detalle) as cupos_disponibles
FROM Materia as m
LEFT JOIN Detalle_Inscripcion as d
ON m.id_materia = d.id_materia
GROUP BY m.id_materia, m.nombre_materia, m.cupos;
GO

--8) Procedimiento de recaudacion por rango de fechas
CREATE PROCEDURE SP_Recaudacion_Por_Fechas
    @fecha_desde DATE,
    @fecha_hasta DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @fecha_desde > @fecha_hasta
    BEGIN
        RAISERROR('La fecha desde no puede ser mayor a la fecha hasta', 16, 1);
        RETURN;
    END

    SELECT 
        metodo_pago,
        COUNT(id_inscripcion) AS cantidad_inscripciones,
        SUM(total) AS total_recaudado,
        AVG(total) AS promedio_por_inscripcion
    FROM Inscripcion
    WHERE fecha_inscripcion BETWEEN @fecha_desde AND @fecha_hasta
    GROUP BY metodo_pago;
END;
GO

-------------------------------------------------------------------------
-- ETAPA 7
-- PROCEDIMIENTOS ALMACENADOS

--1) Consulta parametrizada: listar materias de una categoria junto con su profesor.
--   Si no se pasa categoria, trae todas (valor por default '%').
CREATE PROCEDURE SP_Materias_Por_Categoria
    @categoria VARCHAR(50) = '%'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT m.id_materia, m.nombre_materia, m.categoria, m.fecha_inicio,
           m.cupos, m.precio, p.nombre as profesor_nombre, p.apellido as profesor_apellido
    FROM Materia as m
    JOIN Profesor as p
    ON m.id_profesor = p.id_profesor
    WHERE m.categoria LIKE @categoria;
END;
GO

--2) Consulta parametrizada con LIKE: buscar alumnos cuyo apellido contenga un texto.
--   Si no se pasa nada, trae todos los alumnos.
CREATE PROCEDURE SP_Buscar_Alumnos
    @apellido VARCHAR(50) = ''
AS
BEGIN
    SET NOCOUNT ON;

    SELECT legajo, nombre, apellido, dni, email
    FROM Alumno
    WHERE apellido LIKE '%' + @apellido + '%';
END;
GO

--3) Consulta parametrizada con validacion: mostrar las inscripciones de un alumno.
--   Si el legajo no existe, informa el error en vez de devolver vacio.
CREATE PROCEDURE SP_Inscripciones_De_Alumno
    @legajo INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Alumno WHERE legajo = @legajo)
    BEGIN
        RAISERROR('No existe un alumno con el legajo %d', 16, 1, @legajo);
        RETURN;
    END

    SELECT a.legajo, a.nombre, a.apellido,
           i.id_inscripcion, i.fecha_inscripcion, i.metodo_pago,
           i.cantidad_materias, i.total
    FROM Alumno as a
    JOIN Inscripcion as i
    ON a.legajo = i.id_alumno
    WHERE a.legajo = @legajo;
END;
GO

--4) y 5) Procedimientos de alta con manejo de errores y con transaccion.
--   SP_Alta_Alumno (insercion simple con validaciones) y SP_Alta_Inscripcion
--   (insercion compleja con transaccion y calculo automatico de total/cantidad)
--   se definen en la seccion "CARGA DE DATOS MEDIANTE PROCEDIMIENTOS ALMACENADOS"
--   (despues de crear las tablas), ya que esos mismos procedimientos se usan para
--   la carga inicial de datos. Sus pruebas estan al final del script.

-------------------------------------------------------------------------
-- ETAPA 8
-- Triggers

--1) Validar que el mail sea válido para Alumnos (cumpla con formato requerido)
CREATE TRIGGER TR_Validar_Formato_Email_Alumnos On Alumno
AFTER INSERT
AS 
BEGIN

DECLARE @email VARCHAR(60);

Select 
	@email = email
From inserted

If @email not like '%_@_%._%'
Begin 
	Raiserror('El email es inválido',16,1); --16 es la severidad y 1 el estado
	Rollback transaction
End

End;
Go

--2) Validar que el mail sea válido para Profesores
CREATE TRIGGER TR_Validar_Formato_Email_Profesores On Profesor
AFTER INSERT
AS 
BEGIN

DECLARE @email VARCHAR(60);

Select 
	@email = email
From inserted

If @email not like '%_@_%._%'
Begin 
	Raiserror('El email es inválido',16,1); --16 es la severidad y 1 el estado
	Rollback transaction
End

End;
Go

--3) Actualizar cantidad materias al insertar una instancia de detalle_inscripcion
CREATE TRIGGER TR_Actualizar_Cantidad_Materias_Al_Agregar_Inscripcion On Detalle_Inscripcion
AFTER INSERT
AS 
BEGIN 	
	UPDATE Inscripcion
	Set cantidad_materias=(Select count(*) From Detalle_Inscripcion d Where (d.id_inscripcion = i.id_inscripcion))
	From Inscripcion i 
	Where i.id_inscripcion IN (Select id_inscripcion From inserted);
End;
Go

--4) Actualizar cantidad de materias al eliminar una instancia de detalle_inscripcion
CREATE TRIGGER TR_Actualizar_Cantidad_Materias_Al_Eliminar_Inscripcion On Detalle_Inscripcion
AFTER Delete
AS 
BEGIN 	
	UPDATE Inscripcion
	Set cantidad_materias=(Select count(*) From Detalle_Inscripcion d Where (d.id_inscripcion = i.id_inscripcion))
	From Inscripcion i 
	Where i.id_inscripcion IN (Select id_inscripcion From deleted);
End;
Go

--5) Verificar inscripciones duplicadas por materia
CREATE TRIGGER TR_Validar_Inscripcion_Duplicada On Detalle_Inscripcion
AFTER Insert
AS 
BEGIN
	Declare @id_alumno int;
	Declare @id_materia int;
	Declare @id_inscripcion int;

	Select 
	@id_materia = id_materia,
	@id_inscripcion = id_inscripcion
	From inserted
	
	Select 
	@id_alumno = id_alumno
	From Inscripcion Where Inscripcion.id_inscripcion = @id_inscripcion 



	IF (
        SELECT COUNT(*)
        FROM Detalle_Inscripcion d
        JOIN Inscripcion i
            ON i.id_inscripcion = d.id_inscripcion
        WHERE i.id_alumno = @id_alumno
          AND d.id_materia = @id_materia
    ) > 1
	Begin
		Raiserror('El alumno ya se encuentra inscripto a la materia',16,1);
		Rollback transaction
	End
End;
Go

--6) Actualizar total Inscripcion al agregar materias (de a muchas)
CREATE TRIGGER TR_Actualizar_Total_Inscripcion_Al_Agregar
ON Detalle_Inscripcion
AFTER insert
AS
BEGIN
    UPDATE i
    SET total = (
        SELECT SUM(d.precio_unitario)
        FROM Detalle_Inscripcion d
        WHERE d.id_inscripcion = i.id_inscripcion
    )
    FROM Inscripcion i
    WHERE i.id_inscripcion IN (
        SELECT DISTINCT id_inscripcion
        FROM inserted
    );
END;
GO

--7) Actualizar total Inscripcion al quitar materias (de a muchas)
CREATE TRIGGER TR_Actualizar_Total_Inscripcion_Al_Quitar
ON Detalle_Inscripcion
AFTER Delete
AS
BEGIN
    UPDATE i
    SET total = (
        SELECT SUM(d.precio_unitario)
        FROM Detalle_Inscripcion d
        WHERE d.id_inscripcion = i.id_inscripcion
    )
    FROM Inscripcion i
    WHERE i.id_inscripcion IN (
        SELECT DISTINCT id_inscripcion
        FROM deleted
    );
END;
GO

--8) Actualizar cantidad de cupos y validar que en efecto hayan disponibles
CREATE TRIGGER TR_Validar_Cupos_Detalle_Inscripcion
ON Detalle_Inscripcion
AFTER insert
AS
BEGIN
    IF EXISTS (
        SELECT *
        FROM inserted
        JOIN Materia m
            ON m.id_materia = inserted.id_materia
        WHERE m.cupos <= 0
    )
    BEGIN
        RAISERROR('Ya no hay mas cupos disponibles por lo menos para una materia',16,1);
        Rollback transaction;
        RETURN;
    END;

    UPDATE m
    SET cupos = m.cupos - x.cantidad
    FROM Materia m
    JOIN (
        SELECT id_materia, COUNT(*) AS cantidad
        FROM inserted
        GROUP BY id_materia
    ) x
        ON x.id_materia = m.id_materia;
END;
GO

--9) Liberar cupos al eliminar un detalle inscripción
CREATE TRIGGER TR_Liberar_Cupos_Detalle_Inscripcion
ON Detalle_Inscripcion
AFTER delete
AS
BEGIN
    UPDATE m
    set cupos = m.cupos + x.cantidad
    FROM Materia m
    JOIN (
        SELECT id_materia, COUNT(*) AS cantidad
        FROM deleted
        Group BY id_materia
    ) x
        ON x.id_materia = m.id_materia;
END;
GO

--10) Actualizar total al agregar inscripciones
CREATE TRIGGER TR_Actualizar_Total_Inscripcion_Al_Agregar
ON Detalle_Inscripcion
AFTER insert
AS
BEGIN
    UPDATE i
    SET total = (
        SELECT SUM(d.precio_unitario)
        FROM Detalle_Inscripcion d
        WHERE d.id_inscripcion = i.id_inscripcion
    )
    FROM Inscripcion i
    WHERE i.id_inscripcion IN (
        SELECT DISTINCT id_inscripcion
        FROM inserted
    );
END;
GO

--11) Actualizar total al quitar inscripciones
CREATE TRIGGER TR_Actualizar_Total_Inscripcion_Al_Eliminar
ON Detalle_Inscripcion
AFTER Delete
AS
Begin
    UPDATE i
    SET total = (
        SELECT ISNULL(SUM(d.precio_unitario),0)
        FROM Detalle_Inscripcion d
        WHERE d.id_inscripcion = i.id_inscripcion
    )
    FROM Inscripcion i
    Where i.id_inscripcion IN (
        SELECT DISTINCT id_inscripcion
        FROM deleted
    );
END;
GO
-------------------------------------------------------------------------
-- PRUEBAS DE LOS PROCEDIMIENTOS ALMACENADOS (Etapa 7)

-- 1) Materias de una categoria (o todas si no se pasa parametro)
EXEC SP_Materias_Por_Categoria 'Informatica';
EXEC SP_Materias_Por_Categoria;

-- 2) Buscar alumnos por apellido
EXEC SP_Buscar_Alumnos 'Mar';

-- 3) Inscripciones de un alumno (probar con uno valido y uno inexistente)
EXEC SP_Inscripciones_De_Alumno 64000;
EXEC SP_Inscripciones_De_Alumno 99999;

-- 4) Alta de un alumno nuevo
EXEC SP_Alta_Alumno 'Valentina', 'Rossi', 41999888, 'valentina.rossi@gmail.com';

-- 5) Alta de una inscripcion completa con 2 materias (calcula total y cantidad solo)
EXEC SP_Alta_Inscripcion 64001, 'CREDITO', 1, 2;

-- 5b) Si se intenta inscribir a una materia que el alumno ya tiene, el trigger
--     anti-duplicados lo rechaza y la transaccion se revierte (no queda a medias).
EXEC SP_Alta_Inscripcion 64001, 'CREDITO', 3;

-- 7) Consultar cuanto se recauda en un rango de fechas
EXEC SP_Recaudacion_Por_Fechas '2026-04-01', '2026-04-30';

------------------------------------------------------------------------
-- PRUEBAS DE VISTAS

SELECT * FROM vista_alumnos_inscripciones;
SELECT * FROM vista_detalle_inscripciones_completo;
SELECT * FROM vista_materias_profesor;
SELECT * FROM vista_total_gastado_alumno;
SELECT * FROM vista_inscriptos_por_materia;
SELECT * FROM vista_ventas_por_metodo_pago;
SELECT * FROM vista_cupos_disponibles;

------------------------------------------------------------------------
-- PRUEBAS DE TRIGGERS

-- Debe fallar por email inválido
INSERT INTO Alumno (nombre, apellido, dni, email)
VALUES ('Prueba', 'Email', 40999111, 'email_invalido');

-- Debe fallar por inscripción duplicada a una materia
INSERT INTO Detalle_Inscripcion (id_inscripcion, id_materia, precio_unitario)
VALUES (1, 1, 300000);

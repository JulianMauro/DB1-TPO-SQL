-- ETAPA 4
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


-- INSERTS CARGA DE DATOS


INSERT INTO Alumno (nombre, apellido, dni, email) VALUES
('Tobias', 'Martinez', 43123456, 'tobias.martinez@gmail.com'),
('Jeremias', 'Borda', 44234567, 'jeremias.borda@gmail.com'),
('Guadalupe', 'Miguens', 45345678, 'guadalupe.miguens@gmail.com'),
('Lucia', 'Fernandez', 46456789, 'lucia.fernandez@hotmail.com'),
('Mateo', 'Lopez', 47567890, 'mateo.lopez@gmail.com'),
('Camila', 'Suarez', 48678901, 'camila.suarez@hotmail.com'),
('Benjamin', 'Prat', 49789012, 'benjamin.prat@hotmail.com'),
('Sofia', 'Gomez', 40890123, 'sofia.gomez@gmail.com');

INSERT INTO Profesor (nombre, apellido, email, categoria, sueldo) VALUES
('Juan', 'Montero', 'juan.montero@gmail.com', 'Base de Datos', 1200000),
('Gustavo', 'Escandell', 'gustavo.escandell@gmail.com', 'Programacion', 1500000),
('Horacio', 'Perez', 'horacio.perez@gmail.com', 'Matematica', 1100000),
('Marina', 'Lopez', 'marina.lopez@hotmail.com', 'Economia', 1000000),
('Carlos', 'Diaz', 'carlos.diaz@gmail.com', 'Sistemas', 1300000),
('Julieta', 'Ruiz', 'julieta.ruiz@hotmail.com', 'Estadistica', 1150000),
('Martin', 'Sosa', 'martin.sosa@hotmail.com', 'Arquitectura', 1400000),
('Paula', 'Gimenez', 'paula.gimenez@hotmail.com', 'Administracion', 1050000);

INSERT INTO Materia (nombre_materia, categoria, fecha_inicio, id_profesor, cupos, precio) VALUES
('Base de Datos I', 'Informatica', '2026-08-10', 12000, 30, 300000),
('Programacion I', 'Programacion', '2026-08-12', 12001, 25, 300000),
('Estadistica', 'Matematica', '2026-08-15', 12002, 35, 300000),
('Economia', 'Economia', '2026-08-18', 12003, 40, 300000),
('Sistemas', 'Informatica', '2026-08-20', 12004, 30, 300000),
('Algebra', 'Matematica', '2026-08-22', 12005, 35, 300000),
('Arquitectura', 'Informatica', '2026-08-25', 12006, 20, 300000),
('Administracion', 'Administracion', '2026-08-28', 12007, 45, 300000);

INSERT INTO Inscripcion (id_alumno, fecha_inscripcion, metodo_pago, cantidad_materias, total) VALUES
(64000, '2026-04-01', 'TRANSFERENCIA', 2, 600000),
(64001, '2026-04-02', 'EFECTIVO', 1, 300000),
(64002, '2026-04-03', 'CREDITO', 3, 900000),
(64003, '2026-04-04', 'DEBITO', 1, 300000),
(64004, '2026-04-05', 'TRANSFERENCIA', 2, 600000),
(64005, '2026-04-06', 'EFECTIVO', 1, 300000),
(64006, '2026-04-07', 'CREDITO', 2, 600000),
(64007, '2026-04-08', 'DEBITO', 1, 300000);

INSERT INTO Detalle_Inscripcion (id_inscripcion, id_materia, precio_unitario) VALUES
(1, 1, 300000),
(1, 2, 300000),

(2, 3, 300000),

(3, 1, 300000),
(3, 4, 300000),
(3, 5, 300000),

(4, 6, 300000),

(5, 2, 300000),
(5, 7, 300000),

(6, 8, 300000),

(7, 3, 300000),
(7, 5, 300000),

(8, 4, 300000);


-----------------------------------------------------------------------
-- ETAPA 5
-- CONSULTAS SQL


-- CONSULTAS BASICAS

--1) Mostrar todos los alumnos registrados indicando nombre, apellido y email
SELECT nombre, apellido, email
FROM Alumno;

--2) Listar las materias pertenecientes a la categoría "Informatica"
SELECT nombre_materia, categoria
FROM Materia
WHERE categoria = 'Informatica';

--3) Mostrar los profesores cuyo sueldo sea mayor a $1.200.000
SELECT nombre, apellido, sueldo
FROM Profesor
WHERE sueldo > 1200000;

--4) Obtener las materias que comienzan después del 15/08/2026
SELECT nombre_materia, fecha_inicio
FROM Materia
WHERE fecha_inicio > '2026-08-15';

--5) Listar los alumnos cuyo email contenga "gmail"
SELECT legajo, nombre, apellido, email
FROM Alumno
WHERE email LIKE '%gmail%';


-- CONSULTAS CON JOIN

--6) Mostrar cada materia junto con el nombre y apellido de su profesor
SELECT m.nombre_materia, p.nombre, p.apellido
FROM Materia as m
JOIN Profesor as p
ON m.id_profesor = p.id_profesor;

--7) Listar las inscripciones realizadas indicando nombre del alumno y fecha de inscripción
SELECT a.nombre, a.apellido, i.fecha_inscripcion
FROM Inscripcion as i
JOIN Alumno as a
ON a.legajo = i.id_alumno;

--8) Mostrar el detalle de inscripción indicando alumno, materia y precio unitario
SELECT a.nombre, a.apellido, m.nombre_materia, d.precio_unitario
FROM Detalle_Inscripcion as d
JOIN Inscripcion as i
ON d.id_inscripcion = i.id_inscripcion
JOIN Alumno as a
ON i.id_alumno = a.legajo
JOIN Materia as m
ON d.id_materia = m.id_materia;

--9) Listar todas las materias junto con la cantidad de alumnos inscriptos
SELECT m.id_materia, m.nombre_materia, COUNT(DISTINCT i.id_alumno) as cantidad_alumnos_inscriptos
FROM Materia as m
LEFT JOIN Detalle_Inscripcion as d 
ON m.id_materia = d.id_materia
LEFT JOIN Inscripcion as i 
ON d.id_inscripcion = i.id_inscripcion
GROUP BY m.id_materia, m.nombre_materia;

--10) Mostrar las inscripciones junto con el método de pago utilizado
SELECT id_inscripcion, id_alumno, fecha_inscripcion, metodo_pago, cantidad_materias, total
FROM Inscripcion;


-- CONSULTAS CON GROUP BY

--11) Obtener la cantidad de materias por categoría
SELECT categoria, COUNT(*) as cantidad_materias
FROM Materia
GROUP BY categoria;

--12) Mostrar la cantidad de materias dictadas por cada profesor
SELECT p.id_profesor, p.nombre, p.apellido, COUNT(m.id_materia) as cantidad_materias
FROM Profesor as p
LEFT JOIN Materia as m 
ON p.id_profesor = m.id_profesor
GROUP BY p.id_profesor, p.nombre, p.apellido;

--13) Calcular el total gastado por cada alumno
SELECT a.legajo, a.nombre, a.apellido, (SUM(i.total)) as total_gastado
FROM Alumno as a
LEFT JOIN Inscripcion as i 
ON a.legajo = i.id_alumno
GROUP BY a.legajo, a.nombre, a.apellido;

--14) Obtener el promedio de importe de las inscripciones según método de pago
SELECT metodo_pago, AVG(total) as promedio_importe
FROM Inscripcion
GROUP BY metodo_pago;

--15) Mostrar la cantidad de inscripciones realizadas por cada alumno
SELECT a.legajo, a.nombre, a.apellido, COUNT(i.id_inscripcion) as cantidad_inscripciones
FROM Alumno as a
LEFT JOIN Inscripcion as i ON a.legajo = i.id_alumno
GROUP BY a.legajo, a.nombre, a.apellido;

-- CONSULTAS CON HAVING

--16) Mostrar los alumnos que realizaron más de una inscripción
SELECT a.legajo, a.nombre, a.apellido, COUNT(i.id_inscripcion) as cantidad_inscripciones
FROM Alumno as a
JOIN Inscripcion as i ON a.legajo = i.id_alumno
GROUP BY a.legajo, a.nombre, a.apellido
HAVING COUNT(i.id_inscripcion) > 1;

--17) Listar los profesores que dictan más de una materia
SELECT p.id_profesor, p.nombre, p.apellido, COUNT(m.id_materia) as cantidad_materias
FROM Profesor as p
JOIN Materia as m ON p.id_profesor = m.id_profesor
GROUP BY p.id_profesor, p.nombre, p.apellido
HAVING COUNT(m.id_materia) > 1;

--18) Mostrar las categorías que tengan más de una materia registrada
SELECT categoria, COUNT(*) as cantidad_materias
FROM Materia
GROUP BY categoria
HAVING COUNT(*) > 1;


-- CONSULTAS CON LEFT JOIN

--19) Mostrar todos los alumnos junto con sus inscripciones, incluso aquellos que no tienen ninguna
SELECT a.legajo, a.nombre, a.apellido, i.id_inscripcion, i.fecha_inscripcion, i.metodo_pago, i.total
FROM Alumno as a
LEFT JOIN Inscripcion as i 
ON a.legajo = i.id_alumno;

--20) Mostrar todas las materias junto con sus detalles de inscripción, incluso aquellas que nunca fueron elegidas
SELECT m.id_materia, m.nombre_materia, d.id_detalle, d.id_inscripcion, d.precio_unitario
FROM Materia as m
LEFT JOIN Detalle_Inscripcion as d 
ON m.id_materia = d.id_materia;


-- SUBCONSULTAS

--21) Mostrar alumnos cuyo total gastado sea mayor al promeido general de inscripciones (ESCALAR)
SELECT a.legajo, a.nombre, a.apellido, SUM(i.total) as total_gastado
FROM Alumno as a
JOIN Inscripcion as i 
ON a.legajo = i.id_alumno
GROUP BY a.legajo, a.nombre, a.apellido
HAVING SUM(i.total) > (SELECT AVG(total)
FROM Inscripcion
);

--22) Mostrar alumnos que realizaron al menos una inscripción (IN)
SELECT legajo, nombre, apellido, email
FROM Alumno
WHERE legajo IN ( SELECT id_alumno
FROM Inscripcion
);

--23) Mostrar alumnos que tienen inscripciones registradas (EXISTS)
SELECT a.legajo, a.nombre, a.apellido
FROM Alumno as a
WHERE EXISTS (SELECT 1
FROM Inscripcion as i
WHERE i.id_alumno = a.legajo
);

--24) Mostrar materias que tienen al menos un detalle de inscripción (EXISTS)
SELECT m.id_materia, m.nombre_materia, m.categoria
FROM Materia as m
WHERE EXISTS (SELECT 1
FROM Detalle_Inscripcion as d
WHERE d.id_materia = m.id_materia
);

--25) Mostrar alumnos cuyo total gastado sea mayor a $200.000 (CORRELACIONADA)
SELECT a.legajo, a.nombre, a.apellido
FROM Alumno as a
WHERE (SELECT SUM(i.total)
FROM Inscripcion as i
WHERE i.id_alumno = a.legajo
) > 200000;



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

--4) Insercion simple con manejo de errores: dar de alta un alumno.
--   Valida dni > 0 y que no exista otro alumno con el mismo dni o email.
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

--5) Insercion compleja con transaccion: dar de alta una inscripcion completa
--   con hasta 3 materias. Calcula el total y la cantidad automaticamente, y si
--   algo falla revierte todo (la inscripcion no queda a medias).
CREATE PROCEDURE SP_Alta_Inscripcion
    @id_alumno INT,
    @metodo_pago VARCHAR(50),
    @id_materia1 INT,
    @id_materia2 INT = NULL,
    @id_materia3 INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables para ir acumulando el total y la cantidad de materias
    DECLARE @total INT = 0;
    DECLARE @cantidad INT = 0;
    DECLARE @precio INT;

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
            VALUES (@id_alumno, CAST(GETDATE() AS DATE), @metodo_pago, @cantidad, @total);

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

--4) Actualizar cantidad materias al eliminar una instancia de detalle_insciprcion
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

--5) Verificar inscripciones duplicadas a materia
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


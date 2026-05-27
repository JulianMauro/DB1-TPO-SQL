-- Etapa 4:
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

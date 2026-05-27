-- Etapa 4:
-- Creacion de la base de datos

CREATE DATABASE TP;

CREATE TABLE Alumno(
    legajo INT IDENTITY (64000,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    dni INT NOT NULL,
    CONSTRAINT c_dni
    CHECK (dni > 0),
    email VARCHAR(50) NOT NULL,
);

CREATE TABLE Profesor(
    id_profesor INT IDENTITY (12000,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    sueldo DECIMAL(10,2) NOT NULL,
    CONSTRAINT c_sueldo
    CHECK (sueldo > 0)
);

CREATE TABLE Materia(
    id_materia VARCHAR(20) PRIMARY KEY,
    nombre_materia VARCHAR(50) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    fecha_inicio DATE NOT NULL,
    id_profesor INT NOT NULL,
    CONSTRAINT fk_id_profesor
    FOREIGN KEY (id_profesor) REFERENCES Profesor(id_profesor),
    cupos INT NOT NULL,
    CONSTRAINT c_cupos
    CHECK(cupos >= 0),
    precio DECIMAL(10,2) NOT NULL,
    CONSTRAINT c_precio
    CHECK (precio > 0)
);

CREATE TABLE Inscripcion(
    id_inscrip INT IDENTITY(1,1) PRIMARY KEY,
    id_alumno INT NOT NULL,
    CONSTRAINT ck_legajo
    FOREIGN KEY (id_alumno) REFERENCES Alumno(legajo),
    id_materia VARCHAR(20) NOT NULL,
    CONSTRAINT ck_id_materia
    FOREIGN KEY (id_materia) REFERENCES Materia(id_materia),
    fecha_inscrip DATE NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    CONSTRAINT c_metodo
    CHECK (metodo_pago IN ('CREDITO','DEBITO','TRANSFERENCIA','EFECTIVO')),
    total DECIMAL(10,2) NOT NULL,
    CONSTRAINT c_total
    CHECK (total > 0),
    id_detalle_inscrip INT NOT NULL
);

CREATE TABLE Detalle_Inscripcion(
    id_detalle_inscrip INT IDENTITY(1,1) PRIMARY KEY,
    id_inscrip INT NOT NULL,
    CONSTRAINT ck_id_inscrip
    FOREIGN KEY (id_inscrip) REFERENCES Inscripcion(id_inscrip),
    id_materia VARCHAR(20) NOT NULL,
    CONSTRAINT k_id_materia
    FOREIGN KEY (id_materia) REFERENCES Materia(id_materia),
    cantidad_materia INT NOT NULL,
    CONSTRAINT c_cantidad
    CHECK (cantidad_materia > 0),
    precio_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT c_precio_uni
    CHECK (precio_unitario > 0),
    total DECIMAL(10,2) NOT NULL,
    CONSTRAINT c2_total
    CHECK (total > 0)
);

-- Carga de datos

DROP TABLE Profesor


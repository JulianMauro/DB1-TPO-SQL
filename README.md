# DB1-TPO-SQL

Trabajo Práctico Integrador de **Base de Datos** (Ingeniería de Datos I - UADE).

# Sistema de Gestión Académica

## Descripción del Proyecto

Este proyecto consiste en el diseño e implementación de una base de datos relacional para una institución educativa que administra alumnos, profesores, materias e inscripciones.

El objetivo principal es centralizar la información académica, reducir la redundancia de datos, garantizar la integridad de la información y facilitar la gestión de consultas, reportes e inscripciones.

La base de datos fue desarrollada en SQL Server utilizando tablas relacionadas mediante claves primarias y foráneas, restricciones de integridad, vistas, procedimientos almacenados, triggers y consultas avanzadas.

---

## Problemática

Antes de la implementación del sistema, la información académica presentaba diversos inconvenientes:

* Información dispersa y difícil de administrar.
* Duplicación de datos.
* Falta de control sobre las inscripciones realizadas.
* Dificultad para obtener reportes académicos y administrativos.
* Posibilidad de inconsistencias en la carga de datos.

---

## Objetivos

* Centralizar la información académica.
* Mejorar la integridad y consistencia de los datos.
* Facilitar la administración de alumnos, profesores y materias.
* Permitir el registro y seguimiento de inscripciones.
* Obtener reportes mediante consultas SQL, vistas y procedimientos almacenados.

---

## Entidades Principales

### Alumno

Almacena la información de los estudiantes registrados en el sistema.

Atributos:

* Legajo
* Nombre
* Apellido
* DNI
* Email

### Profesor

Almacena la información de los docentes.

Atributos:

* ID Profesor
* Nombre
* Apellido
* Email
* Categoría
* Sueldo

### Materia

Representa las materias ofrecidas por la institución.

Atributos:

* ID Materia
* Nombre de Materia
* Categoría
* Fecha de Inicio
* Cupos
* Precio
* ID Profesor

### Inscripción

Representa la cabecera de una operación de inscripción realizada por un alumno.

Cada inscripción almacena:

* Alumno que realiza la inscripción.
* Fecha de inscripción.
* Método de pago.
* Cantidad total de materias inscriptas.
* Importe total de la operación.

### Detalle_Inscripción

Representa cada materia incluida dentro de una inscripción.

Permite registrar múltiples materias dentro de una misma inscripción.

Atributos:

* ID Detalle
* ID Inscripción
* ID Materia
* Precio Unitario

---

## Relaciones

### Profesor - Materia

Relación 1:N

Un profesor puede dictar muchas materias.
Cada materia tiene asignado un único profesor.

### Alumno - Inscripción

Relación 1:N

Un alumno puede realizar múltiples inscripciones.
Cada inscripción pertenece a un único alumno.

### Inscripción - Detalle_Inscripción

Relación 1:N

Una inscripción puede contener varias materias.
Cada detalle pertenece a una única inscripción.

### Materia - Detalle_Inscripción

Relación 1:N

Una materia puede aparecer en múltiples detalles de inscripción.
Cada detalle corresponde a una única materia.

Conceptualmente existe una relación N:M entre Alumno y Materia, la cual se resuelve mediante las entidades Inscripción y Detalle_Inscripción.

---

## Funcionalidades Implementadas

* Creación de tablas con restricciones.
* Claves primarias y foráneas.
* Validaciones mediante CHECK.
* Inserción de datos de prueba.
* Consultas básicas.
* JOIN y LEFT JOIN.
* GROUP BY y HAVING.
* Subconsultas:

  * Escalares
  * IN
  * EXISTS
  * Correlacionadas
* Vistas.
* Procedimientos almacenados.
* Triggers.
* Normalización de la base de datos.

---

## Tecnologías Utilizadas

* SQL Server
* SQL (DDL y DML)
* Modelo Relacional
* Diagrama Entidad-Relación (DER)

# DB1-TPO-SQL

Trabajo Práctico Integrador de **Base de Datos** (Ingeniería de Datos I - UADE).

Este repositorio contiene el diseño e implementación de una base de datos relacional
para un sistema de gestión académica: administración de **alumnos**, **profesores**,
**materias** e **inscripciones**.

## Universo del discurso

El sistema modela una institución educativa que necesita organizar su información de
alumnos, profesores, oferta de materias y las inscripciones de los alumnos a esas
materias, resolviendo problemas de redundancia, inconsistencias y falta de control.

## Modelo de datos

El esquema implementado en SQL Server está compuesto por las siguientes tablas:

| Tabla | Descripción |
|-------|-------------|
| `Alumno` | Datos del alumno (legajo, nombre, apellido, DNI, email). |
| `Profesor` | Datos del profesor (id, nombre, apellido, email, categoría, sueldo). |
| `Materia` | Oferta de materias (id, nombre, categoría, fecha de inicio, cupos, precio) y su profesor a cargo. |
| `Inscripcion` | Inscripción de un alumno a una materia (fecha, método de pago, total). |
| `Detalle_Inscripcion` | Detalle de cada inscripción (materia, cantidad, precio unitario, total). |

Incluye claves primarias y foráneas, columnas `IDENTITY` y restricciones de integridad
(`CHECK`, `NOT NULL`) sobre montos, cupos y métodos de pago.

## Contenido del repositorio

- [`TP.sql`](TP.sql) — Script SQL con la creación de la base de datos, tablas y restricciones.

## Estado / próximos pasos

Según la consigna del TP, el trabajo abarca: carga de datos, consultas (básicas, JOIN,
`GROUP BY`/`HAVING`, subconsultas), vistas, procedimientos almacenados y triggers.

## Documentación externa

- 📄 **Documento del TP (Google Docs):** https://docs.google.com/document/d/1DQAHI1LZzGdfU5FOPqGwBLZ-Hv77GzDH6z-bOcB7MeQ/edit?usp=sharing
- 📊 **Diagrama Entidad-Relación (Lucidchart):** https://lucid.app/lucidchart/a8026e5e-6242-41a3-97ed-6ef640ae7324/edit?viewport_loc=538%2C-3445%2C4952%2C3605%2C0_0&invitationId=inv_27c706f4-239c-4391-9868-5c39dc6bc23e

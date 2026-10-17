# Gestión y Seguimiento de Trabajos de Grado – UTS

Aplicación web para gestionar el proceso de trabajo de grado: banco de ideas, inscripción de proyectos,
entregas por fases, revisiones del director, evaluador y comité, prórrogas, alertas de plagio, mensajería y calendario.

**Tecnologías:** JSP + JSTL · Apache Tomcat 9 · MySQL / MariaDB · JDBC (MySQL Connector/J 9.x)

## Documentación del proyecto

| Documento | Contenido |
|---|---|
| [`docs/modelo-entidad-relacion.png`](docs/modelo-entidad-relacion.png) | Modelo entidad–relación con llaves y cardinalidades |
| [`docs/modelo-relacional.png`](docs/modelo-relacional.png) | Modelo relacional con entidades, rombos de relación y cardinalidades |
| [`docs/Scrum_Sprints.md`](docs/Scrum_Sprints.md) | Metodología Scrum: tres sprints con Planning, Review y Retrospective |
| [`LEEME.txt`](LEEME.txt) | Instrucciones de instalación y roles del sistema |

## Metodología

El proyecto se desarrolló con Scrum en **tres sprints de siete días**:

| Sprint | Enfoque | Etiqueta Git |
|---|---|---|
| 1 | Cimientos y acceso: MER, modelo relacional, datos de prueba, conexión JDBC, landing page, registro, login y control por rol | `sprint-1` |
| 2 | Núcleo del negocio: ideas y proyectos, entregas (1:N), integrantes (N:M), buscador con filtros, perfil y paneles por rol | `sprint-2` |
| 3 | Operación y cierre: revisiones por fases, prórrogas, plagio, mensajería, calendario, reportes, pruebas y despliegue | `sprint-3` |

El detalle de cada sprint (historias de usuario, estimación, demostración y retrospectiva) está en [`docs/Scrum_Sprints.md`](docs/Scrum_Sprints.md).
Para ver el código tal como quedó al cierre de cada sprint: `git checkout sprint-1`, `git checkout sprint-2`, `git checkout sprint-3`.

## Instalación

1. Instala XAMPP (MySQL/MariaDB) y Apache Tomcat 9.
2. Importa `base_datos/proyecto_final_2.sql` en phpMyAdmin.
   **Advertencia:** el script empieza con `DROP DATABASE` y borra la base `proyecto_final_2`.
3. Copia esta carpeta como aplicación web en Tomcat. La conexión está en `WEB-INF/fragments/conexion.jspf`
   (usuario `root` sin clave, base `proyecto_final_2`).
4. Abre `http://localhost:8080/<nombre-de-la-aplicacion>/`.

## Usuarios de prueba (solo para desarrollo local)

| Rol | Correo | Clave |
|---|---|---|
| Administrador | admin@uts.edu.co | Admin123 |
| Comité | coordinador@uts.edu.co | Coord123 |
| Docente | diego.alvarez@uts.edu.co | Doc12345 |
| Estudiante | laura.gomez@uts.edu.co | Est12345 |

Estos datos son de ejemplo. No uses estas credenciales ni la conexión `root` sin clave en un servidor real.

## Estructura

```
admin/ coordinador/ docente/ evaluador/ estudiante/   paneles y procesos por rol
WEB-INF/fragments/                                     conexión, sesión, cabeceras y bloques reutilizables
base_datos/                                            script SQL y respaldo
css/ js/ img/ formatos/                                recursos estáticos
docs/                                                  modelos y documentación Scrum
```

## Fuera de alcance
Retiros y cambios (requerimientos 39 y 40).

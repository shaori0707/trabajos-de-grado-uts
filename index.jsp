<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UTS - Sistema de Gestión de Proyectos de Grado</title>
    <link rel="stylesheet" href="css/estilo.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>

    <nav class="navbar">
        <div class="container">
            <div class="logo">
                <img src="img/logo_uts.png" alt="Logo UTS" class="logo-img">
                <span class="logo-text">Proyectos de Grado</span>
            </div>
            <ul class="nav-links">
                <li><a href="#inicio">Inicio</a></li>
                <li><a href="#roles">Participantes</a></li>
                <li><a href="#somos">UTS</a></li>
                <li><a href="login.jsp" class="btn-acceso"><i class="fas fa-user"></i> Acceder</a></li>
            </ul>
        </div>
    </nav>

    <!-- HERO: texto izquierda + imagen derecha -->
    <section id="inicio" class="hero" style="background-image: linear-gradient(135deg, rgba(44,62,80,0.9) 0%, rgba(44,62,80,0.8) 100%), url('img/banner_uts.jpg'); background-size: cover; background-position: center;">
        <div class="container">
            <div class="hero-content">
                <h1>Gestión de Proyectos de Grado <span class="highlight">UTS</span></h1>
                <p>Plataforma oficial para la administración, seguimiento y evaluación de proyectos de grado en las <strong>Unidades Tecnológicas de Santander</strong>.</p>
                <div class="hero-buttons">
                    <a href="login.jsp" class="btn-primary"><i class="fas fa-sign-in-alt"></i> Iniciar sesión</a>
                    <a href="#roles" class="btn-secondary"><i class="fas fa-users"></i> Conocer participantes</a>
                </div>
            </div>
            <div class="hero-image">
                <i class="fas fa-project-diagram"></i>
            </div>
        </div>
    </section>

    <!-- Sección de roles -->
    <section id="roles" class="roles">
        <div class="container">
            <div class="section-header">
                <span class="section-tag">Participantes</span>
                <h2>Roles del Sistema</h2>
                <p>Cada actor cumple una función específica en el proceso de gestión de proyectos de grado</p>
            </div>
            <div class="roles-grid">
                <div class="role-card">
                    <div class="role-icon"><i class="fas fa-user-shield"></i></div>
                    <h3>Administrador</h3>
                    <p>Control total del sistema. Crea, elimina y asigna roles a todos los usuarios.</p>
                </div>
                <div class="role-card">
                    <div class="role-icon"><i class="fas fa-chalkboard-user"></i></div>
                    <h3>Coordinador</h3>
                    <p>Crea ideas de proyecto, aprueba propuestas y monitorea el avance general.</p>
                </div>
                <div class="role-card">
                    <div class="role-icon"><i class="fas fa-user-graduate"></i></div>
                    <h3>Estudiante</h3>
                    <p>Selecciona proyectos, sube recibos, elige compañero y consulta notas.</p>
                </div>
                <div class="role-card">
                    <div class="role-icon"><i class="fas fa-book-open"></i></div>
                    <h3>Director</h3>
                    <p>Califica proyectos, aprueba o reprueba y da observaciones detalladas.</p>
                </div>
                <div class="role-card">
                    <div class="role-icon"><i class="fas fa-check-double"></i></div>
                    <h3>Evaluador</h3>
                    <p>Aprueba de forma definitiva los proyectos de grado.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Sección de características -->
    <section class="features">
        <div class="container">
            <div class="features-content">
                <div class="features-text">
                    <span class="section-tag">Innovación</span>
                    <h2>Tecnología al servicio de la educación</h2>
                    <p>En las UTS implementamos herramientas digitales para optimizar la gestión de proyectos de grado, conectando a todos los actores del proceso académico.</p>
                    <ul class="features-list">
                        <li><i class="fas fa-check-circle"></i> Seguimiento en tiempo real</li>
                        <li><i class="fas fa-check-circle"></i> Evaluación transparente</li>
                        <li><i class="fas fa-check-circle"></i> Comunicación directa entre roles</li>
                        <li><i class="fas fa-check-circle"></i> Acceso a formatos y calendario académico</li>
                    </ul>
                </div>
                <div class="features-image">
                    <img src="https://images.unsplash.com/photo-1522071820081-009f0129c71c?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80" alt="Estudiantes UTS">
                </div>
            </div>
        </div>
    </section>

    <!-- Sección UTS -->
    <section id="somos" class="somos">
        <div class="container">
            <div class="somos-card">
                <i class="fas fa-graduation-cap"></i>
                <h2>Unidades Tecnológicas de Santander</h2>
                <p>Formando líderes con excelencia académica y compromiso social. Nuestro sistema de gestión de proyectos de grado garantiza el acompañamiento continuo a los estudiantes en su trabajo de grado.</p>
                <div class="somos-stats">
                    <div class="stat">
                        <span class="stat-number">+15</span>
                        <span class="stat-label">Tecnologías</span>
                    </div>
                    <div class="stat">
                        <span class="stat-number">+5000</span>
                        <span class="stat-label">Estudiantes</span>
                    </div>
                    <div class="stat">
                        <span class="stat-number">100%</span>
                        <span class="stat-label">Virtual</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <footer class="footer">
        <div class="container">
            <div class="footer-content">
                <div class="footer-logo">
                    <h3>UTS</h3>
                    <p>Unidades Tecnológicas de Santander</p>
                </div>
                <div class="footer-links">
                    <a href="#">Inicio</a>
                    <a href="#roles">Participantes</a>
                    <a href="login.jsp">Acceder</a>
                </div>
                <div class="footer-contact">
                    <p><i class="fas fa-map-marker-alt"></i> Bucaramanga, Santander</p>
                    <p><i class="fas fa-envelope"></i> proyectosgrado@uts.edu.co</p>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2026 UTS - Sistema de Gestión de Proyectos de Grado. Todos los derechos reservados.</p>
            </div>
        </div>
    </footer>

</body>
</html>
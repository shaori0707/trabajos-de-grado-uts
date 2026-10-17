<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="es_CO" />

<!-- Validar sesión y rol -->
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<c:set var="rolRequerido" value="admin" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>

<!-- Conexión a BD -->
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="nombresFase" value="${fn:split('Pago,Propuesta I,Propuesta II,Informe I,Informe II,Cierre', ',')}" />
<c:set var="seccionActual" value="${param.sec != null ? param.sec : 'dashboard'}" />
<c:set var="idAdmin" value="${sessionScope.idUsuario}" />

<sql:query dataSource="${db}" var="adminData">
    SELECT nombre, apellido, email, fecha_registro FROM usuarios WHERE id = ?
    <sql:param value="${idAdmin}" />
</sql:query>

<jsp:useBean id="fechaActual" class="java.util.Date" />

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Administrador - UTS</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background: #F4F7FC;
        }
        
        .dashboard {
            display: flex;
            min-height: 100vh;
        }
        
        /* Sidebar */
        .sidebar {
            width: 280px;
            background: white;
            box-shadow: 2px 0 20px rgba(0,0,0,0.03);
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            transition: all 0.3s ease;
            z-index: 1000;
        }
        
        .sidebar.collapsed {
            transform: translateX(-280px);
        }
        
        .sidebar-logo {
            padding: 25px 24px;
            border-bottom: 1px solid #E9ECEF;
            margin-bottom: 20px;
        }
        
        .sidebar-logo h2 {
            font-size: 1.3rem;
            font-weight: 700;
            color: #A6C21B;
        }
        
        .sidebar-logo p {
            font-size: 0.7rem;
            color: #8BA0AE;
        }
        
        .sidebar-menu {
            list-style: none;
            padding: 0 16px;
        }
        
        .sidebar-menu li {
            margin-bottom: 8px;
        }
        
        .sidebar-menu a {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 12px 18px;
            color: #5A6E7A;
            text-decoration: none;
            font-weight: 500;
            border-radius: 12px;
            transition: all 0.2s;
        }
        
        .sidebar-menu a:hover {
            background: #E8F5E9;
            color: #A6C21B;
        }
        
        .sidebar-menu a.active {
            background: #A6C21B;
            color: white;
        }
        
        .sidebar-menu a i {
            width: 22px;
        }
        
        .menu-divider {
            height: 1px;
            background: #E9ECEF;
            margin: 20px 16px;
        }
        
        .menu-title {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #ADB5BD;
            padding: 16px 18px 8px 18px;
            font-weight: 600;
        }
        
        /* Main Content */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 25px 30px;
            transition: all 0.3s ease;
        }
        
        .menu-toggle {
            position: fixed;
            top: 20px;
            left: 20px;
            z-index: 1100;
            background: white;
            border: none;
            border-radius: 12px;
            padding: 10px 14px;
            cursor: pointer;
            font-size: 1.2rem;
            color: #2C3E50;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: none;
        }
        
        .action-btn {
            background: white;
            border: none;
            padding: 10px 20px;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.85rem;
            color: #2C3E50;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            box-shadow: 0 2px 8px rgba(0,0,0,0.03);
        }
        
        .action-btn:hover {
            background: #A6C21B;
            color: white;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 22px 20px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 10px rgba(0,0,0,0.03);
        }
        
        .stat-left h3 {
            font-size: 1.8rem;
            font-weight: 800;
            color: #2C3E50;
        }
        
        .stat-left p {
            font-size: 0.75rem;
            color: #8BA0AE;
        }
        
        .stat-right {
            width: 50px;
            height: 50px;
            background: rgba(166,194,27,0.1);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            color: #A6C21B;
        }
        
        .section-card {
            background: white;
            border-radius: 24px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.03);
        }
        
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #F0F2F5;
        }
        
        .section-header h3 {
            font-size: 1.2rem;
            font-weight: 700;
            color: #2C3E50;
        }
        
        .badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.7rem;
            font-weight: 600;
        }
        
        .badge-admin { background: #DC3545; color: white; }
        .badge-coordinador { background: #17A2B8; color: white; }
        .badge-director { background: #FD7E14; color: white; }
        .badge-estudiante { background: #A6C21B; color: white; }
        .badge-evaluador { background: #6F42C1; color: white; }
        
        .perfil-info {
            display: flex;
            gap: 20px;
            align-items: center;
            flex-wrap: wrap;
            background: #F8FAFE;
            padding: 20px;
            border-radius: 20px;
        }
        
        .perfil-avatar {
            width: 70px;
            height: 70px;
            background: #A6C21B;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            color: white;
        }
        
        @media (max-width: 992px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .menu-toggle {
                display: block;
            }
            .sidebar {
                transform: translateX(-280px);
            }
            .sidebar.open {
                transform: translateX(0);
            }
            .main-content {
                margin-left: 0;
            }
        }
        
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            .main-content {
                padding: 20px;
            }
            .section-card {
                padding: 15px;
            }
        }
        
        .sidebar {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        
        .logout-sidebar {
            color: #DC3545 !important;
        }
        
        .logout-sidebar:hover {
            background: #DC3545 !important;
            color: white !important;
        }
        
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 2000;
            justify-content: center;
            align-items: center;
        }
        
        .modal-content {
            background: white;
            border-radius: 28px;
            width: 90%;
            max-width: 500px;
            padding: 30px;
            position: relative;
        }
        
        .modal-close {
            position: absolute;
            top: 15px;
            right: 20px;
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
        }

        /* Modal de detalles del proyecto */
.modal-proyecto {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    z-index: 10000;
    justify-content: center;
    align-items: center;
    overflow-y: auto;
}

.modal-proyecto-content {
    background: white;
    border-radius: 28px;
    width: 90%;
    max-width: 1000px;
    max-height: 90vh;
    overflow-y: auto;
    position: relative;
    margin: 20px;
    animation: modalSlideIn 0.3s ease;
}

@keyframes modalSlideIn {
    from {
        transform: translateY(-50px);
        opacity: 0;
    }
    to {
        transform: translateY(0);
        opacity: 1;
    }
}

.modal-proyecto-header {
    background: linear-gradient(135deg, #A6C21B 0%, #8FAA10 100%);
    color: white;
    padding: 20px 25px;
    border-radius: 28px 28px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: sticky;
    top: 0;
    z-index: 10;
}

.modal-proyecto-header h3 {
    margin: 0;
    font-size: 1.3rem;
}

.modal-proyecto-close {
    background: rgba(255,255,255,0.2);
    border: none;
    color: white;
    font-size: 1.5rem;
    cursor: pointer;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s;
}

.modal-proyecto-close:hover {
    background: rgba(255,255,255,0.4);
    transform: rotate(90deg);
}

.modal-proyecto-body {
    padding: 25px;
}

.loading-spinner {
    text-align: center;
    padding: 50px;
}

.loading-spinner i {
    font-size: 3rem;
    color: #A6C21B;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}

.info-detalle {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
    margin-bottom: 25px;
}

.info-detalle-item {
    background: #F8FAFE;
    padding: 18px;
    border-radius: 16px;
    border-left: 4px solid #A6C21B;
}

.info-detalle-label {
    font-size: 0.7rem;
    color: #8BA0AE;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 8px;
}

.info-detalle-value {
    font-size: 0.95rem;
    font-weight: 600;
    color: #2C3E50;
}

.avance-card {
    background: #F8FAFE;
    border-radius: 16px;
    padding: 18px;
    margin-bottom: 15px;
    border-left: 4px solid #17A2B8;
}

.estado-aprobado { background: #A6C21B; color: white; }
.estado-correcciones { background: #FFC107; color: #333; }
.estado-rechazado { background: #DC3545; color: white; }
.estado-pendiente { background: #6C757D; color: white; }

        .badge-docente { background: #FD7E14; color: white; }
.badge-admin { background: #DC3545; color: white; }
.badge-coordinador { background: #17A2B8; color: white; }
.badge-estudiante { background: #A6C21B; color: white; }
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/tg.css">
    <script src="${pageContext.request.contextPath}/js/tg.js" defer></script>
</head>
<body>

<button class="menu-toggle" id="menuToggle">
    <i class="fas fa-bars"></i>
</button>

<div class="dashboard">
    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-logo"><img src="${pageContext.request.contextPath}/img/logo_uts.png" alt="UTS"><i class="fas fa-bars" style="color:#55616C"></i></div>
        
        <div class="menu-title">Navegación</div>
        <ul class="sidebar-menu">
                <li><a href="dashboard.jsp?sec=dashboard" class="${seccionActual == 'dashboard' ? 'active' : ''}"><i class="fas fa-house"></i> Inicio</a></li>
                <li><a href="dashboard.jsp?sec=perfil" class="${seccionActual == 'perfil' ? 'active' : ''}"><i class="fas fa-id-badge"></i> Mi perfil</a></li>
                <li><a href="dashboard.jsp?sec=usuarios" class="${seccionActual == 'usuarios' ? 'active' : ''}"><i class="fas fa-users"></i> Usuarios</a></li>
                <li><a href="dashboard.jsp?sec=docentes" class="${seccionActual == 'docentes' ? 'active' : ''}"><i class="fas fa-chalkboard-user"></i> Docentes y evaluadores</a></li>
                <li><a href="dashboard.jsp?sec=banco" class="${seccionActual == 'banco' ? 'active' : ''}"><i class="fas fa-book"></i> Banco de ideas</a></li>
                <li><a href="dashboard.jsp?sec=proyectos" class="${seccionActual == 'proyectos' ? 'active' : ''}"><i class="fas fa-graduation-cap"></i> Proyectos de grado</a></li>
                <li><a href="dashboard.jsp?sec=formatos" class="${seccionActual == 'formatos' ? 'active' : ''}"><i class="fas fa-cloud-arrow-down"></i> Base documental</a></li>
                <li><a href="dashboard.jsp?sec=calendario" class="${seccionActual == 'calendario' ? 'active' : ''}"><i class="fas fa-calendar-days"></i> Calendario</a></li>
                <li><a href="dashboard.jsp?sec=configuraciones" class="${seccionActual == 'configuraciones' ? 'active' : ''}"><i class="fas fa-gears"></i> Configuraciones</a></li>
                <li><a href="dashboard.jsp?sec=mensajes" class="${seccionActual == 'mensajes' ? 'active' : ''}"><i class="fas fa-envelope"></i> Mensajes</a></li>
                <li><a href="dashboard.jsp?sec=reportes" class="${seccionActual == 'reportes' ? 'active' : ''}"><i class="fas fa-chart-line"></i> Reportes</a></li>
            </ul>
        
        <div style="flex: 1;"></div>
        
        <div class="menu-title"></div>
        <ul class="sidebar-menu">
            <li><a href="${pageContext.request.contextPath}/logout.jsp" class="logout-sidebar" onclick="return confirm('¿Estás seguro de que deseas cerrar sesión?')"><i class="fas fa-sign-out-alt"></i> Cerrar sesión</a></li>
        </ul>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content" id="mainContent">
        <%@ include file="/WEB-INF/fragments/tg_header.jspf" %>
        
                <!-- ==================== SECCIÓN: DASHBOARD ==================== -->
        <c:if test="${seccionActual == 'dashboard'}">
            <sql:query dataSource="${dataSource}" var="resumen">
                SELECT (SELECT COUNT(*) FROM usuarios) AS usuarios,
                       (SELECT COUNT(*) FROM usuarios WHERE rol IN ('docente','evaluador')) AS docentes,
                       (SELECT COUNT(*) FROM proyectos WHERE cancelado = 0 AND estado_fase NOT IN ('Rechazado','Finalizado')) AS proyectos,
                       (SELECT COUNT(*) FROM ideas_proyecto WHERE estado = 'pendiente') AS ideas,
                       (SELECT COUNT(*) FROM formatos_grado) AS formatos,
                       (SELECT COUNT(*) FROM alerta_plagio WHERE atendida = 0) AS plagios
            </sql:query>
            <c:set var="rs" value="${resumen.rows[0]}" />
            <div class="section-card tg-inicio">
                <h2 class="tg-titulo">SISTEMA - TRABAJOS DE <span>GRADO</span></h2>
                <p class="tg-sub" style="text-align:left;margin-top:14px;">Bienvenido al panel del administrador, aquí podrás gestionar:</p>
                <div class="tg-cards">
                    <a class="tg-card" href="dashboard.jsp?sec=usuarios"><i class="fas fa-users"></i><strong>Usuarios</strong><small>${rs.usuarios} usuarios: crea, edita y elimina cuentas y roles.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=docentes"><i class="fas fa-chalkboard-user"></i><strong>Docentes y evaluadores</strong><small>Inscríbelos cada semestre con cédula, correo y nombre.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=proyectos"><i class="fas fa-graduation-cap"></i><strong>Proyectos de grado</strong><small>${rs.proyectos} activos. Edita fase, estado, responsable y docentes.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=banco"><i class="fas fa-book"></i><strong>Banco de ideas</strong><small>Consulta las ideas aprobadas del periodo actual.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=formatos"><i class="fas fa-book-open"></i><strong>Base Documental</strong><small>${rs.formatos} enlaces: calendario, formatos y reglamentos.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=calendario"><i class="fas fa-calendar-days"></i><strong>Calendario Académico</strong><small>Administra los eventos y fechas importantes.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=configuraciones"><i class="fas fa-gears"></i><strong>Configuraciones</strong><small>Fechas del periodo y copia de seguridad.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=mensajes"><i class="fas fa-envelope"></i><strong>Mensajes</strong><small>Comunicación interna con docentes, Comité y estudiantes.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=reportes"><i class="fas fa-chart-line"></i><strong>Reportes</strong><small>Resumen de usuarios y actividad del sistema.</small></a>
                </div>
                <c:if test="${rs.plagios > 0}"><div class="alert alert-warning" style="margin-top:18px;text-align:left;"><i class="fas fa-exclamation-triangle"></i> Hay ${rs.plagios} alerta(s) de posible plagio sin atender por el Comité.</div></c:if>
            </div>
        </c:if>
        <!-- ==================== USUARIOS ==================== -->
        <c:if test="${seccionActual == 'usuarios'}">
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'ok'}"><div class="alert alert-success" style="margin-bottom:16px;">Listo, quedó registrado.</div></c:if>
            <div class="section-card" style="margin-bottom: 25px; background: linear-gradient(135deg, #A6C21B 0%, #8FAA10 100%); color: white; padding: 20px 25px;">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                    <div>
                        <h2 style="font-size: 1.3rem; margin-bottom: 5px;"><i class="fas fa-users"></i> Gestión de Usuarios</h2>
                        <p style="opacity: 0.85; font-size: 0.85rem;">Administra todos los usuarios del sistema, filtrando por rol</p>
                    </div>
                    <div>
                        <span style="background: rgba(255,255,255,0.2); padding: 6px 16px; border-radius: 40px; font-size: 0.8rem;">
                            <i class="fas fa-calendar-alt"></i> <fmt:formatDate value="${fechaActual}" pattern="EEEE, d 'de' MMMM 'de' yyyy" />
                        </span>
                    </div>
                </div>
            </div>
            
            <div class="section-card">
                <div class="section-header">
                    <h3><i class="fas fa-users"></i> Gestión de Usuarios</h3>
                    <button onclick="abrirModalCrearUsuario()" class="action-btn" style="background:#A6C21B; color:white;"><i class="fas fa-user-plus"></i> Nuevo Usuario</button>
                </div>
                
                <div style="background: #F8FAFE; padding: 20px; border-radius: 20px; margin-bottom: 25px;">
                    <form method="get" action="dashboard.jsp" style="display: flex; gap: 15px; align-items: flex-end; flex-wrap: wrap;">
                        <input type="hidden" name="sec" value="usuarios">
                        <div style="flex: 1; min-width: 200px;">
                            <label style="display: block; font-size: 0.75rem; font-weight: 600; color: #6C757D; margin-bottom: 5px;">Filtrar por rol</label>
                            <select name="filtro_rol" style="width: 100%; padding: 10px 15px; border-radius: 12px; border: 1px solid #E9ECEF;">
                                <option value="">Todos los usuarios</option>
                                <option value="admin" ${param.filtro_rol == 'admin' ? 'selected' : ''}>Administradores</option>
                                <option value="coordinador" ${param.filtro_rol == 'coordinador' ? 'selected' : ''}>Comité</option>
                                <option value="docente" ${param.filtro_rol == 'docente' ? 'selected' : ''}>Docentes</option>
                                <option value="estudiante" ${param.filtro_rol == 'estudiante' ? 'selected' : ''}>Estudiantes</option>
                            </select>
                        </div>
                        <div>
                            <label style="display: block; font-size: 0.75rem; font-weight: 600; color: #6C757D; margin-bottom: 5px;">&nbsp;</label>
                            <button type="submit" class="action-btn" style="background:#A6C21B; color:white;"><i class="fas fa-search"></i> Filtrar</button>
                            <a href="dashboard.jsp?sec=usuarios" class="action-btn" style="background:#6C757D; color:white;"><i class="fas fa-eraser"></i> Limpiar</a>
                        </div>
                    </form>
                </div>
                
                <sql:query dataSource="${db}" var="todosUsuarios">
                    SELECT id, nombre, apellido, email, rol, estado, fecha_registro 
                    FROM usuarios 
                    WHERE 1=1
                    <c:if test="${not empty param.filtro_rol}">
                        AND rol = ? 
                        <sql:param value="${param.filtro_rol}" />
                    </c:if>
                    ORDER BY id DESC
                </sql:query>
                
                <div style="margin-bottom: 20px; padding: 8px 15px; background: #E8F5E9; border-radius: 30px; display: inline-block;">
                    <i class="fas fa-users" style="color:#A6C21B;"></i>
                    <span style="font-weight: 600; color:#2C3E50;">${fn:length(todosUsuarios.rows)} usuarios encontrados</span>
                </div>
                
                <div style="overflow-x: auto;">
                    <table class="tg-tabla" data-tg>
                        <thead>
                            <tr style="background: #F8F9FA; border-bottom: 2px solid #E9ECEF;">
                                <th style="text-align: left; padding: 14px 12px;">ID</th>
                                <th style="text-align: left; padding: 14px 12px;">Nombre</th>
                                <th style="text-align: left; padding: 14px 12px;">Email</th>
                                <th style="text-align: left; padding: 14px 12px;">Rol</th>
                                <th style="text-align: left; padding: 14px 12px;">Estado</th>
                                <th style="text-align: center; padding: 14px 12px;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="u" items="${todosUsuarios.rows}">
                                <tr style="border-bottom: 1px solid #F0F2F5;">
                                    <td style="padding: 12px;">${u.id}</td>
                                    <td style="padding: 12px;"><strong>${u.nombre} ${u.apellido}</strong></td>
                                    <td style="padding: 12px;">${u.email}</td>
                                    <td style="padding: 12px;"><span class="badge badge-${u.rol}">${u.rol}</span></td>
                                    <td style="padding: 12px;">
                                        <c:choose>
                                            <c:when test="${u.estado == 1}"><span style="color:#A6C21B;">Activo</span></c:when>
                                            <c:otherwise><span style="color:#DC3545;">Inactivo</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px; text-align: center;">
                                        <button onclick="abrirModalEditarUsuario(${u.id})" class="action-btn" style="background:#A6C21B; color:white; padding: 6px 14px; border: none; cursor: pointer;"><i class="fas fa-edit"></i> Editar</button>
                                        <a href="eliminar_usuario.jsp?id=${u.id}" class="action-btn" style="background:#DC3545; color:white; padding: 6px 14px; text-decoration: none;" onclick="return confirm('¿Eliminar este usuario?')"><i class="fas fa-trash"></i> Eliminar</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                
                <div style="margin-top: 20px; text-align: left;">
                    
                </div>
                
                <c:if test="${empty todosUsuarios.rows}">
                    <div style="text-align: center; padding: 50px;">
                        <p>No hay usuarios registrados con este rol.</p>
                    </div>
                </c:if>
            </div>
            
            <!-- Modal para crear usuario -->
            <div id="modalCrearUsuario" class="modal">
                <div class="modal-content" style="max-width: 550px;">
                    <button class="modal-close" onclick="cerrarModalCrearUsuario()">&times;</button>
                    <h3><i class="fas fa-user-plus"></i> Crear Nuevo Usuario</h3>
                    <form id="formCrearUsuario" action="crear_usuario.jsp" method="post">
                        <input type="hidden" name="modal" value="1">
                        <div><label>Nombre</label><input type="text" name="nombre" id="nombre_usuario" required style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;"></div>
                        <div><label>Apellido</label><input type="text" name="apellido" id="apellido_usuario" required style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;"></div>
                        <div><label>Email</label><input type="email" name="email" id="email_usuario" required style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;"></div>
                        <div><label>Contraseña</label><input type="password" name="password" id="password_usuario" required style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;"></div>
                        <div><label>Rol</label>
                            <select name="rol" id="rol_usuario" required style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;">
                                <option value="">Seleccione</option>
                                <option value="admin">Administrador</option>
                                <option value="coordinador">Comité</option>
                                <option value="estudiante">Estudiante</option>
                                <option value="docente">Docente (Director y Evaluador)</option>
                            </select>
                        </div>
                        <div><label>Cédula (docentes y estudiantes)</label><input type="text" name="cedula" id="cedula" pattern="[0-9]{5,15}" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></div>
                        <div><label>Nivel (solo estudiantes)</label><select name="nivel" id="nivel" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"><option value="">—</option><option value="tecnologia">Tecnología</option><option value="ingenieria">Ingeniería</option></select></div>
                        <div><label>Código (solo estudiantes)</label><input type="text" name="codigo" id="codigo_usuario" style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;"></div>
                        <button type="submit" class="action-btn" style="background:#A6C21B; color:white; width:100%;">Guardar</button>
                    </form>
                </div>
            </div>
            
            <!-- Modal para editar usuario -->
            <div id="modalEditarUsuario" class="modal">
                <div class="modal-content" style="max-width: 550px;">
                    <button class="modal-close" onclick="cerrarModalEditarUsuario()">&times;</button>
                    <h3><i class="fas fa-user-edit"></i> Editar Usuario</h3>
                    <form action="editar_usuario_procesar.jsp" method="post">
                        <input type="hidden" name="id" id="edit_id">
                        <input type="hidden" name="modal" value="1">
                        <div><label>Nombre</label><input type="text" name="nombre" id="edit_nombre" required style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;"></div>
                        <div><label>Apellido</label><input type="text" name="apellido" id="edit_apellido" required style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;"></div>
                        <div><label>Email</label><input type="email" name="email" id="edit_email" required style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;"></div>
                        <div><label>Contraseña (dejar en blanco para no cambiar)</label><input type="password" name="password" id="edit_password" style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;"></div>
                        <div><label>Rol</label>
                            <select name="rol" id="edit_rol" required style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;">
                                <option value="admin">Administrador</option>
                                <option value="coordinador">Comité</option>
                                <option value="estudiante">Estudiante</option>
                                <option value="docente">Docente (Director y Evaluador)</option>
                            </select>
                        </div>
                        <div><label>Estado</label>
                            <select name="estado" id="edit_estado" required style="width:100%; padding: 10px; margin-bottom: 15px; border-radius: 10px; border: 1px solid #ddd;">
                                <option value="1">Activo</option>
                                <option value="0">Inactivo</option>
                            </select>
                        </div>
<div><label>Cédula (docentes y estudiantes)</label><input type="text" name="cedula" id="edit_cedula" pattern="[0-9]{5,15}" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></div>
                        <div><label>Nivel (solo estudiantes)</label><select name="nivel" id="edit_nivel" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"><option value="">—</option><option value="tecnologia">Tecnología</option><option value="ingenieria">Ingeniería</option></select></div>
                        <div><label>Código</label><input type="text" name="codigo" id="edit_codigo" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></div>
                        <button type="submit" class="action-btn" style="background:#A6C21B; color:white; width:100%;">Guardar Cambios</button>
                    </form>
                </div>
            </div>
        </c:if>
        <!-- ==================== SECCIÓN: PROYECTOS ==================== -->
        <c:if test="${seccionActual == 'proyectos'}">
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'ok'}"><div class="alert alert-success" style="margin-bottom:16px;">Listo, quedó registrado.</div></c:if>
            <sql:query dataSource="${dataSource}" var="docs">SELECT id, nombre, apellido FROM usuarios WHERE rol IN ('docente','evaluador') AND estado = 1 ORDER BY nombre</sql:query>
                <sql:query dataSource="${dataSource}" var="evals">SELECT id, nombre, apellido FROM usuarios WHERE rol IN ('docente','evaluador') AND estado = 1 ORDER BY nombre</sql:query>
            <sql:query dataSource="${dataSource}" var="lista">
                SELECT p.id, p.codigo, p.titulo, p.fase_actual, p.estado_fase, p.responsable, p.bloqueado, p.cancelado, p.director_id, p.evaluador_id, p.fecha_sustentacion,
                       (SELECT GROUP_CONCAT(CONCAT(u.nombre, ' ', COALESCE(u.apellido, '')) SEPARATOR ', ') FROM proyecto_estudiantes pe JOIN usuarios u ON u.id = pe.estudiante_id WHERE pe.proyecto_id = p.id) AS estudiantes
                  FROM proyectos p ORDER BY p.id DESC
            </sql:query>
            <c:if test="${not empty param.info}"><c:set var="idInfo" value="${param.info}" /><c:set var="tgCerrar" value="dashboard.jsp?sec=proyectos" /><%@ include file="/WEB-INF/fragments/tg_detalle.jspf" %></c:if>
            <c:set var="ep" value="${null}" />
            <c:forEach var="p" items="${lista.rows}"><c:if test="${p.id == param.editar}"><c:set var="ep" value="${p}" /></c:if></c:forEach>
            <div class="section-card">
                <h2 class="tg-titulo">Proyectos de <span>GRADO</span></h2>
                <p class="tg-sub">Corrige datos cuando el sistema no permita hacerlo por el flujo normal (fase, estado, responsable, bloqueo y docentes). Usa el lápiz azul para editar.</p>
                <div style="overflow-x:auto"><table class="tg-tabla" data-tg>
                    <thead><tr><th>ID</th><th>Descripción</th><th>Estudiantes</th><th class="cen">Estado</th><th class="cen">Acciones</th></tr></thead><tbody>
                    <c:forEach var="p" items="${lista.rows}"><tr>
                        <td>GRA-${fn:substring(100000 + p.id, 1, 6)}</td><td><c:out value="${p.titulo}" /></td><td><c:out value="${p.estudiantes}" /></td>
                        <td class="cen"><c:choose><c:when test="${p.cancelado == 1}"><span class="tg-badge mal">Cancelado</span></c:when><c:when test="${p.estado_fase == 'Finalizado'}"><span class="tg-badge ok">Finalizado</span></c:when><c:when test="${p.estado_fase == 'Rechazado'}"><span class="tg-badge mal">Rechazada</span></c:when>
                            <c:otherwise><span class="tg-badge fase">Fase ${p.fase_actual}</span><span class="tg-badge resp">${p.responsable}</span><c:if test="${p.bloqueado == 1}"><span class="tg-badge mal">Bloqueado</span></c:if></c:otherwise></c:choose></td>
                        <td class="acc cen"><a class="tg-ico pizarra" href="dashboard.jsp?sec=proyectos&info=${p.id}" title="Ver detalles" aria-label="Ver detalles"><i class="far fa-eye"></i></a>
                            <a class="tg-ico azul" href="dashboard.jsp?sec=proyectos&editar=${p.id}" title="Editar proyecto" aria-label="Editar proyecto"><i class="fas fa-pen"></i></a>
                            <form method="post" action="eliminar_proyecto.jsp" style="display:inline"><input type="hidden" name="id" value="${p.id}"><button type="submit" class="tg-ico rojo" title="Eliminar proyecto" aria-label="Eliminar proyecto" onclick="return confirm('Se eliminará el proyecto con sus entregas y revisiones. ¿Continuar?')"><i class="fas fa-trash"></i></button></form></td></tr></c:forEach>
                    </tbody></table></div>
            </div>
            <c:if test="${not empty ep}">
            <div class="modal" style="display:flex" data-fijo><div class="modal-content" style="position:relative">
                <a class="tg-cerrar" href="dashboard.jsp?sec=proyectos" aria-label="Cerrar">&times;</a>
                <div class="tg-modal-titulo">Editar <span>PROYECTO</span></div>
                <p class="tg-sub"><c:out value="${ep.codigo} · ${ep.titulo}" /></p>
                <form method="post" action="corregir_proyecto.jsp" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:12px;"><input type="hidden" name="id" value="${ep.id}">
                    <label>Fase<select name="fase" class="tg-input"><c:forEach var="n" begin="1" end="6"><option value="${n}" ${ep.fase_actual == n ? 'selected' : ''}>${n}. ${nombresFase[n-1]}</option></c:forEach></select></label>
                    <label>Estado<select name="estado" class="tg-input"><c:forEach var="e" items="${fn:split('Pendiente de entrega,En revisión,Aplazado,Rechazado,Finalizado', ',')}"><option ${ep.estado_fase == e ? 'selected' : ''}>${e}</option></c:forEach></select></label>
                    <label>Responsable<select name="responsable" class="tg-input"><c:forEach var="e" items="${fn:split('Estudiante,Director,Evaluador,Comité', ',')}"><option ${ep.responsable == e ? 'selected' : ''}>${e}</option></c:forEach></select></label>
                    <label>Director<select name="directorId" class="tg-input"><option value="">Sin asignar</option><c:forEach var="d" items="${docs.rows}"><option value="${d.id}" ${ep.director_id == d.id ? 'selected' : ''}><c:out value="${d.nombre} ${d.apellido}" /></option></c:forEach></select></label>
                    <label>Evaluador<select name="evaluadorId" class="tg-input"><option value="">Sin asignar</option><c:forEach var="d" items="${evals.rows}"><option value="${d.id}" ${ep.evaluador_id == d.id ? 'selected' : ''}><c:out value="${d.nombre} ${d.apellido}" /></option></c:forEach></select></label>
                    <label>Fecha de sustentación<input type="date" name="sustentacion" value="${ep.fecha_sustentacion}" class="tg-input"></label>
                    <label><input type="checkbox" name="bloqueado" value="1" ${ep.bloqueado == 1 ? 'checked' : ''}> Bloqueado</label>
                    <label><input type="checkbox" name="cancelado" value="1" ${ep.cancelado == 1 ? 'checked' : ''}> Cancelado</label>
                    <div style="grid-column:1/-1;text-align:right"><a class="tg-btn gris" href="dashboard.jsp?sec=proyectos">Cancelar</a> <button type="submit" class="tg-btn" onclick="return confirm('¿Guardar los cambios del proyecto?')">Guardar cambios</button></div>
                </form></div></div>
            </c:if>
        </c:if>
                      <!-- ==================== SECCIÓN: DOCENTES ==================== -->
        <c:if test="${seccionActual == 'docentes'}">
            <div class="banner-fecha"><h2 style="font-size:1.3rem;"><i class="fas fa-chalkboard-teacher"></i> Docentes y evaluadores</h2><p>Inscribe a los docentes y evaluadores cada semestre con cédula, correo y nombre</p></div>
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><i class="fas fa-exclamation-triangle"></i> <c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> Listo, quedó registrado.</div></c:if>
            <form method="post" action="inscribir_docente.jsp" class="section-card" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:12px;align-items:end;">
                <label>Cédula<input type="text" name="cedula" required pattern="[0-9]{5,15}" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                <label>Correo institucional<input type="email" name="correo" required style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                <label>Rol<select name="rol" style="width:100%;padding:10px;border:1px solid #DDE2E5;border-radius:8px;"><option value="docente">Docente (Director y Evaluador)</option></select></label>
                <label>Nombre<input type="text" name="nombre" required maxlength="100" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                <div><button type="submit" class="tg-btn">Inscribir</button></div>
                <p style="grid-column:1/-1;font-size:.85rem;color:#6C757D;">La contraseña inicial es la cédula; el docente debe cambiarla.</p>
            </form>
            <sql:query dataSource="${dataSource}" var="dcs">
                SELECT u.nombre, u.apellido, u.email, u.cedula, u.estado,
                       (SELECT COUNT(*) FROM ideas_proyecto i WHERE i.creado_por = u.id) AS ideas
                  FROM usuarios u WHERE u.rol IN ('docente','evaluador') ORDER BY u.rol, u.nombre
            </sql:query>
            <div class="section-card" style="overflow-x:auto;"><table class="tg-tabla"><tr style="text-align:left;"><th>Nombre</th><th>Rol</th><th>Cédula</th><th>Correo</th><th>Ideas</th><th>Estado</th></tr>
                <c:forEach var="d" items="${dcs.rows}"><tr style="border-top:1px solid #E9ECEF;"><td><c:out value="${d.nombre} ${d.apellido}" /></td><td>${d.rol == 'evaluador' ? 'Evaluador' : 'Docente'}</td><td>${d.cedula}</td><td>${d.email}</td><td>${d.ideas}</td><td>${d.estado == 1 ? 'Activo' : 'Inactivo'}</td></tr></c:forEach></table></div>
        </c:if>
        <!-- ==================== SECCIÓN: BANCO ==================== -->
        <c:if test="${seccionActual == 'banco'}">
            <sql:query dataSource="${dataSource}" var="bancoIdeas">
                SELECT i.id, i.titulo, i.disponible, i.nivel, CONCAT(u.nombre, ' ', COALESCE(u.apellido, '')) AS docente,
                       (SELECT nombre FROM periodo_academico WHERE activo = 1 ORDER BY id DESC LIMIT 1) AS periodo
                  FROM ideas_proyecto i JOIN usuarios u ON u.id = i.creado_por WHERE i.estado = 'aprobada' AND i.origen = 'banco' ORDER BY i.id DESC
            </sql:query>
            <div class="section-card"><h2 class="tg-titulo">Banco de <span>IDEAS</span></h2>
                <p class="tg-sub">Ideas aprobadas del periodo actual.</p>
                <div style="overflow-x:auto"><table class="tg-tabla" data-tg>
                    <thead><tr><th>ID</th><th>Título de la idea</th><th>Disponible</th><th>Periodo</th><th>Nivel</th><th>Docente</th></tr></thead><tbody>
                    <c:forEach var="i" items="${bancoIdeas.rows}"><tr><td>BAN-${fn:substring(100000 + i.id, 1, 6)}</td><td><c:out value="${i.titulo}" /></td>
                        <td><span class="tg-badge ${i.disponible == 1 ? 'ok' : 'mal'}">${i.disponible == 1 ? 'Sí' : 'No'}</span></td><td>${fn:replace(i.periodo, '.', '-')}</td>
                        <td>${i.nivel == 'tecnologia' ? 'Tecnológico' : 'Profesional'}</td><td><c:out value="${i.docente}" /></td></tr></c:forEach></tbody></table></div></div>
        </c:if>
        <!-- ==================== SECCIÓN: CONFIGURACIONES ==================== -->
        <c:if test="${seccionActual == 'configuraciones'}">
            <div class="section-card"><h2 class="tg-titulo">Configuración <span>GENERAL</span></h2>
                <p class="tg-sub">Aquí podrás ajustar algunos módulos generales del sistema para modificar su comportamiento.</p>
                <div class="tg-cards" style="grid-template-columns:repeat(auto-fit,minmax(260px,320px));justify-content:start;">
                    <a class="tg-card" href="dashboard.jsp?sec=periodos"><i class="fas fa-calendar-days"></i><strong>Fechas del periodo</strong><small>Ajusta las fechas del periodo académico actual y las ventanas de cada fase.</small></a>
                    <a class="tg-card" href="#" data-modal="tgModalBackup" onclick="return false;"><i class="fas fa-database"></i><strong>Copia de seguridad</strong><small>Cómo descargar un respaldo del sistema para restauración.</small></a>
                </div></div>
            <div class="modal" id="tgModalBackup"><div class="modal-content" style="position:relative">
                <button type="button" class="tg-cerrar tg-cerrar-modal" aria-label="Cerrar">&times;</button>
                <div class="tg-modal-titulo">Copia de <span>SEGURIDAD</span></div>
                <div class="tg-fila"><b>Con el proyecto:</b><span>Ejecuta <code>base_datos/respaldo_base_datos.bat</code> en el servidor. Genera un archivo .sql con la fecha.</span></div>
                <div class="tg-fila"><b>Con phpMyAdmin:</b><span>Abre la base <code>proyecto_final_2</code> y usa Exportar (método rápido, formato SQL).</span></div>
                <div class="tg-fila"><b>Recomendación:</b><span>Programa el respaldo cada 2 o 3 días con el Programador de tareas de Windows.</span></div>
                <div style="text-align:right;margin-top:16px"><button type="button" class="tg-btn gris tg-cerrar-modal">Cerrar</button></div></div></div>
        </c:if>
        <!-- ==================== SECCIÓN: PERIODOS ==================== -->
        <c:if test="${seccionActual == 'periodos'}">
            <div class="banner-fecha"><h2 style="font-size:1.3rem;"><i class="fas fa-calendar-check"></i> Periodos y fechas</h2><p>Inicio, fin y ventanas de cada fase, definidas por el Consejo de Facultad</p></div>
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><i class="fas fa-exclamation-triangle"></i> <c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> Listo, quedó registrado.</div></c:if>
            <sql:query dataSource="${dataSource}" var="pers">SELECT * FROM periodo_academico ORDER BY fecha_inicio DESC</sql:query>
            <c:if test="${not empty param.editar}"><sql:query dataSource="${dataSource}" var="pe">SELECT * FROM periodo_academico WHERE id = ?<sql:param value="${param.editar}" /></sql:query></c:if>
            <div class="section-card" style="overflow-x:auto;"><table class="tg-tabla"><tr style="text-align:left;"><th>Periodo</th><th>Inicio</th><th>Fin</th><th>Semana límite propuesta</th><th>Activo</th><th></th></tr>
                <c:forEach var="x" items="${pers.rows}"><tr style="border-top:1px solid #E9ECEF;"><td>${x.nombre}</td><td>${fn:substring(x.fecha_inicio,8,10)}/${fn:substring(x.fecha_inicio,5,7)}/${fn:substring(x.fecha_inicio,0,4)}</td><td>${fn:substring(x.fecha_fin,8,10)}/${fn:substring(x.fecha_fin,5,7)}/${fn:substring(x.fecha_fin,0,4)}</td><td>${x.semana_limite_propuesta}</td><td>${x.activo == 1 ? 'Sí' : 'No'}</td><td><a href="dashboard.jsp?sec=periodos&editar=${x.id}" class="tg-btn" style="padding:4px 14px">Editar</a></td></tr></c:forEach></table></div>
            <c:set var="ed" value="${empty pe.rows ? null : pe.rows[0]}" />
            <form method="post" action="guardar_periodo.jsp" class="section-card" style="display:grid;gap:12px;">
                <h3>${empty ed ? 'Nuevo periodo' : 'Editar periodo'}</h3><input type="hidden" name="periodoId" value="${ed.id}">
                <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px;">
                    <label>Nombre (ej. 2026.2)<input type="text" name="nombre" maxlength="10" required value="<c:out value='${ed.nombre}'/>" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                    <label>Inicio<input type="date" name="inicio" required value="${ed.fecha_inicio}" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                    <label>Fin<input type="date" name="fin" required value="${ed.fecha_fin}" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                    <label>Semana límite de la propuesta<input type="number" name="semana" min="1" max="20" required value="${empty ed ? 12 : ed.semana_limite_propuesta}" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                </div>
                <label><input type="checkbox" name="activo" value="1" ${empty ed or ed.activo == 1 ? 'checked' : ''}> Periodo activo</label>
                <c:forEach var="n" begin="1" end="6">
                    <c:set var="vd" value="" /><c:set var="vh" value="" />
                    <c:if test="${not empty ed}"><sql:query dataSource="${dataSource}" var="vf">SELECT desde, hasta FROM ventana_fase WHERE periodo_id = ? AND fase = ?<sql:param value="${ed.id}" /><sql:param value="${n}" /></sql:query>
                        <c:if test="${not empty vf.rows}"><c:set var="vd" value="${vf.rows[0].desde}" /><c:set var="vh" value="${vf.rows[0].hasta}" /></c:if></c:if>
                    <div style="display:grid;grid-template-columns:150px 1fr 1fr;gap:10px;align-items:center;"><strong>${n}. ${nombresFase[n-1]}</strong>
                        <input type="date" name="desde" value="${vd}" aria-label="Desde fase ${n}" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"><input type="date" name="hasta" value="${vh}" aria-label="Hasta fase ${n}" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></div>
                </c:forEach>
                <div><button type="submit" class="action-btn">Guardar periodo</button> <c:if test="${not empty ed}"><a href="dashboard.jsp?sec=periodos" class="action-btn btn-outline">Nuevo</a></c:if></div>
            </form>
        </c:if>
        <!-- ==================== CALENDARIO ==================== -->
                      <!-- ==================== CALENDARIO ==================== -->
        <c:if test="${seccionActual == 'calendario'}">
            <!-- Banner con fecha -->
            <div class="section-card" style="margin-bottom: 25px; background: linear-gradient(135deg, #A6C21B 0%, #8FAA10 100%); color: white; padding: 20px 25px;">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                    <div>
                        <h2 style="font-size: 1.3rem; margin-bottom: 5px;"><i class="fas fa-calendar-alt"></i> Calendario Académico</h2>
                        <p style="opacity: 0.85; font-size: 0.85rem;">Gestiona los eventos y fechas importantes del calendario</p>
                    </div>
                    <div>
                        <span style="background: rgba(255,255,255,0.2); padding: 6px 16px; border-radius: 40px; font-size: 0.8rem;">
                            <i class="fas fa-calendar-alt"></i> <fmt:formatDate value="${fechaActual}" pattern="EEEE, d 'de' MMMM 'de' yyyy" />
                        </span>
                    </div>
                </div>
            </div>
            
            <!-- Variables para el calendario -->
            <c:set var="añoActualCal" value="${param.año != null ? param.año : fechaActual.year + 1900}" />
            <c:set var="mesActualCal" value="${param.mes != null ? param.mes : fechaActual.month + 1}" />
            
            <!-- Calcular mes anterior y siguiente -->
            <c:set var="mesPrevCal" value="${mesActualCal - 1}" />
            <c:set var="añoPrevCal" value="${añoActualCal}" />
            <c:if test="${mesPrevCal < 1}">
                <c:set var="mesPrevCal" value="12" />
                <c:set var="añoPrevCal" value="${añoActualCal - 1}" />
            </c:if>
            
            <c:set var="mesNextCal" value="${mesActualCal + 1}" />
            <c:set var="añoNextCal" value="${añoActualCal}" />
            <c:if test="${mesNextCal > 12}">
                <c:set var="mesNextCal" value="1" />
                <c:set var="añoNextCal" value="${añoActualCal + 1}" />
            </c:if>
            
            <!-- Obtener eventos del mes -->
            <c:set var="fechaInicioCal" value="${añoActualCal}-${mesActualCal < 10 ? '0' : ''}${mesActualCal}-01" />
            <c:set var="ultimoDia" value="31" />
            <c:choose>
                <c:when test="${mesActualCal == 2}">
                    <c:set var="ultimoDia" value="28" />
                    <c:if test="${(añoActualCal % 4 == 0 and añoActualCal % 100 != 0) or (añoActualCal % 400 == 0)}">
                        <c:set var="ultimoDia" value="29" />
                    </c:if>
                </c:when>
                <c:when test="${mesActualCal == 4 or mesActualCal == 6 or mesActualCal == 9 or mesActualCal == 11}">
                    <c:set var="ultimoDia" value="30" />
                </c:when>
            </c:choose>
            <c:set var="fechaFinCal" value="${añoActualCal}-${mesActualCal < 10 ? '0' : ''}${mesActualCal}-${ultimoDia}" />
            
            <sql:query dataSource="${db}" var="eventosMesCal">
                SELECT id, titulo, fecha_evento FROM calendario_academico 
                WHERE fecha_evento BETWEEN ? AND ? 
                ORDER BY fecha_evento
                <sql:param value="${fechaInicioCal}" />
                <sql:param value="${fechaFinCal}" />
            </sql:query>
            
            <!-- Obtener el nombre del mes -->
            <c:set var="mesesNombre" value="Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre" />
            <c:set var="mesNombreCal" value="${fn:split(mesesNombre, ',')[mesActualCal - 1]}" />
            
            <div class="section-card">
                <div class="section-header">
                    <h3><i class="fas fa-calendar-alt"></i> ${mesNombreCal} ${añoActualCal}</h3>
                    <div style="display: flex; gap: 10px;">
                        <a href="https://www.uts.edu.co/sitio/calendario-academico" target="_blank" class="action-btn btn-outline">
            <i class="fas fa-external-link-alt"></i> Calendario UTS
                        <a href="dashboard.jsp?sec=calendario&mes=${mesPrevCal}&año=${añoPrevCal}" class="action-btn" style="background:#6C757D; color:white;"><i class="fas fa-chevron-left"></i> Mes anterior</a>
                        <a href="dashboard.jsp?sec=calendario&mes=${mesNextCal}&año=${añoNextCal}" class="action-btn" style="background:#6C757D; color:white;">Mes siguiente <i class="fas fa-chevron-right"></i></a>
                        
                    </div>
                </div>
                
                <!-- Calendario en cuadrícula -->
                <div class="calendario-container">
                    <div class="calendario-header">
                        <div>Dom</div><div>Lun</div><div>Mar</div><div>Mié</div><div>Jue</div><div>Vie</div><div>Sáb</div>
                    </div>
                    <div class="calendario-grid" id="calendarioGrid">
                        <!-- El contenido se genera con JavaScript para evitar scriplets -->
                    </div>
                </div>
                
                <!-- Lista de eventos del mes -->
                <div style="margin-top: 25px;">
                    <h4 style="margin-bottom: 15px;"><i class="fas fa-list"></i> Eventos de ${mesNombreCal}</h4>
                    <c:forEach var="e" items="${eventosMesCal.rows}">
                        <div style="display: flex; align-items: center; justify-content: space-between; background: #F8FAFE; padding: 12px 20px; border-radius: 16px; margin-bottom: 10px;">
                            <div>
                                <strong>📅 ${e.fecha_evento}</strong><br>
                                <span>${e.titulo}</span>
                            </div>
                            <div>
                                <button onclick="editarEvento(${e.id}, '${e.titulo}', '${e.descripcion}', '${e.fecha_evento}', '${e.tipo}')" class="action-btn" style="padding: 5px 12px;"><i class="fas fa-edit"></i> Editar</button>
                                <a href="eliminar_evento.jsp?id=${e.id}&sec=calendario" class="action-btn" style="padding: 5px 12px; background:#DC3545; color:white;" onclick="return confirm('¿Eliminar este evento?')"><i class="fas fa-trash"></i> Eliminar</a>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty eventosMesCal.rows}">
                        <div style="text-align: center; padding: 30px;">
                            <i class="fas fa-calendar-week" style="font-size: 2rem; color: #ADB5BD;"></i>
                            <p>No hay eventos para este mes.</p>
                        </div>
                    </c:if>
                </div>
            </div>
            
            <!-- JavaScript para generar el calendario -->
            <script>
                // Función para generar el calendario con JavaScript
                function generarCalendario(año, mes, eventos) {
                    var primerDia = new Date(año, mes - 1, 1);
                    var ultimoDia = new Date(año, mes, 0);
                    var primerDiaSemana = primerDia.getDay();
                    var diasEnMes = ultimoDia.getDate();
                    
                    var grid = document.getElementById('calendarioGrid');
                    grid.innerHTML = '';
                    
                    // Días vacíos al inicio
                    for (var i = 0; i < primerDiaSemana; i++) {
                        var divVacio = document.createElement('div');
                        divVacio.className = 'calendario-dia otro-mes';
                        grid.appendChild(divVacio);
                    }
                    
                    // Días del mes
                    for (var d = 1; d <= diasEnMes; d++) {
                        var div = document.createElement('div');
                        div.className = 'calendario-dia';
                        
                        // Verificar si tiene evento
                        if (eventos[d]) {
                            div.classList.add('evento');
                        }
                        
                        var numero = document.createElement('div');
                        numero.className = 'dia-numero';
                        numero.innerText = d;
                        div.appendChild(numero);
                        grid.appendChild(div);
                    }
                    
                    // Días vacíos al final
                    var totalCeldas = primerDiaSemana + diasEnMes;
                    var restantes = 42 - totalCeldas;
                    for (var i = 0; i < restantes; i++) {
                        var divVacio = document.createElement('div');
                        divVacio.className = 'calendario-dia otro-mes';
                        grid.appendChild(divVacio);
                    }
                }
                
                // Obtener eventos del mes actual desde JSP
                var eventosMap = {};
                <c:forEach var="e" items="${eventosMesCal.rows}">
                    var fecha = '${e.fecha_evento}';
                    var dia = parseInt(fecha.split('-')[2]);
                    eventosMap[dia] = true;
                </c:forEach>
                
                // Generar el calendario
                generarCalendario(${añoActualCal}, ${mesActualCal}, eventosMap);
            </script>
            
            <!-- Modal para eventos -->
            <div id="modalEvento" class="modal">
                <div class="modal-content">
                    <button class="modal-close" onclick="cerrarModal()">&times;</button>
                    <h3 id="modalTitulo" style="margin-bottom: 20px;">Nuevo Evento</h3>
                    <form action="guardar_evento.jsp" method="post" target="submitFrame" onsubmit="cerrarModal(); setTimeout(function(){location.reload();}, 300);">
                        <input type="hidden" name="id_evento" id="id_evento">
                        <input type="hidden" name="sec" value="calendario">
                        <div style="margin-bottom: 15px;">
                            <label style="display: block; margin-bottom: 5px; font-weight: 600;">Título</label>
                            <input type="text" name="titulo" id="titulo_evento" required style="width:100%; padding: 10px; border-radius: 12px; border: 1px solid #ddd;">
                        </div>
                        <div style="margin-bottom: 15px;">
                            <label style="display: block; margin-bottom: 5px; font-weight: 600;">Descripción</label>
                            <textarea name="descripcion" id="descripcion_evento" rows="3" style="width:100%; padding: 10px; border-radius: 12px; border: 1px solid #ddd;"></textarea>
                        </div>
                        <div style="margin-bottom: 15px;">
                            <label style="display: block; margin-bottom: 5px; font-weight: 600;">Fecha</label>
                            <input type="date" name="fecha" id="fecha_evento" required style="width:100%; padding: 10px; border-radius: 12px; border: 1px solid #ddd;">
                        </div>
                        <div style="margin-bottom: 20px;">
                            <label style="display: block; margin-bottom: 5px; font-weight: 600;">Tipo</label>
                            <select name="tipo" id="tipo_evento" style="width:100%; padding: 10px; border-radius: 12px; border: 1px solid #ddd;">
                                <option value="reunion">Reunión</option>
                                <option value="entrega">Entrega</option>
                                <option value="sustentacion">Sustentación</option>
                                <option value="plazo">Plazo</option>
                                <option value="otro">Otro</option>
                            </select>
                        </div>
                        <button type="submit" class="action-btn" style="background:#A6C21B; color:white; width:100%; padding: 12px;"><i class="fas fa-save"></i> Guardar Evento</button>
                    </form>
                </div>
            </div>
        </c:if>
        
        <!-- ==================== PERFIL ==================== -->
        <c:if test="${seccionActual == 'perfil'}">
            <div class="section-card" style="margin-bottom: 25px; background: linear-gradient(135deg, #A6C21B 0%, #8FAA10 100%); color: white; padding: 20px 25px;">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                    <div>
                        <h2 style="font-size: 1.3rem; margin-bottom: 5px;"><i class="fas fa-user-circle"></i> Mi Perfil</h2>
                        <p style="opacity: 0.85; font-size: 0.85rem;">Consulta y actualiza tu información personal</p>
                    </div>
                    <div>
                        <span style="background: rgba(255,255,255,0.2); padding: 6px 16px; border-radius: 40px; font-size: 0.8rem;">
                            <i class="fas fa-calendar-alt"></i> <fmt:formatDate value="${fechaActual}" pattern="EEEE, d 'de' MMMM 'de' yyyy" />
                        </span>
                    </div>
                </div>
            </div>
            
            <div class="section-card" style="padding: 0; overflow: hidden; margin-bottom: 30px;">
                <div style="background: linear-gradient(135deg, #A6C21B 0%, #8FAA10 100%); padding: 50px 30px; text-align: center; color: white;">
                    <div class="perfil-avatar-grande" style="width: 130px; height: 130px; background: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 25px; box-shadow: 0 15px 35px rgba(0,0,0,0.15);">
                        <i class="fas fa-user" style="font-size: 4rem; color: #A6C21B;"></i>
                    </div>
                    <h2 style="font-size: 2rem; margin-bottom: 10px; letter-spacing: -0.5px;">${adminData.rows[0].nombre} ${adminData.rows[0].apellido}</h2>
                    <p style="opacity: 0.95; font-size: 1.05rem;"><i class="fas fa-badge"></i> Administrador del Sistema</p>
                </div>
                
                <div style="padding: 40px;">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 30px;">
                        <div style="background: #F8FAFE; border-radius: 24px; padding: 30px; box-shadow: 0 2px 8px rgba(0,0,0,0.03);">
                            <h3 style="color: #2C3E50; margin-bottom: 25px; font-size: 1.3rem; border-left: 4px solid #A6C21B; padding-left: 18px;">
                                <i class="fas fa-user-circle" style="color: #A6C21B; margin-right: 10px;"></i> Información Personal
                            </h3>
                            <div style="display: flex; flex-direction: column; gap: 20px;">
                                <div style="display: flex; align-items: center; gap: 18px; padding: 12px 0; border-bottom: 1px solid #E9ECEF;">
                                    <div style="width: 45px; height: 45px; background: #E8F5E9; border-radius: 15px; display: flex; align-items: center; justify-content: center;">
                                        <i class="fas fa-user" style="font-size: 1.3rem; color: #A6C21B;"></i>
                                    </div>
                                    <div>
                                        <p style="font-size: 0.75rem; color: #8BA0AE; margin-bottom: 3px;">Nombre completo</p>
                                        <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">${adminData.rows[0].nombre} ${adminData.rows[0].apellido}</p>
                                    </div>
                                </div>
                                <div style="display: flex; align-items: center; gap: 18px; padding: 12px 0; border-bottom: 1px solid #E9ECEF;">
                                    <div style="width: 45px; height: 45px; background: #E8F5E9; border-radius: 15px; display: flex; align-items: center; justify-content: center;">
                                        <i class="fas fa-envelope" style="font-size: 1.3rem; color: #A6C21B;"></i>
                                    </div>
                                    <div>
                                        <p style="font-size: 0.75rem; color: #8BA0AE; margin-bottom: 3px;">Correo electrónico</p>
                                        <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">${adminData.rows[0].email}</p>
                                    </div>
                                </div>
                                <div style="display: flex; align-items: center; gap: 18px; padding: 12px 0;">
                                    <div style="width: 45px; height: 45px; background: #E8F5E9; border-radius: 15px; display: flex; align-items: center; justify-content: center;">
                                        <i class="fas fa-user-tag" style="font-size: 1.3rem; color: #A6C21B;"></i>
                                    </div>
                                    <div>
                                        <p style="font-size: 0.75rem; color: #8BA0AE; margin-bottom: 3px;">Rol en el sistema</p>
                                        <p><span style="background:#A6C21B; color:white; padding: 5px 16px; border-radius: 30px; font-size: 0.8rem; font-weight: 600;">Administrador</span></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div style="background: #F8FAFE; border-radius: 24px; padding: 30px; box-shadow: 0 2px 8px rgba(0,0,0,0.03);">
                            <h3 style="color: #2C3E50; margin-bottom: 25px; font-size: 1.3rem; border-left: 4px solid #A6C21B; padding-left: 18px;">
                                <i class="fas fa-chart-line" style="color: #A6C21B; margin-right: 10px;"></i> Estadísticas de la Cuenta
                            </h3>
                            <div style="display: flex; flex-direction: column; gap: 20px;">
                                <div style="display: flex; align-items: center; gap: 18px; padding: 12px 0; border-bottom: 1px solid #E9ECEF;">
                                    <div style="width: 45px; height: 45px; background: #E8F5E9; border-radius: 15px; display: flex; align-items: center; justify-content: center;">
                                        <i class="fas fa-calendar-alt" style="font-size: 1.3rem; color: #A6C21B;"></i>
                                    </div>
                                    <div>
                                        <p style="font-size: 0.75rem; color: #8BA0AE; margin-bottom: 3px;">Fecha de registro</p>
                                        <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">${fn:substring(adminData.rows[0].fecha_registro,8,10)}/${fn:substring(adminData.rows[0].fecha_registro,5,7)}/${fn:substring(adminData.rows[0].fecha_registro,0,4)} ${fn:substring(adminData.rows[0].fecha_registro,11,16)}</p>
                                    </div>
                                </div>
                                <div style="display: flex; align-items: center; gap: 18px; padding: 12px 0; border-bottom: 1px solid #E9ECEF;">
                                    <div style="width: 45px; height: 45px; background: #E8F5E9; border-radius: 15px; display: flex; align-items: center; justify-content: center;">
                                        <i class="fas fa-clock" style="font-size: 1.3rem; color: #A6C21B;"></i>
                                    </div>
                                    <div>
                                        <p style="font-size: 0.75rem; color: #8BA0AE; margin-bottom: 3px;">Estado de la cuenta</p>
                                        <p style="font-weight: 600; color: #A6C21B; font-size: 1rem;"><i class="fas fa-check-circle"></i> Activa</p>
                                    </div>
                                </div>
                                <div style="display: flex; align-items: center; gap: 18px; padding: 12px 0;">
                                    <div style="width: 45px; height: 45px; background: #E8F5E9; border-radius: 15px; display: flex; align-items: center; justify-content: center;">
                                        <i class="fas fa-shield-alt" style="font-size: 1.3rem; color: #A6C21B;"></i>
                                    </div>
                                    <div>
                                        <p style="font-size: 0.75rem; color: #8BA0AE; margin-bottom: 3px;">Nivel de permisos</p>
                                        <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">Acceso total al sistema</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div style="margin-top: 40px; display: flex; gap: 20px; justify-content: center; flex-wrap: wrap;">
                        <button onclick="abrirModalEditarPerfil()" class="action-btn" style="background:#A6C21B; color:white; padding: 14px 32px; font-size: 0.9rem; border-radius: 50px;">
                            <i class="fas fa-edit"></i> Editar mi perfil
                        </button>
                        <button onclick="abrirModalCambiarPassword()" class="action-btn" style="background:#6C757D; color:white; padding: 14px 32px; font-size: 0.9rem; border-radius: 50px;">
                            <i class="fas fa-key"></i> Cambiar contraseña
                        </button>
                        <a href="dashboard.jsp?sec=dashboard" class="action-btn" style="background:#17A2B8; color:white; padding: 14px 32px; font-size: 0.9rem; border-radius: 50px;">
                            <i class="fas fa-arrow-left"></i> Volver al Dashboard
                        </a>
                    </div>
                </div>
            </div>
            
            <!-- Modal para editar perfil -->
            <div id="modalEditarPerfil" class="modal">
                <div class="modal-content" style="max-width: 550px;">
                    <button class="modal-close" onclick="cerrarModalPerfil()">&times;</button>
                    <h3 style="margin-bottom: 25px; color: #2C3E50; font-size: 1.5rem;">
                        <i class="fas fa-user-edit" style="color: #A6C21B;"></i> Editar Perfil
                    </h3>
                    <form action="guardar_perfil.jsp" method="post">
                        <input type="hidden" name="id" value="${idAdmin}">
                        <input type="hidden" name="sec" value="perfil">
                        
                        <div style="margin-bottom: 22px;">
                            <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Nombre</label>
                            <input type="text" name="nombre" value="${adminData.rows[0].nombre}" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                        </div>
                        <div style="margin-bottom: 22px;">
                            <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Apellido</label>
                            <input type="text" name="apellido" value="${adminData.rows[0].apellido}" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                        </div>
                        <div style="margin-bottom: 22px;">
                            <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Correo Electrónico</label>
                            <input type="email" name="email" value="${adminData.rows[0].email}" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                        </div>
                        <div style="margin-bottom: 28px;">
                            <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Nueva Contraseña (opcional)</label>
                            <input type="password" name="password" placeholder="Dejar en blanco para no cambiar" style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                        </div>
                        <div style="display: flex; gap: 15px; justify-content: flex-end;">
                            <button type="button" onclick="cerrarModalPerfil()" class="action-btn" style="background:#6C757D; color:white; padding: 12px 24px;">Cancelar</button>
                            <button type="submit" class="action-btn" style="background:#A6C21B; color:white; padding: 12px 24px;"><i class="fas fa-save"></i> Guardar Cambios</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Modal para cambiar contraseña -->
            <div id="modalCambiarPassword" class="modal">
                <div class="modal-content" style="max-width: 450px;">
                    <button class="modal-close" onclick="cerrarModalPassword()">&times;</button>
                    <h3 style="margin-bottom: 25px; color: #2C3E50; font-size: 1.5rem;">
                        <i class="fas fa-key" style="color: #A6C21B;"></i> Cambiar Contraseña
                    </h3>
                    <form action="cambiar_password.jsp" method="post">
                        <input type="hidden" name="id" value="${idAdmin}">
                        <input type="hidden" name="sec" value="perfil">
                        
                        <div style="margin-bottom: 22px;">
                            <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Contraseña actual</label>
                            <input type="password" name="password_actual" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                        </div>
                        <div style="margin-bottom: 22px;">
                            <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Nueva contraseña</label>
                            <input type="password" name="password_nueva" id="password_nueva" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                        </div>
                        <div style="margin-bottom: 28px;">
                            <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Confirmar nueva contraseña</label>
                            <input type="password" name="password_confirm" id="password_confirm" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                            <span id="password_error" style="color: #DC3545; font-size: 0.75rem; display: none;">Las contraseñas no coinciden</span>
                        </div>
                        <div style="display: flex; gap: 15px; justify-content: flex-end;">
                            <button type="button" onclick="cerrarModalPassword()" class="action-btn" style="background:#6C757D; color:white; padding: 12px 24px;">Cancelar</button>
                            <button type="submit" class="action-btn" style="background:#A6C21B; color:white; padding: 12px 24px;"><i class="fas fa-save"></i> Cambiar Contraseña</button>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>
        
        <!-- ==================== MENSAJES ==================== -->
<c:if test="${seccionActual == 'mensajes'}">
    <div class="section-card" style="margin-bottom: 25px; background: linear-gradient(135deg, #A6C21B 0%, #8FAA10 100%); color: white; padding: 20px 25px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <h2 style="font-size: 1.3rem; margin-bottom: 5px;"><i class="fas fa-envelope"></i> Mensajería Interna</h2>
                <p style="opacity: 0.85; font-size: 0.85rem;">Gestiona tus mensajes con coordinadores, docentes y estudiantes</p>
            </div>
            <div>
                <span style="background: rgba(255,255,255,0.2); padding: 6px 16px; border-radius: 40px; font-size: 0.8rem;">
                    <i class="fas fa-calendar-alt"></i> <fmt:formatDate value="${fechaActual}" pattern="EEEE, d 'de' MMMM 'de' yyyy" />
                </span>
            </div>
        </div>
    </div>

    <!-- Tabs de mensajes -->
    <div style="display: flex; gap: 10px; margin-bottom: 25px; border-bottom: 2px solid #E9ECEF;">
        <a href="javascript:void(0)" onclick="mostrarTabMensajes('recibidos')" id="tab_recibidos_link" style="padding: 12px 25px; text-decoration: none; font-weight: 600; color: #A6C21B; border-bottom: 3px solid #A6C21B;">
            <i class="fas fa-inbox"></i> Recibidos 
            <sql:query dataSource="${dataSource}" var="contNoLeidos">
                SELECT COUNT(*) as total FROM mensajes WHERE destinatario_id = ? AND leido = 0
                <sql:param value="${sessionScope.idUsuario}" />
            </sql:query>
            <c:if test="${contNoLeidos.rows[0].total > 0}">
                <span style="background:#DC3545; color:white; padding:2px 8px; border-radius:20px; font-size:0.7rem;">${contNoLeidos.rows[0].total}</span>
            </c:if>
        </a>
        <a href="javascript:void(0)" onclick="mostrarTabMensajes('enviados')" id="tab_enviados_link" style="padding: 12px 25px; text-decoration: none; font-weight: 600; color: #6C757D; border-bottom: 3px solid transparent;">
            <i class="fas fa-paper-plane"></i> Enviados
        </a>
        <a href="javascript:void(0)" onclick="mostrarTabMensajes('nuevo')" id="tab_nuevo_link" style="padding: 12px 25px; text-decoration: none; font-weight: 600; color: #6C757D; border-bottom: 3px solid transparent;">
            <i class="fas fa-plus-circle"></i> Nuevo Mensaje
        </a>
    </div>
    
    <!-- TAB 1: Mensajes Recibidos -->
    <div id="tab_mensajes_recibidos" style="display: block;">
        <div class="section-card">
            <div class="section-header">
                <h3><i class="fas fa-inbox"></i> Bandeja de Entrada</h3>
                <button onclick="marcarTodosLeidos()" class="action-btn" style="background:#17A2B8; color:white;">
                    <i class="fas fa-check-double"></i> Marcar todos como leídos
                </button>
            </div>
            
            <sql:query dataSource="${dataSource}" var="mensajesRecibidos">
                SELECT m.*, u.nombre, u.apellido, u.rol 
                FROM mensajes m
                JOIN usuarios u ON m.remitente_id = u.id
                WHERE m.destinatario_id = ? AND m.eliminado_destinatario = 0
                ORDER BY m.fecha_envio DESC
                <sql:param value="${sessionScope.idUsuario}" />
            </sql:query>
            
            <c:forEach var="msg" items="${mensajesRecibidos.rows}">
                <div class="mensaje-card" style="background: ${msg.leido == 0 ? '#F0F7FF' : '#F8FAFE'}; border-radius: 16px; padding: 18px; margin-bottom: 12px; border-left: 4px solid ${msg.leido == 0 ? '#A6C21B' : '#E9ECEF'}; cursor: pointer;" onclick="verMensaje(${msg.id}, 'recibido')">
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap;">
                        <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                            <c:if test="${msg.leido == 0}">
                                <span style="background:#A6C21B; color:white; padding:2px 8px; border-radius:20px; font-size:0.7rem;">Nuevo</span>
                            </c:if>
                            <strong style="color:#2C3E50;">
                                <i class="fas fa-user"></i> ${msg.nombre} ${msg.apellido}
                                <span class="badge badge-${msg.rol}" style="margin-left: 8px;">${msg.rol}</span>
                            </strong>
                        </div>
                        <small style="color:#8BA0AE;"><i class="fas fa-calendar"></i> ${fn:substring(msg.fecha_envio,8,10)}/${fn:substring(msg.fecha_envio,5,7)}/${fn:substring(msg.fecha_envio,0,4)} ${fn:substring(msg.fecha_envio,11,16)}</small>
                    </div>
                    <div style="margin-top: 10px;">
                        <strong>${msg.asunto}</strong>
                        <p style="color:#6C757D; margin-top: 5px; font-size:0.85rem;">${fn:substring(msg.mensaje, 0, 100)}${fn:length(msg.mensaje) > 100 ? '...' : ''}</p>
                    </div>
                </div>
            </c:forEach>
            
            <c:if test="${empty mensajesRecibidos.rows}">
                <div style="text-align: center; padding: 50px;">
                    <i class="fas fa-inbox" style="font-size: 3rem; color: #ADB5BD;"></i>
                    <p style="margin-top: 15px;">No hay mensajes en tu bandeja de entrada</p>
                </div>
            </c:if>
        </div>
    </div>
    
    <!-- TAB 2: Mensajes Enviados -->
    <div id="tab_mensajes_enviados" style="display: none;">
        <div class="section-card">
            <div class="section-header">
                <h3><i class="fas fa-paper-plane"></i> Mensajes Enviados</h3>
            </div>
            
            <sql:query dataSource="${dataSource}" var="mensajesEnviados">
                SELECT m.*, u.nombre, u.apellido, u.rol 
                FROM mensajes m
                JOIN usuarios u ON m.destinatario_id = u.id
                WHERE m.remitente_id = ? AND m.eliminado_remitente = 0
                ORDER BY m.fecha_envio DESC
                <sql:param value="${sessionScope.idUsuario}" />
            </sql:query>
            
            <c:forEach var="msg" items="${mensajesEnviados.rows}">
                <div class="mensaje-card" style="background: #F8FAFE; border-radius: 16px; padding: 18px; margin-bottom: 12px; border-left: 4px solid #17A2B8; cursor: pointer;" onclick="verMensaje(${msg.id}, 'enviado')">
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap;">
                        <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                            <strong style="color:#2C3E50;">
                                <i class="fas fa-user"></i> Para: ${msg.nombre} ${msg.apellido}
                                <span class="badge badge-${msg.rol}" style="margin-left: 8px;">${msg.rol}</span>
                            </strong>
                        </div>
                        <small style="color:#8BA0AE;"><i class="fas fa-calendar"></i> ${fn:substring(msg.fecha_envio,8,10)}/${fn:substring(msg.fecha_envio,5,7)}/${fn:substring(msg.fecha_envio,0,4)} ${fn:substring(msg.fecha_envio,11,16)}</small>
                    </div>
                    <div style="margin-top: 10px;">
                        <strong>${msg.asunto}</strong>
                        <p style="color:#6C757D; margin-top: 5px; font-size:0.85rem;">${fn:substring(msg.mensaje, 0, 100)}${fn:length(msg.mensaje) > 100 ? '...' : ''}</p>
                    </div>
                    <div style="margin-top: 10px; text-align: right;">
                        <c:if test="${msg.leido == 1}">
                            <small style="color:#A6C21B;"><i class="fas fa-check-circle"></i> Leído</small>
                        </c:if>
                        <c:if test="${msg.leido == 0}">
                            <small style="color:#FFC107;"><i class="fas fa-clock"></i> No leído</small>
                        </c:if>
                    </div>
                </div>
            </c:forEach>
            
            <c:if test="${empty mensajesEnviados.rows}">
                <div style="text-align: center; padding: 50px;">
                    <i class="fas fa-paper-plane" style="font-size: 3rem; color: #ADB5BD;"></i>
                    <p style="margin-top: 15px;">No has enviado ningún mensaje</p>
                </div>
            </c:if>
        </div>
    </div>
    
  <!-- TAB 3: Nuevo Mensaje -->
<div id="tab_mensajes_nuevo" style="display: none;">
    <div class="section-card">
        <div class="section-header">
            <h3><i class="fas fa-edit"></i> Redactar Nuevo Mensaje</h3>
        </div>
        
        <form id="formEnviarMensaje" action="${pageContext.request.contextPath}/enviar_mensaje_procesar.jsp" method="post" onsubmit="return validarFormMensaje()">
            <input type="hidden" name="sec" value="mensajes">
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px;">Para (correo electrónico):</label>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <input type="email" name="destinatario_email" id="destinatario_email" 
                           list="listaCorreos"
                           placeholder="ejemplo@uts.edu.co" 
                           style="flex: 1; padding: 12px; border-radius: 12px; border: 1px solid #ddd;">
                    
                    <datalist id="listaCorreos">
                        <sql:query dataSource="${dataSource}" var="todosCorreos">
                            SELECT email FROM usuarios WHERE id != ? AND estado = 1
                            <sql:param value="${sessionScope.idUsuario}" />
                        </sql:query>
                        <c:forEach var="c" items="${todosCorreos.rows}">
                            <option value="${c.email}">
                        </c:forEach>
                    </datalist>
                    
                    <button type="button" onclick="buscarPorEmail()" class="action-btn" style="background:#17A2B8; color:white; padding: 12px 20px;">
                        <i class="fas fa-search"></i> Buscar
                    </button>
                </div>
                <div id="infoDestinatario" style="margin-top: 8px; font-size: 0.8rem;"></div>
                <input type="hidden" name="destinatario_id" id="destinatario_id">
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px;">Asunto:</label>
                <input type="text" name="asunto" id="asunto" required style="width:100%; padding: 12px; border-radius: 12px; border: 1px solid #ddd;">
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px;">Mensaje:</label>
                <textarea name="mensaje" id="mensaje" rows="6" required style="width:100%; padding: 12px; border-radius: 12px; border: 1px solid #ddd;"></textarea>
            </div>
            
            <div style="display: flex; gap: 15px; justify-content: flex-end;">
                <button type="button" onclick="mostrarTabMensajes('recibidos')" class="action-btn" style="background:#6C757D; color:white;">Cancelar</button>
                <button type="submit" class="action-btn" style="background:#A6C21B; color:white;" id="btnEnviar" disabled>
    <i class="fas fa-send"></i> Enviar Mensaje
</button>
            </div>
        </form>
    </div>
</div>
</c:if>
        
        <!-- ==================== FORMATOS ==================== -->
<c:if test="${seccionActual == 'formatos'}">
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><c:out value="${param.err}" /></div></c:if>
            <form method="post" action="guardar_formato.jsp" class="section-card" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:12px;align-items:end;">
                <input type="hidden" name="sec" value="formatos">
                <label>Nombre<input type="text" name="nombre" required style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                <label>Descripción<input type="text" name="descripcion" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                <label>Enlace (http:// o https://)<input type="url" name="ruta_archivo" required placeholder="https://..." style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                <label>Tipo<select name="tipo" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"><option>formato</option><option>guia</option><option>reglamento</option><option>acta</option><option>otro</option></select></label>
                <div><button type="submit" class="action-btn">Agregar enlace</button></div>
            </form>
    <div class="section-card" style="margin-bottom: 25px; background: linear-gradient(135deg, #A6C21B 0%, #8FAA10 100%); color: white; padding: 20px 25px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <h2 style="font-size: 1.3rem; margin-bottom: 5px;"><i class="fas fa-file-alt"></i> Formatos de Grado</h2>
                <p style="opacity: 0.85; font-size: 0.85rem;">Documentos y formatos institucionales para proyectos de grado</p>
            </div>
            <div>
                <span style="background: rgba(255,255,255,0.2); padding: 6px 16px; border-radius: 40px; font-size: 0.8rem;">
                    <i class="fas fa-calendar-alt"></i> <fmt:formatDate value="${fechaActual}" pattern="dd/MM/yyyy" />
                </span>
            </div>
        </div>
    </div>
    
    <div class="section-card">
        <div class="section-header">
            <h3><i class="fas fa-file-alt"></i> Documentos Disponibles</h3>
        </div>
        
        <sql:query dataSource="${dataSource}" var="formatosLista">
            SELECT id, nombre, descripcion, ruta_archivo, tipo, fecha_subida FROM formatos_grado WHERE activo = 1 ORDER BY id DESC
        </sql:query>
        
        <!-- Separador por tipo de documento -->
        <div style="margin-bottom: 25px;">
            <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 20px;">
                <button onclick="filtrarFormatos('todos')" id="filtroTodos" class="action-btn" style="background:#A6C21B; color:white;">📋 Todos</button>
                <button onclick="filtrarFormatos('formato')" id="filtroFormato" class="action-btn btn-outline">📄 Formatos</button>
                <button onclick="filtrarFormatos('guia')" id="filtroGuia" class="action-btn btn-outline">📚 Guías</button>
                <button onclick="filtrarFormatos('reglamento')" id="filtroReglamento" class="action-btn btn-outline">⚖️ Reglamentos</button>
                <button onclick="filtrarFormatos('acta')" id="filtroActa" class="action-btn btn-outline">📝 Actas</button>
                <button onclick="filtrarFormatos('otro')" id="filtroOtro" class="action-btn btn-outline">📎 Otros</button>
            </div>
        </div>
        
        <div id="contenedorFormatos">
            <c:forEach var="f" items="${formatosLista.rows}">
                <div class="formato-card" data-tipo="${f.tipo}" style="background: #F8FAFE; border-radius: 20px; padding: 20px; margin-bottom: 20px; border-left: 4px solid #A6C21B; transition: all 0.3s;">
                    <div style="display: flex; align-items: flex-start; gap: 18px; flex-wrap: wrap;">
                        <div style="width: 70px; height: 70px; background: #E8F5E9; border-radius: 18px; display: flex; align-items: center; justify-content: center;">
                            <c:choose>
                                <c:when test="${f.tipo == 'formato'}"><i class="fas fa-file-alt" style="font-size: 2rem; color: #A6C21B;"></i></c:when>
                                <c:when test="${f.tipo == 'guia'}"><i class="fas fa-book" style="font-size: 2rem; color: #17A2B8;"></i></c:when>
                                <c:when test="${f.tipo == 'reglamento'}"><i class="fas fa-gavel" style="font-size: 2rem; color: #FD7E14;"></i></c:when>
                                <c:when test="${f.tipo == 'acta'}"><i class="fas fa-file-signature" style="font-size: 2rem; color: #6F42C1;"></i></c:when>
                                <c:otherwise><i class="fas fa-file-pdf" style="font-size: 2rem; color: #DC3545;"></i></c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div style="flex: 1;">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 10px;">
                                <div>
                                    <h4 style="color: #2C3E50; margin-bottom: 5px; font-size: 1.1rem;">${f.nombre}</h4>
                                    <p style="font-size: 0.85rem; color: #6C757D; margin-bottom: 8px;">${f.descripcion}</p>
                                    <div style="display: flex; gap: 15px; flex-wrap: wrap;">
                                        <span style="background: #E8F5E9; padding: 4px 12px; border-radius: 20px; font-size: 0.7rem;">
                                            <i class="fas fa-tag"></i> ${f.tipo}
                                        </span>
                                        <span style="color: #8BA0AE; font-size: 0.7rem;">
                                            <i class="fas fa-calendar-alt"></i> Subido: ${fn:substring(f.fecha_subida,8,10)}/${fn:substring(f.fecha_subida,5,7)}/${fn:substring(f.fecha_subida,0,4)} ${fn:substring(f.fecha_subida,11,16)}
                                        </span>
                                    </div>
                                </div>
                            </div>
                            
                            <div style="display: flex; gap: 12px; margin-top: 18px; flex-wrap: wrap;">
                                <c:set var="esLink" value="${fn:startsWith(f.ruta_archivo, 'http')}" /><c:url var="urlF" value="/${f.ruta_archivo}" /><a href="${esLink ? f.ruta_archivo : urlF}" target="_blank" class="action-btn" style="background:#17A2B8; color:white; padding: 8px 20px; text-decoration:none; border-radius: 12px; display: inline-flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-eye"></i> Ver documento
                                </a>
                                <c:if test="${not esLink}"><a href="${urlF}" download class="action-btn" style="background:#A6C21B; color:white; padding: 8px 20px; text-decoration:none; border-radius: 12px; display: inline-flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-download"></i> Descargar
                                </a></c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
        
        <c:if test="${empty formatosLista.rows}">
            <div style="text-align: center; padding: 60px; background: #F8FAFE; border-radius: 20px;">
                <i class="fas fa-folder-open" style="font-size: 4rem; color: #ADB5BD;"></i>
                <p style="margin-top: 15px;">No hay formatos disponibles.</p>
            </div>
        </c:if>
    </div>
</c:if>
        
        <!-- ==================== REPORTES ==================== -->
        <c:if test="${seccionActual == 'reportes'}">
            <div class="section-card" style="margin-bottom: 25px; background: linear-gradient(135deg, #A6C21B 0%, #8FAA10 100%); color: white; padding: 20px 25px;">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                    <div>
                        <h2 style="font-size: 1.3rem; margin-bottom: 5px;"><i class="fas fa-chart-line"></i> Panel de Estadísticas</h2>
                        <p style="opacity: 0.85; font-size: 0.85rem;">Visualiza el resumen completo del sistema de proyectos de grado</p>
                    </div>
                    <div>
                        <span style="background: rgba(255,255,255,0.2); padding: 6px 16px; border-radius: 40px; font-size: 0.8rem;">
                            <i class="fas fa-calendar-alt"></i> <fmt:formatDate value="${fechaActual}" pattern="EEEE, d 'de' MMMM 'de' yyyy" />
                        </span>
                    </div>
                </div>
            </div>
            
            <sql:query dataSource="${db}" var="reporteAdmins">SELECT COUNT(*) as total FROM usuarios WHERE rol = 'admin'</sql:query>
            <sql:query dataSource="${db}" var="reporteCoords">SELECT COUNT(*) as total FROM usuarios WHERE rol = 'coordinador'</sql:query>
            <sql:query dataSource="${db}" var="reporteDocentes">SELECT COUNT(*) as total FROM usuarios WHERE rol IN ('docente','evaluador')</sql:query>
            <sql:query dataSource="${db}" var="reporteEstudiantes">SELECT COUNT(*) as total FROM usuarios WHERE rol = 'estudiante'</sql:query>
            <sql:query dataSource="${db}" var="reporteProyectos">SELECT COUNT(*) as total FROM proyectos</sql:query>
            <sql:query dataSource="${db}" var="reporteIdeas">SELECT COUNT(*) as total FROM ideas_proyecto</sql:query>
            <sql:query dataSource="${db}" var="reporteEventos">SELECT COUNT(*) as total FROM calendario_academico WHERE fecha_evento >= CURDATE()</sql:query>
            <sql:query dataSource="${db}" var="reporteFormatos">SELECT COUNT(*) as total FROM formatos_grado</sql:query>
            
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px;">
                <div class="stat-card"><div class="stat-left"><h3>${reporteAdmins.rows[0].total}</h3><p>Administradores</p></div><div class="stat-right"><i class="fas fa-user-shield"></i></div></div>
                <div class="stat-card"><div class="stat-left"><h3>${reporteCoords.rows[0].total}</h3><p>Coordinadores</p></div><div class="stat-right"><i class="fas fa-chalkboard-user"></i></div></div>
                <div class="stat-card"><div class="stat-left"><h3>${reporteEstudiantes.rows[0].total}</h3><p>Estudiantes</p></div><div class="stat-right"><i class="fas fa-user-graduate"></i></div></div>
                <div class="stat-card"><div class="stat-left"><h3>${reporteDocentes.rows[0].total}</h3><p>Docentes</p></div><div class="stat-right"><i class="fas fa-chalkboard-user"></i></div></div>
                <div class="stat-card"><div class="stat-left"><h3>${reporteProyectos.rows[0].total}</h3><p>Proyectos</p></div><div class="stat-right"><i class="fas fa-project-diagram"></i></div></div>
                <div class="stat-card"><div class="stat-left"><h3>${reporteIdeas.rows[0].total}</h3><p>Ideas</p></div><div class="stat-right"><i class="fas fa-lightbulb"></i></div></div>
                <div class="stat-card"><div class="stat-left"><h3>${reporteEventos.rows[0].total}</h3><p>Eventos</p></div><div class="stat-right"><i class="fas fa-calendar-check"></i></div></div>
                <div class="stat-card"><div class="stat-left"><h3>${reporteFormatos.rows[0].total}</h3><p>Formatos</p></div><div class="stat-right"><i class="fas fa-file-alt"></i></div></div>
            </div>
            
            <div class="section-card">
                <h3 style="margin-bottom: 25px; color: #2C3E50;"><i class="fas fa-chart-bar"></i> Distribución de Usuarios por Rol</h3>
                <div style="display: flex; flex-direction: column; gap: 20px;">
                    <div><div style="display: flex; justify-content: space-between;"><span>Administradores</span><span>${reporteAdmins.rows[0].total}</span></div><div style="background:#E9ECEF; border-radius:10px; overflow:hidden;"><div style="width: ${reporteAdmins.rows[0].total * 10}%; height:12px; background:#A6C21B;"></div></div></div>
                    <div><div style="display: flex; justify-content: space-between;"><span>Coordinadores</span><span>${reporteCoords.rows[0].total}</span></div><div style="background:#E9ECEF; border-radius:10px; overflow:hidden;"><div style="width: ${reporteCoords.rows[0].total * 10}%; height:12px; background:#A6C21B;"></div></div></div>
                    <div><div style="display: flex; justify-content: space-between;"><span>Directores</span><span>${reporteDirectores.rows[0].total}</span></div><div style="background:#E9ECEF; border-radius:10px; overflow:hidden;"><div style="width: ${reporteDirectores.rows[0].total * 10}%; height:12px; background:#A6C21B;"></div></div></div>
                    <div><div style="display: flex; justify-content: space-between;"><span>Evaluadores</span><span>${reporteEvaluadores.rows[0].total}</span></div><div style="background:#E9ECEF; border-radius:10px; overflow:hidden;"><div style="width: ${reporteEvaluadores.rows[0].total * 10}%; height:12px; background:#A6C21B;"></div></div></div>
                    <div><div style="display: flex; justify-content: space-between;"><span>Estudiantes</span><span>${reporteEstudiantes.rows[0].total}</span></div><div style="background:#E9ECEF; border-radius:10px; overflow:hidden;"><div style="width: ${reporteEstudiantes.rows[0].total * 2}%; height:12px; background:#A6C21B;"></div></div></div>
                </div>
            </div>
            
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 25px;">
                <div class="section-card" style="text-align:center;"><i class="fas fa-project-diagram" style="font-size:2rem; color:#A6C21B;"></i><h3>Proyectos e Ideas</h3><div style="font-size:2rem; font-weight:700; color:#A6C21B;">${reporteProyectos.rows[0].total + reporteIdeas.rows[0].total}</div></div>
                <div class="section-card" style="text-align:center;"><i class="fas fa-calendar-alt" style="font-size:2rem; color:#A6C21B;"></i><h3>Calendario y Formatos</h3><div style="font-size:2rem; font-weight:700; color:#A6C21B;">${reporteEventos.rows[0].total + reporteFormatos.rows[0].total}</div></div>
                <div class="section-card" style="text-align:center;"><i class="fas fa-users" style="font-size:2rem; color:#A6C21B;"></i><h3>Usuarios</h3><div style="font-size:2rem; font-weight:700; color:#A6C21B;">${reporteAdmins.rows[0].total + reporteCoords.rows[0].total + reporteDirectores.rows[0].total + reporteEstudiantes.rows[0].total + reporteEvaluadores.rows[0].total}</div></div>
            </div>
        </c:if>
    </main>
</div>

<script>
    // Botón hamburguesa
    var menuToggle = document.getElementById('menuToggle');
    var sidebar = document.getElementById('sidebar');
    
    if (menuToggle) {
        menuToggle.onclick = function() {
            sidebar.classList.toggle('open');
        };
    }
    
    // Cerrar sidebar al hacer clic en un enlace (en móvil)
    var sidebarLinks = document.querySelectorAll('.sidebar-menu a');
    for (var i = 0; i < sidebarLinks.length; i++) {
        sidebarLinks[i].addEventListener('click', function() {
            if (window.innerWidth <= 992) {
                sidebar.classList.remove('open');
            }
        });
    }
    
    // Eventos del calendario
    function mostrarFormularioEvento() {
        document.getElementById('modalTitulo').innerText = 'Nuevo Evento';
        document.getElementById('id_evento').value = '';
        document.getElementById('titulo_evento').value = '';
        document.getElementById('descripcion_evento').value = '';
        document.getElementById('fecha_evento').value = '';
        document.getElementById('tipo_evento').value = 'otro';
        document.getElementById('modalEvento').style.display = 'flex';
    }
    
    function editarEvento(id, titulo, descripcion, fecha, tipo) {
        document.getElementById('modalTitulo').innerText = 'Editar Evento';
        document.getElementById('id_evento').value = id;
        document.getElementById('titulo_evento').value = titulo;
        document.getElementById('descripcion_evento').value = descripcion;
        document.getElementById('fecha_evento').value = fecha;
        document.getElementById('tipo_evento').value = tipo;
        document.getElementById('modalEvento').style.display = 'flex';
    }
    
    function cerrarModal() {
        document.getElementById('modalEvento').style.display = 'none';
    }
    
    window.onclick = function(event) {
        var modal = document.getElementById('modalEvento');
        if (event.target == modal) modal.style.display = 'none';
    }
    
    // Funciones para editar perfil
    function abrirModalEditarUsuario(id) {
    console.log("1. Abriendo modal para ID:", id);
    
    document.getElementById('modalEditarUsuario').style.display = 'flex';
    document.getElementById('edit_id').value = id;
    
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'obtener_usuario.jsp?id=' + id, true);
    xhr.onload = function() {
        console.log("2. Estado HTTP:", xhr.status);
        console.log("3. Respuesta completa:", xhr.responseText);
        
        if (xhr.status === 200) {
            var texto = xhr.responseText;
            
            // Método manual para extraer nombre
            var inicioNombre = texto.indexOf("nombre=");
            var finNombre = texto.indexOf("&", inicioNombre);
            if (finNombre === -1) finNombre = texto.length;
            var nombreValor = texto.substring(inicioNombre + 7, finNombre);
            
            var inicioApellido = texto.indexOf("apellido=");
            var finApellido = texto.indexOf("&", inicioApellido);
            if (finApellido === -1) finApellido = texto.length;
            var apellidoValor = texto.substring(inicioApellido + 9, finApellido);
            
            var inicioEmail = texto.indexOf("email=");
            var finEmail = texto.indexOf("&", inicioEmail);
            if (finEmail === -1) finEmail = texto.length;
            var emailValor = texto.substring(inicioEmail + 6, finEmail);
            
            var inicioRol = texto.indexOf("rol=");
            var finRol = texto.indexOf("&", inicioRol);
            if (finRol === -1) finRol = texto.length;
            var rolValor = texto.substring(inicioRol + 4, finRol);
            
            var inicioEstado = texto.indexOf("estado=");
            var finEstado = texto.indexOf("&", inicioEstado);
            if (finEstado === -1) finEstado = texto.length;
            var estadoValor = texto.substring(inicioEstado + 7, finEstado);
            
            console.log("Nombre extraído:", nombreValor);
            console.log("Apellido extraído:", apellidoValor);
            console.log("Email extraído:", emailValor);
            
            document.getElementById('edit_nombre').value = nombreValor;
            document.getElementById('edit_apellido').value = apellidoValor;
            document.getElementById('edit_email').value = emailValor;
            document.getElementById('edit_rol').value = rolValor;
            document.getElementById('edit_estado').value = estadoValor;
            document.getElementById('edit_password').value = '';
        } else {
            alert("Error HTTP: " + xhr.status);
        }
    };
    xhr.onerror = function() {
        alert("Error de red al cargar los datos");
    };
    xhr.send();
}
    
    function cerrarModalEditarUsuario() {
    document.getElementById('modalEditarUsuario').style.display = 'none';
    // Limpiar los campos al cerrar
    document.getElementById('edit_nombre').value = '';
    document.getElementById('edit_apellido').value = '';
    document.getElementById('edit_email').value = '';
    document.getElementById('edit_rol').value = '';
    document.getElementById('edit_estado').value = '1';
    document.getElementById('edit_password').value = '';
}
    
    function guardarPerfil(event) {
        event.preventDefault();
        
        var id = document.querySelector('input[name="id"]').value;
        var nombre = document.querySelector('input[name="nombre"]').value;
        var apellido = document.querySelector('input[name="apellido"]').value;
        var email = document.querySelector('input[name="email"]').value;
        var password = document.querySelector('input[name="password"]').value;
        var sec = document.querySelector('input[name="sec"]').value;
        
        var url = 'guardar_perfil.jsp?id=' + encodeURIComponent(id) + 
                  '&nombre=' + encodeURIComponent(nombre) + 
                  '&apellido=' + encodeURIComponent(apellido) + 
                  '&email=' + encodeURIComponent(email) + 
                  '&password=' + encodeURIComponent(password) + 
                  '&sec=' + encodeURIComponent(sec);
        
        fetch(url, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        }).then(function(response) {
            if (response.ok) {
                cerrarModalPerfil();
                location.reload();
            } else {
                alert('Error al guardar los cambios');
            }
        }).catch(function(error) {
            console.error('Error:', error);
            alert('Error al guardar los cambios');
        });
        
        return false;
    }
    
    // Funciones para cambiar contraseña
    function abrirModalCambiarPassword() {
        document.getElementById('modalCambiarPassword').style.display = 'flex';
        document.getElementById('password_error').style.display = 'none';
        document.getElementById('password_nueva').value = '';
        document.getElementById('password_confirm').value = '';
    }
    
    function cerrarModalPassword() {
        document.getElementById('modalCambiarPassword').style.display = 'none';
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        var form = document.querySelector('#modalCambiarPassword form');
        if (form) {
            form.addEventListener('submit', function(e) {
                var nueva = document.getElementById('password_nueva').value;
                var confirm = document.getElementById('password_confirm').value;
                if (nueva !== confirm) {
                    e.preventDefault();
                    document.getElementById('password_error').style.display = 'block';
                    return false;
                }
                return true;
            });
        }
    });
    
    // Funciones para formatos
    function eliminarFormato(id) {
        if (confirm('¿Estás seguro de eliminar este formato?')) {
            window.location.href = 'eliminar_formato.jsp?id=' + id + '&sec=formatos';
        }
    }
    
    function abrirModalSubirFormato() {
        document.getElementById('modalSubirFormato').style.display = 'flex';
    }
    
    function cerrarModalSubirFormato() {
        document.getElementById('modalSubirFormato').style.display = 'none';
    }
    
    // Funciones para crear usuario
    function abrirModalCrearUsuario() {
        document.getElementById('modalCrearUsuario').style.display = 'flex';
    }
    
    function cerrarModalCrearUsuario() {
        document.getElementById('modalCrearUsuario').style.display = 'none';
    }
    
    // FUNCIÓN PRINCIPAL PARA EDITAR USUARIO
    function abrirModalEditarUsuario(id) {
        document.getElementById('modalEditarUsuario').style.display = 'flex';
        document.getElementById('edit_id').value = id;
        
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'obtener_usuario.jsp?id=' + id, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200) {
                var respuesta = xhr.responseText;
                var partes = respuesta.split('&');
                var datos = {};
                for (var i = 0; i < partes.length; i++) {
                    var igualPos = partes[i].indexOf('=');
                    if (igualPos > 0) {
                        var clave = partes[i].substring(0, igualPos);
                        var valor = decodeURIComponent(partes[i].substring(igualPos + 1));
                        datos[clave] = valor;
                    }
                }
                document.getElementById('edit_nombre').value = datos.nombre || '';
                document.getElementById('edit_apellido').value = datos.apellido || '';
                document.getElementById('edit_email').value = datos.email || '';
                document.getElementById('edit_rol').value = datos.rol || '';
                document.getElementById('edit_estado').value = datos.estado || '';
                document.getElementById('edit_password').value = '';
                document.getElementById('edit_cedula').value = datos.cedula && datos.cedula != 'null' ? datos.cedula : '';
                document.getElementById('edit_nivel').value = datos.nivel && datos.nivel != 'null' ? datos.nivel : '';
                document.getElementById('edit_codigo').value = datos.codigo && datos.codigo != 'null' ? datos.codigo : '';
            }
        };
        xhr.send();
    }
    
    function cerrarModalEditarUsuario() {
        document.getElementById('modalEditarUsuario').style.display = 'none';
    }
    
    // Funciones para editar proyecto
    
    
    function cerrarModalEditarProyecto() {
        document.getElementById('modalEditarProyecto').style.display = 'none';
    }
    
    // Función para mostrar notificaciones
    function mostrarToast(mensaje, tipo) {
        var toast = document.createElement('div');
        toast.className = 'toast toast-' + tipo;
        toast.innerHTML = '<span>' + mensaje + '</span><span class="toast-close" onclick="this.parentElement.remove()">&times;</span>';
        document.body.appendChild(toast);
        setTimeout(function() {
            if (toast) toast.remove();
        }, 3000);
    }

    

function cerrarModalProyecto() {
    document.getElementById('modalDetalleProyecto').style.display = 'none';
    document.getElementById('modalProyectoBody').innerHTML = '<div class="loading-spinner"><i class="fas fa-spinner"></i><p>Cargando información del proyecto...</p></div>';
}

// Cerrar modal al hacer clic fuera del contenido
window.onclick = function(event) {
    var modal = document.getElementById('modalDetalleProyecto');
    if (event.target == modal) {
        cerrarModalProyecto();
    }
}

function mostrarTabMensajes(tabId) {
    document.getElementById('tab_mensajes_recibidos').style.display = 'none';
    document.getElementById('tab_mensajes_enviados').style.display = 'none';
    document.getElementById('tab_mensajes_nuevo').style.display = 'none';
    
    document.getElementById('tab_recibidos_link').style.color = '#6C757D';
    document.getElementById('tab_recibidos_link').style.borderBottom = '3px solid transparent';
    document.getElementById('tab_enviados_link').style.color = '#6C757D';
    document.getElementById('tab_enviados_link').style.borderBottom = '3px solid transparent';
    document.getElementById('tab_nuevo_link').style.color = '#6C757D';
    document.getElementById('tab_nuevo_link').style.borderBottom = '3px solid transparent';
    
    if (tabId === 'recibidos') {
        document.getElementById('tab_mensajes_recibidos').style.display = 'block';
        document.getElementById('tab_recibidos_link').style.color = '#A6C21B';
        document.getElementById('tab_recibidos_link').style.borderBottom = '3px solid #A6C21B';
    } else if (tabId === 'enviados') {
        document.getElementById('tab_mensajes_enviados').style.display = 'block';
        document.getElementById('tab_enviados_link').style.color = '#A6C21B';
        document.getElementById('tab_enviados_link').style.borderBottom = '3px solid #A6C21B';
    } else {
        document.getElementById('tab_mensajes_nuevo').style.display = 'block';
        document.getElementById('tab_nuevo_link').style.color = '#A6C21B';
        document.getElementById('tab_nuevo_link').style.borderBottom = '3px solid #A6C21B';
    }
}

function verMensaje(id, tipo) {
    window.location.href = 'ver_mensaje.jsp?id=' + id + '&tipo=' + tipo;
}

function marcarTodosLeidos() {
    if (confirm('¿Marcar todos los mensajes como leídos?')) {
        window.location.href = 'marcar_leidos.jsp';
    }
}

function validarFormMensaje() {
    var destinatario = document.getElementById('destinatario_id').value;
    var asunto = document.getElementById('asunto').value;
    var mensaje = document.getElementById('mensaje').value;
    
    if (!destinatario) {
        alert('Por favor seleccione un destinatario');
        return false;
    }
    if (!asunto.trim()) {
        alert('Por favor escriba un asunto');
        return false;
    }
    if (!mensaje.trim()) {
        alert('Por favor escriba un mensaje');
        return false;
    }
    return true;
}

function buscarPorEmail() {
    var email = document.getElementById('destinatario_email').value;
    var infoDiv = document.getElementById('infoDestinatario');
    var btnEnviar = document.getElementById('btnEnviar');
    var destinatarioId = document.getElementById('destinatario_id');
    
    if (!email) {
        infoDiv.innerHTML = '<span style="color:#DC3545;">Ingrese un correo electrónico</span>';
        btnEnviar.disabled = true;
        return;
    }
    
    infoDiv.innerHTML = '<span style="color:#17A2B8;"><i class="fas fa-spinner fa-spin"></i> Buscando...</span>';
    
    // Usar ruta absoluta desde la raíz del proyecto
    var url = "${pageContext.request.contextPath}/buscar_usuario_por_email.jsp?email=" + encodeURIComponent(email);
    
    console.log("URL de búsqueda:", url);
    
    fetch(url)
        .then(function(response) {
            return response.json();
        })
        .then(function(data) {
            console.log("Respuesta:", data);
            if (data.existe) {
                infoDiv.innerHTML = '<span style="color:#A6C21B;"><i class="fas fa-check-circle"></i> ' + 
                                    data.nombre + ' ' + data.apellido + 
                                    ' (' + data.rol + ')</span>';
                destinatarioId.value = data.id;
                btnEnviar.disabled = false;
            } else {
                infoDiv.innerHTML = '<span style="color:#DC3545;"><i class="fas fa-times-circle"></i> ' + (data.error || 'Usuario no encontrado') + '</span>';
                destinatarioId.value = '';
                btnEnviar.disabled = true;
            }
        })
        .catch(function(error) {
            console.error("Error:", error);
            infoDiv.innerHTML = '<span style="color:#DC3545;"><i class="fas fa-exclamation-circle"></i> Error al buscar</span>';
            btnEnviar.disabled = true;
        });
}

function validarFormMensaje() {
    var destinatarioId = document.getElementById('destinatario_id').value;
    var asunto = document.getElementById('asunto').value;
    var mensaje = document.getElementById('mensaje').value;
    
    // Mostrar alert con los datos que se van a enviar
    alert("Datos a enviar:\n" +
          "Destinatario ID: " + destinatarioId + "\n" +
          "Asunto: " + asunto + "\n" +
          "Mensaje: " + mensaje);
    
    if (!destinatarioId) {
        alert('Por favor busque y seleccione un destinatario válido');
        return false;
    }
    if (!asunto.trim()) {
        alert('Por favor escriba un asunto');
        return false;
    }
    if (!mensaje.trim()) {
        alert('Por favor escriba un mensaje');
        return false;
    }
    return true;
}
function filtrarFormatos(tipo) {
    // Cambiar estilo de los botones
    document.querySelectorAll('[id^="filtro"]').forEach(function(btn) {
        btn.style.background = '';
        btn.style.color = '#A6C21B';
        btn.classList.add('btn-outline');
    });
    
    if (tipo === 'todos') {
        document.getElementById('filtroTodos').style.background = '#A6C21B';
        document.getElementById('filtroTodos').style.color = 'white';
        document.getElementById('filtroTodos').classList.remove('btn-outline');
    } else if (tipo === 'formato') {
        document.getElementById('filtroFormato').style.background = '#A6C21B';
        document.getElementById('filtroFormato').style.color = 'white';
        document.getElementById('filtroFormato').classList.remove('btn-outline');
    } else if (tipo === 'guia') {
        document.getElementById('filtroGuia').style.background = '#A6C21B';
        document.getElementById('filtroGuia').style.color = 'white';
        document.getElementById('filtroGuia').classList.remove('btn-outline');
    } else if (tipo === 'reglamento') {
        document.getElementById('filtroReglamento').style.background = '#A6C21B';
        document.getElementById('filtroReglamento').style.color = 'white';
        document.getElementById('filtroReglamento').classList.remove('btn-outline');
    } else if (tipo === 'acta') {
        document.getElementById('filtroActa').style.background = '#A6C21B';
        document.getElementById('filtroActa').style.color = 'white';
        document.getElementById('filtroActa').classList.remove('btn-outline');
    } else if (tipo === 'otro') {
        document.getElementById('filtroOtro').style.background = '#A6C21B';
        document.getElementById('filtroOtro').style.color = 'white';
        document.getElementById('filtroOtro').classList.remove('btn-outline');
    }
    
    // Filtrar tarjetas
    var tarjetas = document.querySelectorAll('.formato-card');
    tarjetas.forEach(function(tarjeta) {
        if (tipo === 'todos') {
            tarjeta.style.display = 'block';
        } else {
            var tipoTarjeta = tarjeta.getAttribute('data-tipo');
            if (tipoTarjeta === tipo) {
                tarjeta.style.display = 'block';
            } else {
                tarjeta.style.display = 'none';
            }
        }
    });
}
</script>

<style>
    .modal {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.5);
        z-index: 2000;
        justify-content: center;
        align-items: center;
    }
    .modal-content {
        background: white;
        border-radius: 28px;
        width: 90%;
        max-width: 500px;
        padding: 30px;
        position: relative;
    }
    .modal-close {
        position: absolute;
        top: 15px;
        right: 20px;
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
    }
    
    .perfil-avatar-grande {
        transition: transform 0.3s;
    }
    .perfil-avatar-grande:hover {
        transform: scale(1.05);
    }
    
    .sidebar {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }
    
    .logout-sidebar {
        color: #DC3545 !important;
    }
    
    .logout-sidebar:hover {
        background: #DC3545 !important;
        color: white !important;
    }
    
    /* Responsive */
    @media (min-width: 993px) {
        .menu-toggle { display: none; }
        .sidebar { transform: translateX(0) !important; }
        .main-content { margin-left: 280px; }
    }
    
    @media (max-width: 992px) {
        .stats-grid { grid-template-columns: repeat(2, 1fr); }
        .menu-toggle { display: block; }
        .sidebar { transform: translateX(-100%); }
        .sidebar.open { transform: translateX(0); }
        .main-content { margin-left: 0; padding: 70px 20px 20px 20px; }
    }
    
    @media (max-width: 768px) {
        .stats-grid { grid-template-columns: 1fr; }
        .main-content { padding: 60px 15px 15px 15px; }
        .section-card { padding: 15px; }
    }
    
    /* Toast */
    .toast {
        position: fixed;
        bottom: 20px;
        right: 20px;
        min-width: 280px;
        padding: 15px 20px;
        border-radius: 12px;
        color: white;
        font-weight: 500;
        z-index: 9999;
        animation: slideIn 0.3s ease;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }
    .toast-success { background: linear-gradient(135deg, #A6C21B, #8FAA10); }
    .toast-error { background: linear-gradient(135deg, #DC3545, #C82333); }
    .toast-info { background: linear-gradient(135deg, #17A2B8, #138496); }
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    .toast-close { float: right; cursor: pointer; margin-left: 15px; opacity: 0.8; }
    .toast-close:hover { opacity: 1; }

            /* Calendario en cuadrícula */
        .calendario-container {
            background: white;
            border-radius: 20px;
            overflow: hidden;
            border: 1px solid #E9ECEF;
        }
        
        .calendario-header {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            background: #A6C21B;
            color: white;
            text-align: center;
            padding: 12px 0;
            font-weight: 600;
        }
        
        .calendario-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            min-height: 350px;
        }
        
        .calendario-dia {
            border: 1px solid #F0F2F5;
            min-height: 80px;
            padding: 8px;
            vertical-align: top;
            position: relative;
        }
        
        .calendario-dia.otro-mes {
            background: #F8FAFE;
            color: #ADB5BD;
        }
        
        .calendario-dia.evento {
            background: #E8F5E9;
        }
        
        .calendario-dia.evento .dia-numero {
            font-weight: 700;
            color: #A6C21B;
        }
        
        .dia-numero {
            font-weight: 500;
            font-size: 0.9rem;
        }

        .alert {
    padding: 15px 20px;
    border-radius: 12px;
    margin-bottom: 20px;
    font-size: 0.9rem;
}

.alert-success {
    background: #D4EDDA;
    color: #155724;
    border-left: 4px solid #A6C21B;
}

.alert-error {
    background: #F8D7DA;
    color: #721C24;
    border-left: 4px solid #DC3545;
}

.alert-info {
    background: #D1ECF1;
    color: #0C5460;
    border-left: 4px solid #17A2B8;
}
</style>

<iframe name="submitFrame" style="display:none;"></iframe>
</body>
</html>
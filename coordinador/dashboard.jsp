<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="es_CO" />

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>

<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="nombresFase" value="${fn:split('Pago,Propuesta I,Propuesta II,Informe I,Informe II,Cierre', ',')}" />
<%@ include file="/WEB-INF/fragments/bloqueo_plazos.jspf" %>
<c:set var="seccionActual" value="${param.sec != null ? param.sec : 'dashboard'}" />
<c:set var="idCoordinador" value="${sessionScope.idUsuario}" />

<jsp:useBean id="fechaActual" class="java.util.Date" />

<!-- Consultas corregidas - SIN tabla estudiantes -->
<sql:query dataSource="${dataSource}" var="totalIdeas">SELECT COUNT(*) as total FROM ideas_proyecto</sql:query>
<sql:query dataSource="${dataSource}" var="totalProyectos">SELECT COUNT(*) as total FROM proyectos</sql:query>
<sql:query dataSource="${dataSource}" var="totalEstudiantes">SELECT COUNT(*) as total FROM usuarios WHERE rol = 'estudiante'</sql:query>
<sql:query dataSource="${dataSource}" var="totalDocentes">SELECT COUNT(*) as total FROM usuarios WHERE rol IN ('docente','evaluador')</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Comité - UTS</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        :root {
            --color-principal: #A6C21B;
            --color-principal-hover: #8FAA10;
            --color-info: #17A2B8;
            --color-warning: #FD7E14;
            --color-danger: #DC3545;
            --color-dark: #2C3E50;
            --color-gray: #6C757D;
            --color-gray-light: #F4F7FC;
            --color-white: #FFFFFF;
            --color-border: #E9ECEF;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: var(--color-gray-light); }
        .dashboard { display: flex; min-height: 100vh; }
        .sidebar {
            width: 280px;
            background: white;
            box-shadow: 2px 0 20px rgba(0,0,0,0.03);
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            transition: all 0.3s ease;
            z-index: 1000;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .sidebar-logo { padding: 25px 24px; border-bottom: 1px solid var(--color-border); margin-bottom: 20px; }
        .sidebar-logo h2 { font-size: 1.3rem; font-weight: 700; color: var(--color-principal); }
        .sidebar-logo p { font-size: 0.7rem; color: #8BA0AE; }
        .sidebar-menu { list-style: none; padding: 0 16px; }
        .sidebar-menu li { margin-bottom: 8px; }
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
        .sidebar-menu a:hover { background: #E8F5E9; color: var(--color-principal); }
        .sidebar-menu a.active { background: var(--color-principal); color: white; }
        .sidebar-menu a i { width: 22px; }
        .menu-title { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 1px; color: #ADB5BD; padding: 16px 18px 8px 18px; font-weight: 600; }
        .logout-sidebar { color: var(--color-danger) !important; }
        .logout-sidebar:hover { background: var(--color-danger) !important; color: white !important; }
        .main-content { flex: 1; margin-left: 280px; padding: 25px 30px; transition: all 0.3s ease; }
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
            color: var(--color-dark);
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: none;
        }
        .action-btn {
            background: var(--color-principal);
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }
        .action-btn:hover { background: var(--color-principal-hover); transform: translateY(-2px); }
        .btn-outline { background: transparent; color: var(--color-principal); border: 1px solid var(--color-principal); }
        .btn-outline:hover { background: var(--color-principal); color: white; }
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
        .stat-card {
            background: white;
            padding: 22px 20px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 10px rgba(0,0,0,0.03);
            border: 1px solid var(--color-border);
        }
        .stat-info h3 { font-size: 1.8rem; font-weight: 800; color: var(--color-dark); }
        .stat-info p { font-size: 0.75rem; color: #8BA0AE; }
        .stat-right { width: 50px; height: 50px; background: rgba(166,194,27,0.1); border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; color: var(--color-principal); }
        .section-card {
            background: white;
            border-radius: 24px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.03);
            border: 1px solid var(--color-border);
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #F0F2F5;
            flex-wrap: wrap;
            gap: 15px;
        }
        .section-header h3 { font-size: 1.2rem; font-weight: 700; color: var(--color-dark); }
        .section-header h3 i { color: var(--color-principal); margin-right: 10px; }
        .badge { padding: 4px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; }
        .badge-aprobada { background: #D1FAE5; color: #059669; }
        .badge-pendiente { background: #FEF3C7; color: #D97706; }
        .badge-rechazada { background: #FEE2E2; color: #DC2626; }
        .badge-propuesta { background: #E0F2FE; color: #0284C7; }
        .badge-aprobado_coordinador { background: #D1FAE5; color: #059669; }
        .badge-revision_director { background: #FEF3C7; color: #D97706; }
        .badge-aprobado_director { background: #D1FAE5; color: #059669; }
        .badge-aprobado_evaluador { background: #D1FAE5; color: #059669; }
        .banner-fecha {
            background: linear-gradient(135deg, var(--color-principal) 0%, var(--color-principal-hover) 100%);
            border-radius: 24px;
            padding: 20px 25px;
            margin-bottom: 30px;
            color: white;
        }
        .tabla-datos { width: 100%; border-collapse: collapse; }
        .tabla-datos th, .tabla-datos td { padding: 12px; text-align: left; border-bottom: 1px solid #E9ECEF; }
        .tabla-datos th { background: #F8F9FA; font-weight: 600; color: #2C3E50; }
        .tabla-datos tr:hover { background: #F8FAFE; }
        .buscador { margin-bottom: 20px; display: flex; gap: 10px; flex-wrap: wrap; }
        .buscador input { flex: 1; padding: 12px 15px; border: 1px solid #E9ECEF; border-radius: 30px; font-family: 'Inter', sans-serif; }
        .buscador select { padding: 12px 15px; border: 1px solid #E9ECEF; border-radius: 30px; font-family: 'Inter', sans-serif; }
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
            max-width: 550px;
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
        .tabs { display: flex; gap: 10px; margin-bottom: 25px; border-bottom: 2px solid #E9ECEF; flex-wrap: wrap; }
        .tab-btn { padding: 10px 25px; background: none; border: none; cursor: pointer; font-weight: 600; color: #6C757D; border-bottom: 3px solid transparent; transition: all 0.2s; }
        .tab-btn:hover { color: #A6C21B; }
        .tab-btn.active { color: #A6C21B; border-bottom-color: #A6C21B; }
        .idea-card {
            background: white;
            border-radius: 20px;
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid #E9ECEF;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.03);
        }
        .idea-card:hover { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(0,0,0,0.08); }
        .idea-card.aprobada { border-left: 4px solid #A6C21B; }
        .idea-card.rechazada { border-left: 4px solid #DC3545; }
        .idea-card.pendiente { border-left: 4px solid #FD7E14; }
        .idea-header { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 15px; margin-bottom: 15px; }
        .idea-header h4 { font-size: 1.1rem; color: #2C3E50; margin-bottom: 8px; }
        .idea-header h4 i { margin-right: 8px; }
        .idea-meta { display: flex; gap: 20px; flex-wrap: wrap; font-size: 0.75rem; color: #8BA0AE; }
        .idea-meta i { margin-right: 5px; }
        .idea-badge { padding: 5px 15px; border-radius: 30px; font-size: 0.7rem; font-weight: 600; }
        .idea-badge.pendiente { background: #FEF3C7; color: #D97706; }
        .idea-badge.aprobada { background: #D1FAE5; color: #059669; }
        .idea-badge.rechazada { background: #FEE2E2; color: #DC2626; }
        .idea-body { margin: 15px 0; padding: 15px 0; border-top: 1px solid #F0F2F5; border-bottom: 1px solid #F0F2F5; }
        .idea-body p { color: #4A5568; line-height: 1.6; font-size: 0.9rem; }
        .idea-actions { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 10px; }
        .empty-state { text-align: center; padding: 60px 20px; background: #F8FAFE; border-radius: 20px; color: #ADB5BD; }
        .empty-state i { font-size: 3rem; margin-bottom: 15px; }
        @media (max-width: 992px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .menu-toggle { display: block; }
            .sidebar { transform: translateX(-280px); }
            .sidebar.open { transform: translateX(0); }
            .main-content { margin-left: 0; }
        }
        @media (max-width: 768px) {
            .stats-grid { grid-template-columns: 1fr; }
            .main-content { padding: 20px; }
        }

        .loading-spinner {
    text-align: center;
    padding: 50px;
}
.loading-spinner i {
    font-size: 2rem;
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
   
   .calendario-container {
    background: white;
    border-radius: 20px;
    overflow: hidden;
    border: 1px solid #E9ECEF;
    margin-bottom: 25px;
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
    <aside class="sidebar" id="sidebar">
        <div>
            <div class="sidebar-logo"><img src="${pageContext.request.contextPath}/img/logo_uts.png" alt="UTS"><i class="fas fa-bars" style="color:#55616C"></i></div>
            <div class="menu-title">Navegación</div>
            <ul class="sidebar-menu">
                <li><a href="dashboard.jsp?sec=dashboard" class="${seccionActual == 'dashboard' ? 'active' : ''}"><i class="fas fa-house"></i> Inicio</a></li>
                <li><a href="dashboard.jsp?sec=perfil" class="${seccionActual == 'perfil' ? 'active' : ''}"><i class="fas fa-id-badge"></i> Mi perfil</a></li>
                <li><a href="dashboard.jsp?sec=banco" class="${seccionActual == 'banco' ? 'active' : ''}"><i class="fas fa-book"></i> Banco de ideas</a></li>
                <li><a href="dashboard.jsp?sec=proyectos" class="${seccionActual == 'proyectos' ? 'active' : ''}"><i class="fas fa-graduation-cap"></i> Proyectos de grado</a></li>
                <li><a href="dashboard.jsp?sec=ideas" class="${seccionActual == 'ideas' ? 'active' : ''}"><i class="fas fa-lightbulb"></i> Propuestas Banco</a></li>
                <li><a href="dashboard.jsp?sec=docentes" class="${seccionActual == 'docentes' ? 'active' : ''}"><i class="fas fa-chalkboard-user"></i> Docentes</a></li>
                <li><a href="dashboard.jsp?sec=asignaciones" class="${seccionActual == 'asignaciones' ? 'active' : ''}"><i class="fas fa-user-gear"></i> Asignar director y evaluador</a></li>
                <li><a href="dashboard.jsp?sec=prorrogas" class="${seccionActual == 'prorrogas' ? 'active' : ''}"><i class="fas fa-clock-rotate-left"></i> Prórrogas</a></li>
                <li><a href="dashboard.jsp?sec=formatos" class="${seccionActual == 'formatos' ? 'active' : ''}"><i class="fas fa-cloud-arrow-down"></i> Base documental</a></li>
                <li><a href="dashboard.jsp?sec=configuraciones" class="${seccionActual == 'configuraciones' ? 'active' : ''}"><i class="fas fa-gears"></i> Configuraciones</a></li>
                <li><a href="dashboard.jsp?sec=mensajes" class="${seccionActual == 'mensajes' ? 'active' : ''}"><i class="fas fa-envelope"></i> Mensajes</a></li>
            </ul>
        </div>
        <div>
            <div class="menu-title"></div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/logout.jsp" class="logout-sidebar" onclick="return confirm('¿Cerrar sesión?')"><i class="fas fa-sign-out-alt"></i> Cerrar sesión</a></li>
            </ul>
        </div>
    </aside>
    
    <main class="main-content">
        <%@ include file="/WEB-INF/fragments/tg_header.jspf" %>
        <!-- ==================== SECCIÓN: DASHBOARD ==================== -->
        <c:if test="${seccionActual == 'dashboard'}">
            <sql:query dataSource="${dataSource}" var="resumen">
                SELECT (SELECT COUNT(*) FROM proyectos WHERE fase_actual = 1 AND estado_fase = 'En revisión' AND responsable = 'Comité' AND cancelado = 0) AS pagos,
                       (SELECT COUNT(*) FROM proyectos WHERE fase_actual = 6 AND estado_fase = 'En revisión' AND responsable = 'Comité' AND cancelado = 0) AS cierres,
                       (SELECT COUNT(*) FROM ideas_proyecto WHERE estado = 'pendiente') AS ideas,
                       (SELECT COUNT(*) FROM alerta_plagio WHERE atendida = 0) AS plagios
            </sql:query>
            <c:set var="rs" value="${resumen.rows[0]}" />
            <div class="section-card tg-inicio">
                <h2 class="tg-titulo">SISTEMA - TRABAJOS DE <span>GRADO</span></h2>
                <p class="tg-sub" style="text-align:left;margin-top:14px;">Bienvenido al portal de sistemas trabajo de grado, aquí podrás acceder a:</p>
                <div class="tg-cards">
                    <a class="tg-card" href="dashboard.jsp?sec=proyectos"><c:if test="${rs.pagos + rs.cierres > 0}"><span class="tg-n">${rs.pagos + rs.cierres}</span></c:if><i class="fas fa-graduation-cap"></i><strong>Proyectos de grado</strong><small>${rs.pagos} pagos por revisar y ${rs.cierres} cierres pendientes.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=ideas"><c:if test="${rs.ideas > 0}"><span class="tg-n">${rs.ideas}</span></c:if><i class="fas fa-lightbulb"></i><strong>Propuestas Banco</strong><small>Aprueba o rechaza las ideas propuestas por docentes y estudiantes.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=banco"><i class="fas fa-book"></i><strong>Banco de ideas</strong><small>Consulta las ideas aprobadas del periodo actual.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=formatos"><i class="fas fa-book-open"></i><strong>Base Documental</strong><small>Calendario, formatos y reglamentos institucionales.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=configuraciones"><i class="fas fa-gears"></i><strong>Configuraciones</strong><small>Fechas del periodo y copia de seguridad.</small></a>
                </div>
                <c:if test="${rs.plagios > 0}"><div class="alert alert-warning" style="margin-top:18px;text-align:left;"><i class="fas fa-exclamation-triangle"></i> Hay ${rs.plagios} alerta(s) de posible plagio sin atender: ábrelas desde Proyectos de grado.</div></c:if>
            </div>
        </c:if>

        <c:if test="${seccionActual == 'ideas'}">
    <div class="banner-fecha">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <h2 style="font-size: 1.3rem;"><i class="fas fa-lightbulb"></i> Ideas de Proyecto</h2>
                <p>Gestiona las ideas de proyecto propuestas por estudiantes o creadas por ti</p>
            </div>
            <div>
                <button onclick="abrirModalCrearIdea()" class="action-btn" style="background: #A6C21B; color: white;">
                    <i class="fas fa-plus"></i> Nueva Idea
                </button>
            </div>
        </div>
    </div>

    <!-- Modal para crear nueva idea -->
<div id="modalCrearIdea" class="modal">
    <div class="modal-content" style="max-width: 600px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #E9ECEF;">
            <h3 style="color: #2C3E50;"><i class="fas fa-lightbulb"></i> Nueva Idea de Proyecto</h3>
            <button class="modal-close" onclick="cerrarModalCrearIdea()" style="background: none; border: none; font-size: 1.5rem; cursor: pointer;">&times;</button>
        </div>
        
        <form id="formCrearIdea" action="crear_idea_procesar.jsp" method="post" target="submitFrame" onsubmit="cerrarModalCrearIdea(); setTimeout(function(){location.reload();}, 500);">
            <input type="hidden" name="sec" value="ideas">
            <div style="margin-bottom: 20px;"><label style="display:block;font-weight:600;margin-bottom:8px;">Nivel</label><select name="nivel" required style="width:100%;padding:12px;border-radius:12px;border:1px solid #ddd;"><option value="tecnologia">Tecnología</option><option value="ingenieria">Ingeniería</option></select></div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: #2C3E50;">Título de la idea</label>
                <input type="text" name="titulo" required style="width:100%; padding: 12px; border-radius: 12px; border: 1px solid #ddd; font-family: 'Inter', sans-serif;">
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: #2C3E50;">Descripción</label>
                <textarea name="descripcion" rows="5" required style="width:100%; padding: 12px; border-radius: 12px; border: 1px solid #ddd; font-family: 'Inter', sans-serif;"></textarea>
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: #2C3E50;">Objetivos (opcional)</label>
                <textarea name="objetivos" rows="3" style="width:100%; padding: 12px; border-radius: 12px; border: 1px solid #ddd; font-family: 'Inter', sans-serif;"></textarea>
            </div>
            
            <div style="display: flex; gap: 15px; justify-content: flex-end;">
                <button type="button" onclick="cerrarModalCrearIdea()" class="action-btn" style="background: #6C757D;">Cancelar</button>
                <button type="submit" class="action-btn" style="background: #A6C21B;"><i class="fas fa-save"></i> Guardar Idea</button>
            </div>
        </form>
    </div>
</div>
            
            <div class="tabs">
                <button class="tab-btn active" onclick="mostrarTabIdea('pendientes')"><i class="fas fa-clock"></i> Pendientes</button>
                <button class="tab-btn" onclick="mostrarTabIdea('aprobadas')"><i class="fas fa-check-circle"></i> Aprobadas</button>
                <button class="tab-btn" onclick="mostrarTabIdea('rechazadas')"><i class="fas fa-times-circle"></i> Rechazadas</button>
            </div>
            
            <div id="tab-pendientes" class="tab-idea">
                <sql:query dataSource="${dataSource}" var="ideasPendientes">
                    SELECT i.id, i.titulo, i.descripcion, i.fecha_creacion, i.nivel, i.origen, i.comentario_coordinador,
                           u.nombre as creador_nombre, u.apellido as creador_apellido, u.rol as creador_rol
                    FROM ideas_proyecto i
                    LEFT JOIN usuarios u ON i.creado_por = u.id
                    WHERE i.estado = 'pendiente'
                    ORDER BY i.fecha_creacion DESC
                </sql:query>
                <form method="post" action="ideas_masivo.jsp">
                <div style="margin-bottom:12px;display:flex;gap:8px;flex-wrap:wrap;align-items:center;">
                    <button type="submit" name="decision" value="aprobada" class="action-btn" style="background:#A6C21B;" onclick="return confirm('¿Aprobar las ideas marcadas?')">Aprobar marcadas</button>
                    <button type="submit" name="decision" value="rechazada" class="action-btn" style="background:#DC3545;" onclick="return confirm('¿Rechazar las ideas marcadas?')">Rechazar marcadas</button>
                    <input type="text" name="comentario" placeholder="Comentario para quien propuso (opcional)" style="flex:1;min-width:220px;padding:10px;border:1px solid #ddd;border-radius:10px;">
                </div>
                <c:forEach var="i" items="${ideasPendientes.rows}">
                    <div class="idea-card pendiente">
                        <div class="idea-header">
                            <div>
                                <h4><i class="fas fa-lightbulb"></i> ${i.titulo}</h4>
                                <div class="idea-meta">
                                    <span><i class="fas fa-user"></i> Creado por: ${i.creador_nombre} ${i.creador_apellido} (${i.creador_rol})</span>
                                    <span><i class="fas fa-calendar-alt"></i> ${fn:substring(i.fecha_creacion,8,10)}/${fn:substring(i.fecha_creacion,5,7)}/${fn:substring(i.fecha_creacion,0,4)} ${fn:substring(i.fecha_creacion,11,16)}</span> <span>Nivel: ${empty i.nivel ? 'sin nivel' : i.nivel} · ${i.origen}</span>
                                </div>
                            </div>
                            <div><label><input type="checkbox" name="ids" value="${i.id}"> Marcar</label> <span class="idea-badge pendiente">Pendiente</span></div>
                        </div>
                        <div class="idea-body"><p>${i.descripcion}</p></div>
                        <div class="idea-actions">
                            <a href="aprobar_idea.jsp?id=${i.id}" class="action-btn" style="background:#A6C21B;" onclick="return confirm('¿Aprobar esta idea?')"><i class="fas fa-check"></i> Aprobar</a>
                            <a href="rechazar_idea.jsp?id=${i.id}" class="action-btn" style="background:#DC3545;" onclick="return confirm('¿Rechazar esta idea?')"><i class="fas fa-times"></i> Rechazar</a>
                        </div>
                    </div>
                </c:forEach>
                </form>
                <c:if test="${empty ideasPendientes.rows}">
                    <div class="empty-state"><i class="fas fa-inbox"></i><p>No hay ideas pendientes</p></div>
                </c:if>
            </div>
            
            <div id="tab-aprobadas" class="tab-idea" style="display: none;">
                <sql:query dataSource="${dataSource}" var="ideasAprobadas">
                    SELECT i.id, i.titulo, i.descripcion, i.fecha_creacion, i.nivel, i.origen, i.comentario_coordinador,
                           u.nombre as creador_nombre, u.apellido as creador_apellido, u.rol as creador_rol
                    FROM ideas_proyecto i
                    LEFT JOIN usuarios u ON i.creado_por = u.id
                    WHERE i.estado = 'aprobada'
                    ORDER BY i.fecha_creacion DESC
                </sql:query>
                <c:forEach var="i" items="${ideasAprobadas.rows}">
                    <div class="idea-card aprobada">
                        <div class="idea-header">
                            <div>
                                <h4><i class="fas fa-check-circle"></i> ${i.titulo}</h4>
                                <div class="idea-meta">
                                    <span><i class="fas fa-user"></i> Creado por: ${i.creador_nombre} ${i.creador_apellido} (${i.creador_rol})</span>
                                    <span><i class="fas fa-calendar-alt"></i> ${fn:substring(i.fecha_creacion,8,10)}/${fn:substring(i.fecha_creacion,5,7)}/${fn:substring(i.fecha_creacion,0,4)} ${fn:substring(i.fecha_creacion,11,16)}</span> <span>Nivel: ${empty i.nivel ? 'sin nivel' : i.nivel} · ${i.origen}</span>
                                </div>
                            </div>
                            <div class="idea-badge aprobada">Aprobada</div>
                        </div>
                        <div class="idea-body"><p>${i.descripcion}</p></div>
                    </div>
                </c:forEach>
                <c:if test="${empty ideasAprobadas.rows}">
                    <div class="empty-state"><i class="fas fa-check-circle"></i><p>No hay ideas aprobadas</p></div>
                </c:if>
            </div>
            
            <div id="tab-rechazadas" class="tab-idea" style="display: none;">
                <sql:query dataSource="${dataSource}" var="ideasRechazadas">
                    SELECT i.id, i.titulo, i.descripcion, i.fecha_creacion, i.nivel, i.origen, i.comentario_coordinador,
                           u.nombre as creador_nombre, u.apellido as creador_apellido, u.rol as creador_rol
                    FROM ideas_proyecto i
                    LEFT JOIN usuarios u ON i.creado_por = u.id
                    WHERE i.estado = 'rechazada'
                    ORDER BY i.fecha_creacion DESC
                </sql:query>
                <c:forEach var="i" items="${ideasRechazadas.rows}">
                    <div class="idea-card rechazada">
                        <div class="idea-header">
                            <div>
                                <h4><i class="fas fa-times-circle"></i> ${i.titulo}</h4>
                                <div class="idea-meta">
                                    <span><i class="fas fa-user"></i> Creado por: ${i.creador_nombre} ${i.creador_apellido} (${i.creador_rol})</span>
                                    <span><i class="fas fa-calendar-alt"></i> ${fn:substring(i.fecha_creacion,8,10)}/${fn:substring(i.fecha_creacion,5,7)}/${fn:substring(i.fecha_creacion,0,4)} ${fn:substring(i.fecha_creacion,11,16)}</span> <span>Nivel: ${empty i.nivel ? 'sin nivel' : i.nivel} · ${i.origen}</span>
                                </div>
                            </div>
                            <div class="idea-badge rechazada">Rechazada</div>
                            <c:if test="${not empty i.comentario_coordinador}"><small>Comentario: <c:out value="${i.comentario_coordinador}" /></small></c:if>
                        </div>
                        <div class="idea-body"><p>${i.descripcion}</p></div>
                    </div>
                </c:forEach>
                <c:if test="${empty ideasRechazadas.rows}">
                    <div class="empty-state"><i class="fas fa-times-circle"></i><p>No hay ideas rechazadas</p></div>
                </c:if>
            </div>
        </c:if>
        <!-- ==================== SECCIÓN: PROYECTOS ==================== -->
        <c:if test="${seccionActual == 'proyectos'}">
            
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><i class="fas fa-exclamation-triangle"></i> <c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> Listo, quedó registrado.</div></c:if>
            <c:set var="q" value="${fn:trim(param.q)}" /><c:set var="patron" value="%${q}%" />
            <c:set var="fFase" value="${empty param.fase ? '' : param.fase}" /><c:set var="fEst" value="${empty param.est ? '' : param.est}" />
            <c:set var="pagina" value="${empty param.pag or param.pag < 1 ? 1 : param.pag}" />
            <sql:query dataSource="${dataSource}" var="tot">
                SELECT COUNT(*) AS n FROM proyectos p LEFT JOIN usuarios ud ON ud.id = p.director_id LEFT JOIN usuarios ue ON ue.id = p.evaluador_id
                WHERE (? = '' OR p.codigo LIKE ? OR p.titulo LIKE ? OR ud.nombre LIKE ? OR ud.apellido LIKE ? OR ue.nombre LIKE ? OR ue.apellido LIKE ?
                       OR EXISTS (SELECT 1 FROM proyecto_estudiantes pe JOIN usuarios u ON u.id = pe.estudiante_id
                                   WHERE pe.proyecto_id = p.id AND (u.nombre LIKE ? OR u.apellido LIKE ? OR u.cedula LIKE ?)))
                   AND (? = '' OR p.fase_actual = ?) AND (? = '' OR p.estado_fase = ?)<sql:param value="${q}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${fFase}" /><sql:param value="${fFase}" /><sql:param value="${fEst}" /><sql:param value="${fEst}" />
            </sql:query>
            <c:set var="paginas" value="${fn:substringBefore((tot.rows[0].n + 19) / 20, '.')}" />
            <c:if test="${paginas < 1}"><c:set var="paginas" value="1" /></c:if>
            <sql:query dataSource="${dataSource}" var="lista">
                SELECT p.id, p.codigo, p.titulo, p.modalidad, p.fase_actual, p.estado_fase, p.responsable, p.bloqueado, p.cancelado,
                       CONCAT(ud.nombre, ' ', COALESCE(ud.apellido, '')) AS director, CONCAT(ue.nombre, ' ', COALESCE(ue.apellido, '')) AS evaluador,
                       (SELECT GROUP_CONCAT(CONCAT(u.nombre, ' ', COALESCE(u.apellido, '')) SEPARATOR ', ') FROM proyecto_estudiantes pe JOIN usuarios u ON u.id = pe.estudiante_id WHERE pe.proyecto_id = p.id) AS estudiantes
                  FROM proyectos p LEFT JOIN usuarios ud ON ud.id = p.director_id LEFT JOIN usuarios ue ON ue.id = p.evaluador_id
                WHERE (? = '' OR p.codigo LIKE ? OR p.titulo LIKE ? OR ud.nombre LIKE ? OR ud.apellido LIKE ? OR ue.nombre LIKE ? OR ue.apellido LIKE ?
                       OR EXISTS (SELECT 1 FROM proyecto_estudiantes pe JOIN usuarios u ON u.id = pe.estudiante_id
                                   WHERE pe.proyecto_id = p.id AND (u.nombre LIKE ? OR u.apellido LIKE ? OR u.cedula LIKE ?)))
                   AND (? = '' OR p.fase_actual = ?) AND (? = '' OR p.estado_fase = ?)<sql:param value="${q}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${patron}" /><sql:param value="${fFase}" /><sql:param value="${fFase}" /><sql:param value="${fEst}" /><sql:param value="${fEst}" />
                 ORDER BY p.id DESC LIMIT 20 OFFSET ?
                <sql:param value="${(pagina - 1) * 20}" />
            </sql:query>
            <c:set var="idPanel" value="${param.gestionar}" />
            <c:if test="${not empty param.info}"><c:set var="idInfo" value="${param.info}" /><c:set var="tgCerrar" value="dashboard.jsp?sec=proyectos" /><%@ include file="/WEB-INF/fragments/tg_detalle.jspf" %></c:if>
            <c:if test="${not empty idPanel}">
                <sql:query dataSource="${dataSource}" var="pq">
                    SELECT p.*, per.nombre AS periodo_nombre, CONCAT(ud.nombre, ' ', COALESCE(ud.apellido, '')) AS director_nombre, CONCAT(ue.nombre, ' ', COALESCE(ue.apellido, '')) AS evaluador_nombre,
                           DATEDIFF(DATE(p.fecha_limite_revision), CURDATE()) AS dias_restantes,
                           (SELECT COUNT(*) FROM seguimiento s WHERE s.proyecto_id = p.id) AS seguimientos
                      FROM proyectos p LEFT JOIN periodo_academico per ON per.id = p.periodo_id LEFT JOIN usuarios ud ON ud.id = p.director_id LEFT JOIN usuarios ue ON ue.id = p.evaluador_id WHERE p.id = ?
                    <sql:param value="${idPanel}" />
                </sql:query>
                <c:if test="${not empty pq.rows}">
                <c:set var="pp" value="${pq.rows[0]}" />
                <sql:query dataSource="${dataSource}" var="integ">SELECT u.nombre, u.apellido, u.cedula FROM proyecto_estudiantes pe JOIN usuarios u ON u.id = pe.estudiante_id WHERE pe.proyecto_id = ?<sql:param value="${pp.id}" /></sql:query>
                <sql:query dataSource="${dataSource}" var="ents">SELECT fase, tipo, version, url, fecha, estudiante_id, (SELECT CONCAT(nombre, ' ', COALESCE(apellido, '')) FROM usuarios WHERE id = entrega.estudiante_id) AS estudiante FROM entrega WHERE proyecto_id = ? ORDER BY fecha DESC, id DESC<sql:param value="${pp.id}" /></sql:query>
                <sql:query dataSource="${dataSource}" var="revs">SELECT r.fase, r.rol_revisor, r.estado, r.observacion, r.fecha, CONCAT(u.nombre, ' ', COALESCE(u.apellido, '')) AS revisor FROM revision r JOIN usuarios u ON u.id = r.revisor_id WHERE r.proyecto_id = ? ORDER BY r.fecha DESC, r.id DESC<sql:param value="${pp.id}" /></sql:query>
                <sql:query dataSource="${dataSource}" var="plag">SELECT a.id, a.detalle, a.fecha, a.atendida, CONCAT(u.nombre, ' ', COALESCE(u.apellido, '')) AS docente FROM alerta_plagio a JOIN usuarios u ON u.id = a.docente_id WHERE a.proyecto_id = ? ORDER BY a.fecha DESC<sql:param value="${pp.id}" /></sql:query>
                <c:set var="tgVolver" value="dashboard.jsp?sec=proyectos" /><c:set var="tgPlagio" value="" />
                <%@ include file="/WEB-INF/fragments/tg_seguimiento.jspf" %>
                <div class="section-card">
                    <h3 style="margin-bottom:6px">Acciones del proyecto</h3>
                    <p class="tg-sub">Modalidad ${pp.modalidad} · Periodo ${fn:replace(pp.periodo_nombre, '.', '-')}
                        <c:if test="${pp.bloqueado == 1}"> · <strong style="color:#C0392B;">Bloqueado: <c:out value="${pp.motivo_bloqueo}" /></strong></c:if>
                        <c:if test="${pp.cancelado == 1}"> · <strong style="color:#C0392B;">Cancelado</strong></c:if>
                        <c:if test="${not empty pp.fecha_limite_revision}"> · Fecha límite de respuesta: ${fn:substring(pp.fecha_limite_revision,8,10)}/${fn:substring(pp.fecha_limite_revision,5,7)}/${fn:substring(pp.fecha_limite_revision,0,4)} (${pp.dias_restantes} días)</c:if></p>
                    <div class="tg-fila"><b>Director</b><span><c:out value="${empty fn:trim(pp.director_nombre) ? 'Sin asignar' : pp.director_nombre}" /></span></div>
                    <div class="tg-fila"><b>Evaluador</b><span><c:out value="${empty fn:trim(pp.evaluador_nombre) ? 'Sin asignar' : pp.evaluador_nombre}" /></span></div>
                    <div class="tg-fila"><b>Seguimientos del director</b><span>${pp.seguimientos}</span></div>
                    <div class="tg-fila"><b>Integrantes</b><span><c:forEach var="i" items="${integ.rows}" varStatus="s"><c:out value="${i.nombre} ${i.apellido} (${i.cedula})" /><c:if test="${not s.last}">, </c:if></c:forEach></span></div>
                    <c:if test="${not empty plag.rows}"><h4 style="margin-top:14px;">Alertas de posible plagio</h4>
                    <c:forEach var="a" items="${plag.rows}"><form method="post" action="atender_plagio.jsp" style="font-size:.9rem;margin:6px 0;"><input type="hidden" name="id" value="${a.id}"><input type="hidden" name="proyectoId" value="${pp.id}">
                        <c:out value="${a.docente}" />: <c:out value="${a.detalle}" /> <c:choose><c:when test="${a.atendida == 1}"><span class="badge badge-aprobada">Atendida</span></c:when><c:otherwise><button class="action-btn" type="submit">Marcar atendida</button></c:otherwise></c:choose></form></c:forEach></c:if>

                    <c:if test="${not empty param.gestionar and pp.cancelado == 0}">
                        <c:if test="${pp.bloqueado == 1 and pp.motivo_bloqueo == 'Plazo de revisión vencido'}">
                            <form method="post" action="desbloquear.jsp" style="margin-top:14px;"><input type="hidden" name="proyectoId" value="${pp.id}">
                                <button type="submit" class="action-btn" style="background:#FD7E14;" onclick="return confirm('¿Desbloquear y dar 5 días más al responsable?')">Desbloquear (5 días más)</button></form>
                        </c:if>
                        <sql:query dataSource="${dataSource}" var="docs">
                            SELECT u.id, u.nombre, u.apellido, (SELECT COUNT(*) FROM proyectos x WHERE x.director_id = u.id AND x.cancelado = 0 AND x.estado_fase NOT IN ('Rechazado','Finalizado')) AS dirige
                              FROM usuarios u WHERE u.rol IN ('docente','evaluador') AND u.estado = 1 ORDER BY u.nombre
                        </sql:query>
                <sql:query dataSource="${dataSource}" var="evals">SELECT id, nombre, apellido FROM usuarios WHERE rol IN ('docente','evaluador') AND estado = 1 ORDER BY nombre</sql:query>
                        <c:if test="${pp.estado_fase == 'En revisión' and pp.responsable == 'Comité' and (pp.fase_actual == 1 or pp.fase_actual == 6)}">
                        <form method="post" action="revisar_fase.jsp" style="margin-top:18px;padding:16px;background:#F8FAFE;border-radius:14px;display:grid;gap:12px;">
                            <h4><c:choose><c:when test="${pp.fase_actual == 1}">Revisar el pago (fase 1)</c:when><c:otherwise>Cierre del proceso (fase final)</c:otherwise></c:choose></h4>
                            <input type="hidden" name="proyectoId" value="${pp.id}">
                            <div><label><input type="radio" name="decision" value="Aprobado" required> Aprobado</label>
                                <c:if test="${pp.fase_actual == 1}"> &nbsp; <label><input type="radio" name="decision" value="Aplazado"> Aplazado</label></c:if>
                                &nbsp; <label><input type="radio" name="decision" value="Rechazado"> Rechazado</label></div>
                            <c:if test="${pp.fase_actual == 1}">
                                <small>Cada integrante subió su propio comprobante de pago (revísalos en la fase 1).</small>
                                <label>Director (al aprobar)<select name="directorId" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"><option value="">Seleccionar</option>
                                    <c:forEach var="d" items="${docs.rows}"><option value="${d.id}" ${d.id == pp.director_sugerido_id ? 'selected' : ''}><c:out value="${d.nombre} ${d.apellido}" /> (${d.dirige} proyectos)${d.id == pp.director_sugerido_id ? ' · sugerido' : ''}</option></c:forEach></select></label>
                                <label>Evaluador (al aprobar)<select name="evaluadorId" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"><option value="">Seleccionar</option>
                                    <c:forEach var="d" items="${evals.rows}"><option value="${d.id}"><c:out value="${d.nombre} ${d.apellido}" /></option></c:forEach></select></label>
                            </c:if>
                            <c:if test="${pp.fase_actual == 6}"><label>Fecha de sustentación (al aprobar)<input type="date" name="fechaSustentacion" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label></c:if>
                            <label>Observaciones (obligatorias si es Aplazado o Rechazado)<textarea name="observacion" rows="3" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></textarea></label>
                            <label><input type="checkbox" name="confirmar" value="1"> Confirmo el rechazo (termina el proyecto)</label>
                            <div><button type="submit" class="action-btn">Guardar decisión</button></div>
                        </form></c:if>
                        <form method="post" action="asignar_docentes.jsp" style="margin-top:18px;padding:16px;background:#F8FAFE;border-radius:14px;display:grid;gap:12px;">
                            <h4>Asignar o reasignar director y evaluador</h4><input type="hidden" name="proyectoId" value="${pp.id}">
                            <label>Director<select name="directorId" required style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"><c:forEach var="d" items="${docs.rows}"><option value="${d.id}" ${d.id == pp.director_id ? 'selected' : ''}><c:out value="${d.nombre} ${d.apellido}" /> (${d.dirige} proyectos)</option></c:forEach></select></label>
                            <label>Evaluador<select name="evaluadorId" required style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"><c:forEach var="d" items="${evals.rows}"><option value="${d.id}" ${d.id == pp.evaluador_id ? 'selected' : ''}><c:out value="${d.nombre} ${d.apellido}" /></option></c:forEach></select></label>
                            <div><button type="submit" class="action-btn">Guardar asignación</button></div>
                        </form>
                    </c:if>
                </div></c:if>
            </c:if>
            <div class="section-card">
                <h2 class="tg-titulo">Proyectos de <span>GRADO</span></h2>
                <form method="get" action="dashboard.jsp" class="tg-controles">
                    <input type="hidden" name="sec" value="proyectos">
                    <input type="search" name="q" value="<c:out value='${q}'/>" placeholder="Código, proyecto, docente, estudiante o cédula" style="flex:1;min-width:240px;">
                    <select name="fase"><option value="">Toda fase</option><c:forEach var="n" begin="1" end="6"><option value="${n}" ${fFase == n ? 'selected' : ''}>${n}. ${nombresFase[n-1]}</option></c:forEach></select>
                    <select name="est"><option value="">Todo estado</option><c:forEach var="e" items="${fn:split('Pendiente de entrega,En revisión,Aplazado,Rechazado,Finalizado', ',')}"><option ${fEst == e ? 'selected' : ''}>${e}</option></c:forEach></select>
                    <button type="submit" class="tg-btn">Buscar</button>
                </form>
                <div style="overflow-x:auto"><table class="tg-tabla">
                    <thead><tr><th>ID</th><th>Descripción</th><th>Estudiantes</th><th class="cen">Estado</th><th class="cen">Acciones</th></tr></thead><tbody>
                    <c:forEach var="p" items="${lista.rows}"><tr>
                        <td>GRA-${fn:substring(100000 + p.id, 1, 6)}</td><td><c:out value="${p.titulo}" /></td><td><c:out value="${p.estudiantes}" /></td>
                        <td class="cen"><c:choose><c:when test="${p.cancelado == 1}"><span class="tg-badge mal">Cancelado</span></c:when><c:when test="${p.estado_fase == 'Finalizado'}"><span class="tg-badge ok">Finalizado</span></c:when><c:when test="${p.estado_fase == 'Rechazado'}"><span class="tg-badge mal">Rechazada</span></c:when>
                            <c:otherwise><span class="tg-badge fase">Fase ${p.fase_actual}</span><span class="tg-badge resp">${p.responsable}</span><c:if test="${p.bloqueado == 1}"><span class="tg-badge mal">Bloqueado</span></c:if></c:otherwise></c:choose></td>
                        <td class="acc cen"><a class="tg-ico pizarra" href="dashboard.jsp?sec=proyectos&info=${p.id}" title="Ver detalles" aria-label="Ver detalles"><i class="far fa-eye"></i></a>
                            <a class="tg-ico azul" href="dashboard.jsp?sec=proyectos&gestionar=${p.id}" title="Gestionar fases" aria-label="Gestionar fases"><i class="fas fa-briefcase"></i></a></td></tr></c:forEach>
                    </tbody></table></div>
                <c:if test="${empty lista.rows}"><p style="margin-top:12px;">No se encontraron proyectos.</p></c:if>
                <div class="tg-pie"><span>Mostrando la página ${pagina} de ${paginas}</span><div class="tg-pag">
                    <c:forEach var="n" begin="1" end="${paginas}"><a href="dashboard.jsp?sec=proyectos&pag=${n}&fase=${fFase}&est=${fn:escapeXml(fEst)}&q=${fn:escapeXml(q)}" class="${n == pagina ? 'act' : ''}">${n}</a></c:forEach></div></div>
            </div>
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

        
        <c:if test="${seccionActual == 'calendario'}">
    <div class="banner-fecha">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <h2 style="font-size: 1.3rem;"><i class="fas fa-calendar-alt"></i> Calendario Académico</h2>
                <p>Gestiona los eventos y fechas importantes del calendario</p>
            </div>
            <div>
                <span style="background: rgba(255,255,255,0.2); padding: 6px 16px; border-radius: 40px;">
                    <i class="fas fa-calendar-alt"></i> <fmt:formatDate value="${fechaActual}" pattern="dd/MM/yyyy" />
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
    
    <sql:query dataSource="${dataSource}" var="eventosMesCal">
        SELECT id, titulo, fecha_evento, tipo FROM calendario_academico 
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
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                 <a href="https://www.uts.edu.co/sitio/calendario-academico" target="_blank" class="action-btn btn-outline">
            <i class="fas fa-external-link-alt"></i> Calendario UTS
                <a href="dashboard.jsp?sec=calendario&mes=${mesPrevCal}&año=${añoPrevCal}" class="action-btn" style="background:#6C757D; color:white;">
                    <i class="fas fa-chevron-left"></i> Mes anterior
                </a>
                <a href="dashboard.jsp?sec=calendario&mes=${mesNextCal}&año=${añoNextCal}" class="action-btn" style="background:#6C757D; color:white;">
                    Mes siguiente <i class="fas fa-chevron-right"></i>
                </a>
                
                <button onclick="mostrarFormularioEvento()" class="action-btn" style="background:#A6C21B; color:white;">
                    <i class="fas fa-plus"></i> Agregar Evento
                </button>
                
                
            </div>
        </div>
        
        <!-- Calendario en cuadrícula -->
        <div class="calendario-container">
            <div class="calendario-header">
                <div>Dom</div><div>Lun</div><div>Mar</div><div>Mié</div><div>Jue</div><div>Vie</div><div>Sáb</div>
            </div>
            <div class="calendario-grid" id="calendarioGrid"></div>
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
                        <button onclick="editarEvento(${e.id}, '${e.titulo}', '${e.descripcion}', '${e.fecha_evento}', '${e.tipo}')" class="action-btn" style="padding: 5px 12px;">
                            <i class="fas fa-edit"></i> Editar
                        </button>
                        <a href="eliminar_evento.jsp?id=${e.id}&sec=calendario" class="action-btn" style="padding: 5px 12px; background:#DC3545; color:white;" onclick="return confirm('¿Eliminar este evento?')">
                            <i class="fas fa-trash"></i> Eliminar
                        </a>
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
    
    
    <script>
        function generarCalendario(año, mes, eventos) {
            var primerDia = new Date(año, mes - 1, 1);
            var ultimoDia = new Date(año, mes, 0);
            var primerDiaSemana = primerDia.getDay();
            var diasEnMes = ultimoDia.getDate();
            
            var grid = document.getElementById('calendarioGrid');
            grid.innerHTML = '';
            
            for (var i = 0; i < primerDiaSemana; i++) {
                var divVacio = document.createElement('div');
                divVacio.className = 'calendario-dia otro-mes';
                grid.appendChild(divVacio);
            }
            
            for (var d = 1; d <= diasEnMes; d++) {
                var div = document.createElement('div');
                div.className = 'calendario-dia';
                if (eventos[d]) {
                    div.classList.add('evento');
                }
                var numero = document.createElement('div');
                numero.className = 'dia-numero';
                numero.innerText = d;
                div.appendChild(numero);
                grid.appendChild(div);
            }
            
            var totalCeldas = primerDiaSemana + diasEnMes;
            var restantes = 42 - totalCeldas;
            for (var i = 0; i < restantes; i++) {
                var divVacio = document.createElement('div');
                divVacio.className = 'calendario-dia otro-mes';
                grid.appendChild(divVacio);
            }
        }
        
        var eventosMap = {};
        <c:forEach var="e" items="${eventosMesCal.rows}">
            var fecha = '${e.fecha_evento}';
            var dia = parseInt(fecha.split('-')[2]);
            eventosMap[dia] = true;
        </c:forEach>
        
        generarCalendario(${añoActualCal}, ${mesActualCal}, eventosMap);
    </script>
    
    <!-- Modal para eventos -->
    <div id="modalEvento" class="modal">
        <div class="modal-content">
            <button class="modal-close" onclick="cerrarModal()">&times;</button>
            <h3 id="modalTitulo" style="margin-bottom: 20px;">Nuevo Evento</h3>
            <form action="guardar_evento.jsp" method="post" target="submitFrame" onsubmit="cerrarModal(); setTimeout(function(){location.reload();}, 500);">
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
                <button type="submit" class="action-btn" style="background:#A6C21B; color:white; width:100%; padding: 12px;">
                    <i class="fas fa-save"></i> Guardar Evento
                </button>
            </form>
        </div>
    </div>
    
    <script>
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
            if (event.target == modal) {
                modal.style.display = 'none';
            }
        }
    </script>
</c:if>
        
        <c:if test="${seccionActual == 'docentes'}">
            <div class="banner-fecha"><h2 style="font-size:1.3rem;"><i class="fas fa-chalkboard-teacher"></i> Docentes</h2><p>El Comité inscribe a los docentes cada semestre con cédula, correo y nombre</p></div>
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><i class="fas fa-exclamation-triangle"></i> <c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> Listo, quedó registrado.</div></c:if>
            <form method="post" action="inscribir_docente.jsp" class="section-card" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:12px;align-items:end;">
                <label>Cédula<input type="text" name="cedula" required pattern="[0-9]{5,15}" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                <label>Correo institucional<input type="email" name="correo" required style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                                <label>Nombre<input type="text" name="nombre" required maxlength="100" style="width:100%;padding:10px;border:1px solid #E9ECEF;border-radius:10px;"></label>
                <div><button type="submit" class="tg-btn">Inscribir</button></div>
                <p style="grid-column:1/-1;font-size:.85rem;color:#6C757D;">La contraseña inicial es la cédula; el docente debe cambiarla.</p>
            </form>
            <sql:query dataSource="${dataSource}" var="dcs">
                SELECT u.nombre, u.apellido, u.email, u.cedula, u.estado,
                       (SELECT COUNT(*) FROM ideas_proyecto i WHERE i.creado_por = u.id) AS ideas
                  FROM usuarios u WHERE u.rol IN ('docente','evaluador') ORDER BY u.rol, u.nombre
            </sql:query>
            <div class="section-card" style="overflow-x:auto;"><table class="tg-tabla"><tr style="text-align:left;"><th>Nombre</th><th>Cédula</th><th>Correo</th><th>Ideas</th><th>Estado</th></tr>
                <c:forEach var="d" items="${dcs.rows}"><tr style="border-top:1px solid #E9ECEF;"><td><c:out value="${d.nombre} ${d.apellido}" /></td><td>${d.cedula}</td><td>${d.email}</td><td>${d.ideas}</td><td>${d.estado == 1 ? 'Activo' : 'Inactivo'}</td></tr></c:forEach></table></div>
        </c:if>
        <!-- ==================== SECCIÓN: PRÓRROGAS ==================== -->
        <c:if test="${seccionActual == 'prorrogas'}">
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><i class="fas fa-exclamation-triangle"></i> <c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> Listo, quedó registrado.</div></c:if>
            <sql:query dataSource="${dataSource}" var="prs">
                SELECT r.id, r.numero, r.url_carta, r.url_pago, r.estado, r.solo_correcciones, r.fecha_solicitud, p.codigo, p.titulo,
                       (SELECT GROUP_CONCAT(CONCAT(u.nombre, ' ', COALESCE(u.apellido, '')) SEPARATOR ', ') FROM proyecto_estudiantes pe JOIN usuarios u ON u.id = pe.estudiante_id WHERE pe.proyecto_id = p.id) AS estudiantes
                  FROM prorroga r JOIN proyectos p ON p.id = r.proyecto_id ORDER BY (r.estado = 'Pendiente') DESC, r.id DESC LIMIT 100
            </sql:query>
            <div class="section-card">
                <h2 class="tg-titulo">Solicitudes de <span>PRÓRROGA</span></h2>
                <p class="tg-sub">Cada prórroga da 180 días más (máximo 2 por proyecto). Si es solo para correcciones, el estudiante puede reentregar sin esperar los plazos mínimos.</p>
                <div style="overflow-x:auto"><table class="tg-tabla">
                    <thead><tr><th>Proyecto</th><th>Estudiantes</th><th class="cen">N.º</th><th class="cen">Tipo</th><th class="cen">Documentos</th><th class="cen">Estado</th><th class="cen">Decisión</th></tr></thead><tbody>
                    <c:forEach var="r" items="${prs.rows}"><tr>
                        <td><c:out value="${r.codigo}" /><br><small><c:out value="${r.titulo}" /></small></td>
                        <td><c:out value="${r.estudiantes}" /></td>
                        <td class="cen">${r.numero}</td>
                        <td class="cen">${r.solo_correcciones == 1 ? 'Solo correcciones' : 'Completa'}</td>
                        <td class="cen"><a href="<c:out value='${r.url_carta}'/>" target="_blank" rel="noopener noreferrer">Carta</a> · <a href="<c:out value='${r.url_pago}'/>" target="_blank" rel="noopener noreferrer">Pago</a></td>
                        <td class="cen"><span class="tg-badge ${r.estado == 'Aprobada' ? 'ok' : (r.estado == 'Rechazada' ? 'mal' : 'fase')}">${r.estado}</span></td>
                        <td class="cen"><c:if test="${r.estado == 'Pendiente'}">
                            <form method="post" action="decidir_prorroga.jsp" style="display:flex;gap:6px;justify-content:center"><input type="hidden" name="prorrogaId" value="${r.id}">
                                <button type="submit" name="decision" value="Aprobada" class="tg-btn" style="padding:5px 12px" onclick="return confirm('¿Aprobar la prórroga de 180 días?')">Aprobar</button>
                                <button type="submit" name="decision" value="Rechazada" class="tg-btn gris" style="padding:5px 12px" onclick="return confirm('¿Rechazar la solicitud?')">Rechazar</button></form></c:if></td></tr></c:forEach>
                    <c:if test="${empty prs.rows}"><tr><td colspan="7" class="cen">No hay solicitudes de prórroga.</td></tr></c:if>
                    </tbody></table></div>
            </div>
        </c:if>
        <!-- ==================== SECCIÓN: ASIGNACIONES ==================== -->
        <c:if test="${seccionActual == 'asignaciones'}">
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><i class="fas fa-exclamation-triangle"></i> <c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> Asignación guardada.</div></c:if>
            <sql:query dataSource="${dataSource}" var="dcAs">
                SELECT u.id, u.nombre, u.apellido, (SELECT COUNT(*) FROM proyectos x WHERE x.director_id = u.id AND x.cancelado = 0 AND x.estado_fase NOT IN ('Rechazado','Finalizado')) AS dirige
                  FROM usuarios u WHERE u.rol IN ('docente','evaluador') AND u.estado = 1 ORDER BY u.nombre
            </sql:query>
            <sql:query dataSource="${dataSource}" var="asig">
                SELECT p.id, p.codigo, p.titulo, p.fase_actual, p.director_id, p.evaluador_id,
                       (SELECT GROUP_CONCAT(CONCAT(u.nombre, ' ', COALESCE(u.apellido, '')) SEPARATOR ', ') FROM proyecto_estudiantes pe JOIN usuarios u ON u.id = pe.estudiante_id WHERE pe.proyecto_id = p.id) AS estudiantes
                  FROM proyectos p WHERE p.cancelado = 0 AND p.estado_fase NOT IN ('Rechazado', 'Finalizado') ORDER BY (p.director_id IS NULL) DESC, p.id DESC
            </sql:query>
            <div class="section-card">
                <h2 class="tg-titulo">Asignar <span>DIRECTOR Y EVALUADOR</span></h2>
                <p class="tg-sub">Asigna o reasigna director y evaluador a los estudiantes inscritos. Deben ser docentes distintos; se busca equilibrar la carga (unos 10 proyectos por director).</p>
                <div style="overflow-x:auto"><table class="tg-tabla">
                    <thead><tr><th>Proyecto</th><th>Estudiantes</th><th>Director</th><th>Evaluador</th><th class="cen">Acción</th></tr></thead><tbody>
                    <c:forEach var="p" items="${asig.rows}"><tr>
                        <td><c:out value="${p.codigo}" /> · Fase ${p.fase_actual}<br><small><c:out value="${p.titulo}" /></small></td>
                        <td><c:out value="${p.estudiantes}" /></td>
                        <td><select name="directorId" form="fa${p.id}" required class="tg-input"><c:if test="${empty p.director_id}"><option value="" selected disabled>Sin asignar</option></c:if>
                            <c:forEach var="d" items="${dcAs.rows}"><option value="${d.id}" ${d.id == p.director_id ? 'selected' : ''}><c:out value="${d.nombre} ${d.apellido}" /> (${d.dirige})</option></c:forEach></select></td>
                        <td><select name="evaluadorId" form="fa${p.id}" required class="tg-input"><c:if test="${empty p.evaluador_id}"><option value="" selected disabled>Sin asignar</option></c:if>
                            <c:forEach var="d" items="${dcAs.rows}"><option value="${d.id}" ${d.id == p.evaluador_id ? 'selected' : ''}><c:out value="${d.nombre} ${d.apellido}" /></option></c:forEach></select></td>
                        <td class="cen"><form id="fa${p.id}" method="post" action="asignar_docentes.jsp"><input type="hidden" name="proyectoId" value="${p.id}"><input type="hidden" name="volver" value="asignaciones"><button type="submit" class="tg-btn" style="padding:5px 12px">Guardar</button></form></td></tr></c:forEach>
                    <c:if test="${empty asig.rows}"><tr><td colspan="5" class="cen">No hay proyectos activos.</td></tr></c:if>
                    </tbody></table></div>
            </div>
        </c:if>
        <c:if test="${seccionActual == 'formatos'}">
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><c:out value="${param.err}" /></div></c:if>
    <div class="banner-fecha">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <h2 style="font-size: 1.3rem;"><i class="fas fa-file-alt"></i> Formatos de Grado</h2>
                <p>Documentos y formatos institucionales para proyectos de grado</p>
            </div>
            <div>
                <button onclick="abrirModalSubirFormato()" class="action-btn" style="background: #A6C21B; color: white;">
                    <i class="fas fa-upload"></i> Subir Formato
                </button>
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
                <button onclick="filtrarFormatos('todos')" id="filtroTodos" class="action-btn btn-outline" style="background:#A6C21B; color:white;">📋 Todos</button>
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
                        <!-- Icono según tipo -->
                        <div style="width: 70px; height: 70px; background: #E8F5E9; border-radius: 18px; display: flex; align-items: center; justify-content: center;">
                            <c:choose>
                                <c:when test="${f.tipo == 'formato'}"><i class="fas fa-file-alt" style="font-size: 2rem; color: #A6C21B;"></i></c:when>
                                <c:when test="${f.tipo == 'guia'}"><i class="fas fa-book" style="font-size: 2rem; color: #17A2B8;"></i></c:when>
                                <c:when test="${f.tipo == 'reglamento'}"><i class="fas fa-gavel" style="font-size: 2rem; color: #FD7E14;"></i></c:when>
                                <c:when test="${f.tipo == 'acta'}"><i class="fas fa-file-signature" style="font-size: 2rem; color: #6F42C1;"></i></c:when>
                                <c:otherwise><i class="fas fa-file-pdf" style="font-size: 2rem; color: #DC3545;"></i></c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!-- Información -->
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
                            
                            <!-- Botones de acción -->
                            <div style="display: flex; gap: 12px; margin-top: 18px; flex-wrap: wrap;">
                                <c:set var="esLink" value="${fn:startsWith(f.ruta_archivo, 'http')}" /><c:url var="urlF" value="/${f.ruta_archivo}" /><a href="${esLink ? f.ruta_archivo : urlF}" target="_blank" class="action-btn" style="background:#17A2B8; color:white; padding: 8px 20px; text-decoration:none; border-radius: 12px; display: inline-flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-eye"></i> Ver documento
                                </a>
                                <c:if test="${not esLink}"><a href="${urlF}" download class="action-btn" style="background:#A6C21B; color:white; padding: 8px 20px; text-decoration:none; border-radius: 12px; display: inline-flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-download"></i> Descargar
                                </a></c:if>
                                <button onclick="eliminarFormato(${f.id})" class="action-btn" style="background:#DC3545; color:white; padding: 8px 20px; border:none; border-radius: 12px; cursor:pointer; display: inline-flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-trash"></i> Eliminar
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
        
        <c:if test="${empty formatosLista.rows}">
            <div style="text-align: center; padding: 60px; background: #F8FAFE; border-radius: 20px;">
                <i class="fas fa-folder-open" style="font-size: 4rem; color: #ADB5BD;"></i>
                <p style="margin-top: 15px;">No hay formatos disponibles. Sube el primero usando el botón "Subir Formato".</p>
            </div>
        </c:if>
    </div>
</c:if>
        <!-- Modal para subir formato -->
<div id="modalSubirFormato" class="modal">
    <div class="modal-content" style="max-width: 550px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #E9ECEF;">
            <h3 style="color: #2C3E50;"><i class="fas fa-upload"></i> Subir Nuevo Formato</h3>
            <button class="modal-close" onclick="cerrarModalSubirFormato()" style="background: none; border: none; font-size: 1.5rem; cursor: pointer;">&times;</button>
        </div>
        
        <form action="guardar_formato.jsp" method="post">
            <input type="hidden" name="sec" value="formatos">
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: #2C3E50;">Nombre del formato</label>
                <input type="text" name="nombre" required style="width:100%; padding: 12px; border-radius: 12px; border: 1px solid #ddd;">
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: #2C3E50;">Descripción</label>
                <textarea name="descripcion" rows="3" style="width:100%; padding: 12px; border-radius: 12px; border: 1px solid #ddd;"></textarea>
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: #2C3E50;">Tipo de documento</label>
                <select name="tipo" style="width:100%; padding: 12px; border-radius: 12px; border: 1px solid #ddd;">
                    <option value="formato">Formato</option>
                    <option value="guia">Guía</option>
                    <option value="reglamento">Reglamento</option>
                    <option value="acta">Acta</option>
                    <option value="otro">Otro</option>
                </select>
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: #2C3E50;">Enlace del documento (URL)</label>
                <input type="url" placeholder="https://..." name="ruta_archivo" required style="width:100%; padding: 12px; border-radius: 12px; border: 1px solid #ddd;" placeholder="https://... o formatos/archivo.docx">
                <small style="color: #6C757D;">Pega el enlace de descarga directa de Google Drive o de la UTS</small>
            </div>
            
            <div style="display: flex; gap: 15px; justify-content: flex-end;">
                <button type="button" onclick="cerrarModalSubirFormato()" class="action-btn" style="background: #6C757D;">Cancelar</button>
                <button type="submit" class="action-btn" style="background: #A6C21B;"><i class="fas fa-save"></i> Guardar Formato</button>
            </div>
        </form>
    </div>
</div>

<!-- ==================== MENSAJES ==================== -->
<c:if test="${seccionActual == 'mensajes'}">
    <div class="banner-fecha">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <h2 style="font-size: 1.3rem;"><i class="fas fa-envelope"></i> Mensajería Interna</h2>
                <p>Gestiona tus mensajes con administradores, docentes y estudiantes</p>
            </div>
            <div>
                <span style="background: rgba(255,255,255,0.2); padding: 6px 16px; border-radius: 40px;">
                    <i class="fas fa-calendar-alt"></i> <fmt:formatDate value="${fechaActual}" pattern="dd/MM/yyyy" />
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
            
            <form id="formEnviarMensaje" action="enviar_mensaje_procesar.jsp" method="post" onsubmit="return validarFormMensaje()">
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

        <c:if test="${seccionActual == 'perfil'}">
    <div class="banner-fecha">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <h2 style="font-size: 1.3rem;"><i class="fas fa-user-circle"></i> Mi Perfil</h2>
                <p>Consulta y actualiza tu información personal</p>
            </div>
            <div>
                <span style="background: rgba(255,255,255,0.2); padding: 6px 16px; border-radius: 40px;">
                    <i class="fas fa-calendar-alt"></i> <fmt:formatDate value="${fechaActual}" pattern="dd/MM/yyyy" />
                </span>
            </div>
        </div>
    </div>
    
    <sql:query dataSource="${dataSource}" var="coordinadorData">
        SELECT nombre, apellido, email, fecha_registro FROM usuarios WHERE id = ?
        <sql:param value="${idCoordinador}" />
    </sql:query>
    
    <div class="section-card" style="padding: 0; overflow: hidden; margin-bottom: 30px;">
        <div style="background: linear-gradient(135deg, #A6C21B 0%, #8FAA10 100%); padding: 50px 30px; text-align: center; color: white;">
            <div style="width: 130px; height: 130px; background: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 25px; box-shadow: 0 15px 35px rgba(0,0,0,0.15);">
                <i class="fas fa-user" style="font-size: 4rem; color: #A6C21B;"></i>
            </div>
            <c:forEach var="c" items="${coordinadorData.rows}">
                <h2 style="font-size: 2rem; margin-bottom: 10px; letter-spacing: -0.5px;">${c.nombre} ${c.apellido}</h2>
                <p style="opacity: 0.95; font-size: 1.05rem;"><i class="fas fa-badge"></i> Coordinador del Sistema</p>
            </c:forEach>
        </div>
        
        <div style="padding: 40px;">
            <c:forEach var="c" items="${coordinadorData.rows}">
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
                                    <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">${c.nombre} ${c.apellido}</p>
                                </div>
                            </div>
                            <div style="display: flex; align-items: center; gap: 18px; padding: 12px 0; border-bottom: 1px solid #E9ECEF;">
                                <div style="width: 45px; height: 45px; background: #E8F5E9; border-radius: 15px; display: flex; align-items: center; justify-content: center;">
                                    <i class="fas fa-envelope" style="font-size: 1.3rem; color: #A6C21B;"></i>
                                </div>
                                <div>
                                    <p style="font-size: 0.75rem; color: #8BA0AE; margin-bottom: 3px;">Correo electrónico</p>
                                    <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">${c.email}</p>
                                </div>
                            </div>
                            <div style="display: flex; align-items: center; gap: 18px; padding: 12px 0;">
                                <div style="width: 45px; height: 45px; background: #E8F5E9; border-radius: 15px; display: flex; align-items: center; justify-content: center;">
                                    <i class="fas fa-user-tag" style="font-size: 1.3rem; color: #A6C21B;"></i>
                                </div>
                                <div>
                                    <p style="font-size: 0.75rem; color: #8BA0AE; margin-bottom: 3px;">Rol en el sistema</p>
                                    <p><span style="background:#A6C21B; color:white; padding: 5px 16px; border-radius: 30px; font-size: 0.8rem; font-weight: 600;">Coordinador</span></p>
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
                                    <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">${fn:substring(c.fecha_registro,8,10)}/${fn:substring(c.fecha_registro,5,7)}/${fn:substring(c.fecha_registro,0,4)} ${fn:substring(c.fecha_registro,11,16)}</p>
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
                                    <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">Gestión completa de proyectos</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
            
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
                <input type="hidden" name="id" value="${idCoordinador}">
                <input type="hidden" name="sec" value="perfil">
                
                <div style="margin-bottom: 22px;">
                    <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Nombre</label>
                    <c:forEach var="c" items="${coordinadorData.rows}">
                        <input type="text" name="nombre" value="${c.nombre}" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                    </c:forEach>
                </div>
                <div style="margin-bottom: 22px;">
                    <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Apellido</label>
                    <c:forEach var="c" items="${coordinadorData.rows}">
                        <input type="text" name="apellido" value="${c.apellido}" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                    </c:forEach>
                </div>
                <div style="margin-bottom: 22px;">
                    <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Correo Electrónico</label>
                    <c:forEach var="c" items="${coordinadorData.rows}">
                        <input type="email" name="email" value="${c.email}" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                    </c:forEach>
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
                <input type="hidden" name="id" value="${idCoordinador}">
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
        
    </main>
</div>

<!-- Modal Asignar Docente -->


<script>
    var menuToggle = document.getElementById('menuToggle');
    var sidebar = document.getElementById('sidebar');
    if (menuToggle) { menuToggle.onclick = function() { sidebar.classList.toggle('open'); }; }
    
    function mostrarTabIdea(tab) {
        document.getElementById('tab-pendientes').style.display = 'none';
        document.getElementById('tab-aprobadas').style.display = 'none';
        document.getElementById('tab-rechazadas').style.display = 'none';
        document.getElementById('tab-' + tab).style.display = 'block';
        var btns = document.querySelectorAll('.tab-btn');
        btns.forEach(function(btn) { btn.classList.remove('active'); });
        event.target.classList.add('active');
    }
    
    function abrirModalAsignarDocente(proyectoId, cargo, docenteActualId) {
    document.getElementById('asignar_proyecto_id').value = proyectoId;
    document.getElementById('asignar_cargo').value = cargo;
    
    // Cambiar el título del modal según el cargo
    var titulo = (cargo === 'director') ? 'Director' : 'Evaluador';
    document.getElementById('modalCargoTitle').innerText = titulo;
    
    // Limpiar el select
    var select = document.getElementById('asignar_docente_id');
    select.value = '';
    
    // Si hay un docente actual, mostrarlo pero permitir cambio
    if (docenteActualId) {
        // Opcional: marcar el docente actual en el select
        for (var i = 0; i < select.options.length; i++) {
            if (select.options[i].value == docenteActualId) {
                select.options[i].selected = true;
                break;
            }
        }
    }
    
    document.getElementById('modalAsignarDocente').style.display = 'flex';
}

function cerrarModalAsignarDocente() {
    document.getElementById('modalAsignarDocente').style.display = 'none';
}
    
    // Cerrar modal al hacer clic fuera
    window.onclick = function(event) {
        var modal = document.getElementById('modalAsignarDocente');
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    }

    
function cerrarModalProyecto() {
    document.getElementById('modalDetalleProyecto').style.display = 'none';
}

// Cerrar modal al hacer clic fuera
window.onclick = function(event) {
    var modal = document.getElementById('modalDetalleProyecto');
    if (event.target == modal) {
        cerrarModalProyecto();
    }
}

function abrirModalCrearIdea() {
    document.getElementById('modalCrearIdea').style.display = 'flex';
}

function cerrarModalCrearIdea() {
    document.getElementById('modalCrearIdea').style.display = 'none';
}

// Cerrar modal al hacer clic fuera
window.onclick = function(event) {
    var modalCrear = document.getElementById('modalCrearIdea');
    var modalDetalle = document.getElementById('modalDetalleProyecto');
    var modalAsignar = document.getElementById('modalAsignarDocente');
    
    if (event.target == modalCrear) {
        modalCrear.style.display = 'none';
    }
    if (event.target == modalDetalle) {
        modalDetalle.style.display = 'none';
    }
    if (event.target == modalAsignar) {
        modalAsignar.style.display = 'none';
    }
}

function mostrarTabProyecto(tab) {
    // Ocultar todas las pestañas
    document.getElementById('tab-proyectos-pendientes').style.display = 'none';
    document.getElementById('tab-proyectos-todos').style.display = 'none';
    document.getElementById('tab-proyectos-completos').style.display = 'none';
    
    // Mostrar la pestaña seleccionada
    document.getElementById('tab-proyectos-' + tab).style.display = 'block';
    
    // Actualizar estilos de los botones
    var btns = document.querySelectorAll('.tabs .tab-btn');
    btns.forEach(function(btn) {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
}

// Filtro de búsqueda para la tabla de todos los proyectos
document.getElementById('buscadorTabla').addEventListener('keyup', function() {
    var input = document.getElementById('buscadorTabla');
    var filter = input.value.toUpperCase();
    var table = document.getElementById('tablaTodosProyectos');
    var tr = table.getElementsByTagName('tr');
    
    for (var i = 1; i < tr.length; i++) {
        var tdTitulo = tr[i].getElementsByTagName('td')[1];
        var tdEstudiantes = tr[i].getElementsByTagName('td')[2];
        if (tdTitulo || tdEstudiantes) {
            var txtTitulo = tdTitulo ? tdTitulo.textContent || tdTitulo.innerText : '';
            var txtEstudiantes = tdEstudiantes ? tdEstudiantes.textContent || tdEstudiantes.innerText : '';
            if (txtTitulo.toUpperCase().indexOf(filter) > -1 || txtEstudiantes.toUpperCase().indexOf(filter) > -1) {
                tr[i].style.display = '';
            } else {
                tr[i].style.display = 'none';
            }
        }
    }
});

function abrirModalSubirFormato() {
    document.getElementById('modalSubirFormato').style.display = 'flex';
}

function cerrarModalSubirFormato() {
    document.getElementById('modalSubirFormato').style.display = 'none';
}

function eliminarFormato(id) {
    if (confirm('¿Estás seguro de eliminar este formato?')) {
        window.location.href = 'eliminar_formato.jsp?id=' + id + '&sec=formatos';
    }
}

function filtrarFormatos(tipo) {
    // Cambiar estilo de los botones
    var botones = document.querySelectorAll('#contenedorFormatos ~ div button, .section-card .action-btn.btn-outline');
    document.querySelectorAll('[id^="filtro"]').forEach(function(btn) {
        btn.style.background = '';
        btn.style.color = '#A6C21B';
    });
    
    if (tipo === 'todos') {
        document.getElementById('filtroTodos').style.background = '#A6C21B';
        document.getElementById('filtroTodos').style.color = 'white';
    } else if (tipo === 'formato') {
        document.getElementById('filtroFormato').style.background = '#A6C21B';
        document.getElementById('filtroFormato').style.color = 'white';
    } else if (tipo === 'guia') {
        document.getElementById('filtroGuia').style.background = '#A6C21B';
        document.getElementById('filtroGuia').style.color = 'white';
    } else if (tipo === 'reglamento') {
        document.getElementById('filtroReglamento').style.background = '#A6C21B';
        document.getElementById('filtroReglamento').style.color = 'white';
    } else if (tipo === 'acta') {
        document.getElementById('filtroActa').style.background = '#A6C21B';
        document.getElementById('filtroActa').style.color = 'white';
    } else if (tipo === 'otro') {
        document.getElementById('filtroOtro').style.background = '#A6C21B';
        document.getElementById('filtroOtro').style.color = 'white';
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

function abrirModalEditarPerfil() {
    document.getElementById('modalEditarPerfil').style.display = 'flex';
}

function cerrarModalPerfil() {
    document.getElementById('modalEditarPerfil').style.display = 'none';
}

function abrirModalCambiarPassword() {
    document.getElementById('modalCambiarPassword').style.display = 'flex';
    document.getElementById('password_error').style.display = 'none';
    document.getElementById('password_nueva').value = '';
    document.getElementById('password_confirm').value = '';
}

function cerrarModalPassword() {
    document.getElementById('modalCambiarPassword').style.display = 'none';
}

// Validar contraseñas en el modal de cambio
var formPassword = document.querySelector('#modalCambiarPassword form');
if (formPassword) {
    formPassword.addEventListener('submit', function(e) {
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
    
    fetch('buscar_usuario_por_email.jsp?email=' + encodeURIComponent(email))
        .then(function(response) {
            return response.json();
        })
        .then(function(data) {
            if (data.existe) {
                infoDiv.innerHTML = '<span style="color:#A6C21B;"><i class="fas fa-check-circle"></i> ' + 
                                    data.nombre + ' ' + data.apellido + 
                                    ' (' + data.rol + ')</span>';
                destinatarioId.value = data.id;
                btnEnviar.disabled = false;
            } else {
                infoDiv.innerHTML = '<span style="color:#DC3545;"><i class="fas fa-times-circle"></i> Usuario no encontrado</span>';
                destinatarioId.value = '';
                btnEnviar.disabled = true;
            }
        })
        .catch(function(error) {
            infoDiv.innerHTML = '<span style="color:#DC3545;">Error al buscar</span>';
            btnEnviar.disabled = true;
        });
}

function validarFormMensaje() {
    var destinatarioId = document.getElementById('destinatario_id').value;
    var asunto = document.getElementById('asunto').value;
    var mensaje = document.getElementById('mensaje').value;
    
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
</script>

<iframe name="submitFrame" style="display:none;"></iframe>
</body>
</html>
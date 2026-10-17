<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="es_CO" />

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<c:set var="rolRequerido" value="evaluador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>

<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<%@ include file="/WEB-INF/fragments/bloqueo_plazos.jspf" %>
<c:set var="nombresFase" value="${fn:split('Pago,Propuesta I,Propuesta II,Informe I,Informe II,Cierre', ',')}" />
<c:set var="seccionActual" value="${param.sec != null ? param.sec : 'dashboard'}" />
<c:set var="idDocente" value="${sessionScope.idUsuario}" />

<jsp:useBean id="fechaActual" class="java.util.Date" />

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Evaluador - UTS</title>
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
        .stats-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 30px; }
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
        .badge-director { background: #FD7E14; color: white; }
        .badge-evaluador { background: #17A2B8; color: white; }
        .banner-fecha {
            background: linear-gradient(135deg, var(--color-principal) 0%, var(--color-principal-hover) 100%);
            border-radius: 24px;
            padding: 20px 25px;
            margin-bottom: 30px;
            color: white;
        }
        .proyecto-card {
            background: #F8FAFE;
            border-radius: 20px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 4px solid var(--color-principal);
            transition: all 0.3s;
        }
        .proyecto-card:hover { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(0,0,0,0.08); }
        .avance-item {
            background: white;
            border-radius: 16px;
            padding: 15px;
            margin-bottom: 12px;
            border: 1px solid #E9ECEF;
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
            max-width: 600px;
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
        .empty-state { text-align: center; padding: 60px 20px; background: #F8FAFE; border-radius: 20px; color: #ADB5BD; }
        .empty-state i { font-size: 3rem; margin-bottom: 15px; }
        @media (max-width: 992px) {
            .stats-grid { grid-template-columns: 1fr; }
            .menu-toggle { display: block; }
            .sidebar { transform: translateX(-280px); }
            .sidebar.open { transform: translateX(0); }
            .main-content { margin-left: 0; }
        }
        @media (max-width: 768px) {
            .main-content { padding: 20px; }
        }

        .proyecto-evaluacion-card {
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .proyecto-evaluacion-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(0,0,0,0.1);
        }
        .form-evaluacion label:hover {
            background: #F0F2F5;
            transition: all 0.2s;
        }
        .form-evaluacion input[type="radio"] {
            accent-color: #A6C21B;
            width: 18px;
            height: 18px;
        }
        .proyecto-director-card {
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .proyecto-director-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(0,0,0,0.1);
        }
        .avance-item {
            transition: all 0.2s;
        }
        .avance-item:hover {
            background: #F0F2F5;
        }
        .form-evaluacion label:hover,
        .avance-item select:hover {
            cursor: pointer;
        }
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
                <li><a href="dashboard.jsp?sec=evaluador" class="${seccionActual == 'evaluador' ? 'active' : ''}"><i class="fas fa-clipboard-user"></i> Proyectos como Evaluador</a></li>
                <li><a href="dashboard.jsp?sec=formatos" class="${seccionActual == 'formatos' ? 'active' : ''}"><i class="fas fa-cloud-arrow-down"></i> Base documental</a></li>
                <li><a href="dashboard.jsp?sec=calendario" class="${seccionActual == 'calendario' ? 'active' : ''}"><i class="fas fa-calendar-days"></i> Calendario Académico</a></li>
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
            <sql:query dataSource="${dataSource}" var="res">
                SELECT (SELECT COUNT(*) FROM proyectos WHERE evaluador_id = ? AND cancelado = 0 AND fase_actual >= 3 AND estado_fase NOT IN ('Rechazado','Finalizado')) AS asignados,
                       (SELECT COUNT(*) FROM proyectos WHERE evaluador_id = ? AND cancelado = 0 AND bloqueado = 0 AND estado_fase = 'En revisión' AND responsable = 'Evaluador') AS pendientes
                <sql:param value="${idDocente}" /><sql:param value="${idDocente}" />
            </sql:query>
            <c:set var="rs" value="${res.rows[0]}" />
            <div class="section-card tg-inicio">
                <h2 class="tg-titulo">SISTEMA - TRABAJOS DE <span>GRADO</span></h2>
                <p class="tg-sub" style="text-align:left;margin-top:14px;">Bienvenido al portal de sistemas trabajo de grado, aquí podrás acceder a:</p>
                <div class="tg-cards">
                    <a class="tg-card" href="dashboard.jsp?sec=evaluador"><c:if test="${rs.pendientes > 0}"><span class="tg-n">${rs.pendientes}</span></c:if><i class="fas fa-clipboard-user"></i><strong>Proyectos como Evaluador</strong><small>${rs.asignados} proyectos asignados. Evalúa con la rejilla la propuesta y el informe (5 días por revisión).</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=formatos"><i class="fas fa-book-open"></i><strong>Base Documental</strong><small>Accede a toda la información documental organizada de manera eficiente.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=calendario"><i class="fas fa-calendar-days"></i><strong>Calendario Académico</strong><small>Consulta las fechas importantes y eventos académicos.</small></a>
                    <a class="tg-card" href="dashboard.jsp?sec=mensajes"><i class="fas fa-envelope"></i><strong>Mensajes</strong><small>Comunicación interna con docentes, Comité y estudiantes.</small></a>
                </div>
            </div>
        </c:if>
        <!-- ==================== SECCIÓN: EVALUADOR ==================== -->
        <c:if test="${seccionActual == 'evaluador'}">

            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><i class="fas fa-exclamation-triangle"></i> <c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> Listo, quedó registrado.</div></c:if>
            <c:set var="tgVolver" value="dashboard.jsp?sec=evaluador" /><c:set var="tgPlagio" value="" /><c:set var="tgRol" value="evaluador" />
            <c:if test="${not empty param.ver}">
                <sql:query dataSource="${dataSource}" var="pq">SELECT p.*, DATEDIFF(DATE(p.fecha_limite_revision), CURDATE()) AS dias_restantes FROM proyectos p WHERE p.id = ? AND p.evaluador_id = ? AND p.cancelado = 0 AND p.fase_actual >= 3
                    <sql:param value="${param.ver}" /><sql:param value="${idDocente}" /></sql:query>
            </c:if>
            <c:choose>
            <c:when test="${not empty param.ver and not empty pq.rows}">
                <c:set var="pp" value="${pq.rows[0]}" />
                <sql:query dataSource="${dataSource}" var="ents">SELECT fase, tipo, version, url, fecha, estudiante_id, (SELECT CONCAT(nombre, ' ', COALESCE(apellido, '')) FROM usuarios WHERE id = entrega.estudiante_id) AS estudiante FROM entrega WHERE proyecto_id = ? ORDER BY fecha DESC, id DESC<sql:param value="${pp.id}" /></sql:query>
                <sql:query dataSource="${dataSource}" var="revs">SELECT r.fase, r.rol_revisor, r.estado, r.observacion, r.fecha, CONCAT(u.nombre, ' ', COALESCE(u.apellido, '')) AS revisor FROM revision r JOIN usuarios u ON u.id = r.revisor_id WHERE r.proyecto_id = ? ORDER BY r.fecha DESC, r.id DESC<sql:param value="${pp.id}" /></sql:query>
                <%@ include file="/WEB-INF/fragments/tg_seguimiento.jspf" %>
                <c:if test="${pp.bloqueado == 1}"><div class="section-card"><p class="tg-sub" style="color:#C0392B;margin:0">Proyecto bloqueado: <c:out value="${pp.motivo_bloqueo}" /></p></div></c:if>
            </c:when>
            <c:otherwise>
            <c:set var="q" value="${fn:trim(param.q)}" /><c:set var="patron" value="%${q}%" />
            <sql:query dataSource="${dataSource}" var="lista">
                SELECT p.id, p.codigo, p.titulo, p.fase_actual, p.estado_fase, p.responsable, p.bloqueado, p.cancelado, p.fecha_limite_revision,
                       DATEDIFF(DATE(p.fecha_limite_revision), CURDATE()) AS dias
                  FROM proyectos p WHERE p.evaluador_id = ? AND p.cancelado = 0 AND p.fase_actual >= 3
                 ORDER BY (p.responsable = 'Evaluador' AND p.estado_fase = 'En revisión') DESC, p.id DESC
                <sql:param value="${idDocente}" />
            </sql:query>
            <c:if test="${not empty param.info}"><c:set var="idInfo" value="${param.info}" /><c:set var="tgCerrar" value="dashboard.jsp?sec=evaluador" /><%@ include file="/WEB-INF/fragments/tg_detalle.jspf" %></c:if>
            <div class="section-card">
                <h2 class="tg-titulo">Proyectos de <span>GRADO</span></h2>
                <p class="tg-sub">Solo ves los proyectos que el director ya aprobó.</p>
                <div style="overflow-x:auto"><table class="tg-tabla" data-tg>
                    <thead><tr><th>ID</th><th>Descripción</th><th class="cen">Estado</th><th class="cen">Plazo</th><th class="cen">Acciones</th></tr></thead><tbody>
                    <c:forEach var="p" items="${lista.rows}"><tr>
                        <td>GRA-${fn:substring(100000 + p.id, 1, 6)}</td><td><c:out value="${p.titulo}" /></td>
                        <td class="cen"><c:choose><c:when test="${p.estado_fase == 'Finalizado'}"><span class="tg-badge ok">Finalizado</span></c:when><c:when test="${p.estado_fase == 'Rechazado'}"><span class="tg-badge mal">Rechazada</span></c:when>
                            <c:otherwise><span class="tg-badge fase">Fase ${p.fase_actual}</span><span class="tg-badge resp">${p.responsable}</span><c:if test="${p.bloqueado == 1}"><span class="tg-badge mal">Bloqueado</span></c:if></c:otherwise></c:choose></td>
                        <td class="cen"><c:if test="${p.estado_fase == 'En revisión' and p.responsable == 'Evaluador' and not empty p.fecha_limite_revision}"><span style="${p.dias <= 2 ? 'color:#C0392B;font-weight:700;' : ''}">${fn:substring(p.fecha_limite_revision,8,10)}/${fn:substring(p.fecha_limite_revision,5,7)}/${fn:substring(p.fecha_limite_revision,0,4)} (<c:choose><c:when test="${p.dias < 0}">vencido</c:when><c:otherwise>${p.dias} d</c:otherwise></c:choose>)</span></c:if></td>
                        <td class="acc cen"><a class="tg-ico pizarra" href="dashboard.jsp?sec=evaluador&info=${p.id}" title="Ver detalles" aria-label="Ver detalles"><i class="far fa-eye"></i></a>
                            <a class="tg-ico azul" href="dashboard.jsp?sec=evaluador&ver=${p.id}" title="Seguimiento del proyecto" aria-label="Seguimiento del proyecto"><i class="fas fa-briefcase"></i></a></td></tr></c:forEach>
                    </tbody></table></div>
            </div>
            </c:otherwise>
            </c:choose>
        </c:if>
        <!-- ==================== SECCIÓN: FORMATOS ==================== -->
        <c:if test="${seccionActual == 'formatos'}">

            <sql:query dataSource="${dataSource}" var="docs">SELECT id, nombre, descripcion, ruta_archivo, tipo FROM formatos_grado WHERE activo = 1 ORDER BY id</sql:query>
            <div class="section-card">
                <h2 class="tg-titulo">Base <span>DOCUMENTAL</span></h2>
                <p class="tg-sub">Aquí podrás acceder a la información institucional vigente para tener en cuenta durante el desarrollo del proyecto de grado:</p>
                <div class="tg-cards">
                    <c:forEach var="d" items="${docs.rows}">
                        <a class="tg-card" href="<c:out value='${d.ruta_archivo}'/>" target="_blank" rel="noopener noreferrer">
                            <i class="fas ${d.tipo == 'reglamento' ? 'fa-list-check' : (d.tipo == 'guia' ? 'fa-book' : 'fa-file-lines')}"></i>
                            <strong><c:out value="${d.nombre}" /></strong><small><c:out value="${d.descripcion}" /></small></a>
                    </c:forEach>
                </div>
                <c:if test="${empty docs.rows}"><p>Aún no hay documentos registrados.</p></c:if>
            </div>
        </c:if>


        
        <!-- ==================== CALENDARIO ==================== -->
        <c:if test="${seccionActual == 'calendario'}">
            <div class="banner-fecha">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                    <div>
                        <h2 style="font-size: 1.3rem;"><i class="fas fa-calendar-alt"></i> Calendario Académico</h2>
                        <p>Consulta las fechas importantes del calendario académico</p>
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
                SELECT id, titulo, descripcion, fecha_evento, tipo FROM calendario_academico 
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
        <a href="dashboard.jsp?sec=calendario&mes=${mesPrevCal}&año=${añoPrevCal}" class="action-btn" style="background:#6C757D; color:white;">
            <i class="fas fa-chevron-left"></i> Mes anterior
        </a>
        <a href="dashboard.jsp?sec=calendario&mes=${mesNextCal}&año=${añoNextCal}" class="action-btn" style="background:#6C757D; color:white;">
            Mes siguiente <i class="fas fa-chevron-right"></i>
        </a>
        <a href="https://www.uts.edu.co/sitio/calendario-academico" target="_blank" class="action-btn btn-outline">
            <i class="fas fa-external-link-alt"></i> Calendario UTS
        </a>
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
                                <c:if test="${not empty e.descripcion}">
                                    <p style="font-size: 0.75rem; color: #6C757D; margin-top: 5px;">${e.descripcion}</p>
                                </c:if>
                            </div>
                            <div>
                                <span class="badge" style="background:#E0F2FE; color:#0284C7;">${e.tipo}</span>
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
                        if (eventos[d]) { div.classList.add('evento'); }
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
        </c:if>
        
                <!-- ==================== MENSAJES ==================== -->
        <c:if test="${seccionActual == 'mensajes'}">
            <div class="banner-fecha">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                    <div>
                        <h2 style="font-size: 1.3rem;"><i class="fas fa-envelope"></i> Mensajería Interna</h2>
                        <p>Comunicación con administradores, coordinadores y estudiantes</p>
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
                        SELECT COUNT(*) as total FROM mensajes WHERE destinatario_id = ? AND (leido = 0 OR leido IS NULL)
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
                        WHERE m.destinatario_id = ? AND (m.eliminado_destinatario IS NULL OR m.eliminado_destinatario = 0)
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
                                        <span class="badge" style="background:#E0F2FE; color:#0284C7; margin-left: 8px;">${msg.rol}</span>
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
                        WHERE m.remitente_id = ? AND (m.eliminado_remitente IS NULL OR m.eliminado_remitente = 0)
                        ORDER BY m.fecha_envio DESC
                        <sql:param value="${sessionScope.idUsuario}" />
                    </sql:query>
                    
                    <c:forEach var="msg" items="${mensajesEnviados.rows}">
                        <div class="mensaje-card" style="background: #F8FAFE; border-radius: 16px; padding: 18px; margin-bottom: 12px; border-left: 4px solid #17A2B8; cursor: pointer;" onclick="verMensaje(${msg.id}, 'enviado')">
                            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap;">
                                <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                                    <strong style="color:#2C3E50;">
                                        <i class="fas fa-user"></i> Para: ${msg.nombre} ${msg.apellido}
                                        <span class="badge" style="background:#E0F2FE; color:#0284C7; margin-left: 8px;">${msg.rol}</span>
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
        
        <!-- ==================== PERFIL ==================== -->
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
            
            <sql:query dataSource="${dataSource}" var="docenteData">
                SELECT nombre, apellido, email, fecha_registro FROM usuarios WHERE id = ?
                <sql:param value="${idDocente}" />
            </sql:query>
            
            <div class="section-card" style="padding: 0; overflow: hidden; margin-bottom: 30px;">
                <div style="background: linear-gradient(135deg, #A6C21B 0%, #8FAA10 100%); padding: 50px 30px; text-align: center; color: white;">
                    <div style="width: 130px; height: 130px; background: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 25px;">
                        <i class="fas fa-user" style="font-size: 4rem; color: #A6C21B;"></i>
                    </div>
                    <c:forEach var="d" items="${docenteData.rows}">
                        <h2 style="font-size: 2rem;">${d.nombre} ${d.apellido}</h2>
                        <p>Docente del Sistema</p>
                    </c:forEach>
                </div>
                
                <div style="padding: 40px;">
                    <c:forEach var="d" items="${docenteData.rows}">
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 30px;">
                            <div style="background: #F8FAFE; border-radius: 24px; padding: 30px;">
                                <h3>Información Personal</h3>
                                <div style="margin-top: 20px;">
                                    <p><strong>Nombre:</strong> ${d.nombre} ${d.apellido}</p>
                                    <p><strong>Email:</strong> ${d.email}</p>
                                    <p><strong>Rol:</strong> Docente</p>
                                </div>
                            </div>
                            <div style="background: #F8FAFE; border-radius: 24px; padding: 30px;">
                                <h3>Estadísticas</h3>
                                <div style="margin-top: 20px;">
                                    <p><strong>Fecha de registro:</strong> ${fn:substring(d.fecha_registro,8,10)}/${fn:substring(d.fecha_registro,5,7)}/${fn:substring(d.fecha_registro,0,4)} ${fn:substring(d.fecha_registro,11,16)}</p>
                                    <p><strong>Estado:</strong> Activo</p>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                    
                    <div style="margin-top: 40px; display: flex; gap: 20px; justify-content: center; flex-wrap: wrap;">
                        <button onclick="abrirModalEditarPerfil()" class="action-btn" style="background:#A6C21B;">Editar mi perfil</button>
                        <button onclick="abrirModalCambiarPassword()" class="action-btn" style="background:#6C757D;">Cambiar contraseña</button>
                        <a href="dashboard.jsp?sec=dashboard" class="action-btn" style="background:#17A2B8;">Volver al Dashboard</a>
                    </div>
                </div>
            </div>
            
            <!-- Modal para editar perfil -->
            <div id="modalEditarPerfil" class="modal">
                <div class="modal-content" style="max-width: 550px;">
                    <button class="modal-close" onclick="cerrarModalPerfil()">&times;</button>
                    <h3>Editar Perfil</h3>
                    <form action="guardar_perfil.jsp" method="post">
                        <input type="hidden" name="id" value="${idDocente}">
                        <input type="hidden" name="sec" value="perfil">
                        <c:forEach var="d" items="${docenteData.rows}">
                            <div style="margin-bottom: 15px;">
                                <label>Nombre</label>
                                <input type="text" name="nombre" value="${d.nombre}" required class="form-control">
                            </div>
                            <div style="margin-bottom: 15px;">
                                <label>Apellido</label>
                                <input type="text" name="apellido" value="${d.apellido}" required class="form-control">
                            </div>
                            <div style="margin-bottom: 15px;">
                                <label>Email</label>
                                <input type="email" name="email" value="${d.email}" required class="form-control">
                            </div>
                        </c:forEach>
                        <div style="margin-bottom: 15px;">
                            <label>Nueva Contraseña (opcional)</label>
                            <input type="password" name="password" class="form-control">
                        </div>
                        <button type="submit" class="action-btn" style="width:100%;">Guardar Cambios</button>
                    </form>
                </div>
            </div>

            <!-- Modal para cambiar contraseña -->
            <div id="modalCambiarPassword" class="modal">
                <div class="modal-content" style="max-width: 450px;">
                    <button class="modal-close" onclick="cerrarModalPassword()">&times;</button>
                    <h3>Cambiar Contraseña</h3>
                    <form action="cambiar_password.jsp" method="post">
                        <input type="hidden" name="id" value="${idDocente}">
                        <input type="hidden" name="sec" value="perfil">
                        <div style="margin-bottom: 15px;">
                            <label>Contraseña actual</label>
                            <input type="password" name="password_actual" required class="form-control">
                        </div>
                        <div style="margin-bottom: 15px;">
                            <label>Nueva contraseña</label>
                            <input type="password" name="password_nueva" id="password_nueva" required class="form-control">
                        </div>
                        <div style="margin-bottom: 15px;">
                            <label>Confirmar nueva contraseña</label>
                            <input type="password" name="password_confirm" id="password_confirm" required class="form-control">
                            <span id="password_error" style="color: #DC3545; display: none;">Las contraseñas no coinciden</span>
                        </div>
                        <button type="submit" class="action-btn" style="width:100%;">Cambiar Contraseña</button>
                    </form>
                </div>
            </div>
        </c:if>
        
        
    </main>
</div>

<script>
    var menuToggle = document.getElementById('menuToggle');
    var sidebar = document.getElementById('sidebar');
    if (menuToggle) { menuToggle.onclick = function() { sidebar.classList.toggle('open'); }; }
    
    function verDetalleProyecto(id) {
        window.location.href = 'ver_proyecto.jsp?id=' + id;
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
    }
    
    function cerrarModalPassword() {
        document.getElementById('modalCambiarPassword').style.display = 'none';
    }
    
    function calificarAnteproyecto(proyectoId) {
    document.getElementById('calificar_proyecto_id').value = proyectoId;
    document.getElementById('modalCalificarAnteproyecto').style.display = 'flex';
}

function cerrarModalCalificar() {
    document.getElementById('modalCalificarAnteproyecto').style.display = 'none';
}

// Cerrar modal si haces clic fuera
window.onclick = function(event) {
    var modal = document.getElementById('modalCalificarAnteproyecto');
    if (event.target == modal) {
        modal.style.display = 'none';
    }
}
    
    // Validar contraseñas
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

</script>

<script>
    // Función para cambiar entre pestañas de mensajes
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


<!-- Modal para calificar anteproyecto (VERSIÓN BONITA) -->

</body>
</html>
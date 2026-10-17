<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="es_CO" />

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<c:set var="rolRequerido" value="estudiante" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>

<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<c:set var="estId" value="${sessionScope.idUsuario}" />
<%@ include file="/WEB-INF/fragments/estado_proyecto.jspf" %>

<c:set var="seccionActual" value="${param.sec != null ? param.sec : 'dashboard'}" />
<c:set var="idEstudiante" value="${sessionScope.idUsuario}" />
<c:set var="nombresFase" value="${fn:split('Pago,Propuesta I,Propuesta II,Informe I,Informe II,Cierre', ',')}" />

<jsp:useBean id="fechaActual" class="java.util.Date" />

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Estudiante - UTS</title>
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
        .badge-pendiente { background: #FEF3C7; color: #D97706; }
        .badge-aprobado { background: #D1FAE5; color: #059669; }
        .badge-info { background: #E0F2FE; color: #0284C7; }
        .banner-fecha {
            background: linear-gradient(135deg, var(--color-principal) 0%, var(--color-principal-hover) 100%);
            border-radius: 24px;
            padding: 20px 25px;
            margin-bottom: 30px;
            color: white;
        }
        .paso-activo { background: #A6C21B; color: white; padding: 4px 12px; border-radius: 20px; font-size: 0.7rem; }
        .paso-inactivo { background: #E9ECEF; color: #6C757D; padding: 4px 12px; border-radius: 20px; font-size: 0.7rem; }
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
        @media (max-width: 992px) {
            .menu-toggle { display: block; }
            .sidebar { transform: translateX(-280px); }
            .sidebar.open { transform: translateX(0); }
            .main-content { margin-left: 0; }
        }
        @media (max-width: 768px) {
            .main-content { padding: 20px; }
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
                <li><a href="dashboard.jsp?sec=seleccionarIdea" class="${seccionActual == 'seleccionarIdea' ? 'active' : ''}"><i class="fas fa-book"></i> Banco de ideas</a></li>
                <li><a href="dashboard.jsp?sec=misIdeas" class="${seccionActual == 'misIdeas' ? 'active' : ''}"><i class="fas fa-lightbulb"></i> Propuestas Banco</a></li>
                <li><a href="dashboard.jsp?sec=historial" class="${seccionActual == 'historial' ? 'active' : ''}"><i class="fas fa-clock-rotate-left"></i> Historial</a></li>
                <li><a href="dashboard.jsp?sec=calendario" class="${seccionActual == 'calendario' ? 'active' : ''}"><i class="fas fa-calendar-days"></i> Calendario</a></li>
                <li><a href="dashboard.jsp?sec=formatos" class="${seccionActual == 'formatos' ? 'active' : ''}"><i class="fas fa-cloud-arrow-down"></i> Base documental</a></li>
            </ul>
        </div>
        <div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/logout.jsp" class="logout-sidebar" onclick="return confirm('¿Cerrar sesión?')"><i class="fas fa-sign-out-alt"></i> Cerrar sesión</a></li>
            </ul>
        </div>
    </aside>
    
    <main class="main-content">
        <%@ include file="/WEB-INF/fragments/tg_header.jspf" %>
        
        <!-- ==================== SECCIÓN: DASHBOARD ==================== -->
        <c:if test="${seccionActual == 'dashboard'}">
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><i class="fas fa-exclamation-triangle"></i> <c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'proyecto_creado' or param.msg == 'entrega_ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> ${param.msg == 'entrega_ok' ? 'Documentos enviados: quedaron en revisión.' : 'Proyecto creado. Ya puedes subir el comprobante de pago en la fase 1.'}</div></c:if>
            
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><i class="fas fa-exclamation-triangle"></i> <c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'proyecto_creado' or param.msg == 'entrega_ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> Listo, quedó registrado.</div></c:if>
            <c:if test="${param.msg == 'pago_ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> Tu pago quedó registrado. Falta el pago de tu compañero para enviarlo al Comité.</div></c:if>
            <c:if test="${param.msg == 'prorroga_ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> Solicitud de prórroga enviada al Comité.</div></c:if>
            <c:choose><c:when test="${empty proy}">            <div class="section-card"><p>Aún no tienes un proyecto activo.</p><a href="dashboard.jsp?sec=seleccionarIdea" class="action-btn" style="margin-top:12px;">Elegir una idea</a></div></c:when><c:otherwise>
            <sql:query dataSource="${dataSource}" var="integrantes">
                SELECT u.nombre, u.apellido, u.cedula, EXISTS (SELECT 1 FROM entrega e WHERE e.proyecto_id = pe.proyecto_id AND e.fase = 1 AND e.tipo = 'Pago' AND e.estudiante_id = u.id AND e.fecha > COALESCE((SELECT MAX(r.fecha) FROM revision r WHERE r.proyecto_id = pe.proyecto_id AND r.fase = 1), '2000-01-01')) AS pago_reg FROM proyecto_estudiantes pe JOIN usuarios u ON u.id = pe.estudiante_id WHERE pe.proyecto_id = ?
                <sql:param value="${proy.id}" />
            </sql:query>
            <sql:query dataSource="${dataSource}" var="ultRev">
                SELECT rol_revisor, estado, observacion, fecha FROM revision WHERE proyecto_id = ? AND fase = ? ORDER BY id DESC LIMIT 1
                <sql:param value="${proy.id}" /><sql:param value="${proy.fase_actual}" />
            </sql:query>
            <c:set var="pp" value="${proy}" /><c:set var="tgEntrega" value="1" /><c:set var="tgSinVolver" value="1" /><c:set var="tgVolver" value="dashboard.jsp" /><c:set var="tgPlagio" value="" />
            <sql:query dataSource="${dataSource}" var="ents">SELECT fase, tipo, version, url, fecha, estudiante_id, (SELECT CONCAT(nombre, ' ', COALESCE(apellido, '')) FROM usuarios WHERE id = entrega.estudiante_id) AS estudiante FROM entrega WHERE proyecto_id = ? ORDER BY fecha DESC, id DESC<sql:param value="${proy.id}" /></sql:query>
            <sql:query dataSource="${dataSource}" var="revs">SELECT r.fase, r.rol_revisor, r.estado, r.observacion, r.fecha, CONCAT(u.nombre, ' ', COALESCE(u.apellido, '')) AS revisor FROM revision r JOIN usuarios u ON u.id = r.revisor_id WHERE r.proyecto_id = ? ORDER BY r.fecha DESC, r.id DESC<sql:param value="${proy.id}" /></sql:query>
            <%@ include file="/WEB-INF/fragments/tg_seguimiento.jspf" %>
            <div class="section-card">
                <div style="display:flex;justify-content:space-between;flex-wrap:wrap;gap:12px;">
                    <div><small>Código <strong><c:out value="${proy.codigo}" /></strong> · ${proy.modalidad} · Periodo ${proy.periodo_nombre}</small>
                        <h3 style="margin-top:6px;"><c:out value="${proy.titulo}" /></h3></div>
                    <div>
                        <c:if test="${proy.pagado == 1}"><span class="badge badge-aprobado">PAGADO</span></c:if>
                        <c:if test="${proy.bloqueado == 1}"><span class="badge" style="background:#FEE2E2;color:#B91C1C;">Bloqueado</span></c:if>
                        <c:if test="${proy.cancelado == 1}"><span class="badge" style="background:#FEE2E2;color:#B91C1C;">Cancelado</span></c:if>
                    </div>
                </div>
                
                <p><strong>Fase actual:</strong> ${proy.fase_actual}. ${nombresFase[proy.fase_actual-1]} &nbsp;·&nbsp;
                   <strong>Estado:</strong> <span class="badge ${proy.estado_fase == 'En revisión' ? 'badge-info' : (proy.estado_fase == 'Finalizado' ? 'badge-aprobado' : 'badge-pendiente')}">${proy.estado_fase}</span> &nbsp;·&nbsp;
                   <strong>Responsable:</strong> ${proy.responsable}</p>
                <c:if test="${proy.estado_fase == 'En revisión' and not empty proy.fecha_limite_revision}">
                    <p style="margin-top:8px;${proy.dias_restantes <= 2 ? 'color:#DC3545;font-weight:700;' : ''}">
                        <i class="fas fa-hourglass-half"></i> Fecha límite de respuesta: ${fn:substring(proy.fecha_limite_revision,8,10)}/${fn:substring(proy.fecha_limite_revision,5,7)}/${fn:substring(proy.fecha_limite_revision,0,4)}
                        (<c:choose><c:when test="${proy.dias_restantes < 0}">vencido</c:when><c:otherwise>${proy.dias_restantes} días restantes</c:otherwise></c:choose>)</p>
                </c:if>
                <c:if test="${not empty proy.fecha_sustentacion}"><p style="margin-top:8px;"><i class="fas fa-microphone"></i> Sustentación: ${fn:substring(proy.fecha_sustentacion,8,10)}/${fn:substring(proy.fecha_sustentacion,5,7)}/${fn:substring(proy.fecha_sustentacion,0,4)}</p></c:if>
                <p style="margin-top:8px;"><strong>Director:</strong> <c:out value="${empty proy.director_nombre ? 'Por asignar' : proy.director_nombre}" /> &nbsp;·&nbsp; <strong>Evaluador:</strong> <c:out value="${empty proy.evaluador_nombre ? 'Por asignar' : proy.evaluador_nombre}" /></p>
                <p style="margin-top:8px;"><strong>Integrantes:</strong>
                    <c:forEach var="i" items="${integrantes.rows}" varStatus="s"><c:out value="${i.nombre} ${i.apellido}" /> <span class="badge ${proy.pagado == 1 ? 'badge-aprobado' : (i.pago_reg == 1 ? 'badge-info' : 'badge-pendiente')}">${proy.pagado == 1 ? 'PAGADO' : (i.pago_reg == 1 ? 'Pago enviado' : 'Pago pendiente')}</span><c:if test="${not s.last}"> · </c:if></c:forEach></p>
                <c:if test="${not empty ultRev.rows and (proy.estado_fase == 'Aplazado' or proy.estado_fase == 'Rechazado')}">
                    <div style="margin-top:14px;padding:14px;border-radius:12px;background:#FEF3C7;border-left:4px solid #FD7E14;">
                        <strong>Observaciones de ${ultRev.rows[0].rol_revisor} (${ultRev.rows[0].estado}):</strong><br><c:out value="${ultRev.rows[0].observacion}" />
                    </div>
                </c:if>
                <c:if test="${proy.estado_fase == 'Rechazado' or proy.cancelado == 1}"><p style="margin-top:12px;">El proceso terminó: debes empezar de nuevo en otra modalidad desde el banco de ideas.</p></c:if>
                
            </div>
            <sql:query dataSource="${dataSource}" var="prorrogas">SELECT numero, estado, solo_correcciones, fecha_solicitud FROM prorroga WHERE proyecto_id = ? ORDER BY numero DESC<sql:param value="${proy.id}" /></sql:query>
            <c:set var="prAprob" value="0" /><c:set var="prPend" value="0" />
            <c:forEach var="r" items="${prorrogas.rows}"><c:if test="${r.estado == 'Aprobada'}"><c:set var="prAprob" value="${prAprob + 1}" /></c:if><c:if test="${r.estado == 'Pendiente'}"><c:set var="prPend" value="${prPend + 1}" /></c:if></c:forEach>
            <c:if test="${proy.cancelado == 0 and (proy.bloqueado == 1 and proy.motivo_bloqueo == 'Plazo de 180 días vencido' or not empty prorrogas.rows)}">
            <div class="section-card">
                <h3 style="margin-bottom:6px">Prórrogas (${prAprob} de 2 usadas)</h3>
                <c:forEach var="r" items="${prorrogas.rows}"><p style="font-size:.9rem">Prórroga ${r.numero}: <strong>${r.estado}</strong><c:if test="${r.solo_correcciones == 1}"> (solo correcciones)</c:if> · ${fn:substring(r.fecha_solicitud,8,10)}/${fn:substring(r.fecha_solicitud,5,7)}/${fn:substring(r.fecha_solicitud,0,4)}</p></c:forEach>
                <c:if test="${proy.bloqueado == 1 and proy.motivo_bloqueo == 'Plazo de 180 días vencido' and prPend == 0}">
                    <p class="tg-sub">Tu plazo de 180 días venció. Puedes pedir una prórroga de 180 días (máximo 2): adjunta el enlace de la carta y el de un nuevo pago.</p>
                    <form method="post" action="solicitar_prorroga.jsp" style="display:grid;gap:10px">
                        <label>Enlace de la carta<input type="url" name="urlCarta" required placeholder="https://..." class="tg-input" style="width:100%"></label>
                        <label>Enlace del nuevo pago<input type="url" name="urlPago" required placeholder="https://..." class="tg-input" style="width:100%"></label>
                        <label><input type="checkbox" name="soloCorrecciones" value="1"> La prórroga es solo para correcciones</label>
                        <div><button type="submit" class="tg-btn">Solicitar prórroga</button></div>
                    </form>
                </c:if>
                <c:if test="${prPend > 0}"><p class="tg-sub">Tu solicitud está pendiente de respuesta del Comité.</p></c:if>
            </div>
            </c:if>
            </c:otherwise></c:choose>
        </c:if>
        <!-- ==================== SECCIÓN: SELECCIONARIDEA ==================== -->
        <c:if test="${seccionActual == 'seleccionarIdea'}">
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><i class="fas fa-exclamation-triangle"></i> <c:out value="${param.err}" /></div></c:if>
            <sql:query dataSource="${dataSource}" var="yo">SELECT nivel, cedula FROM usuarios WHERE id = ?<sql:param value="${idEstudiante}" /></sql:query>
            <sql:query dataSource="${dataSource}" var="yaActivo">
                SELECT COUNT(*) AS n FROM proyecto_estudiantes pe JOIN usuarios u ON u.id = pe.estudiante_id JOIN proyectos p ON p.id = pe.proyecto_id
                 WHERE u.cedula = ? AND p.cancelado = 0 AND p.estado_fase <> 'Rechazado'
                <sql:param value="${yo.rows[0].cedula}" />
            </sql:query>
            <c:set var="puedeElegir" value="${yaActivo.rows[0].n == 0}" />
            <sql:query dataSource="${dataSource}" var="ideas">
                SELECT i.id, i.titulo, i.disponible, i.nivel, CONCAT(u.nombre, ' ', COALESCE(u.apellido, '')) AS autor,
                       (SELECT nombre FROM periodo_academico WHERE activo = 1 ORDER BY id DESC LIMIT 1) AS periodo
                  FROM ideas_proyecto i JOIN usuarios u ON u.id = i.creado_por
                 WHERE i.estado = 'aprobada' AND i.nivel = ? AND (i.origen = 'banco' OR i.creado_por = ?)
                 ORDER BY i.id DESC
                <sql:param value="${yo.rows[0].nivel}" /><sql:param value="${idEstudiante}" />
            </sql:query>
            <c:if test="${puedeElegir}">
                <sql:query dataSource="${dataSource}" var="companeros">
                    SELECT u.id, u.nombre, u.apellido FROM usuarios u
                     WHERE u.rol = 'estudiante' AND u.estado = 1 AND u.nivel = ? AND u.id <> ?
                       AND NOT EXISTS (SELECT 1 FROM proyecto_estudiantes pe JOIN proyectos p ON p.id = pe.proyecto_id WHERE pe.estudiante_id = u.id AND p.cancelado = 0 AND p.estado_fase <> 'Rechazado')
                     ORDER BY u.nombre
                    <sql:param value="${yo.rows[0].nivel}" /><sql:param value="${idEstudiante}" />
                </sql:query>
                <sql:query dataSource="${dataSource}" var="docentes">SELECT id, nombre, apellido FROM usuarios WHERE rol IN ('docente','evaluador') AND estado = 1 ORDER BY nombre</sql:query>
            </c:if>
            <div class="section-card">
                <h2 class="tg-titulo">Banco de <span>IDEAS</span></h2>
                <p class="tg-sub">Solo ves las ideas de tu mismo nivel. <c:choose><c:when test="${puedeElegir}">Pulsa «Elegir» en una idea disponible para iniciar tu proyecto.</c:when><c:otherwise>Ya perteneces a un proyecto activo, por eso no puedes elegir otra idea.</c:otherwise></c:choose></p>
                <div style="overflow-x:auto"><table class="tg-tabla" data-tg>
                    <thead><tr><th>ID</th><th>Título de la idea</th><th>Disponible</th><th>Periodo</th><th>Nivel</th><th>Docente</th><c:if test="${puedeElegir}"><th class="cen">Acciones</th></c:if></tr></thead><tbody>
                    <c:forEach var="i" items="${ideas.rows}"><tr>
                        <td>BAN-${fn:substring(100000 + i.id, 1, 6)}</td><td><c:out value="${i.titulo}" /></td>
                        <td><span class="tg-badge ${i.disponible == 1 ? 'ok' : 'mal'}">${i.disponible == 1 ? 'Sí' : 'No'}</span></td>
                        <td>${fn:replace(i.periodo, '.', '-')}</td><td>${i.nivel == 'tecnologia' ? 'Tecnológico' : 'Profesional'}</td><td><c:out value="${i.autor}" /></td>
                        <c:if test="${puedeElegir}"><td class="cen"><c:if test="${i.disponible == 1}"><button type="button" class="tg-btn" style="padding:5px 14px" data-elegir="${i.id}" data-titulo="<c:out value='${i.titulo}'/>">Elegir</button></c:if></td></c:if></tr></c:forEach>
                    </tbody></table></div>
            </div>
            <c:if test="${puedeElegir}">
            <div class="modal" id="tgModalElegir"><div class="modal-content" style="position:relative">
                <button type="button" class="tg-cerrar tg-cerrar-modal" aria-label="Cerrar">&times;</button>
                <div class="tg-modal-titulo">Iniciar <span>PROYECTO</span></div>
                <p class="tg-sub">Idea elegida: <strong id="tgElegirTitulo"></strong></p>
                <form method="post" action="guardarProyecto.jsp" style="display:grid;gap:12px">
                    <input type="hidden" name="ideaId" id="tgElegirId">
                    <label>Modalidad<select name="modalidad" class="tg-input"><option>Desarrollo tecnológico</option><option>Proyecto de investigación</option><option>Monografía</option></select></label>
                    <label>Compañero (máximo 2 integrantes; 3 si es interdisciplinario o robusto)<select name="companeroId" class="tg-input"><option value="0">No aplica</option>
                        <c:forEach var="comp" items="${companeros.rows}"><option value="${comp.id}"><c:out value="${comp.nombre} ${comp.apellido}" /></option></c:forEach></select></label>
                    <label>Tercer integrante (solo si es interdisciplinario o muy robusto)<select name="companero2Id" class="tg-input"><option value="0">No aplica</option>
                        <c:forEach var="comp" items="${companeros.rows}"><option value="${comp.id}"><c:out value="${comp.nombre} ${comp.apellido}" /></option></c:forEach></select></label>
                    <label>Motivo del tercer integrante<select name="motivoTercero" class="tg-input"><option value="">No aplica</option><option>Interdisciplinario</option><option>Proyecto robusto</option></select></label>
                    <label>Director sugerido (opcional, no vinculante)<select name="directorSugerido" class="tg-input"><option value="">Sin sugerencia</option>
                        <c:forEach var="d" items="${docentes.rows}"><option value="${d.id}"><c:out value="${d.nombre} ${d.apellido}" /></option></c:forEach></select></label>
                    <div style="text-align:right"><button type="button" class="tg-btn gris tg-cerrar-modal">Cancelar</button> <button type="submit" class="tg-btn">Iniciar proyecto</button></div>
                </form></div></div>
            </c:if>
        </c:if>
        <!-- ==================== SECCIÓN: MIS IDEAS ==================== -->
        <c:if test="${seccionActual == 'misIdeas'}">
            <div class="banner-fecha">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                    <div>
                        <h2 style="font-size: 1.3rem;"><i class="fas fa-lightbulb"></i> Mis Ideas de Proyecto</h2>
                        <p>Propón ideas de proyecto para que sean evaluadas por el coordinador</p>
                    </div>
                    <div>
                        <button onclick="abrirModalCrearIdea()" class="action-btn" style="background: #A6C21B; color: white;">
                            <i class="fas fa-plus"></i> Nueva Idea
                        </button>
                    </div>
                </div>
            </div>
            
            <div class="section-card">
                <sql:query dataSource="${dataSource}" var="misIdeas">
                    SELECT i.id, i.titulo, i.descripcion, i.estado, i.fecha_creacion, i.comentario_coordinador
                    FROM ideas_proyecto i
                    WHERE i.creado_por = ?
                    ORDER BY i.fecha_creacion DESC
                    <sql:param value="${idEstudiante}" />
                </sql:query>
                
                <c:forEach var="idea" items="${misIdeas.rows}">
                    <div class="idea-card" style="background: #F8FAFE; border-radius: 20px; padding: 20px; margin-bottom: 20px; border-left: 4px solid #FD7E14;">
                        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; margin-bottom: 10px;">
                            <h4>${idea.titulo}</h4>
                            <c:choose>
                                <c:when test="${idea.estado == 'aprobada'}"><span class="badge badge-aprobado">✅ Aprobada</span></c:when>
                                <c:when test="${idea.estado == 'rechazada'}"><span class="badge badge-rechazado">❌ Rechazada</span></c:when>
                                <c:otherwise><span class="badge badge-pendiente">⏳ Pendiente</span></c:otherwise>
                            </c:choose>
                        </div>
                        <p style="margin: 10px 0;">${idea.descripcion}</p>
                        <small><i class="fas fa-calendar-alt"></i> ${fn:substring(idea.fecha_creacion,8,10)}/${fn:substring(idea.fecha_creacion,5,7)}/${fn:substring(idea.fecha_creacion,0,4)} ${fn:substring(idea.fecha_creacion,11,16)}</small>
                        <c:if test="${not empty idea.comentario_coordinador}">
                            <div style="margin-top: 15px; padding: 12px; background: #FFF3E0; border-radius: 12px;">
                                <i class="fas fa-comment"></i> <strong>Comentario del coordinador:</strong> ${idea.comentario_coordinador}
                            </div>
                        </c:if>
                    </div>
                </c:forEach>
                
                <c:if test="${empty misIdeas.rows}">
                    <div style="text-align: center; padding: 60px;">
                        <i class="fas fa-lightbulb" style="font-size: 3rem; color: #ADB5BD;"></i>
                        <p>No has propuesto ninguna idea.</p>
                        <button onclick="abrirModalCrearIdea()" class="action-btn" style="margin-top: 15px;">Crear mi primera idea</button>
                    </div>
                </c:if>
            </div>
            
            <!-- Modal para crear idea -->
            <div id="modalCrearIdea" class="modal">
                <div class="modal-content">
                    <button class="modal-close" onclick="cerrarModalCrearIdea()">&times;</button>
                    <h3>Nueva Idea de Proyecto</h3>
                    <form action="crear_idea.jsp" method="post" target="submitFrame" onsubmit="cerrarModalCrearIdea(); setTimeout(function(){window.location.href='dashboard.jsp?sec=misIdeas';}, 500);">
                        <div style="margin-bottom: 15px;">
                            <label>Título</label>
                            <input type="text" name="titulo" required class="form-control" style="width:100%; padding: 10px; border-radius: 12px; border: 1px solid #ddd;">
                        </div>
                        <div style="margin-bottom: 15px;">
                            <label>Descripción</label>
                            <textarea name="descripcion" rows="4" required style="width:100%; padding: 10px; border-radius: 12px; border: 1px solid #ddd;"></textarea>
                        </div>
                        <div style="margin-bottom: 15px;">
                            <label>Objetivos (opcional)</label>
                            <textarea name="objetivos" rows="3" style="width:100%; padding: 10px; border-radius: 12px; border: 1px solid #ddd;"></textarea>
                        </div>
                        <button type="submit" class="action-btn" style="width:100%;"><i class="fas fa-save"></i> Guardar Idea</button>
                    </form>
                </div>
            </div>
        </c:if>
        
        <!-- ==================== SECCIÓN: HISTORIAL ==================== -->
        <c:if test="${seccionActual == 'historial'}">
            <div class="banner-fecha"><h2 style="font-size: 1.3rem;"><i class="fas fa-history"></i> Historial de versiones</h2><p>Cada enlace entregado, con fase, fecha y URL; y las decisiones recibidas</p></div>
            <c:if test="${not empty param.err}"><div class="alert alert-warning" style="margin-bottom:16px;"><i class="fas fa-exclamation-triangle"></i> <c:out value="${param.err}" /></div></c:if>
            <c:if test="${param.msg == 'proyecto_creado' or param.msg == 'entrega_ok'}"><div class="alert alert-success" style="margin-bottom:16px;"><i class="fas fa-check-circle"></i> Listo, quedó registrado.</div></c:if>
            <c:if test="${not empty proy}">
            <sql:query dataSource="${dataSource}" var="entregas">
                SELECT e.fase, e.tipo, e.version, e.url, e.fecha FROM entrega e WHERE e.proyecto_id = ? ORDER BY e.fecha DESC, e.id DESC
                <sql:param value="${proy.id}" />
            </sql:query>
            <sql:query dataSource="${dataSource}" var="revisiones">
                SELECT r.fase, r.rol_revisor, r.estado, r.observacion, r.fecha, CONCAT(u.nombre, ' ', COALESCE(u.apellido, '')) AS revisor
                  FROM revision r JOIN usuarios u ON u.id = r.revisor_id WHERE r.proyecto_id = ? ORDER BY r.fecha DESC, r.id DESC
                <sql:param value="${proy.id}" />
            </sql:query>
            <div class="section-card" style="overflow-x:auto;">
                <h3>Entregas</h3>
                <table style="width:100%;border-collapse:collapse;margin-top:10px;font-size:.9rem;">
                    <tr style="text-align:left;"><th>Fase</th><th>Documento</th><th>Versión</th><th>Fecha</th><th>Enlace</th></tr>
                    <c:forEach var="e" items="${entregas.rows}">
                        <tr style="border-top:1px solid #E9ECEF;"><td>${e.fase}. ${nombresFase[e.fase-1]}</td><td>${e.tipo}</td><td>v${e.version}</td>
                            <td>${fn:substring(e.fecha,8,10)}/${fn:substring(e.fecha,5,7)}/${fn:substring(e.fecha,0,4)} ${fn:substring(e.fecha,11,16)}</td>
                            <td><a href="<c:out value='${e.url}'/>" target="_blank" rel="noopener noreferrer">Abrir</a></td></tr>
                    </c:forEach>
                </table>
                <c:if test="${empty entregas.rows}"><p style="margin-top:10px;">Aún no has entregado enlaces.</p></c:if>
            </div>
            <div class="section-card" style="overflow-x:auto;">
                <h3>Decisiones y observaciones</h3>
                <table style="width:100%;border-collapse:collapse;margin-top:10px;font-size:.9rem;">
                    <tr style="text-align:left;"><th>Fase</th><th>Revisó</th><th>Decisión</th><th>Observación</th><th>Fecha</th></tr>
                    <c:forEach var="r" items="${revisiones.rows}">
                        <tr style="border-top:1px solid #E9ECEF;"><td>${r.fase}. ${nombresFase[r.fase-1]}</td><td><c:out value="${r.revisor}" /> (${r.rol_revisor})</td><td>${r.estado}</td>
                            <td><c:out value="${r.observacion}" /></td><td>${fn:substring(r.fecha,8,10)}/${fn:substring(r.fecha,5,7)}/${fn:substring(r.fecha,0,4)}</td></tr>
                    </c:forEach>
                </table>
                <c:if test="${empty revisiones.rows}"><p style="margin-top:10px;">Aún no hay decisiones.</p></c:if>
            </div>
            </c:if>
            <c:if test="${empty proy}">            <div class="section-card"><p>Aún no tienes un proyecto activo.</p><a href="dashboard.jsp?sec=seleccionarIdea" class="action-btn" style="margin-top:12px;">Elegir una idea</a></div></c:if>
        </c:if>
        <!-- ==================== SECCIÓN: CALENDARIO ==================== -->
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
                
                <div class="calendario-container">
                    <div class="calendario-header">
                        <div>Dom</div><div>Lun</div><div>Mar</div><div>Mié</div><div>Jue</div><div>Vie</div><div>Sáb</div>
                    </div>
                    <div class="calendario-grid" id="calendarioGrid"></div>
                </div>
                
                <div style="margin-top: 25px;">
                    <h4 style="margin-bottom: 15px;"><i class="fas fa-list"></i> Eventos de ${mesNombreCal}</h4>
                    <c:forEach var="e" items="${eventosMesCal.rows}">
                        <div style="display: flex; align-items: center; justify-content: space-between; background: #F8FAFE; padding: 12px 20px; border-radius: 16px; margin-bottom: 10px;">
                            <div>
                                <strong>📅 ${e.fecha_evento}</strong><br>
                                <span>${e.titulo}</span>
                                <c:if test="${not empty e.descripcion}">
                                    <p style="font-size: 0.75rem; color: #6C757D;">${e.descripcion}</p>
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
        
        <!-- ==================== SECCIÓN: FORMATOS ==================== -->
        <c:if test="${seccionActual == 'formatos'}">
            <div class="banner-fecha">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                    <div>
                        <h2 style="font-size: 1.3rem;"><i class="fas fa-file-alt"></i> Formatos de Grado</h2>
                        <p>Documentos y formatos institucionales para proyectos de grado</p>
                    </div>
                    <div>
                        <span style="background: rgba(255,255,255,0.2); padding: 6px 16px; border-radius: 40px;">
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
                    SELECT id, nombre, descripcion, ruta_archivo, tipo, fecha_subida 
                    FROM formatos_grado WHERE activo = 1 ORDER BY id DESC
                </sql:query>
                
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
                        <div class="formato-card" data-tipo="${f.tipo}" style="background: #F8FAFE; border-radius: 20px; padding: 20px; margin-bottom: 20px; border-left: 4px solid #A6C21B;">
                            <div style="display: flex; align-items: flex-start; gap: 18px; flex-wrap: wrap;">
                                <div style="width: 70px; height: 70px; background: #E8F5E9; border-radius: 18px; display: flex; align-items: center; justify-content: center;">
                                    <i class="fas fa-file-pdf" style="font-size: 2rem; color: #DC3545;"></i>
                                </div>
                                <div style="flex: 1;">
                                    <h4>${f.nombre}</h4>
                                    <p style="font-size: 0.85rem; color: #6C757D;">${f.descripcion}</p>
                                    <div style="display: flex; gap: 15px; flex-wrap: wrap; margin-top: 8px;">
                                        <span class="badge" style="background:#E8F5E9; color:#A6C21B;">${f.tipo}</span>
                                        <span style="font-size: 0.7rem; color: #8BA0AE;"><i class="fas fa-calendar-alt"></i> ${fn:substring(f.fecha_subida,8,10)}/${fn:substring(f.fecha_subida,5,7)}/${fn:substring(f.fecha_subida,0,4)} ${fn:substring(f.fecha_subida,11,16)}</span>
                                    </div>
                                    <div style="display: flex; gap: 12px; margin-top: 18px;">
                                        <c:set var="esLink" value="${fn:startsWith(f.ruta_archivo, 'http')}" /><c:url var="urlF" value="/${f.ruta_archivo}" /><a href="${esLink ? f.ruta_archivo : urlF}" target="_blank" class="action-btn" style="background:#17A2B8;">Ver</a>
                                        <c:if test="${not esLink}"><a href="${urlF}" download class="action-btn" style="background:#A6C21B;">Descargar</a></c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                
                <c:if test="${empty formatosLista.rows}">
                    <div style="text-align: center; padding: 60px;">
                        <i class="fas fa-folder-open" style="font-size: 4rem; color: #ADB5BD;"></i>
                        <p>No hay formatos disponibles.</p>
                    </div>
                </c:if>
            </div>
            
            <script>
                function filtrarFormatos(tipo) {
                    var botones = ['filtroTodos', 'filtroFormato', 'filtroGuia', 'filtroReglamento', 'filtroActa', 'filtroOtro'];
                    botones.forEach(function(id) {
                        var btn = document.getElementById(id);
                        if(btn) { btn.style.background = ''; btn.style.color = '#A6C21B'; }
                    });
                    if(tipo === 'todos') {
                        var btnTodos = document.getElementById('filtroTodos');
                        if(btnTodos) { btnTodos.style.background = '#A6C21B'; btnTodos.style.color = 'white'; }
                    } else {
                        var btnEsp = document.getElementById('filtro' + tipo.charAt(0).toUpperCase() + tipo.slice(1));
                        if(btnEsp) { btnEsp.style.background = '#A6C21B'; btnEsp.style.color = 'white'; }
                    }
                    var tarjetas = document.querySelectorAll('.formato-card');
                    tarjetas.forEach(function(tarjeta) {
                        if(tipo === 'todos') tarjeta.style.display = 'block';
                        else {
                            var tipoTarjeta = tarjeta.getAttribute('data-tipo');
                            tarjeta.style.display = tipoTarjeta === tipo ? 'block' : 'none';
                        }
                    });
                }
            </script>
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
            
            <sql:query dataSource="${dataSource}" var="estudianteDataPerfil">
                SELECT nombre, apellido, email, codigo, fecha_registro FROM usuarios WHERE id = ?
                <sql:param value="${idEstudiante}" />
            </sql:query>
            
            <div class="section-card" style="padding: 0; overflow: hidden; margin-bottom: 30px;">
                <div style="background: linear-gradient(135deg, #A6C21B 0%, #8FAA10 100%); padding: 50px 30px; text-align: center; color: white;">
                    <div style="width: 130px; height: 130px; background: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 25px; box-shadow: 0 15px 35px rgba(0,0,0,0.15);">
                        <i class="fas fa-user-graduate" style="font-size: 4rem; color: #A6C21B;"></i>
                    </div>
                    <c:forEach var="e" items="${estudianteDataPerfil.rows}">
                        <h2 style="font-size: 2rem; margin-bottom: 10px; letter-spacing: -0.5px;">${e.nombre} ${e.apellido}</h2>
                        <p style="opacity: 0.95; font-size: 1.05rem;"><i class="fas fa-badge"></i> Estudiante del Sistema</p>
                    </c:forEach>
                </div>
                
                <div style="padding: 40px;">
                    <c:forEach var="e" items="${estudianteDataPerfil.rows}">
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
                                            <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">${e.nombre} ${e.apellido}</p>
                                        </div>
                                    </div>
                                    <div style="display: flex; align-items: center; gap: 18px; padding: 12px 0; border-bottom: 1px solid #E9ECEF;">
                                        <div style="width: 45px; height: 45px; background: #E8F5E9; border-radius: 15px; display: flex; align-items: center; justify-content: center;">
                                            <i class="fas fa-envelope" style="font-size: 1.3rem; color: #A6C21B;"></i>
                                        </div>
                                        <div>
                                            <p style="font-size: 0.75rem; color: #8BA0AE; margin-bottom: 3px;">Correo electrónico</p>
                                            <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">${e.email}</p>
                                        </div>
                                    </div>
                                    <div style="display: flex; align-items: center; gap: 18px; padding: 12px 0; border-bottom: 1px solid #E9ECEF;">
                                        <div style="width: 45px; height: 45px; background: #E8F5E9; border-radius: 15px; display: flex; align-items: center; justify-content: center;">
                                            <i class="fas fa-id-card" style="font-size: 1.3rem; color: #A6C21B;"></i>
                                        </div>
                                        <div>
                                            <p style="font-size: 0.75rem; color: #8BA0AE; margin-bottom: 3px;">Código estudiantil</p>
                                            <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">${e.codigo}</p>
                                        </div>
                                    </div>
                                    <div style="display: flex; align-items: center; gap: 18px; padding: 12px 0;">
                                        <div style="width: 45px; height: 45px; background: #E8F5E9; border-radius: 15px; display: flex; align-items: center; justify-content: center;">
                                            <i class="fas fa-user-tag" style="font-size: 1.3rem; color: #A6C21B;"></i>
                                        </div>
                                        <div>
                                            <p style="font-size: 0.75rem; color: #8BA0AE; margin-bottom: 3px;">Rol en el sistema</p>
                                            <p><span style="background:#A6C21B; color:white; padding: 5px 16px; border-radius: 30px; font-size: 0.8rem; font-weight: 600;">Estudiante</span></p>
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
                                            <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">${fn:substring(e.fecha_registro,8,10)}/${fn:substring(e.fecha_registro,5,7)}/${fn:substring(e.fecha_registro,0,4)} ${fn:substring(e.fecha_registro,11,16)}</p>
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
                                            <p style="font-weight: 600; color: #2C3E50; font-size: 1rem;">Acceso a gestión de proyecto de grado</p>
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
                    <form action="guardar_perfil.jsp" method="post" target="submitFrame" onsubmit="cerrarModalPerfil(); setTimeout(function(){location.reload();}, 500);">
                        <input type="hidden" name="id" value="${idEstudiante}">
                        <input type="hidden" name="sec" value="perfil">
                        
                        <c:forEach var="e" items="${estudianteDataPerfil.rows}">
                            <div style="margin-bottom: 22px;">
                                <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Nombre</label>
                                <input type="text" name="nombre" value="${e.nombre}" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                            </div>
                            <div style="margin-bottom: 22px;">
                                <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Apellido</label>
                                <input type="text" name="apellido" value="${e.apellido}" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                            </div>
                            <div style="margin-bottom: 22px;">
                                <label style="display: block; font-weight: 600; margin-bottom: 10px; color: #2C3E50;">Correo Electrónico</label>
                                <input type="email" name="email" value="${e.email}" required style="width:100%; padding: 14px; border-radius: 14px; border: 1px solid #E9ECEF; font-size: 0.95rem;">
                            </div>
                        </c:forEach>
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
                    <form action="cambiar_password.jsp" method="post" target="submitFrame" onsubmit="cerrarModalPassword(); setTimeout(function(){location.reload();}, 500);">
                        <input type="hidden" name="id" value="${idEstudiante}">
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

<script>
    var menuToggle = document.getElementById('menuToggle');
    var sidebar = document.getElementById('sidebar');
    if (menuToggle) {
        menuToggle.onclick = function() {
            sidebar.classList.toggle('open');
        };
    }
    
    function abrirModalCrearIdea() {
        document.getElementById('modalCrearIdea').style.display = 'flex';
    }
    
    function cerrarModalCrearIdea() {
        document.getElementById('modalCrearIdea').style.display = 'none';
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
    
    // Mensajes de éxito
    <c:if test="${param.msg == 'recibo_subido'}">
        alert('¡Recibo subido exitosamente! Ahora puedes seleccionar un proyecto.');
    </c:if>
    <c:if test="${param.msg == 'proyecto_creado'}">
        alert('¡Proyecto creado exitosamente! Ahora puedes seleccionar un compañero.');
    </c:if>
    <c:if test="${param.msg == 'companero_asignado'}">
        alert('¡Compañero asignado exitosamente!');
    </c:if>
    <c:if test="${param.msg == 'anteproyecto_subido'}">
        alert('¡Anteproyecto registrado exitosamente!');
    </c:if>
</script>

<script>
    // Verificar si viene de un pago reciente
    if(window.location.href.indexOf('recibo_subido') > -1) {
        // Forzar recarga de la página sin caché
        window.location.href = window.location.href.split('?')[0] + '?sec=dashboard&t=' + new Date().getTime();
    }

    
</script>

<iframe name="submitFrame" style="display:none;"></iframe>

</body>
</html>
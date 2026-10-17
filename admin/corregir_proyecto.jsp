<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="admin" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Corrección de datos de un proyecto por el administrador (cuando el flujo normal no lo permite). Req. 82. --%>
<c:set var="error" value="" />
<c:if test="${pageContext.request.method != 'POST' or empty param.id or param.fase < 1 or param.fase > 6
      or (param.estado != 'Pendiente de entrega' and param.estado != 'En revisión' and param.estado != 'Aplazado' and param.estado != 'Rechazado' and param.estado != 'Finalizado')
      or (param.responsable != 'Estudiante' and param.responsable != 'Director' and param.responsable != 'Evaluador' and param.responsable != 'Comité')}">
    <c:set var="error" value="Datos de fase, estado o responsable no válidos." />
</c:if>
<c:if test="${empty error and not empty param.directorId and param.directorId == param.evaluadorId}"><c:set var="error" value="Director y evaluador deben ser personas distintas." /></c:if>
<c:if test="${empty error and (not empty param.directorId or not empty param.evaluadorId)}">
    <sql:query dataSource="${dataSource}" var="rolesOk">
        SELECT (SELECT COUNT(*) FROM usuarios WHERE id = ? AND rol IN ('docente','evaluador')) AS dir, (SELECT COUNT(*) FROM usuarios WHERE id = ? AND rol = 'evaluador') AS ev
        <sql:param value="${empty param.directorId ? 0 : param.directorId}" /><sql:param value="${empty param.evaluadorId ? 0 : param.evaluadorId}" />
    </sql:query>
    <c:if test="${(not empty param.directorId and rolesOk.rows[0].dir == 0) or (not empty param.evaluadorId and rolesOk.rows[0].ev == 0)}"><c:set var="error" value="El director debe ser un docente y el evaluador un usuario con rol Evaluador." /></c:if>
</c:if>
<c:if test="${empty error}">
    <sql:update dataSource="${dataSource}">
        UPDATE proyectos SET fase_actual = ?, estado_fase = ?, responsable = ?, bloqueado = ?, motivo_bloqueo = ?, cancelado = ?,
               director_id = ?, evaluador_id = ?, fecha_sustentacion = ?,
               fecha_limite_revision = CASE WHEN ? = 'En revisión' AND ? IN ('Director', 'Evaluador') THEN COALESCE(fecha_limite_revision, DATE_ADD(NOW(), INTERVAL 5 DAY)) ELSE NULL END
         WHERE id = ?
        <sql:param value="${param.fase}" /><sql:param value="${param.estado}" /><sql:param value="${param.responsable}" />
        <sql:param value="${param.bloqueado == '1' ? 1 : 0}" /><sql:param value="${param.bloqueado == '1' ? 'Corregido por el administrador' : null}" />
        <sql:param value="${param.cancelado == '1' ? 1 : 0}" />
        <sql:param value="${empty param.directorId ? null : param.directorId}" /><sql:param value="${empty param.evaluadorId ? null : param.evaluadorId}" />
        <sql:param value="${empty param.sustentacion ? null : param.sustentacion}" />
        <sql:param value="${param.estado}" /><sql:param value="${param.responsable}" />
        <sql:param value="${param.id}" />
    </sql:update>
    <c:redirect url="dashboard.jsp?sec=proyectos&msg=ok" />
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="proyectos" /><c:param name="err" value="${error}" /></c:redirect>

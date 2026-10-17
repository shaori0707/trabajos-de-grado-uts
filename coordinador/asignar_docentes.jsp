<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Asigna o reasigna director y evaluador (personas distintas). Req. 26, 75. --%>
<c:set var="error" value="" />
<c:choose>
    <c:when test="${pageContext.request.method != 'POST' or empty param.proyectoId or empty param.directorId or empty param.evaluadorId}"><c:set var="error" value="Selecciona director y evaluador." /></c:when>
    <c:when test="${param.directorId == param.evaluadorId}"><c:set var="error" value="Director y evaluador deben ser personas distintas." /></c:when>
</c:choose>
<c:if test="${empty error}">
    <sql:query dataSource="${dataSource}" var="docs">
        SELECT (SELECT COUNT(*) FROM usuarios WHERE id = ? AND rol IN ('docente','evaluador') AND estado = 1) + (SELECT COUNT(*) FROM usuarios WHERE id = ? AND rol IN ('docente','evaluador') AND estado = 1) AS n
        <sql:param value="${param.directorId}" /><sql:param value="${param.evaluadorId}" />
    </sql:query>
    <c:if test="${docs.rows[0].n != 2}"><c:set var="error" value="El director debe ser un docente y el evaluador otro docente (distinto), ambos activos." /></c:if>
</c:if>
<c:if test="${empty error}">
    <sql:update dataSource="${dataSource}">
        UPDATE proyectos SET director_id = ?, evaluador_id = ? WHERE id = ? AND cancelado = 0
        <sql:param value="${param.directorId}" /><sql:param value="${param.evaluadorId}" /><sql:param value="${param.proyectoId}" />
    </sql:update>
    <c:redirect url="dashboard.jsp"><c:param name="sec" value="${param.volver == 'asignaciones' ? 'asignaciones' : 'proyectos'}" /><c:param name="gestionar" value="${param.volver == 'asignaciones' ? '' : param.proyectoId}" /><c:param name="msg" value="ok" /></c:redirect>
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="${param.volver == 'asignaciones' ? 'asignaciones' : 'proyectos'}" /><c:param name="gestionar" value="${param.volver == 'asignaciones' ? '' : param.proyectoId}" /><c:param name="err" value="${error}" /></c:redirect>

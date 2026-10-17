<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- El Comité revisa la fase 1 (pago) o cierra la fase final. Req. 20-22, 24-26, 74, 75, 78. --%>
<c:set var="idP" value="${param.proyectoId}" />
<c:set var="error" value="" />
<sql:query dataSource="${dataSource}" var="pq">
    SELECT id, fase_actual, estado_fase, responsable, cancelado, bloqueado FROM proyectos WHERE id = ?
    <sql:param value="${idP}" />
</sql:query>
<c:set var="dec" value="${param.decision}" />
<c:set var="obs" value="${fn:trim(param.observacion)}" />
<c:choose>
    <c:when test="${pageContext.request.method != 'POST' or empty pq.rows}"><c:set var="error" value="Proyecto no encontrado." /></c:when>
    <c:when test="${pq.rows[0].cancelado == 1 or pq.rows[0].estado_fase != 'En revisión' or pq.rows[0].responsable != 'Comité' or (pq.rows[0].fase_actual != 1 and pq.rows[0].fase_actual != 6)}">
        <c:set var="error" value="Este proyecto no está pendiente de decisión del Comité." />
    </c:when>
    <c:when test="${dec != 'Aprobado' and dec != 'Aplazado' and dec != 'Rechazado'}"><c:set var="error" value="Elige una decisión." /></c:when>
    <c:when test="${pq.rows[0].fase_actual == 6 and dec == 'Aplazado'}"><c:set var="error" value="En el cierre solo se puede aprobar o rechazar." /></c:when>
    <c:when test="${dec != 'Aprobado' and empty obs}"><c:set var="error" value="Aplazado y Rechazado exigen observaciones." /></c:when>
    <c:when test="${dec == 'Rechazado' and param.confirmar != '1'}"><c:set var="error" value="Confirma el rechazo: termina el proyecto." /></c:when>
    <c:when test="${dec == 'Aprobado' and pq.rows[0].fase_actual == 1 and (empty param.directorId or empty param.evaluadorId)}"><c:set var="error" value="Al aprobar la fase 1 debes asignar director y evaluador." /></c:when>
    <c:when test="${dec == 'Aprobado' and pq.rows[0].fase_actual == 1 and param.directorId == param.evaluadorId}"><c:set var="error" value="Director y evaluador deben ser personas distintas." /></c:when>
    <c:when test="${dec == 'Aprobado' and pq.rows[0].fase_actual == 6 and empty param.fechaSustentacion}"><c:set var="error" value="Indica la fecha de sustentación." /></c:when>
</c:choose>
<c:if test="${empty error and dec == 'Aprobado' and pq.rows[0].fase_actual == 1}">
    <sql:query dataSource="${dataSource}" var="docs">
        SELECT (SELECT COUNT(*) FROM usuarios WHERE id = ? AND rol IN ('docente','evaluador') AND estado = 1) + (SELECT COUNT(*) FROM usuarios WHERE id = ? AND rol IN ('docente','evaluador') AND estado = 1) AS n
        <sql:param value="${param.directorId}" /><sql:param value="${param.evaluadorId}" />
    </sql:query>
    <c:if test="${docs.rows[0].n != 2}"><c:set var="error" value="El director debe ser un docente y el evaluador otro docente (distinto), ambos activos." /></c:if>
</c:if>

<c:if test="${empty error}">
    <c:set var="fase" value="${pq.rows[0].fase_actual}" />
    <sql:transaction dataSource="${dataSource}">
        <sql:update>
            INSERT INTO revision (proyecto_id, fase, revisor_id, rol_revisor, estado, observacion, firma)
            VALUES (?, ?, ?, 'Comité', ?, ?, 1)
            <sql:param value="${idP}" /><sql:param value="${fase}" /><sql:param value="${sessionScope.idUsuario}" />
            <sql:param value="${dec}" /><sql:param value="${empty obs ? null : obs}" />
        </sql:update>
        <c:choose>
            <c:when test="${dec == 'Rechazado'}">
                <sql:update>UPDATE proyectos SET estado_fase = 'Rechazado', fecha_limite_revision = NULL WHERE id = ?<sql:param value="${idP}" /></sql:update>
            </c:when>
            <c:when test="${dec == 'Aplazado'}">
                <sql:update>UPDATE proyectos SET estado_fase = 'Aplazado', responsable = 'Estudiante', fecha_limite_revision = NULL WHERE id = ?<sql:param value="${idP}" /></sql:update>
            </c:when>
            <c:when test="${fase == 1}">
                <sql:update>
                    UPDATE proyectos SET fase_actual = 2, estado_fase = 'Pendiente de entrega', responsable = 'Estudiante',
                           director_id = ?, evaluador_id = ?, pago_cubre_todos = 1, fecha_inicio_fase = NOW(), fecha_limite_revision = NULL
                     WHERE id = ?
                    <sql:param value="${param.directorId}" /><sql:param value="${param.evaluadorId}" /><sql:param value="${idP}" />
                </sql:update>
            </c:when>
            <c:otherwise>
                <sql:update>UPDATE proyectos SET estado_fase = 'Finalizado', fecha_sustentacion = ?, fecha_limite_revision = NULL WHERE id = ?
                    <sql:param value="${param.fechaSustentacion}" /><sql:param value="${idP}" /></sql:update>
            </c:otherwise>
        </c:choose>
    </sql:transaction>
    <c:redirect url="dashboard.jsp?sec=proyectos&msg=ok" />
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="proyectos" /><c:param name="gestionar" value="${idP}" /><c:param name="err" value="${error}" /></c:redirect>

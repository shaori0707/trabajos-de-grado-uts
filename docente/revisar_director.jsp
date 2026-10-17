<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="docente" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<c:set var="idDocente" value="${sessionScope.idUsuario}" />
<%-- El director revisa y firma la propuesta (fase 2) o el informe (fase 4). Req. 20-24, 65, 66. --%>
<c:set var="error" value="" />
<c:set var="dec" value="${param.decision}" />
<c:set var="obs" value="${fn:trim(param.observacion)}" />
<sql:query dataSource="${dataSource}" var="pq">
    SELECT p.id, p.fase_actual, p.estado_fase, p.responsable, p.bloqueado, p.cancelado,
           (SELECT COUNT(*) FROM seguimiento s WHERE s.proyecto_id = p.id) AS seguimientos
      FROM proyectos p WHERE p.id = ? AND p.director_id = ?
    <sql:param value="${param.proyectoId}" /><sql:param value="${idDocente}" />
</sql:query>
<c:choose>
    <c:when test="${pageContext.request.method != 'POST' or empty pq.rows}"><c:set var="error" value="Proyecto no encontrado." /></c:when>
    <c:when test="${pq.rows[0].cancelado == 1 or pq.rows[0].bloqueado == 1}"><c:set var="error" value="El proyecto está bloqueado o cancelado." /></c:when>
    <c:when test="${(pq.rows[0].fase_actual != 2 and pq.rows[0].fase_actual != 4) or pq.rows[0].estado_fase != 'En revisión' or pq.rows[0].responsable != 'Director'}"><c:set var="error" value="Este proyecto no está pendiente de tu revisión." /></c:when>
    <c:when test="${dec != 'Aprobado' and dec != 'Aplazado' and dec != 'Rechazado'}"><c:set var="error" value="Elige una decisión." /></c:when>
    <c:when test="${dec != 'Aprobado' and empty obs}"><c:set var="error" value="Aplazado y Rechazado exigen observaciones." /></c:when>
    <c:when test="${dec == 'Rechazado' and param.confirmar != '1'}"><c:set var="error" value="Confirma el rechazo: termina el proyecto." /></c:when>
    <c:when test="${dec == 'Aprobado' and param.firma != '1'}"><c:set var="error" value="No se puede aprobar sin tu firma en el documento." /></c:when>
    <c:when test="${dec == 'Aprobado' and pq.rows[0].fase_actual == 4 and pq.rows[0].seguimientos < 2}"><c:set var="error" value="Antes del informe final debes haber hecho al menos 2 seguimientos." /></c:when>
</c:choose>
<c:if test="${empty error}">
    <c:set var="fase" value="${pq.rows[0].fase_actual}" />
    <sql:transaction dataSource="${dataSource}">
        <sql:update>
            INSERT INTO revision (proyecto_id, fase, revisor_id, rol_revisor, estado, observacion, firma)
            VALUES (?, ?, ?, 'Director', ?, ?, ?)
            <sql:param value="${param.proyectoId}" /><sql:param value="${fase}" /><sql:param value="${idDocente}" />
            <sql:param value="${dec}" /><sql:param value="${empty obs ? null : obs}" /><sql:param value="${param.firma == '1' ? 1 : 0}" />
        </sql:update>
        <c:choose>
            <c:when test="${dec == 'Aprobado'}">
                <%-- Avanza: el director debe enviar lo aprobado al evaluador y al Comité (fases 3 y 5) --%>
                <sql:update>UPDATE proyectos SET fase_actual = fase_actual + 1, estado_fase = 'En revisión', responsable = 'Director',
                        fecha_inicio_fase = NOW(), fecha_limite_revision = DATE_ADD(NOW(), INTERVAL 5 DAY) WHERE id = ?<sql:param value="${param.proyectoId}" /></sql:update>
            </c:when>
            <c:when test="${dec == 'Aplazado'}">
                <sql:update>UPDATE proyectos SET estado_fase = 'Aplazado', responsable = 'Estudiante', fecha_limite_revision = NULL WHERE id = ?<sql:param value="${param.proyectoId}" /></sql:update>
            </c:when>
            <c:otherwise>
                <sql:update>UPDATE proyectos SET estado_fase = 'Rechazado', fecha_limite_revision = NULL WHERE id = ?<sql:param value="${param.proyectoId}" /></sql:update>
            </c:otherwise>
        </c:choose>
    </sql:transaction>
    <c:redirect url="dashboard.jsp"><c:param name="sec" value="director" /><c:param name="msg" value="ok" /></c:redirect>
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="director" /><c:param name="ver" value="${param.proyectoId}" /><c:param name="err" value="${error}" /></c:redirect>

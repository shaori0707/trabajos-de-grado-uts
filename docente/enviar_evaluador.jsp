<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="docente" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<c:set var="idDocente" value="${sessionScope.idUsuario}" />
<%-- El director envía al evaluador (y al Comité) lo que aprobó: fases 3 y 5. Req. 17, 23, 67. --%>
<c:set var="error" value="" />
<sql:query dataSource="${dataSource}" var="pq">
    SELECT id, fase_actual, estado_fase, responsable, bloqueado, cancelado, evaluador_id FROM proyectos WHERE id = ? AND director_id = ?
    <sql:param value="${param.proyectoId}" /><sql:param value="${idDocente}" />
</sql:query>
<c:choose>
    <c:when test="${pageContext.request.method != 'POST' or empty pq.rows}"><c:set var="error" value="Proyecto no encontrado." /></c:when>
    <c:when test="${pq.rows[0].cancelado == 1 or pq.rows[0].bloqueado == 1}"><c:set var="error" value="El proyecto está bloqueado o cancelado." /></c:when>
    <c:when test="${(pq.rows[0].fase_actual != 3 and pq.rows[0].fase_actual != 5) or pq.rows[0].estado_fase != 'En revisión' or pq.rows[0].responsable != 'Director'}"><c:set var="error" value="No hay nada pendiente de enviar." /></c:when>
    <c:when test="${empty pq.rows[0].evaluador_id}"><c:set var="error" value="El Comité aún no asignó evaluador." /></c:when>
</c:choose>
<c:if test="${empty error}">
    <sql:update dataSource="${dataSource}">
        UPDATE proyectos SET responsable = 'Evaluador', fecha_inicio_fase = NOW(), fecha_limite_revision = DATE_ADD(NOW(), INTERVAL 5 DAY) WHERE id = ?
        <sql:param value="${param.proyectoId}" />
    </sql:update>
    <c:redirect url="dashboard.jsp"><c:param name="sec" value="director" /><c:param name="msg" value="ok" /></c:redirect>
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="director" /><c:param name="ver" value="${param.proyectoId}" /><c:param name="err" value="${error}" /></c:redirect>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- El Comité aprueba o rechaza una prórroga. Aprobada: +180 días y se desbloquea. Req. 31, 32, 77. --%>
<c:set var="error" value="" />
<sql:query dataSource="${dataSource}" var="pr">SELECT id, proyecto_id, solo_correcciones, estado FROM prorroga WHERE id = ?<sql:param value="${param.prorrogaId}" /></sql:query>
<c:choose>
    <c:when test="${pageContext.request.method != 'POST' or empty pr.rows or pr.rows[0].estado != 'Pendiente'}"><c:set var="error" value="La solicitud no existe o ya fue decidida." /></c:when>
    <c:when test="${param.decision != 'Aprobada' and param.decision != 'Rechazada'}"><c:set var="error" value="Elige una decisión." /></c:when>
</c:choose>
<c:if test="${empty error}">
    <sql:transaction dataSource="${dataSource}">
        <sql:update>UPDATE prorroga SET estado = ?, fecha_decision = NOW() WHERE id = ?<sql:param value="${param.decision}" /><sql:param value="${param.prorrogaId}" /></sql:update>
        <c:if test="${param.decision == 'Aprobada'}">
            <sql:update>
                UPDATE proyectos SET dias_prorroga = dias_prorroga + 180, bloqueado = 0, motivo_bloqueo = NULL,
                       prorroga_correcciones = ?,
                       fecha_limite_revision = CASE WHEN estado_fase = 'En revisión' AND responsable IN ('Director', 'Evaluador') THEN DATE_ADD(NOW(), INTERVAL 5 DAY) ELSE fecha_limite_revision END
                 WHERE id = ? AND cancelado = 0
                <sql:param value="${pr.rows[0].solo_correcciones}" /><sql:param value="${pr.rows[0].proyecto_id}" />
            </sql:update>
        </c:if>
    </sql:transaction>
    <c:redirect url="dashboard.jsp"><c:param name="sec" value="prorrogas" /><c:param name="msg" value="ok" /></c:redirect>
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="prorrogas" /><c:param name="err" value="${error}" /></c:redirect>

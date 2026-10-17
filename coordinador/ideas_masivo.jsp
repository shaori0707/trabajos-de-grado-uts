<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Aprueba o rechaza ideas, una o varias a la vez. Req. 5, 73. --%>
<c:if test="${pageContext.request.method == 'POST' and (param.decision == 'aprobada' or param.decision == 'rechazada')}">
    <sql:transaction dataSource="${dataSource}">
        <c:forEach var="idIdea" items="${paramValues.ids}">
            <sql:update>
                UPDATE ideas_proyecto SET estado = ?, fecha_revision = NOW(), revisado_por = ?,
                       comentario_coordinador = ?
                 WHERE id = ? AND estado = 'pendiente'
                <sql:param value="${param.decision}" />
                <sql:param value="${sessionScope.idUsuario}" />
                <sql:param value="${empty fn:trim(param.comentario) ? null : fn:trim(param.comentario)}" />
                <sql:param value="${idIdea}" />
            </sql:update>
        </c:forEach>
    </sql:transaction>
</c:if>
<c:redirect url="dashboard.jsp?sec=ideas" />

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Decisión individual sobre una idea (la masiva está en ideas_masivo.jsp). --%>
<c:if test="${not empty param.id}">
    <sql:update dataSource="${dataSource}">
        UPDATE ideas_proyecto SET estado = 'rechazada', fecha_revision = NOW(), revisado_por = ? WHERE id = ? AND estado = 'pendiente'
        <sql:param value="${sessionScope.idUsuario}" />
        <sql:param value="${param.id}" />
    </sql:update>
</c:if>
<c:redirect url="dashboard.jsp?sec=ideas" />

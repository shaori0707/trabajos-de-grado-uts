<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="idMensaje" value="${param.id}" />
<c:set var="sec" value="${param.sec}" />

<sql:update dataSource="${db}">
    UPDATE mensajes SET leido = 0 WHERE id = ?
    <sql:param value="${idMensaje}" />
</sql:update>

<c:redirect url="dashboard.jsp?sec=${sec}" />
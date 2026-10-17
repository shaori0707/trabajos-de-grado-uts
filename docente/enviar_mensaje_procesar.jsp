<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="remitente_id" value="${sessionScope.idUsuario}" />
<c:set var="destinatario_id" value="${param.destinatario_id}" />
<c:set var="asunto" value="${param.asunto}" />
<c:set var="mensaje" value="${param.mensaje}" />
<c:set var="sec" value="${param.sec}" />

<c:if test="${not empty destinatario_id and not empty asunto and not empty mensaje}">
    <sql:update dataSource="${dataSource}">
        INSERT INTO mensajes (remitente_id, destinatario_id, asunto, mensaje, fecha_envio, leido, importante) 
        VALUES (?, ?, ?, ?, NOW(), 0, 0)
        <sql:param value="${remitente_id}" />
        <sql:param value="${destinatario_id}" />
        <sql:param value="${asunto}" />
        <sql:param value="${mensaje}" />
    </sql:update>
</c:if>

<c:redirect url="dashboard.jsp?sec=${not empty sec ? sec : 'mensajes'}" />
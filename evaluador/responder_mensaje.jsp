<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="remitenteId" value="${sessionScope.idUsuario}" />
<c:set var="destinatarioId" value="${param.destinatario_id}" />
<c:set var="asunto" value="${param.asunto}" />
<c:set var="mensaje" value="${param.mensaje}" />
<c:set var="idOriginal" value="${param.id_original}" />

<sql:update dataSource="${db}">
    INSERT INTO mensajes (remitente_id, destinatario_id, asunto, mensaje, leido) 
    VALUES (?, ?, ?, ?, 0)
    <sql:param value="${remitenteId}" />
    <sql:param value="${destinatarioId}" />
    <sql:param value="${asunto}" />
    <sql:param value="${mensaje}" />
</sql:update>

<c:redirect url="dashboard.jsp?sec=mensajes" />
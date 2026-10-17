<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="idMensaje" value="${param.id}" />
<c:set var="idUsuario" value="${sessionScope.idUsuario}" />

<!-- Marcar como leído -->
<sql:update dataSource="${db}">
    UPDATE mensajes SET leido = 1 WHERE id = ? AND destinatario_id = ?
    <sql:param value="${idMensaje}" />
    <sql:param value="${idUsuario}" />
</sql:update>

<!-- Obtener datos del mensaje -->
<sql:query dataSource="${db}" var="mensaje">
    SELECT m.id, m.asunto, m.mensaje, m.fecha_envio, m.leido, m.remitente_id,
           u.nombre as remitente_nombre, u.apellido as remitente_apellido
    FROM mensajes m
    JOIN usuarios u ON m.remitente_id = u.id
    WHERE m.id = ?
    <sql:param value="${idMensaje}" />
</sql:query>

<c:forEach var="m" items="${mensaje.rows}">
    {
        "id": ${m.id},
        "asunto": "${fn:replace(m.asunto, '"', '\\"')}",
        "mensaje": "${fn:replace(m.mensaje, '"', '\\"')}",
        "fecha": "${m.fecha_envio}",
        "leido": ${m.leido},
        "remitente": "${m.remitente_nombre} ${m.remitente_apellido}",
        "remitente_id": ${m.remitente_id}
    }
</c:forEach>
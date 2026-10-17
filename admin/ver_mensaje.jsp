<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="idMensaje" value="${param.id}" />
<c:set var="tipo" value="${param.tipo}" />

<c:if test="${not empty idMensaje and tipo == 'recibido'}">
    <sql:update dataSource="${dataSource}">
        UPDATE mensajes SET leido = 1 WHERE id = ? AND destinatario_id = ?
        <sql:param value="${idMensaje}" />
        <sql:param value="${sessionScope.idUsuario}" />
    </sql:update>
</c:if>

<sql:query dataSource="${dataSource}" var="mensaje">
    SELECT m.*, 
           r.nombre as remitente_nombre, r.apellido as remitente_apellido, r.rol as remitente_rol,
           d.nombre as destinatario_nombre, d.apellido as destinatario_apellido, d.rol as destinatario_rol
    FROM mensajes m
    JOIN usuarios r ON m.remitente_id = r.id
    JOIN usuarios d ON m.destinatario_id = d.id
    WHERE m.id = ?
    <sql:param value="${idMensaje}" />
</sql:query>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Ver Mensaje - UTS</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background: #F4F7FC; padding: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .card { background: white; border-radius: 24px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .btn { background: #28A745; color: white; padding: 10px 20px; border-radius: 12px; text-decoration: none; display: inline-block; }
        .btn:hover { background: #218838; }
        .info { background: #F8FAFE; padding: 15px; border-radius: 16px; margin-bottom: 20px; }
    </style>
</head>
<body>
<div class="container">
    <div class="card">
        <h2><i class="fas fa-envelope"></i> Detalle del Mensaje</h2>
        
        <c:forEach var="msg" items="${mensaje.rows}">
            <div class="info">
                <p><strong><i class="fas fa-user"></i> De:</strong> ${msg.remitente_nombre} ${msg.remitente_apellido} (${msg.remitente_rol})</p>
                <p><strong><i class="fas fa-user"></i> Para:</strong> ${msg.destinatario_nombre} ${msg.destinatario_apellido} (${msg.destinatario_rol})</p>
                <p><strong><i class="fas fa-tag"></i> Asunto:</strong> ${msg.asunto}</p>
                <p><strong><i class="fas fa-calendar"></i> Fecha:</strong> ${msg.fecha_envio}</p>
            </div>
            
            <div style="margin: 20px 0; padding: 20px; background: #F8FAFE; border-radius: 16px;">
                <p>${msg.mensaje}</p>
            </div>
        </c:forEach>
        
        <div style="display: flex; gap: 15px; margin-top: 20px;">
            <a href="javascript:history.back()" class="btn"><i class="fas fa-arrow-left"></i> Volver</a>
            <a href="dashboard.jsp?sec=mensajes" class="btn" style="background:#6C757D;"><i class="fas fa-inbox"></i> Ir a Mensajes</a>
        </div>
    </div>
</div>
</body>
</html>
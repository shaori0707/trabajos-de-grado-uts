<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<c:set var="rolRequerido" value="admin" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>

<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="idRemitente" value="${sessionScope.idUsuario}" />

<!-- CORREGIDO: usar 'docente' en lugar de 'director' y 'evaluador' -->
<sql:query dataSource="${dataSource}" var="destinatarios">
    SELECT id, nombre, apellido, rol FROM usuarios 
    WHERE rol IN ('docente', 'evaluador', 'coordinador', 'admin') AND id != ?
    ORDER BY rol, nombre
    <sql:param value="${idRemitente}" />
</sql:query>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Enviar Mensaje - UTS</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background: #F4F7FC; padding: 40px; }
        .container { max-width: 600px; margin: 0 auto; }
        .card { background: white; border-radius: 24px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); border: 1px solid #E9ECEF; }
        h2 { color: #2C3E50; margin-bottom: 20px; border-left: 4px solid #28A745; padding-left: 15px; }
        label { display: block; font-weight: 600; margin-bottom: 8px; color: #2C3E50; }
        input, select, textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 12px;
            margin-bottom: 20px;
            font-family: 'Inter', sans-serif;
        }
        button {
            background: #28A745;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 600;
            width: 100%;
        }
        button:hover { background: #218838; }
        .cancelar {
            background: #6C757D;
            margin-top: 10px;
            display: block;
            text-align: center;
            text-decoration: none;
            padding: 12px 24px;
            border-radius: 12px;
            color: white;
            font-weight: 600;
        }
        .cancelar:hover { background: #5a6268; }
        .badge { padding: 4px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; display: inline-block; margin-left: 8px; }
        .badge-admin { background: #DC3545; color: white; }
        .badge-docente { background: #FD7E14; color: white; }
        .badge-coordinador { background: #17A2B8; color: white; }
    </style>
</head>
<body>
<div class="container">
    <div class="card">
        <h2><i class="fas fa-paper-plane"></i> Enviar Mensaje</h2>
        <form action="enviar_mensaje_procesar.jsp" method="post">
            <div>
                <label>Para:</label>
                <select name="destinatario_id" required>
                    <option value="">Seleccione un destinatario</option>
                    <c:forEach var="d" items="${destinatarios.rows}">
                        <option value="${d.id}">
                            ${d.nombre} ${d.apellido}
                            <span class="badge badge-${d.rol}">${d.rol}</span>
                        </option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label>Asunto:</label>
                <input type="text" name="asunto" required>
            </div>
            <div>
                <label>Mensaje:</label>
                <textarea name="mensaje" rows="5" required></textarea>
            </div>
            <button type="submit"><i class="fas fa-send"></i> Enviar Mensaje</button>
            <a href="dashboard.jsp?sec=mensajes" class="cancelar">Cancelar</a>
        </form>
    </div>
</div>
</body>
</html>
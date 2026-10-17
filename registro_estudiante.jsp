<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Registro de estudiantes: solo con correo institucional (req. 1). Contraseña guardada con SHA2 (req. 48). --%>
<c:set var="error" value="" />
<c:if test="${pageContext.request.method == 'POST'}">
    <c:set var="correo" value="${fn:toLowerCase(fn:trim(param.email))}" />
    <c:set var="cedula" value="${fn:trim(param.cedula)}" />
    <c:choose>
        <c:when test="${empty fn:trim(param.nombre) or empty fn:trim(param.apellido) or empty correo}"><c:set var="error" value="Completa nombre, apellido y correo." /></c:when>
        <c:when test="${fn:length(cedula) < 5 or fn:length(cedula) > 15}"><c:set var="error" value="La cédula debe tener entre 5 y 15 dígitos." /></c:when>
        <c:when test="${param.nivel != 'tecnologia' and param.nivel != 'ingenieria'}"><c:set var="error" value="Elige tu nivel." /></c:when>
        <c:when test="${fn:length(param.password) < 6 or param.password != param.password2}"><c:set var="error" value="La contraseña debe tener 6 caracteres o más y coincidir en ambos campos." /></c:when>
    </c:choose>
    <c:if test="${empty error}">
        <sql:query dataSource="${dataSource}" var="cfg">SELECT valor FROM configuracion WHERE clave = 'dominios_correo'</sql:query>
        <c:set var="inst" value="${false}" />
        <c:forEach var="dom" items="${fn:split(empty cfg.rows ? 'uts.edu.co,correo.uts.edu.co' : cfg.rows[0].valor, ',')}">
            <c:set var="sufijo" value="@${fn:trim(dom)}" />
            <c:if test="${fn:endsWith(correo, sufijo)}"><c:set var="inst" value="${true}" /></c:if>
        </c:forEach>
        <c:if test="${not inst}"><c:set var="error" value="Sin correo institucional no te puedes inscribir." /></c:if>
    </c:if>
    <c:if test="${empty error}">
        <sql:query dataSource="${dataSource}" var="dup">SELECT id FROM usuarios WHERE email = ? OR cedula = ?<sql:param value="${correo}" /><sql:param value="${cedula}" /></sql:query>
        <c:if test="${not empty dup.rows}"><c:set var="error" value="Ya existe un usuario con ese correo o cédula." /></c:if>
    </c:if>
    <c:if test="${empty error}">
        <sql:update dataSource="${dataSource}">
            INSERT INTO usuarios (nombre, apellido, email, password, rol, cedula, nivel, estado) VALUES (?, ?, ?, SHA2(?, 256), 'estudiante', ?, ?, 1)
            <sql:param value="${fn:trim(param.nombre)}" /><sql:param value="${fn:trim(param.apellido)}" /><sql:param value="${correo}" />
            <sql:param value="${param.password}" /><sql:param value="${cedula}" /><sql:param value="${param.nivel}" />
        </sql:update>
        <c:redirect url="login.jsp?registro=exitoso" />
    </c:if>
</c:if>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de estudiante - UTS</title>
    <link rel="stylesheet" href="css/estilo.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body class="login-body">
<div class="login-container"><div class="login-card"><div class="login-card-content">
    <h2 style="text-align:center;">Registro de estudiante</h2>
    <p style="text-align:center;margin-bottom:20px;">Usa tu correo institucional</p>
    <c:if test="${not empty error}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <c:out value="${error}" /></div></c:if>
    <form method="post" class="login-form">
        <div class="input-group"><input type="text" name="nombre" placeholder="Nombre" required value="<c:out value='${param.nombre}'/>"></div>
        <div class="input-group"><input type="text" name="apellido" placeholder="Apellido" required value="<c:out value='${param.apellido}'/>"></div>
        <div class="input-group"><input type="text" name="cedula" placeholder="Cédula" required pattern="[0-9]{5,15}" value="<c:out value='${param.cedula}'/>"></div>
        <div class="input-group"><input type="email" name="email" placeholder="Correo institucional" required value="<c:out value='${param.email}'/>"></div>
        <div class="input-group"><select name="nivel" required><option value="">Nivel</option><option value="tecnologia" ${param.nivel == 'tecnologia' ? 'selected' : ''}>Tecnología</option><option value="ingenieria" ${param.nivel == 'ingenieria' ? 'selected' : ''}>Ingeniería</option></select></div>
        <div class="input-group"><input type="password" name="password" placeholder="Contraseña (mínimo 6)" required></div>
        <div class="input-group"><input type="password" name="password2" placeholder="Repite la contraseña" required></div>
        <button type="submit" class="btn-login">Registrarme</button>
    </form>
    <div class="login-footer"><a href="login.jsp" class="back-home"><i class="fas fa-arrow-left"></i> Volver al inicio de sesión</a></div>
</div></div></div>
</body>
</html>

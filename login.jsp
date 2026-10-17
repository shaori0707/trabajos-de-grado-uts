<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - UTS Proyectos de Grado</title>
    <link rel="stylesheet" href="css/estilo.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body class="login-body">

<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<%-- Procesar el login solo cuando se envía el formulario (sin scriptlets, solo JSTL) --%>
<c:if test="${pageContext.request.method == 'POST' and not empty fn:trim(param.email) and not empty param.password}">
    <c:set var="emailLogin" value="${fn:toLowerCase(fn:trim(param.email))}" />

    <%-- Req. 1: solo correo institucional (dominios definidos en la tabla configuracion) --%>
    <sql:query dataSource="${dataSource}" var="cfgDominios">
        SELECT valor FROM configuracion WHERE clave = 'dominios_correo'
    </sql:query>
    <c:choose>
        <c:when test="${not empty cfgDominios.rows}">
            <c:set var="listaDominios" value="${cfgDominios.rows[0].valor}" />
        </c:when>
        <c:otherwise>
            <c:set var="listaDominios" value="uts.edu.co,correo.uts.edu.co" />
        </c:otherwise>
    </c:choose>
    <c:set var="correoInstitucional" value="${false}" />
    <c:forEach var="dom" items="${fn:split(listaDominios, ',')}">
        <c:set var="sufijo" value="@${fn:trim(dom)}" />
        <c:if test="${fn:endsWith(emailLogin, sufijo)}">
            <c:set var="correoInstitucional" value="${true}" />
        </c:if>
    </c:forEach>

    <c:choose>
        <c:when test="${not correoInstitucional}">
            <c:set var="errorLogin" value="dominio" scope="page" />
        </c:when>
        <c:otherwise>
            <%-- Req. 48: la contraseña se guarda con SHA2 (256), se compara el hash --%>
            <sql:query dataSource="${dataSource}" var="resLogin">
                SELECT id, nombre, apellido, email, rol, codigo, nivel, cedula
                  FROM usuarios
                 WHERE email = ? AND password = SHA2(?, 256) AND estado = 1
                <sql:param value="${emailLogin}" />
                <sql:param value="${param.password}" />
            </sql:query>

            <c:choose>
                <c:when test="${not empty resLogin.rows}">
                    <c:set var="usuario" value="${resLogin.rows[0]}" scope="session" />
                    <c:set var="user" value="${resLogin.rows[0]}" scope="session" />
                    <c:set var="rol" value="${resLogin.rows[0].rol}" scope="session" />
                    <c:set var="idUsuario" value="${resLogin.rows[0].id}" scope="session" />
                    <c:set var="nombreUsuario" value="${resLogin.rows[0].nombre} ${resLogin.rows[0].apellido}" scope="session" />
                    <c:set var="emailUsuario" value="${resLogin.rows[0].email}" scope="session" />

                    <%-- Menú distinto por rol (req. 2). 'coordinador' es el rol del Comité. --%>
                    <c:choose>
                        <c:when test="${resLogin.rows[0].rol == 'admin'}"><c:redirect url="admin/dashboard.jsp" /></c:when>
                        <c:when test="${resLogin.rows[0].rol == 'coordinador'}"><c:redirect url="coordinador/dashboard.jsp" /></c:when>
                        <c:when test="${resLogin.rows[0].rol == 'evaluador'}"><c:redirect url="docente/dashboard.jsp" /></c:when>
                        <c:when test="${resLogin.rows[0].rol == 'docente'}"><c:redirect url="docente/dashboard.jsp" /></c:when>
                        <c:when test="${resLogin.rows[0].rol == 'estudiante'}"><c:redirect url="estudiante/dashboard.jsp" /></c:when>
                        <c:otherwise><c:redirect url="index.jsp" /></c:otherwise>
                    </c:choose>
                </c:when>
                <c:otherwise>
                    <c:set var="errorLogin" value="credenciales" scope="page" />
                </c:otherwise>
            </c:choose>
        </c:otherwise>
    </c:choose>
</c:if>

<div class="login-container">
    <div class="login-card">
        <img src="img/banner_inicio.png" alt="Banner UTS" class="login-tira-horizontal">
        <div class="login-card-content">
            <h2 style="text-align: center;">Bienvenido</h2>
            <p style="text-align: center; margin-bottom: 30px;">Ingresa a tu cuenta de Proyectos de Grado UTS</p>

            <c:if test="${errorLogin == 'credenciales'}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> Credenciales incorrectas. Intente de nuevo.
                </div>
            </c:if>
            <c:if test="${errorLogin == 'dominio'}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> Debes ingresar con tu correo institucional.
                </div>
            </c:if>
            <c:if test="${param.error == 'sin_permiso'}">
                <div class="alert alert-error">
                    <i class="fas fa-ban"></i> No tienes permiso para ver esa página.
                </div>
            </c:if>

            <c:if test="${param.registro == 'exitoso'}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> Registro exitoso. Ahora puedes iniciar sesión.
                </div>
            </c:if>

            <form method="post" class="login-form">
                <div class="input-group">
                    <i class="fas fa-envelope"></i>
                    <input type="email" name="email" placeholder="Correo institucional" value="${fn:escapeXml(param.email)}" required>
                </div>
                <div class="input-group">
                    <i class="fas fa-lock"></i>
                    <input type="password" name="password" placeholder="Contraseña" required>
                </div>
                <button type="submit" class="btn-login">
                    <i class="fas fa-arrow-right-to-bracket"></i> Iniciar sesión
                </button>
            </form>

            <div class="login-links">
                <a href="registro_estudiante.jsp" class="register-link">
                    <i class="fas fa-user-plus"></i> ¿Eres estudiante? Regístrate aquí
                </a>
            </div>

            <div class="login-footer">
                <a href="index.jsp" class="back-home"><i class="fas fa-home"></i> Volver al inicio</a>
            </div>
        </div>
    </div>

    <div class="login-info">
        <p><i class="fas fa-info-circle"></i> Docentes, Comité y administradores: sus credenciales son asignadas por el administrador del sistema.</p>
    </div>
</div>

</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Actualiza nombre, apellido y correo institucional del usuario en sesión; contraseña opcional (SHA2). --%>
<c:set var="sec" value="${empty param.sec ? 'perfil' : param.sec}" />
<c:set var="correo" value="${fn:toLowerCase(fn:trim(param.email))}" />
<c:set var="error" value="" />
<c:if test="${pageContext.request.method != 'POST' or empty fn:trim(param.nombre) or empty correo}"><c:set var="error" value="datos_incompletos" /></c:if>
<c:if test="${empty error}">
    <sql:query dataSource="${dataSource}" var="cfg">SELECT valor FROM configuracion WHERE clave = 'dominios_correo'</sql:query>
    <c:set var="inst" value="${false}" />
    <c:forEach var="dom" items="${fn:split(empty cfg.rows ? 'uts.edu.co,correo.uts.edu.co' : cfg.rows[0].valor, ',')}">
        <c:set var="sufijo" value="@${fn:trim(dom)}" />
        <c:if test="${fn:endsWith(correo, sufijo)}"><c:set var="inst" value="${true}" /></c:if>
    </c:forEach>
    <c:if test="${not inst}"><c:set var="error" value="correo_no_institucional" /></c:if>
</c:if>
<c:if test="${empty error}">
    <sql:query dataSource="${dataSource}" var="dup">SELECT id FROM usuarios WHERE email = ? AND id <> ?
        <sql:param value="${correo}" /><sql:param value="${sessionScope.idUsuario}" /></sql:query>
    <c:if test="${not empty dup.rows}"><c:set var="error" value="correo_duplicado" /></c:if>
</c:if>
<c:if test="${empty error}">
    <sql:update dataSource="${dataSource}">UPDATE usuarios SET nombre = ?, apellido = ?, email = ? WHERE id = ?
        <sql:param value="${fn:trim(param.nombre)}" /><sql:param value="${fn:trim(param.apellido)}" /><sql:param value="${correo}" /><sql:param value="${sessionScope.idUsuario}" /></sql:update>
    <c:if test="${fn:length(param.password) >= 6}">
        <sql:update dataSource="${dataSource}">UPDATE usuarios SET password = SHA2(?, 256) WHERE id = ?
            <sql:param value="${param.password}" /><sql:param value="${sessionScope.idUsuario}" /></sql:update>
    </c:if>
    <c:set var="nombreUsuario" value="${fn:trim(param.nombre)}" scope="session" />
    <c:set var="emailUsuario" value="${correo}" scope="session" />
    <c:redirect url="dashboard.jsp?sec=${sec}&msg=perfil_actualizado" />
</c:if>
<c:redirect url="dashboard.jsp?sec=${sec}&error=${error}" />

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Cambia la contraseña del usuario en sesión (nunca el id del formulario). Req. 48. --%>
<c:set var="sec" value="${empty param.sec ? 'perfil' : param.sec}" />
<c:if test="${pageContext.request.method == 'POST' and not empty param.password_actual and fn:length(param.password_nueva) >= 6}">
    <sql:query dataSource="${dataSource}" var="ok">
        SELECT id FROM usuarios WHERE id = ? AND password = SHA2(?, 256)
        <sql:param value="${sessionScope.idUsuario}" /><sql:param value="${param.password_actual}" />
    </sql:query>
    <c:if test="${not empty ok.rows}">
        <sql:update dataSource="${dataSource}">UPDATE usuarios SET password = SHA2(?, 256) WHERE id = ?
            <sql:param value="${param.password_nueva}" /><sql:param value="${sessionScope.idUsuario}" /></sql:update>
        <c:redirect url="dashboard.jsp?sec=${sec}&msg=password_actualizado" />
    </c:if>
    <c:redirect url="dashboard.jsp?sec=${sec}&error=password_incorrecto" />
</c:if>
<c:redirect url="dashboard.jsp?sec=${sec}&error=password_invalido" />

<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>

<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="email" value="${param.email}" />
<c:set var="idActual" value="${sessionScope.idUsuario}" />

<c:if test="${not empty email}">
    <sql:query dataSource="${dataSource}" var="usuario">
        SELECT id, nombre, apellido, rol FROM usuarios 
        WHERE email = ? AND id != ? AND estado = 1
        <sql:param value="${email}" />
        <sql:param value="${idActual}" />
    </sql:query>
    
    <c:forEach var="u" items="${usuario.rows}">
        {"existe": true, "id": ${u.id}, "nombre": "${u.nombre}", "apellido": "${u.apellido}", "rol": "${u.rol}"}
    </c:forEach>
    
    <c:if test="${empty usuario.rows}">
        {"existe": false}
    </c:if>
</c:if>

<c:if test="${empty email}">
    {"existe": false}
</c:if>
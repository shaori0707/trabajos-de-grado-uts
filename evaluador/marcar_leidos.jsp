<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<sql:update dataSource="${dataSource}">
    UPDATE mensajes SET leido = 1 WHERE destinatario_id = ?
    <sql:param value="${sessionScope.idUsuario}" />
</sql:update>

<c:redirect url="dashboard.jsp?sec=mensajes&msg=todos_leidos" />
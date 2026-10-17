<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>

<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="idIdea" value="${param.id}" />

<sql:update dataSource="${db}">
    DELETE FROM ideas_proyecto WHERE id = ?
    <sql:param value="${idIdea}" />
</sql:update>

<c:redirect url="dashboard.jsp?sec=ideas" />
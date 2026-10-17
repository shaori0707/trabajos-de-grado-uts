<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>

<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="idFormato" value="${param.id}" />
<c:set var="sec" value="${param.sec}" />

<c:if test="${not empty idFormato}">
    <sql:update dataSource="${dataSource}">
        DELETE FROM formatos_grado WHERE id = ?
        <sql:param value="${idFormato}" />
    </sql:update>
</c:if>

<c:redirect url="dashboard.jsp?sec=${not empty sec ? sec : 'formatos'}" />
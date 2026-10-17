<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<c:set var="rolRequerido" value="admin" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>

<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="idEvento" value="${param.id_evento}" />
<c:set var="titulo" value="${param.titulo}" />
<c:set var="descripcion" value="${param.descripcion}" />
<c:set var="fecha" value="${param.fecha}" />
<c:set var="tipo" value="${param.tipo}" />
<c:set var="sec" value="${param.sec}" />

<c:if test="${not empty titulo and not empty fecha}">
    
    <c:choose>
        <c:when test="${not empty idEvento}">
            <!-- Editar evento existente -->
            <sql:update dataSource="${dataSource}">
                UPDATE calendario_academico 
                SET titulo = ?, descripcion = ?, fecha_evento = ?, tipo = ?
                WHERE id = ?
                <sql:param value="${titulo}" />
                <sql:param value="${descripcion}" />
                <sql:param value="${fecha}" />
                <sql:param value="${tipo}" />
                <sql:param value="${idEvento}" />
            </sql:update>
        </c:when>
        <c:otherwise>
            <!-- Crear nuevo evento -->
            <sql:update dataSource="${dataSource}">
                INSERT INTO calendario_academico (titulo, descripcion, fecha_evento, tipo, creado_por, fecha_creacion)
                VALUES (?, ?, ?, ?, ?, NOW())
                <sql:param value="${titulo}" />
                <sql:param value="${descripcion}" />
                <sql:param value="${fecha}" />
                <sql:param value="${tipo}" />
                <sql:param value="${sessionScope.idUsuario}" />
            </sql:update>
        </c:otherwise>
    </c:choose>
    
    <c:redirect url="dashboard.jsp?sec=${not empty sec ? sec : 'calendario'}&msg=evento_guardado" />
    
</c:if>

<c:if test="${empty titulo or empty fecha}">
    <c:redirect url="dashboard.jsp?sec=${not empty sec ? sec : 'calendario'}&error=faltan_datos" />
</c:if>
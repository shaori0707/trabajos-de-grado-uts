<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- El Comité registra una idea en el banco (nivel obligatorio). --%>
<c:if test="${pageContext.request.method == 'POST' and not empty fn:trim(param.titulo) and not empty fn:trim(param.descripcion) and (param.nivel == 'tecnologia' or param.nivel == 'ingenieria')}">
    <sql:update dataSource="${dataSource}">
        INSERT INTO ideas_proyecto (titulo, descripcion, objetivos, nivel, origen, creado_por, estado, disponible, fecha_creacion)
        VALUES (?, ?, ?, ?, 'banco', ?, 'pendiente', 1, NOW())
        <sql:param value="${fn:trim(param.titulo)}" />
        <sql:param value="${fn:trim(param.descripcion)}" />
        <sql:param value="${param.objetivos}" />
        <sql:param value="${param.nivel}" />
        <sql:param value="${sessionScope.idUsuario}" />
    </sql:update>
</c:if>
<c:redirect url="dashboard.jsp?sec=ideas" />

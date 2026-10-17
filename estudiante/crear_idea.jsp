<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="estudiante" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- El estudiante propone una idea propia; la revisa el Comité por repetición y alcance (req. 8, 55). --%>
<c:set var="idEstudiante" value="${sessionScope.idUsuario}" />

<c:if test="${pageContext.request.method == 'POST' and not empty fn:trim(param.titulo) and not empty fn:trim(param.descripcion)}">
    <sql:update dataSource="${dataSource}">
        INSERT INTO ideas_proyecto (titulo, descripcion, objetivos, nivel, origen, creado_por, estado, disponible, fecha_creacion)
        SELECT ?, ?, ?, u.nivel, 'propia', u.id, 'pendiente', 1, NOW() FROM usuarios u WHERE u.id = ?
        <sql:param value="${fn:trim(param.titulo)}" />
        <sql:param value="${fn:trim(param.descripcion)}" />
        <sql:param value="${param.objetivos}" />
        <sql:param value="${idEstudiante}" />
    </sql:update>
</c:if>

<c:redirect url="dashboard.jsp?sec=misIdeas" />

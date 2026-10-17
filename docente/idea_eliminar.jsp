<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="docente" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<c:set var="idDocente" value="${sessionScope.idUsuario}" />
<%-- Elimina una idea propia que nadie haya tomado. Req. 63. --%>
<c:if test="${pageContext.request.method == 'POST' and not empty param.id}">
    <sql:update dataSource="${dataSource}">DELETE FROM ideas_proyecto WHERE id = ? AND creado_por = ? AND NOT EXISTS (SELECT 1 FROM proyectos p WHERE p.idea_id = ideas_proyecto.id)
        <sql:param value="${param.id}" /><sql:param value="${idDocente}" /></sql:update>
</c:if>
<c:redirect url="dashboard.jsp?sec=ideas" />

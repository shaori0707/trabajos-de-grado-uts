<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="admin" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Elimina un proyecto y libera su idea del banco. Req. 82. --%>
<c:if test="${pageContext.request.method == 'POST' and not empty param.id}">
    <sql:transaction dataSource="${dataSource}">
        <sql:update>UPDATE ideas_proyecto SET disponible = 1 WHERE id = (SELECT idea_id FROM (SELECT idea_id FROM proyectos WHERE id = ?) x) AND origen = 'banco'<sql:param value="${param.id}" /></sql:update>
        <sql:update>DELETE FROM proyectos WHERE id = ?<sql:param value="${param.id}" /></sql:update>
    </sql:transaction>
</c:if>
<c:redirect url="dashboard.jsp?sec=proyectos&msg=ok" />

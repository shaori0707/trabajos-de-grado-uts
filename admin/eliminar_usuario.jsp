<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="admin" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Elimina un usuario. No a sí mismo ni a un docente con proyectos asignados (la base lo impide: RESTRICT). Req. 80. --%>
<c:set var="error" value="" />
<c:if test="${empty param.id or param.id == sessionScope.idUsuario}"><c:set var="error" value="No puedes eliminar tu propio usuario." /></c:if>
<c:if test="${empty error}">
    <sql:query dataSource="${dataSource}" var="uso">SELECT COUNT(*) AS n FROM proyectos WHERE director_id = ? OR evaluador_id = ?
        <sql:param value="${param.id}" /><sql:param value="${param.id}" /></sql:query>
    <c:if test="${uso.rows[0].n > 0}"><c:set var="error" value="El docente tiene proyectos como director o evaluador: reasígnalos desde el panel del Comité antes de eliminarlo." /></c:if>
</c:if>
<c:if test="${empty error}">
    <sql:update dataSource="${dataSource}">DELETE FROM usuarios WHERE id = ?<sql:param value="${param.id}" /></sql:update>
    <c:redirect url="dashboard.jsp?sec=usuarios&msg=ok" />
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="usuarios" /><c:param name="err" value="${error}" /></c:redirect>

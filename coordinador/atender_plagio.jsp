<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<c:if test="${pageContext.request.method == 'POST' and not empty param.id}">
    <sql:update dataSource="${dataSource}">UPDATE alerta_plagio SET atendida = 1 WHERE id = ?<sql:param value="${param.id}" /></sql:update>
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="proyectos" /><c:param name="gestionar" value="${param.proyectoId}" /></c:redirect>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="docente" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<c:set var="idDocente" value="${sessionScope.idUsuario}" />
<%-- El director registra un seguimiento al estudiante (mínimo 2 antes del informe final). Req. 66. --%>
<c:set var="nota" value="${fn:trim(param.nota)}" />
<sql:query dataSource="${dataSource}" var="pq">SELECT id FROM proyectos WHERE id = ? AND director_id = ? AND cancelado = 0 AND estado_fase <> 'Rechazado'
    <sql:param value="${param.proyectoId}" /><sql:param value="${idDocente}" /></sql:query>
<c:if test="${pageContext.request.method == 'POST' and not empty pq.rows and not empty nota}">
    <sql:update dataSource="${dataSource}">INSERT INTO seguimiento (proyecto_id, director_id, nota) VALUES (?, ?, ?)
        <sql:param value="${param.proyectoId}" /><sql:param value="${idDocente}" /><sql:param value="${nota}" /></sql:update>
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="director" /><c:param name="ver" value="${param.proyectoId}" /></c:redirect>

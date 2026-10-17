<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="docente" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<c:set var="idDocente" value="${sessionScope.idUsuario}" />
<%-- El director informa al Comité de un posible plagio. Req. 68. --%>
<c:set var="detalle" value="${fn:trim(param.detalle)}" />
<sql:query dataSource="${dataSource}" var="pq">SELECT id FROM proyectos WHERE id = ? AND (director_id = ? OR evaluador_id = ?)
    <sql:param value="${param.proyectoId}" /><sql:param value="${idDocente}" /><sql:param value="${idDocente}" /></sql:query>
<c:if test="${pageContext.request.method == 'POST' and not empty pq.rows and not empty detalle}">
    <sql:update dataSource="${dataSource}">INSERT INTO alerta_plagio (proyecto_id, docente_id, detalle) VALUES (?, ?, ?)
        <sql:param value="${param.proyectoId}" /><sql:param value="${idDocente}" /><sql:param value="${detalle}" /></sql:update>
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="${param.volver == 'evaluador' ? 'evaluador' : 'director'}" /><c:param name="ver" value="${param.proyectoId}" /><c:param name="msg" value="ok" /></c:redirect>

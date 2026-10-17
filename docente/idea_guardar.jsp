<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="docente" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<c:set var="idDocente" value="${sessionScope.idUsuario}" />
<%-- El docente registra o edita una idea del banco (máx. 3 vigentes). Req. 4, 5, 63. --%>
<c:set var="error" value="" />
<c:set var="titulo" value="${fn:trim(param.titulo)}" /><c:set var="desc" value="${fn:trim(param.descripcion)}" />
<c:if test="${pageContext.request.method != 'POST' or empty titulo or empty desc or (param.nivel != 'tecnologia' and param.nivel != 'ingenieria')}">
    <c:set var="error" value="Completa título, descripción y nivel." />
</c:if>
<c:if test="${empty error and empty param.id}">
    <sql:query dataSource="${dataSource}" var="cnt">SELECT COUNT(*) AS n FROM ideas_proyecto WHERE creado_por = ? AND estado IN ('pendiente', 'aprobada') AND origen = 'banco'<sql:param value="${idDocente}" /></sql:query>
    <c:if test="${cnt.rows[0].n >= 3}"><c:set var="error" value="Ya tienes 3 ideas vigentes. Edita una rechazada o elimina una no tomada." /></c:if>
</c:if>
<c:if test="${empty error}">
    <c:choose>
        <c:when test="${empty param.id}">
            <sql:update dataSource="${dataSource}">INSERT INTO ideas_proyecto (titulo, descripcion, objetivos, nivel, origen, creado_por, estado, disponible, fecha_creacion) VALUES (?, ?, ?, ?, 'banco', ?, 'pendiente', 1, NOW())
                <sql:param value="${titulo}" /><sql:param value="${desc}" /><sql:param value="${param.objetivos}" /><sql:param value="${param.nivel}" /><sql:param value="${idDocente}" /></sql:update>
        </c:when>
        <c:otherwise>
            <%-- Editar una idea la devuelve a revisión del Comité; no se edita si ya fue tomada --%>
            <sql:update dataSource="${dataSource}">UPDATE ideas_proyecto SET titulo = ?, descripcion = ?, objetivos = ?, nivel = ?, estado = 'pendiente', comentario_coordinador = NULL
                 WHERE id = ? AND creado_por = ? AND disponible = 1 AND NOT EXISTS (SELECT 1 FROM proyectos p WHERE p.idea_id = ideas_proyecto.id)
                <sql:param value="${titulo}" /><sql:param value="${desc}" /><sql:param value="${param.objetivos}" /><sql:param value="${param.nivel}" /><sql:param value="${param.id}" /><sql:param value="${idDocente}" /></sql:update>
        </c:otherwise>
    </c:choose>
    <c:redirect url="dashboard.jsp?sec=ideas&msg=ok" />
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="ideas" /><c:param name="err" value="${error}" /></c:redirect>

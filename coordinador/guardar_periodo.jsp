<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Crea o actualiza un periodo y las ventanas de cada fase. Req. 43. --%>
<c:set var="error" value="" />
<c:set var="nombre" value="${fn:trim(param.nombre)}" />
<c:choose>
    <c:when test="${pageContext.request.method != 'POST' or empty nombre or fn:length(nombre) > 10 or empty param.inicio or empty param.fin}"><c:set var="error" value="Completa nombre (ej. 2026.2), inicio y fin." /></c:when>
    <c:when test="${param.fin <= param.inicio}"><c:set var="error" value="La fecha de fin debe ser posterior al inicio." /></c:when>
    <c:when test="${empty param.semana or param.semana < 1 or param.semana > 20}"><c:set var="error" value="La semana límite debe estar entre 1 y 20." /></c:when>
</c:choose>
<c:if test="${empty error}">
    <c:forEach var="i" begin="0" end="5">
        <c:set var="d" value="${paramValues.desde[i]}" /><c:set var="h" value="${paramValues.hasta[i]}" />
        <c:if test="${(empty d) != (empty h) or (not empty d and h < d)}"><c:set var="error" value="Revisa las fechas de la fase ${i + 1}." /></c:if>
    </c:forEach>
</c:if>
<c:if test="${empty error}">
    <sql:query dataSource="${dataSource}" var="dup">SELECT id FROM periodo_academico WHERE nombre = ? AND id <> ?
        <sql:param value="${nombre}" /><sql:param value="${empty param.periodoId ? 0 : param.periodoId}" /></sql:query>
    <c:if test="${not empty dup.rows}"><c:set var="error" value="Ya existe un periodo con ese nombre." /></c:if>
</c:if>
<c:if test="${empty error}">
    <sql:transaction dataSource="${dataSource}">
        <c:choose>
            <c:when test="${empty param.periodoId}">
                <sql:update>INSERT INTO periodo_academico (nombre, fecha_inicio, fecha_fin, semana_limite_propuesta, activo) VALUES (?, ?, ?, ?, 0)
                    <sql:param value="${nombre}" /><sql:param value="${param.inicio}" /><sql:param value="${param.fin}" /><sql:param value="${param.semana}" /></sql:update>
            </c:when>
            <c:otherwise>
                <sql:update>UPDATE periodo_academico SET nombre = ?, fecha_inicio = ?, fecha_fin = ?, semana_limite_propuesta = ? WHERE id = ?
                    <sql:param value="${nombre}" /><sql:param value="${param.inicio}" /><sql:param value="${param.fin}" /><sql:param value="${param.semana}" /><sql:param value="${param.periodoId}" /></sql:update>
            </c:otherwise>
        </c:choose>
        <c:forEach var="i" begin="0" end="5">
            <c:if test="${not empty paramValues.desde[i]}">
                <sql:update>
                    INSERT INTO ventana_fase (periodo_id, fase, desde, hasta)
                    SELECT id, ?, ?, ? FROM periodo_academico WHERE nombre = ?
                    ON DUPLICATE KEY UPDATE desde = VALUES(desde), hasta = VALUES(hasta)
                    <sql:param value="${i + 1}" /><sql:param value="${paramValues.desde[i]}" /><sql:param value="${paramValues.hasta[i]}" /><sql:param value="${nombre}" />
                </sql:update>
            </c:if>
        </c:forEach>
        <c:if test="${param.activo == '1'}">
            <sql:update>UPDATE periodo_academico SET activo = (nombre = ?)<sql:param value="${nombre}" /></sql:update>
        </c:if>
    </sql:transaction>
    <c:redirect url="dashboard.jsp?sec=periodos&msg=ok" />
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="periodos" /><c:param name="err" value="${error}" /></c:redirect>

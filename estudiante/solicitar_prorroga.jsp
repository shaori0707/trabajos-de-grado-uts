<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="estudiante" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- El estudiante solicita una prórroga de 180 días (máx. 2) con carta y nuevo pago. Req. 31, 62. --%>
<c:set var="estId" value="${sessionScope.idUsuario}" />
<%@ include file="/WEB-INF/fragments/estado_proyecto.jspf" %>
<c:set var="error" value="" />
<c:set var="carta" value="${fn:trim(param.urlCarta)}" /><c:set var="pago" value="${fn:trim(param.urlPago)}" />
<c:choose>
    <c:when test="${pageContext.request.method != 'POST' or empty proy}"><c:set var="error" value="No tienes un proyecto." /></c:when>
    <c:when test="${proy.cancelado == 1}"><c:set var="error" value="El proyecto está cancelado." /></c:when>
    <c:when test="${proy.bloqueado != 1 or proy.motivo_bloqueo != 'Plazo de 180 días vencido'}"><c:set var="error" value="Solo puedes pedir prórroga cuando venció el plazo de 180 días." /></c:when>
    <c:when test="${empty carta or empty pago or not (fn:startsWith(carta, 'http://') or fn:startsWith(carta, 'https://')) or not (fn:startsWith(pago, 'http://') or fn:startsWith(pago, 'https://')) or fn:contains(carta, ' ') or fn:contains(pago, ' ')}"><c:set var="error" value="Los enlaces de la carta y del pago deben empezar con http:// o https:// y no tener espacios." /></c:when>
</c:choose>
<c:if test="${empty error}">
    <sql:query dataSource="${dataSource}" var="cnt">
        SELECT COALESCE(SUM(estado = 'Aprobada'), 0) AS aprob, COALESCE(SUM(estado = 'Pendiente'), 0) AS pend, COALESCE(MAX(numero), 0) AS maxn FROM prorroga WHERE proyecto_id = ?
        <sql:param value="${proy.id}" />
    </sql:query>
    <c:choose>
        <c:when test="${cnt.rows[0].aprob >= 2}">
            <%-- Prórrogas agotadas: el proyecto se cancela y debe empezar en otra modalidad --%>
            <sql:update dataSource="${dataSource}">UPDATE proyectos SET cancelado = 1, motivo_bloqueo = 'Prórrogas agotadas' WHERE id = ?<sql:param value="${proy.id}" /></sql:update>
            <c:redirect url="dashboard.jsp"><c:param name="sec" value="dashboard" /><c:param name="err" value="Ya usaste las 2 prórrogas: el proyecto se canceló y debes empezar en otra modalidad." /></c:redirect>
        </c:when>
        <c:when test="${cnt.rows[0].pend > 0}"><c:set var="error" value="Ya tienes una solicitud pendiente." /></c:when>
    </c:choose>
</c:if>
<c:if test="${empty error}">
    <sql:update dataSource="${dataSource}">
        INSERT INTO prorroga (proyecto_id, numero, url_carta, url_pago, solo_correcciones) VALUES (?, ?, ?, ?, ?)
        <sql:param value="${proy.id}" /><sql:param value="${cnt.rows[0].maxn + 1}" /><sql:param value="${carta}" /><sql:param value="${pago}" /><sql:param value="${param.soloCorrecciones == '1' ? 1 : 0}" />
    </sql:update>
    <c:redirect url="dashboard.jsp?sec=dashboard&msg=prorroga_ok" />
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="dashboard" /><c:param name="err" value="${error}" /></c:redirect>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="estudiante" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Registra los enlaces URL de la fase actual (fases 1, 2 y 4). Req. 13, 17, 19, 28, 33-37. --%>
<c:set var="estId" value="${sessionScope.idUsuario}" />
<%@ include file="/WEB-INF/fragments/estado_proyecto.jspf" %>

<c:set var="error" value="" />
<c:choose>
    <c:when test="${pageContext.request.method != 'POST' or empty proy}">
        <c:set var="error" value="No tienes un proyecto para entregar." />
    </c:when>
    <c:when test="${param.fase != proy.fase_actual}">
        <c:set var="error" value="La fase ya cambió. Vuelve a abrir la entrega." />
    </c:when>
    <c:when test="${not empty proy.motivo_no_entrega}">
        <c:set var="error" value="${proy.motivo_no_entrega}" />
    </c:when>
    <c:when test="${proy.estado_fase != 'Pendiente de entrega' and proy.estado_fase != 'Aplazado'}">
        <c:set var="error" value="Esta fase no admite entregas ahora." />
    </c:when>
</c:choose>

<c:if test="${empty error}">
    <c:choose>
        <c:when test="${proy.fase_actual == 1}"><c:set var="tipos" value="Pago" /></c:when>
        <c:when test="${proy.fase_actual == 2}"><c:set var="tipos" value="F-124,Rejilla,Turnitin" /></c:when>
        <c:otherwise><c:set var="tipos" value="F-125,F-129,Turnitin" /></c:otherwise>
    </c:choose>
    <%-- Validar cada enlace: no vacío, http:// o https://, sin espacios (req. 35) --%>
    <c:forEach var="tipo" items="${fn:split(tipos, ',')}" varStatus="st">
        <c:set var="u" value="${st.index == 0 ? param.u1 : (st.index == 1 ? param.u2 : param.u3)}" />
        <c:set var="u" value="${fn:trim(u)}" />
        <c:if test="${empty u or not (fn:startsWith(u, 'http://') or fn:startsWith(u, 'https://')) or fn:contains(u, ' ') or fn:length(u) > 500 or fn:length(u) < 9}">
            <c:set var="error" value="El enlace de ${tipo} no es válido: debe empezar con http:// o https://, no estar vacío ni tener espacios." />
        </c:if>
    </c:forEach>
</c:if>

<c:if test="${empty error}">
    <sql:transaction dataSource="${dataSource}">
        <c:forEach var="tipo" items="${fn:split(tipos, ',')}" varStatus="st">
            <c:set var="u" value="${fn:trim(st.index == 0 ? param.u1 : (st.index == 1 ? param.u2 : param.u3))}" />
            <sql:update>
                INSERT INTO entrega (proyecto_id, fase, tipo, url, estudiante_id, version)
                SELECT ?, ?, ?, ?, ?, COALESCE(MAX(version), 0) + 1 FROM entrega
                 WHERE proyecto_id = ? AND fase = ? AND tipo = ?
                <sql:param value="${proy.id}" /><sql:param value="${proy.fase_actual}" />
                <sql:param value="${tipo}" /><sql:param value="${u}" /><sql:param value="${estId}" />
                <sql:param value="${proy.id}" /><sql:param value="${proy.fase_actual}" /><sql:param value="${tipo}" />
            </sql:update>
        </c:forEach>
        <%-- Fase 1: cada integrante registra SU PROPIO pago; pasa al Comité cuando todos pagaron (req. 13) --%>
        <sql:query var="pagosOk">
            SELECT (SELECT COUNT(*) FROM proyecto_estudiantes WHERE proyecto_id = ?) AS total,
                   (SELECT COUNT(DISTINCT e.estudiante_id) FROM entrega e
                     WHERE e.proyecto_id = ? AND e.fase = 1 AND e.tipo = 'Pago'
                       AND e.estudiante_id IN (SELECT estudiante_id FROM proyecto_estudiantes WHERE proyecto_id = ?)
                       AND e.fecha > COALESCE((SELECT MAX(r.fecha) FROM revision r WHERE r.proyecto_id = ? AND r.fase = 1), '2000-01-01')) AS pagaron
            <sql:param value="${proy.id}" /><sql:param value="${proy.id}" /><sql:param value="${proy.id}" /><sql:param value="${proy.id}" />
        </sql:query>
        <c:set var="todosPagaron" value="${proy.fase_actual != 1 or pagosOk.rows[0].pagaron >= pagosOk.rows[0].total}" />
        <c:if test="${todosPagaron}">
        <sql:update>
            UPDATE proyectos SET estado_fase = 'En revisión', responsable = ?,
                   fecha_inicio_fase = NOW(),
                   fecha_limite_revision = CASE WHEN ? = 'Comité' THEN NULL ELSE DATE_ADD(NOW(), INTERVAL 5 DAY) END
             WHERE id = ?
            <sql:param value="${proy.fase_actual == 1 ? 'Comité' : 'Director'}" />
            <sql:param value="${proy.fase_actual == 1 ? 'Comité' : 'Director'}" />
            <sql:param value="${proy.id}" />
        </sql:update>
        </c:if>
    </sql:transaction>
    <c:redirect url="dashboard.jsp?sec=dashboard&msg=${todosPagaron ? 'entrega_ok' : 'pago_ok'}" />
</c:if>

<c:redirect url="dashboard.jsp">
    <c:param name="sec" value="dashboard" />
    <c:param name="err" value="${error}" />
</c:redirect>

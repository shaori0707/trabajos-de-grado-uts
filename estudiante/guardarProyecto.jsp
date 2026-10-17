<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="estudiante" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Crea el proyecto (fase 1) a partir de una idea. Req. 7-12, 15, 16, 52, 56. --%>
<c:set var="estId" value="${sessionScope.idUsuario}" />
<c:set var="error" value="" />

<c:if test="${pageContext.request.method != 'POST' or empty param.ideaId}">
    <c:set var="error" value="Selecciona una idea." />
</c:if>

<c:if test="${empty error}">
    <sql:query dataSource="${dataSource}" var="yo">
        SELECT id, nivel, cedula FROM usuarios WHERE id = ? AND rol = 'estudiante' AND estado = 1
        <sql:param value="${estId}" />
    </sql:query>
    <sql:query dataSource="${dataSource}" var="periodo">
        SELECT id, nombre FROM periodo_academico WHERE activo = 1 ORDER BY id DESC LIMIT 1
    </sql:query>
    <sql:query dataSource="${dataSource}" var="idea">
        SELECT id, titulo, descripcion, nivel, origen, creado_por FROM ideas_proyecto
         WHERE id = ? AND estado = 'aprobada' AND disponible = 1
        <sql:param value="${param.ideaId}" />
    </sql:query>
    <c:choose>
        <c:when test="${empty yo.rows or empty yo.rows[0].cedula or empty yo.rows[0].nivel}">
            <c:set var="error" value="Tu perfil no tiene cédula o nivel. Pide al administrador que lo complete." />
        </c:when>
        <c:when test="${empty periodo.rows}">
            <c:set var="error" value="No hay un periodo académico activo." />
        </c:when>
        <c:when test="${empty idea.rows}">
            <c:set var="error" value="La idea no existe, no está aprobada o ya fue tomada." />
        </c:when>
        <c:when test="${idea.rows[0].nivel != yo.rows[0].nivel}">
            <c:set var="error" value="Solo puedes escoger ideas de tu mismo nivel." />
        </c:when>
        <c:when test="${idea.rows[0].origen == 'propia' and idea.rows[0].creado_por != estId}">
            <c:set var="error" value="Esa idea propia pertenece a otro estudiante." />
        </c:when>
    </c:choose>
</c:if>

<%-- Un estudiante solo puede pertenecer a un proyecto activo: se valida por cédula (req. 10) --%>
<c:if test="${empty error}">
    <sql:query dataSource="${dataSource}" var="activos">
        SELECT COUNT(*) AS n FROM proyecto_estudiantes pe
          JOIN usuarios u ON u.id = pe.estudiante_id
          JOIN proyectos p ON p.id = pe.proyecto_id
         WHERE u.cedula = ? AND p.cancelado = 0 AND p.estado_fase <> 'Rechazado'
        <sql:param value="${yo.rows[0].cedula}" />
    </sql:query>
    <c:if test="${activos.rows[0].n > 0}">
        <c:set var="error" value="Ya perteneces a un proyecto activo." />
    </c:if>
</c:if>

<%-- Compañero opcional (0 = No aplica) --%>
<c:set var="companeroId" value="${empty param.companeroId ? 0 : param.companeroId}" />
<c:if test="${empty error and companeroId != 0}">
    <sql:query dataSource="${dataSource}" var="comp">
        SELECT u.id FROM usuarios u
         WHERE u.id = ? AND u.id <> ? AND u.rol = 'estudiante' AND u.estado = 1 AND u.nivel = ?
           AND NOT EXISTS (SELECT 1 FROM proyecto_estudiantes pe JOIN proyectos p ON p.id = pe.proyecto_id
                            WHERE pe.estudiante_id = u.id AND p.cancelado = 0 AND p.estado_fase <> 'Rechazado')
        <sql:param value="${companeroId}" />
        <sql:param value="${estId}" />
        <sql:param value="${yo.rows[0].nivel}" />
    </sql:query>
    <c:if test="${empty comp.rows}">
        <c:set var="error" value="El compañero no es válido: debe ser del mismo nivel y no tener proyecto activo." />
    </c:if>
</c:if>

<%-- Tercer integrante: solo interdisciplinario o muy robusto (req. 12) --%>
<c:set var="companero2Id" value="${empty param.companero2Id ? 0 : param.companero2Id}" />
<c:if test="${empty error and companero2Id != 0}">
    <c:choose>
        <c:when test="${companeroId == 0 or companero2Id == companeroId}"><c:set var="error" value="El tercer integrante requiere un segundo compañero distinto." /></c:when>
        <c:when test="${param.motivoTercero != 'Interdisciplinario' and param.motivoTercero != 'Proyecto robusto'}"><c:set var="error" value="Indica si el proyecto es interdisciplinario o muy robusto para tener 3 integrantes." /></c:when>
        <c:otherwise>
            <sql:query dataSource="${dataSource}" var="comp2">
                SELECT u.id FROM usuarios u
                 WHERE u.id = ? AND u.id <> ? AND u.rol = 'estudiante' AND u.estado = 1 AND u.nivel = ?
                   AND NOT EXISTS (SELECT 1 FROM proyecto_estudiantes pe JOIN proyectos p ON p.id = pe.proyecto_id
                                    WHERE pe.estudiante_id = u.id AND p.cancelado = 0 AND p.estado_fase <> 'Rechazado')
                <sql:param value="${companero2Id}" /><sql:param value="${estId}" /><sql:param value="${yo.rows[0].nivel}" />
            </sql:query>
            <c:if test="${empty comp2.rows}"><c:set var="error" value="El tercer integrante no es válido: debe ser del mismo nivel y no tener proyecto activo." /></c:if>
        </c:otherwise>
    </c:choose>
</c:if>

<c:if test="${empty error}">
    <c:set var="modalidad" value="${param.modalidad}" />
    <c:if test="${modalidad != 'Monografía' and modalidad != 'Proyecto de investigación' and modalidad != 'Desarrollo tecnológico'}">
        <c:set var="modalidad" value="Desarrollo tecnológico" />
    </c:if>
    <c:set var="prefijo" value="${yo.rows[0].nivel == 'tecnologia' ? '65' : '125'}" />

    <sql:transaction dataSource="${dataSource}">
        <%-- Código único: 65/125 + semestre + consecutivo que se reinicia cada semestre (req. 15) --%>
        <sql:update>
            INSERT INTO proyectos (titulo, descripcion, creado_por, idea_id, periodo_id, modalidad, fase_actual,
                                   estado_fase, responsable, director_sugerido_id, codigo, consecutivo, fecha_inicio_fase)
            SELECT ?, ?, ?, ?, ?, ?, 1, 'Pendiente de entrega', 'Estudiante', ?,
                   CONCAT(?, '-', REPLACE(?, '.', ''), '-', LPAD(c.sig, 3, '0')), c.sig, NOW()
              FROM (SELECT COALESCE(MAX(consecutivo), 0) + 1 AS sig FROM proyectos WHERE periodo_id = ?) c
            <sql:param value="${idea.rows[0].titulo}" />
            <sql:param value="${idea.rows[0].descripcion}" />
            <sql:param value="${estId}" />
            <sql:param value="${idea.rows[0].id}" />
            <sql:param value="${periodo.rows[0].id}" />
            <sql:param value="${modalidad}" />
            <sql:param value="${empty param.directorSugerido ? null : param.directorSugerido}" />
            <sql:param value="${prefijo}" />
            <sql:param value="${periodo.rows[0].nombre}" />
            <sql:param value="${periodo.rows[0].id}" />
        </sql:update>
        <sql:update>
            INSERT INTO proyecto_estudiantes (proyecto_id, estudiante_id)
            SELECT p.id, ? FROM proyectos p WHERE p.idea_id = ? AND p.creado_por = ? ORDER BY p.id DESC LIMIT 1
            <sql:param value="${estId}" />
            <sql:param value="${idea.rows[0].id}" />
            <sql:param value="${estId}" />
        </sql:update>
        <c:if test="${companeroId != 0}">
            <sql:update>
                INSERT INTO proyecto_estudiantes (proyecto_id, estudiante_id)
                SELECT p.id, ? FROM proyectos p WHERE p.idea_id = ? AND p.creado_por = ? ORDER BY p.id DESC LIMIT 1
                <sql:param value="${companeroId}" />
                <sql:param value="${idea.rows[0].id}" />
                <sql:param value="${estId}" />
            </sql:update>
            <sql:update>UPDATE usuarios SET companero_id = ? WHERE id = ?
                <sql:param value="${companeroId}" /><sql:param value="${estId}" /></sql:update>
        </c:if>
        <c:if test="${companero2Id != 0}">
            <sql:update>
                INSERT INTO proyecto_estudiantes (proyecto_id, estudiante_id)
                SELECT p.id, ? FROM proyectos p WHERE p.idea_id = ? AND p.creado_por = ? ORDER BY p.id DESC LIMIT 1
                <sql:param value="${companero2Id}" /><sql:param value="${idea.rows[0].id}" /><sql:param value="${estId}" />
            </sql:update>
            <sql:update>UPDATE proyectos SET interdisciplinario = ?, motivo_tercer = ? WHERE idea_id = ? AND creado_por = ? ORDER BY id DESC LIMIT 1
                <sql:param value="${param.motivoTercero == 'Interdisciplinario' ? 1 : 0}" /><sql:param value="${param.motivoTercero}" /><sql:param value="${idea.rows[0].id}" /><sql:param value="${estId}" /></sql:update>
        </c:if>
        <%-- Idea del banco tomada: queda no disponible (req. 9) --%>
        <sql:update>UPDATE ideas_proyecto SET disponible = 0 WHERE id = ?
            <sql:param value="${idea.rows[0].id}" /></sql:update>
    </sql:transaction>
    <c:redirect url="dashboard.jsp?sec=dashboard&msg=proyecto_creado" />
</c:if>

<c:redirect url="dashboard.jsp">
    <c:param name="sec" value="seleccionarIdea" />
    <c:param name="err" value="${error}" />
</c:redirect>

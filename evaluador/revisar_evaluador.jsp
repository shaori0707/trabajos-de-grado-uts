<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="evaluador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<c:set var="idDocente" value="${sessionScope.idUsuario}" />
<%-- El evaluador evalúa con la rejilla la propuesta (fase 3) o el informe (fase 5). Req. 20-24, 70-72. --%>
<c:set var="error" value="" />
<c:set var="dec" value="${param.decision}" />
<c:set var="obs" value="${fn:trim(param.observacion)}" />
<sql:query dataSource="${dataSource}" var="pq">
    SELECT p.id, p.fase_actual, p.estado_fase, p.responsable, p.bloqueado, p.cancelado,
           (SELECT COUNT(*) FROM revision r WHERE r.proyecto_id = p.id AND r.fase = p.fase_actual - 1 AND r.rol_revisor = 'Director' AND r.estado = 'Aprobado' AND r.firma = 1) AS firma_director
      FROM proyectos p WHERE p.id = ? AND p.evaluador_id = ?
    <sql:param value="${param.proyectoId}" /><sql:param value="${idDocente}" />
</sql:query>
<c:choose>
    <c:when test="${pageContext.request.method != 'POST' or empty pq.rows}"><c:set var="error" value="Proyecto no encontrado." /></c:when>
    <c:when test="${pq.rows[0].cancelado == 1 or pq.rows[0].bloqueado == 1}"><c:set var="error" value="El proyecto está bloqueado o cancelado." /></c:when>
    <c:when test="${(pq.rows[0].fase_actual != 3 and pq.rows[0].fase_actual != 5) or pq.rows[0].estado_fase != 'En revisión' or pq.rows[0].responsable != 'Evaluador'}"><c:set var="error" value="Este proyecto no está pendiente de tu evaluación." /></c:when>
    <c:when test="${dec != 'Aprobado' and dec != 'Aplazado' and dec != 'Rechazado'}"><c:set var="error" value="Elige una decisión." /></c:when>
    <c:when test="${param.cumpleGeneral == null or param.cumpleEspecificos == null}"><c:set var="error" value="Completa la rejilla (objetivo general y específicos)." /></c:when>
    <c:when test="${dec != 'Aprobado' and empty obs}"><c:set var="error" value="Aplazado y Rechazado exigen observaciones." /></c:when>
    <c:when test="${dec == 'Rechazado' and param.confirmar != '1'}"><c:set var="error" value="Confirma el rechazo: termina el proyecto." /></c:when>
    <c:when test="${dec == 'Aprobado' and param.firma != '1'}"><c:set var="error" value="No se puede aprobar sin tu firma en el documento." /></c:when>
    <c:when test="${dec == 'Aprobado' and (param.cumpleGeneral != '1' or param.cumpleEspecificos != '1')}"><c:set var="error" value="Para aprobar, la rejilla debe cumplir el objetivo general y los específicos." /></c:when>
    <c:when test="${dec == 'Aprobado' and pq.rows[0].firma_director == 0}"><c:set var="error" value="Falta la firma del director en la fase anterior." /></c:when>
</c:choose>
<c:if test="${empty error}">
    <c:set var="fase" value="${pq.rows[0].fase_actual}" />
    <sql:transaction dataSource="${dataSource}">
        <sql:update>
            INSERT INTO revision (proyecto_id, fase, revisor_id, rol_revisor, estado, observacion, firma, cumple_general, cumple_especificos)
            VALUES (?, ?, ?, 'Evaluador', ?, ?, ?, ?, ?)
            <sql:param value="${param.proyectoId}" /><sql:param value="${fase}" /><sql:param value="${idDocente}" />
            <sql:param value="${dec}" /><sql:param value="${empty obs ? null : obs}" /><sql:param value="${param.firma == '1' ? 1 : 0}" />
            <sql:param value="${param.cumpleGeneral == '1' ? 1 : 0}" /><sql:param value="${param.cumpleEspecificos == '1' ? 1 : 0}" />
        </sql:update>
        <c:choose>
            <c:when test="${dec == 'Aprobado' and fase == 3}">
                <%-- Propuesta aprobada: arranca el conteo de 90/180 días para el informe (req. 28) --%>
                <sql:update>UPDATE proyectos SET fase_actual = 4, estado_fase = 'Pendiente de entrega', responsable = 'Estudiante',
                        fecha_aprobacion_propuesta = NOW(), fecha_inicio_fase = NOW(), fecha_limite_revision = NULL WHERE id = ?<sql:param value="${param.proyectoId}" /></sql:update>
            </c:when>
            <c:when test="${dec == 'Aprobado'}">
                <sql:update>UPDATE proyectos SET fase_actual = 6, estado_fase = 'En revisión', responsable = 'Comité',
                        fecha_inicio_fase = NOW(), fecha_limite_revision = NULL WHERE id = ?<sql:param value="${param.proyectoId}" /></sql:update>
            </c:when>
            <c:when test="${dec == 'Aplazado'}">
                <%-- Se devuelve a la fase de entrega del estudiante para que corrija y registre un nuevo enlace --%>
                <sql:update>UPDATE proyectos SET fase_actual = fase_actual - 1, estado_fase = 'Aplazado', responsable = 'Estudiante', fecha_limite_revision = NULL WHERE id = ?<sql:param value="${param.proyectoId}" /></sql:update>
            </c:when>
            <c:otherwise>
                <sql:update>UPDATE proyectos SET estado_fase = 'Rechazado', fecha_limite_revision = NULL WHERE id = ?<sql:param value="${param.proyectoId}" /></sql:update>
            </c:otherwise>
        </c:choose>
    </sql:transaction>
    <c:redirect url="dashboard.jsp"><c:param name="sec" value="evaluador" /><c:param name="msg" value="ok" /></c:redirect>
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="evaluador" /><c:param name="ver" value="${param.proyectoId}" /><c:param name="err" value="${error}" /></c:redirect>

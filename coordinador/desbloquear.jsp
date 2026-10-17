<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Desbloquea un proyecto frenado por plazo de revisión vencido y da 5 días más al responsable. --%>
<c:if test="${pageContext.request.method == 'POST' and not empty param.proyectoId}">
    <sql:update dataSource="${dataSource}">
        UPDATE proyectos SET bloqueado = 0, motivo_bloqueo = NULL, fecha_limite_revision = DATE_ADD(NOW(), INTERVAL 5 DAY)
         WHERE id = ? AND bloqueado = 1 AND cancelado = 0 AND motivo_bloqueo = 'Plazo de revisión vencido'
        <sql:param value="${param.proyectoId}" />
    </sql:update>
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="proyectos" /><c:param name="gestionar" value="${param.proyectoId}" /><c:param name="msg" value="ok" /></c:redirect>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="coordinador" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Registra un enlace en la base documental (solo URL http/https). Req. 44, 81. --%>
<c:set var="url" value="${fn:trim(param.ruta_archivo)}" />
<c:set var="sec" value="${empty param.sec ? 'formatos' : param.sec}" />
<c:choose>
    <c:when test="${pageContext.request.method == 'POST' and not empty fn:trim(param.nombre) and (fn:startsWith(url, 'http://') or fn:startsWith(url, 'https://')) and not fn:contains(url, ' ') and fn:length(url) <= 255}">
        <sql:update dataSource="${dataSource}">
            INSERT INTO formatos_grado (nombre, descripcion, ruta_archivo, tipo, subido_por, fecha_subida) VALUES (?, ?, ?, ?, ?, NOW())
            <sql:param value="${fn:trim(param.nombre)}" /><sql:param value="${param.descripcion}" /><sql:param value="${url}" />
            <sql:param value="${empty param.tipo ? 'formato' : param.tipo}" /><sql:param value="${sessionScope.idUsuario}" />
        </sql:update>
        <c:redirect url="dashboard.jsp?sec=${sec}&msg=ok" />
    </c:when>
    <c:otherwise><c:redirect url="dashboard.jsp"><c:param name="sec" value="${sec}" /><c:param name="err" value="El enlace debe empezar con http:// o https:// y no tener espacios." /></c:redirect></c:otherwise>
</c:choose>

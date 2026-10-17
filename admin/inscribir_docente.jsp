<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="admin" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- El Comité inscribe docentes con solo tres datos: cédula, correo y nombre. Req. 3, 79. --%>
<c:set var="error" value="" />
<c:set var="correo" value="${fn:toLowerCase(fn:trim(param.correo))}" />
<c:set var="cedula" value="${fn:trim(param.cedula)}" />
<c:set var="nombre" value="${fn:trim(param.nombre)}" />
<c:if test="${pageContext.request.method != 'POST' or empty correo or empty cedula or empty nombre}"><c:set var="error" value="Completa cédula, correo y nombre." /></c:if>
<c:if test="${empty error and (fn:length(cedula) < 5 or fn:length(cedula) > 15)}"><c:set var="error" value="La cédula debe tener entre 5 y 15 dígitos." /></c:if>
<c:if test="${empty error}">
    <sql:query dataSource="${dataSource}" var="cfg">SELECT valor FROM configuracion WHERE clave = 'dominios_correo'</sql:query>
    <c:set var="inst" value="${false}" />
    <c:forEach var="dom" items="${fn:split(empty cfg.rows ? 'uts.edu.co,correo.uts.edu.co' : cfg.rows[0].valor, ',')}">
        <c:set var="sufijo" value="@${fn:trim(dom)}" />
        <c:if test="${fn:endsWith(correo, sufijo)}"><c:set var="inst" value="${true}" /></c:if>
    </c:forEach>
    <c:if test="${not inst}"><c:set var="error" value="El correo debe ser institucional." /></c:if>
</c:if>
<c:if test="${empty error}">
    <sql:query dataSource="${dataSource}" var="dup">SELECT id FROM usuarios WHERE email = ? OR cedula = ?
        <sql:param value="${correo}" /><sql:param value="${cedula}" /></sql:query>
    <c:if test="${not empty dup.rows}"><c:set var="error" value="Ya existe un usuario con ese correo o cédula." /></c:if>
</c:if>
<c:if test="${empty error}">
    <%-- Contraseña inicial = cédula, guardada con SHA2 (req. 48); el docente debe cambiarla --%>
    <sql:update dataSource="${dataSource}">
        INSERT INTO usuarios (nombre, email, cedula, password, rol, estado) VALUES (?, ?, ?, SHA2(?, 256), ?, 1)
        <sql:param value="${nombre}" /><sql:param value="${correo}" /><sql:param value="${cedula}" /><sql:param value="${cedula}" /><sql:param value="${param.rol == 'evaluador' ? 'evaluador' : 'docente'}" />
    </sql:update>
    <c:redirect url="dashboard.jsp?sec=docentes&msg=ok" />
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="docentes" /><c:param name="err" value="${error}" /></c:redirect>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="admin" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Crea un usuario con cualquier rol. La contraseña se guarda con SHA2. Req. 80, 48. --%>
<c:set var="correo" value="${fn:toLowerCase(fn:trim(param.email))}" />
<c:set var="cedula" value="${fn:trim(param.cedula)}" />
<c:set var="error" value="" />
<c:if test="${pageContext.request.method != 'POST' or empty fn:trim(param.nombre) or empty correo or (param.rol != 'admin' and param.rol != 'coordinador' and param.rol != 'docente' and param.rol != 'evaluador' and param.rol != 'estudiante')}"><c:set var="error" value="Completa nombre, correo y rol." /></c:if>
<c:if test="${empty error and (param.rol == 'docente' or param.rol == 'evaluador' or param.rol == 'estudiante') and (fn:length(cedula) < 5 or fn:length(cedula) > 15)}"><c:set var="error" value="La cédula (5 a 15 dígitos) es obligatoria para docentes, evaluadores y estudiantes." /></c:if>
<c:if test="${empty error and param.rol == 'estudiante' and param.nivel != 'tecnologia' and param.nivel != 'ingenieria'}"><c:set var="error" value="Indica el nivel del estudiante (tecnología o ingeniería)." /></c:if>
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
    <sql:query dataSource="${dataSource}" var="dup">SELECT id FROM usuarios WHERE (email = ? OR (? <> '' AND cedula = ?)) AND id <> ?
        <sql:param value="${correo}" /><sql:param value="${cedula}" /><sql:param value="${cedula}" /><sql:param value="${empty param.id ? 0 : param.id}" /></sql:query>
    <c:if test="${not empty dup.rows}"><c:set var="error" value="Ya existe un usuario con ese correo o cédula." /></c:if>
</c:if>
<c:if test="${empty error and fn:length(param.password) < 6}"><c:set var="error" value="La contraseña debe tener al menos 6 caracteres." /></c:if>
<c:if test="${empty error}">
    <sql:update dataSource="${dataSource}">
        INSERT INTO usuarios (nombre, apellido, email, password, rol, codigo, cedula, nivel, estado)
        VALUES (?, ?, ?, SHA2(?, 256), ?, ?, ?, ?, 1)
        <sql:param value="${fn:trim(param.nombre)}" /><sql:param value="${fn:trim(param.apellido)}" /><sql:param value="${correo}" />
        <sql:param value="${param.password}" /><sql:param value="${param.rol}" />
        <sql:param value="${empty fn:trim(param.codigo) ? null : fn:trim(param.codigo)}" />
        <sql:param value="${empty cedula ? null : cedula}" />
        <sql:param value="${param.rol == 'estudiante' ? param.nivel : null}" />
    </sql:update>
    <c:redirect url="dashboard.jsp?sec=usuarios&msg=ok" />
</c:if>
<c:redirect url="dashboard.jsp"><c:param name="sec" value="usuarios" /><c:param name="err" value="${error}" /></c:redirect>

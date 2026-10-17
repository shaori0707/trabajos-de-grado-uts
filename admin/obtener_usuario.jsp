<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="rolRequerido" value="admin" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<%@ include file="/WEB-INF/fragments/conexion.jspf" %>
<%-- Devuelve los datos de un usuario como clave=valor (valores codificados) para el modal de edición. --%>
<c:if test="${not empty param.id}">
<sql:query dataSource="${dataSource}" var="usuario">
SELECT id, nombre, apellido, email, rol, codigo, cedula, nivel, COALESCE(estado, 1) AS estado FROM usuarios WHERE id = ?
<sql:param value="${param.id}"/>
</sql:query>
<c:forEach var="u" items="${usuario.rows}">nombre=${fn:replace(fn:replace(u.nombre, '%', '%25'), '&', '%26')}&apellido=${fn:replace(fn:replace(u.apellido, '%', '%25'), '&', '%26')}&email=${u.email}&rol=${u.rol}&estado=${u.estado}&codigo=${u.codigo}&cedula=${u.cedula}&nivel=${u.nivel}</c:forEach>
</c:if>

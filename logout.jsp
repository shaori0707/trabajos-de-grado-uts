<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:remove var="usuario" scope="session" />
<c:remove var="rol" scope="session" />
<c:remove var="idUsuario" scope="session" />
<c:remove var="nombreUsuario" scope="session" />

<c:redirect url="index.jsp" />
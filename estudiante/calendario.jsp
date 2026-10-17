<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>
<c:set var="rolRequerido" value="estudiante" scope="page" />
<%@ include file="/WEB-INF/fragments/validar_sesion.jspf" %>

<%@ include file="/WEB-INF/fragments/conexion.jspf" %>

<c:set var="idEstudiante" value="${sessionScope.idUsuario}" />
<jsp:useBean id="fechaActual" class="java.util.Date" />

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calendario - Estudiante UTS</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        :root {
            --color-principal: #28A745;
            --color-principal-hover: #1B8C3A;
            --color-info: #17A2B8;
            --color-warning: #FD7E14;
            --color-danger: #DC3545;
            --color-dark: #2C3E50;
            --color-gray: #6C757D;
            --color-gray-light: #F4F7FC;
            --color-white: #FFFFFF;
            --color-border: #E9ECEF;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: var(--color-gray-light); }
        .container { max-width: 1200px; margin: 0 auto; padding: 40px 20px; }
        .banner-fecha {
            background: linear-gradient(135deg, var(--color-principal) 0%, var(--color-principal-hover) 100%);
            border-radius: 24px;
            padding: 20px 25px;
            margin-bottom: 30px;
            color: white;
        }
        .section-card {
            background: white;
            border-radius: 24px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.03);
            border: 1px solid var(--color-border);
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #F0F2F5;
            flex-wrap: wrap;
            gap: 15px;
        }
        .section-header h3 { font-size: 1.2rem; font-weight: 700; color: var(--color-dark); }
        .section-header h3 i { color: var(--color-principal); margin-right: 10px; }
        .action-btn {
            background: var(--color-principal);
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }
        .action-btn:hover { background: var(--color-principal-hover); transform: translateY(-2px); }
        .btn-outline { background: transparent; color: var(--color-principal); border: 1px solid var(--color-principal); }
        .btn-outline:hover { background: var(--color-principal); color: white; }
        .badge { padding: 4px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; }
        .btn-volver { background: #6C757D; color: white; padding: 10px 20px; border-radius: 30px; text-decoration: none; display: inline-block; margin-top: 20px; }
        .calendario-container {
            background: white;
            border-radius: 20px;
            overflow: hidden;
            border: 1px solid #E9ECEF;
            margin-bottom: 25px;
        }
        .calendario-header {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            background: #28A745;
            color: white;
            text-align: center;
            padding: 12px 0;
            font-weight: 600;
        }
        .calendario-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            min-height: 350px;
        }
        .calendario-dia {
            border: 1px solid #F0F2F5;
            min-height: 80px;
            padding: 8px;
            position: relative;
        }
        .calendario-dia.otro-mes {
            background: #F8FAFE;
            color: #ADB5BD;
        }
        .calendario-dia.evento {
            background: #E8F5E9;
        }
        .calendario-dia.evento .dia-numero {
            font-weight: 700;
            color: #28A745;
        }
        .dia-numero {
            font-weight: 500;
            font-size: 0.9rem;
        }
        @media (max-width: 768px) {
            .container { padding: 20px; }
            .calendario-dia { min-height: 50px; font-size: 0.8rem; }
        }
    </style>
</head>
<body>

<div class="container">
    <!-- ==================== CALENDARIO ==================== -->
    <div class="banner-fecha">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <h2 style="font-size: 1.3rem;"><i class="fas fa-calendar-alt"></i> Calendario Académico</h2>
                <p>Consulta las fechas importantes del calendario académico</p>
            </div>
            <div>
                <span style="background: rgba(255,255,255,0.2); padding: 6px 16px; border-radius: 40px;">
                    <i class="fas fa-calendar-alt"></i> <fmt:formatDate value="${fechaActual}" pattern="dd/MM/yyyy" />
                </span>
            </div>
        </div>
    </div>
    
    <!-- Variables para el calendario -->
    <c:set var="añoActualCal" value="${param.año != null ? param.año : fechaActual.year + 1900}" />
    <c:set var="mesActualCal" value="${param.mes != null ? param.mes : fechaActual.month + 1}" />
    
    <!-- Calcular mes anterior y siguiente -->
    <c:set var="mesPrevCal" value="${mesActualCal - 1}" />
    <c:set var="añoPrevCal" value="${añoActualCal}" />
    <c:if test="${mesPrevCal < 1}">
        <c:set var="mesPrevCal" value="12" />
        <c:set var="añoPrevCal" value="${añoActualCal - 1}" />
    </c:if>
    
    <c:set var="mesNextCal" value="${mesActualCal + 1}" />
    <c:set var="añoNextCal" value="${añoActualCal}" />
    <c:if test="${mesNextCal > 12}">
        <c:set var="mesNextCal" value="1" />
        <c:set var="añoNextCal" value="${añoActualCal + 1}" />
    </c:if>
    
    <!-- Obtener eventos del mes -->
    <c:set var="fechaInicioCal" value="${añoActualCal}-${mesActualCal < 10 ? '0' : ''}${mesActualCal}-01" />
    <c:set var="ultimoDia" value="31" />
    <c:choose>
        <c:when test="${mesActualCal == 2}">
            <c:set var="ultimoDia" value="28" />
            <c:if test="${(añoActualCal % 4 == 0 and añoActualCal % 100 != 0) or (añoActualCal % 400 == 0)}">
                <c:set var="ultimoDia" value="29" />
            </c:if>
        </c:when>
        <c:when test="${mesActualCal == 4 or mesActualCal == 6 or mesActualCal == 9 or mesActualCal == 11}">
            <c:set var="ultimoDia" value="30" />
        </c:when>
    </c:choose>
    <c:set var="fechaFinCal" value="${añoActualCal}-${mesActualCal < 10 ? '0' : ''}${mesActualCal}-${ultimoDia}" />
    
    <sql:query dataSource="${dataSource}" var="eventosMesCal">
        SELECT id, titulo, descripcion, fecha_evento, tipo FROM calendario_academico 
        WHERE fecha_evento BETWEEN ? AND ? 
        ORDER BY fecha_evento
        <sql:param value="${fechaInicioCal}" />
        <sql:param value="${fechaFinCal}" />
    </sql:query>
    
    <!-- Obtener el nombre del mes -->
    <c:set var="mesesNombre" value="Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre" />
    <c:set var="mesNombreCal" value="${fn:split(mesesNombre, ',')[mesActualCal - 1]}" />
    
    <div class="section-card">
        <div class="section-header">
            <h3><i class="fas fa-calendar-alt"></i> ${mesNombreCal} ${añoActualCal}</h3>
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                <a href="calendario.jsp?mes=${mesPrevCal}&año=${añoPrevCal}" class="action-btn" style="background:#6C757D; color:white;">
                    <i class="fas fa-chevron-left"></i> Mes anterior
                </a>
                <a href="calendario.jsp?mes=${mesNextCal}&año=${añoNextCal}" class="action-btn" style="background:#6C757D; color:white;">
                    Mes siguiente <i class="fas fa-chevron-right"></i>
                </a>
                <a href="https://www.uts.edu.co/sitio/calendario-academico" target="_blank" class="action-btn btn-outline">
                    <i class="fas fa-external-link-alt"></i> Calendario UTS
                </a>
            </div>
        </div>
        
        <!-- Calendario en cuadrícula -->
        <div class="calendario-container">
            <div class="calendario-header">
                <div>Dom</div><div>Lun</div><div>Mar</div><div>Mié</div><div>Jue</div><div>Vie</div><div>Sáb</div>
            </div>
            <div class="calendario-grid" id="calendarioGrid"></div>
        </div>
        
        <!-- Lista de eventos del mes -->
        <div style="margin-top: 25px;">
            <h4 style="margin-bottom: 15px;"><i class="fas fa-list"></i> Eventos de ${mesNombreCal}</h4>
            <c:forEach var="e" items="${eventosMesCal.rows}">
                <div style="display: flex; align-items: center; justify-content: space-between; background: #F8FAFE; padding: 12px 20px; border-radius: 16px; margin-bottom: 10px;">
                    <div>
                        <strong>📅 ${e.fecha_evento}</strong><br>
                        <span>${e.titulo}</span>
                        <c:if test="${not empty e.descripcion}">
                            <p style="font-size: 0.75rem; color: #6C757D; margin-top: 5px;">${e.descripcion}</p>
                        </c:if>
                    </div>
                    <div>
                        <span class="badge" style="background:#E0F2FE; color:#0284C7;">${e.tipo}</span>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty eventosMesCal.rows}">
                <div style="text-align: center; padding: 30px;">
                    <i class="fas fa-calendar-week" style="font-size: 2rem; color: #ADB5BD;"></i>
                    <p>No hay eventos para este mes.</p>
                    <p style="font-size: 0.8rem;">Agrega eventos en la tabla calendario_academico</p>
                </div>
            </c:if>
        </div>
    </div>
    
    <div style="text-align: center; margin-top: 20px;">
        <a href="dashboard.jsp" class="btn-volver"><i class="fas fa-arrow-left"></i> Volver al Dashboard</a>
    </div>
</div>

<script>
    function generarCalendario(año, mes, eventos) {
        var primerDia = new Date(año, mes - 1, 1);
        var ultimoDia = new Date(año, mes, 0);
        var primerDiaSemana = primerDia.getDay();
        var diasEnMes = ultimoDia.getDate();
        
        var grid = document.getElementById('calendarioGrid');
        grid.innerHTML = '';
        
        for (var i = 0; i < primerDiaSemana; i++) {
            var divVacio = document.createElement('div');
            divVacio.className = 'calendario-dia otro-mes';
            grid.appendChild(divVacio);
        }
        
        for (var d = 1; d <= diasEnMes; d++) {
            var div = document.createElement('div');
            div.className = 'calendario-dia';
            if (eventos[d]) {
                div.classList.add('evento');
            }
            var numero = document.createElement('div');
            numero.className = 'dia-numero';
            numero.innerText = d;
            div.appendChild(numero);
            grid.appendChild(div);
        }
        
        var totalCeldas = primerDiaSemana + diasEnMes;
        var restantes = 42 - totalCeldas;
        for (var i = 0; i < restantes; i++) {
            var divVacio = document.createElement('div');
            divVacio.className = 'calendario-dia otro-mes';
            grid.appendChild(divVacio);
        }
    }
    
    var eventosMap = {};
    <c:forEach var="e" items="${eventosMesCal.rows}">
        var fecha = '${e.fecha_evento}';
        var dia = parseInt(fecha.split('-')[2]);
        eventosMap[dia] = true;
    </c:forEach>
    
    generarCalendario(${añoActualCal}, ${mesActualCal}, eventosMap);
</script>

</body>
</html>
/* Tablas con "Mostrar N registros", buscador y paginación; modales; menú de usuario */
(function () {
  function listo(f){document.readyState!=='loading'?f():document.addEventListener('DOMContentLoaded',f);}
  function mejorar(t){
    var filas=[].slice.call(t.tBodies[0].rows),por=5,pag=1,q='';
    var cont=t.parentNode;
    var ctr=document.createElement('div');ctr.className='tg-controles';
    ctr.innerHTML='<label>Mostrar <select>'+[5,10,20,50].map(function(n){return '<option>'+n+'</option>';}).join('')+'</select> registros por página</label><label>Buscar: <input type="search" placeholder="Ingrese una clave."></label>';
    var pie=document.createElement('div');pie.className='tg-pie';
    cont.insertBefore(ctr,t);cont.insertBefore(pie,t.nextSibling);
    function pintar(){
      var vis=filas.filter(function(f){return !q||f.textContent.toLowerCase().indexOf(q)>-1;});
      var total=Math.max(1,Math.ceil(vis.length/por));if(pag>total)pag=total;
      filas.forEach(function(f){f.style.display='none';});
      vis.slice((pag-1)*por,pag*por).forEach(function(f){f.style.display='';});
      var h='<span>'+(vis.length?'Mostrando la página '+pag+' de '+total:'Ningún dato disponible')+'</span><div class="tg-pag">';
      h+='<button data-p="1">&laquo;</button><button data-p="'+Math.max(1,pag-1)+'">&lsaquo;</button>';
      for(var i=Math.max(1,pag-2);i<=Math.min(total,pag+2);i++)h+='<button data-p="'+i+'"'+(i===pag?' class="act"':'')+'>'+i+'</button>';
      h+='<button data-p="'+Math.min(total,pag+1)+'">&rsaquo;</button><button data-p="'+total+'">&raquo;</button></div>';
      pie.innerHTML=h;
    }
    pie.addEventListener('click',function(e){var b=e.target.closest('button[data-p]');if(b){pag=+b.dataset.p;pintar();}});
    ctr.querySelector('select').addEventListener('change',function(e){por=+e.target.value;pag=1;pintar();});
    ctr.querySelector('input').addEventListener('input',function(e){q=e.target.value.toLowerCase().trim();pag=1;pintar();});
    pintar();
  }
  listo(function(){
    document.querySelectorAll('table.tg-tabla[data-tg]').forEach(mejorar);
    document.querySelectorAll('[data-modal]').forEach(function(b){b.addEventListener('click',function(){var m=document.getElementById(b.dataset.modal);if(m)m.style.display='flex';});});
    document.querySelectorAll('.tg-cerrar-modal').forEach(function(b){b.addEventListener('click',function(){var m=b.closest('.modal');if(m)m.style.display='none';});});
    document.querySelectorAll('.modal').forEach(function(m){m.addEventListener('click',function(e){if(e.target===m&&!m.hasAttribute('data-fijo'))m.style.display='none';});});
    document.querySelectorAll('[data-elegir]').forEach(function(b){b.addEventListener('click',function(){var m=document.getElementById('tgModalElegir');if(!m)return;document.getElementById('tgElegirId').value=b.dataset.elegir;document.getElementById('tgElegirTitulo').textContent=b.dataset.titulo;m.style.display='flex';});});
    document.addEventListener('click',function(e){document.querySelectorAll('.tg-menu-user.abierto').forEach(function(x){if(!x.parentNode.contains(e.target))x.classList.remove('abierto');});});
  });
})();

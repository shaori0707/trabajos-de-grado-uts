@echo off
REM Copia de seguridad de la base de datos (XAMPP). Programarla cada 2 o 3 días con el Programador de tareas de Windows.
set FECHA=%date:~-4%%date:~3,2%%date:~0,2%
"C:\xampp\mysql\bin\mysqldump.exe" -u root --default-character-set=utf8mb4 --routines proyecto_final_2 > "%~dp0respaldo_proyectos_grados_%FECHA%.sql"
echo Respaldo creado: respaldo_proyectos_grados_%FECHA%.sql
pause

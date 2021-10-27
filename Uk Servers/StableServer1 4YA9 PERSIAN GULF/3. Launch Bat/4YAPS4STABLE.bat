@echo off
:dcs
echo (%time%) DCS started. 4YA Server 4 Stable 
"C:\Program Files\Eagle Dynamics 4YA Stable\DCS World Stable Server\bin\dcs.exe" --server --norender -w 4YAPS4STABLE
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs
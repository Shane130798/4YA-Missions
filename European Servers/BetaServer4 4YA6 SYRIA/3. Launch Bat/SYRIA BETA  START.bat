@echo off
:dcs
echo (%time%) DCS started server4 Syria Pve Beta.
"D:\DCS World OpenBeta Server 4\bin\DCS.exe" --norender --server -w BetaServer4
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs
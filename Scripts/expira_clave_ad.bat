REM @ECHO OFF

SET "USUARIO=ncas002"
SET "RTA1=nada"


net user %USUARIO% /domain | find "expira" >NUL && SET "RTA1"

ECHO %USUARIO%
ECHO %RTA1%





pause

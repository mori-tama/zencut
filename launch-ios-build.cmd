@echo off
title EAS-iOS-build
set "PATH=C:\Users\morit\AppData\Roaming\fnm\node-versions\v24.16.0\installation;%PATH%"
cd /d C:\Users\morit\builders-weekend\app
echo === EAS iOS dev build ===
npx eas-cli build -p ios --profile development
pause

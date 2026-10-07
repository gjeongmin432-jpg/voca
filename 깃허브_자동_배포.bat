@echo off
chcp 65001 > nul
python "%~dp0deploy.py"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo 실행 중 오류가 발생했습니다.
    pause
)

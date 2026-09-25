@echo off
echo Starting School ERP Backend API Server...
cd /d "%~dp0backend"
call .venv\Scripts\python.exe server.py
pause

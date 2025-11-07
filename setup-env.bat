@echo off
REM ============================================
REM   BasicDemo Environment Setup (Batch)
REM ============================================
REM 此脚本是 setup.ps1 的轻量级调用器
REM 适用于不方便直接运行 PowerShell 的场景

chcp 65001 >nul 2>&1
cls
echo ========================================
echo   BasicDemo Environment Setup
echo ========================================
echo.
echo Running PowerShell setup script...
echo.

REM 运行 PowerShell 安装脚本（完整功能版）
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup.ps1"

echo.
echo ========================================
echo Press any key to exit...
echo ========================================
pause >nul



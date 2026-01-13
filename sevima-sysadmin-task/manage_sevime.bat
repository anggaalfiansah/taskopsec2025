@echo off
setlocal enabledelayedexpansion

:: --- KUNCI JALUR PROYEK ---
set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

set "CONTAINER_NAME=sevima-task2-ubuntu"
set "REMOTE_CERT=/root/ca/cacert.pem"
set "LOCAL_CERT=sevima-ca.crt"
set "HOSTS_PATH=%SystemRoot%\System32\drivers\etc\hosts"
set "DOMAINS=www.sevima.site utara.sevima.site timur.sevima.site barat.sevima.site"

:: 1. Cek Hak Akses Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Klik kanan file ini dan pilih 'Run as Administrator'!
    pause & exit
)

:MENU
cls
echo ========================================================
echo        SEVIMA CLIENT MANAGER (SRE TASK)
echo ========================================================
echo  Lokasi: %PROJECT_DIR%
echo ========================================================
echo  1. INSTALL   (Ambil Cert + Trust CA + Setup Hosts)
echo  2. UNINSTALL (Remove Trust CA + Clean Hosts)
echo  3. EXIT
echo ========================================================
set /p choice="Pilih menu [1-3]: "

if "%choice%"=="1" goto INSTALL
if "%choice%"=="2" goto UNINSTALL
if "%choice%"=="3" exit
goto MENU

:INSTALL
echo.
echo [LOG] Menarik sertifikat dari container...
docker cp %CONTAINER_NAME%:%REMOTE_CERT% "%PROJECT_DIR%%LOCAL_CERT%"

if %errorLevel% neq 0 (
    echo [FAIL] Gagal ambil cert. Cek apakah container jalan.
    pause & goto MENU
)

echo [LOG] Mendaftarkan ke Windows Trusted Root Store...
certutil -addstore -f "Root" "%PROJECT_DIR%%LOCAL_CERT%" >nul

echo [LOG] Sinkronisasi file hosts Windows...
for %%D in (%DOMAINS%) do (
    findstr /l /c:"%%D" "%HOSTS_PATH%" >nul
    if !errorlevel! neq 0 (
        echo 127.0.0.1  %%D >> "%HOSTS_PATH%"
        echo [OK] Added %%D
    ) else (
        echo [SKIP] %%D sudah ada.
    )
)

:: Hapus file temp
if exist "%PROJECT_DIR%%LOCAL_CERT%" del /f /q "%PROJECT_DIR%%LOCAL_CERT%"

echo.
echo ========================================================
echo  STATUS: SELESAI
echo  INFO  : HTTPS SEKARANG TERPERCAYA
echo  URL   : https://barat.sevima.site:4435
echo ========================================================
pause
goto MENU

:UNINSTALL
echo.
echo [LOG] Menghapus SEVIMA CA dari Windows Store...
certutil -delstore "Root" "SEVIMA CA" >nul

echo [LOG] Membersihkan domain dari file hosts...
powershell -Command "$p='%HOSTS_PATH%'; (Get-Content $p) | Where-Object { $_ -notmatch 'sevima.site' } | Set-Content $p"

echo ✅ SELESAI! Sistem Windows kembali bersih.
pause
goto MENU
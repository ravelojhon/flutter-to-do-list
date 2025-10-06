@echo off
REM Script de configuración de desarrollo para Flutter Task List App (Windows)
REM Ejecutar con: scripts\dev_setup.bat

setlocal enabledelayedexpansion

echo 🚀 Configurando entorno de desarrollo para Flutter Task List App...

REM Verificar si Flutter está instalado
echo ================================
echo Verificando Flutter SDK
echo ================================
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter no está instalado. Por favor instala Flutter primero.
    exit /b 1
)

echo [INFO] Flutter encontrado
flutter --version | findstr "Flutter"

REM Limpiar proyecto
echo ================================
echo Limpiando proyecto
echo ================================
echo [INFO] Ejecutando flutter clean...
flutter clean

REM Obtener dependencias
echo ================================
echo Instalando dependencias
echo ================================
echo [INFO] Ejecutando flutter pub get...
flutter pub get

REM Generar archivos de código
echo ================================
echo Generando archivos de código
echo ================================
echo [INFO] Ejecutando build_runner...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Verificar análisis de código
echo ================================
echo Verificando análisis de código
echo ================================
echo [INFO] Ejecutando flutter analyze...
flutter analyze
if %errorlevel% equ 0 (
    echo [INFO] ✅ Análisis de código exitoso
) else (
    echo [WARNING] ⚠️  Se encontraron problemas en el análisis de código
)

REM Ejecutar tests
echo ================================
echo Ejecutando tests
echo ================================
echo [INFO] Ejecutando flutter test...
flutter test
if %errorlevel% equ 0 (
    echo [INFO] ✅ Todos los tests pasaron
) else (
    echo [WARNING] ⚠️  Algunos tests fallaron
)

REM Verificar formato de código
echo ================================
echo Verificando formato de código
echo ================================
echo [INFO] Ejecutando flutter format...
flutter format --set-exit-if-changed .
if %errorlevel% equ 0 (
    echo [INFO] ✅ Código está correctamente formateado
) else (
    echo [WARNING] ⚠️  Código necesita formateo. Ejecutando flutter format...
    flutter format .
)

REM Verificar dispositivos disponibles
echo ================================
echo Verificando dispositivos disponibles
echo ================================
echo [INFO] Dispositivos disponibles:
flutter devices

echo ================================
echo 🎉 Configuración completada
echo ================================
echo [INFO] El proyecto está listo para desarrollo!
echo [INFO] Para ejecutar la app: flutter run
echo [INFO] Para ejecutar tests: flutter test
echo [INFO] Para analizar código: flutter analyze
echo [INFO] Para formatear código: flutter format .

pause

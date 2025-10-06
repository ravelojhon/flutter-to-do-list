#!/bin/bash

# Script de configuración de desarrollo para Flutter Task List App
# Ejecutar con: chmod +x scripts/dev_setup.sh && ./scripts/dev_setup.sh

set -e

echo "🚀 Configurando entorno de desarrollo para Flutter Task List App..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con color
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Verificar si Flutter está instalado
print_header "Verificando Flutter SDK"
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado. Por favor instala Flutter primero."
    exit 1
fi

print_message "Flutter encontrado: $(flutter --version | head -n 1)"

# Verificar versión de Flutter
FLUTTER_VERSION=$(flutter --version | grep "Flutter" | awk '{print $2}')
REQUIRED_VERSION="3.9.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$FLUTTER_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    print_warning "Versión de Flutter: $FLUTTER_VERSION. Se recomienda $REQUIRED_VERSION o superior."
fi

# Limpiar proyecto
print_header "Limpiando proyecto"
print_message "Ejecutando flutter clean..."
flutter clean

# Obtener dependencias
print_header "Instalando dependencias"
print_message "Ejecutando flutter pub get..."
flutter pub get

# Generar archivos de código
print_header "Generando archivos de código"
print_message "Ejecutando build_runner..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Verificar análisis de código
print_header "Verificando análisis de código"
print_message "Ejecutando flutter analyze..."
if flutter analyze; then
    print_message "✅ Análisis de código exitoso"
else
    print_warning "⚠️  Se encontraron problemas en el análisis de código"
fi

# Ejecutar tests
print_header "Ejecutando tests"
print_message "Ejecutando flutter test..."
if flutter test; then
    print_message "✅ Todos los tests pasaron"
else
    print_warning "⚠️  Algunos tests fallaron"
fi

# Verificar formato de código
print_header "Verificando formato de código"
print_message "Ejecutando flutter format..."
if flutter format --set-exit-if-changed .; then
    print_message "✅ Código está correctamente formateado"
else
    print_warning "⚠️  Código necesita formateo. Ejecutando flutter format..."
    flutter format .
fi

# Configurar pre-commit hooks (si está disponible)
print_header "Configurando pre-commit hooks"
if command -v pre-commit &> /dev/null; then
    print_message "Instalando pre-commit hooks..."
    pre-commit install
    print_message "✅ Pre-commit hooks configurados"
else
    print_warning "pre-commit no está instalado. Para instalarlo: pip install pre-commit"
fi

# Verificar dispositivos disponibles
print_header "Verificando dispositivos disponibles"
print_message "Dispositivos disponibles:"
flutter devices

print_header "🎉 Configuración completada"
print_message "El proyecto está listo para desarrollo!"
print_message "Para ejecutar la app: flutter run"
print_message "Para ejecutar tests: flutter test"
print_message "Para analizar código: flutter analyze"
print_message "Para formatear código: flutter format ."

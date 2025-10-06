# 📋 Task List App

Una aplicación de gestión de tareas moderna construida con Flutter, siguiendo los principios de Clean Architecture y utilizando Riverpod para el manejo de estado.

## ✨ Características

- ✅ **Gestión de Tareas**: Crear, editar, completar y eliminar tareas
- 🎨 **Material 3 Design**: Interfaz moderna con Material Design 3
- 🌙 **Tema Adaptativo**: Soporte para modo claro y oscuro
- 📊 **Estadísticas**: Visualización de progreso y estadísticas de tareas
- 🔄 **Estado Inmutable**: Uso de Freezed para entidades inmutables
- 🏗️ **Clean Architecture**: Separación clara de responsabilidades
- 🧪 **Testing**: Estructura preparada para testing unitario

## 🏗️ Arquitectura

El proyecto sigue los principios de Clean Architecture:

```
lib/
├── core/           # Utilidades y casos de uso base
├── data/           # Capa de datos (repositorios, modelos, fuentes de datos)
├── domain/         # Capa de dominio (entidades, repositorios, casos de uso)
└── presentation/   # Capa de presentación (páginas, widgets, providers)
```

## 🚀 Tecnologías Utilizadas

- **Flutter**: Framework de UI
- **Riverpod**: Gestión de estado
- **Freezed**: Generación de código para entidades inmutables
- **Drift**: ORM para base de datos local
- **Material 3**: Sistema de diseño

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter_riverpod: ^2.6.1    # State management
  drift: ^2.28.2               # Database ORM
  freezed_annotation: ^2.4.4   # Code generation
  json_annotation: ^4.9.0      # JSON serialization
```

## 🛠️ Instalación y Configuración

### Prerrequisitos

- Flutter SDK (versión 3.9.0 o superior)
- Dart SDK
- Android Studio / VS Code con extensiones de Flutter

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd Flutter
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Generar archivos de código**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 🧪 Testing

Para ejecutar los tests:

```bash
# Tests unitarios
flutter test

# Análisis de código
flutter analyze

# Tests de integración
flutter test integration_test/
```

## 📱 Capturas de Pantalla

La aplicación incluye:
- Lista de tareas con estadísticas
- Diálogos para crear y editar tareas
- Indicadores de estado (pendiente/completada)
- Interfaz responsive con Material 3

## 🔧 Comandos Útiles

```bash
# Limpiar y reconstruir
flutter clean && flutter pub get

# Generar código
flutter packages pub run build_runner build --delete-conflicting-outputs

# Verificar dependencias
flutter pub deps

# Actualizar dependencias
flutter pub upgrade
```

## 📋 Funcionalidades Implementadas

### Gestión de Tareas
- ✅ Crear nueva tarea
- ✅ Marcar como completada/pendiente
- ✅ Editar título de tarea
- ✅ Eliminar tarea
- ✅ Actualizar lista (pull-to-refresh)

### UI/UX
- ✅ Interfaz Material 3
- ✅ Tema claro y oscuro
- ✅ Estadísticas en tiempo real
- ✅ Estados de carga y error
- ✅ Diálogos de confirmación
- ✅ Snackbars informativos

### Arquitectura
- ✅ Clean Architecture
- ✅ State management con Riverpod
- ✅ Entidades inmutables con Freezed
- ✅ Separación de responsabilidades

## 🚧 Próximas Funcionalidades

- [ ] Persistencia de datos con Drift
- [ ] Filtros de tareas (pendientes, completadas)
- [ ] Búsqueda de tareas
- [ ] Categorías y etiquetas
- [ ] Notificaciones
- [ ] Sincronización en la nube

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Autor

Desarrollado con ❤️ usando Flutter y Clean Architecture.

---

**Nota**: Este proyecto está en desarrollo activo. Las funcionalidades pueden cambiar en futuras versiones.
# Flutter To-Do List

Una aplicación moderna de lista de tareas desarrollada con Flutter, utilizando Riverpod para la gestión de estado y Drift para la persistencia de datos local.

## 🎯 Objetivo

Esta aplicación permite a los usuarios gestionar sus tareas diarias de manera eficiente, con funcionalidades como:
- Crear, editar y eliminar tareas
- Marcar tareas como completadas
- Persistencia de datos local
- Interfaz de usuario moderna y responsiva
- Gestión de estado reactiva

## 📋 Requerimientos

### Requisitos del Sistema
- **Flutter SDK**: >=3.0.0
- **Dart SDK**: >=3.0.0
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Windows**: Windows 10+
- **macOS**: macOS 10.14+
- **Linux**: Ubuntu 18.04+ o equivalente

### Dependencias Principales
- `flutter_riverpod`: Gestión de estado reactiva
- `drift`: Base de datos local SQLite
- `drift_flutter`: Integración de Drift con Flutter
- `build_runner`: Generación de código
- `json_annotation`: Anotaciones para serialización JSON

## 🚀 Instalación y Configuración

### 1. Clonar el repositorio
```bash
git clone <url-del-repositorio>
cd flutter-todo-list
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Generar código (Drift)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Ejecutar la aplicación
```bash
flutter run
```

## 🧪 Testing

### Ejecutar todos los tests
```bash
flutter test
```

### Ejecutar tests con cobertura
```bash
flutter test --coverage
```

### Ejecutar tests específicos
```bash
flutter test test/unit/
flutter test test/integration/
```

## 🔧 Comandos Útiles

### Desarrollo
```bash
# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release

# Hot reload (durante desarrollo)
r

# Hot restart (durante desarrollo)
R
```

### Generación de Código
```bash
# Generar código de Drift
flutter pub run build_runner build

# Generar código y eliminar archivos conflictivos
flutter pub run build_runner build --delete-conflicting-outputs

# Generar código en modo watch (desarrollo)
flutter pub run build_runner watch
```

### Build y Deploy
```bash
# Build para Android
flutter build apk

# Build para iOS
flutter build ios

# Build para Web
flutter build web

# Build para Windows
flutter build windows

# Build para macOS
flutter build macos

# Build para Linux
flutter build linux
```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── app/                     # Configuración de la aplicación
├── core/                    # Utilidades y constantes
├── data/                    # Capa de datos (Drift)
│   ├── database/
│   └── models/
├── presentation/            # Capa de presentación
│   ├── pages/
│   ├── widgets/
│   └── providers/
└── shared/                  # Componentes compartidos
```

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo multiplataforma
- **Riverpod**: Gestión de estado reactiva y dependency injection
- **Drift**: ORM para SQLite con generación de código
- **Dart**: Lenguaje de programación

## 📱 Características

- ✅ Crear nuevas tareas
- ✏️ Editar tareas existentes
- 🗑️ Eliminar tareas
- ✅ Marcar tareas como completadas
- 💾 Persistencia de datos local
- 🎨 Interfaz moderna y responsiva
- 🔄 Gestión de estado reactiva

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Soporte

Si tienes alguna pregunta o problema, por favor:
1. Revisa la documentación
2. Busca en los issues existentes
3. Crea un nuevo issue si es necesario

---

**Desarrollado con ❤️ usando Flutter**

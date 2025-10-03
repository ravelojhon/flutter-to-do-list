/// Constantes de la aplicación
class AppConstants {
  // Database
  static const String databaseName = 'todo_database.db';
  static const int databaseVersion = 1;

  // API
  static const String baseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 4.0;

  // Validation
  static const int minTitleLength = 1;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

/// Rutas de la aplicación
class AppRoutes {
  static const String home = '/';
  static const String todoList = '/todos';
  static const String todoDetail = '/todo/:id';
  static const String todoCreate = '/todo/create';
  static const String todoEdit = '/todo/:id/edit';
  static const String settings = '/settings';
}

/// Claves de almacenamiento local
class StorageKeys {
  static const String theme = 'theme';
  static const String language = 'language';
  static const String userPreferences = 'user_preferences';
}

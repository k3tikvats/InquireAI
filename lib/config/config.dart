class Config {
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://localhost:8000');

  static const String wsBaseUrl = String.fromEnvironment('WS_BASE_URL',
      defaultValue: 'ws://localhost:8000');

  static String get chatWebSocketUrl => '$wsBaseUrl/ws/chat';
  static String get chatHttpUrl => '$apiBaseUrl/chat';
}

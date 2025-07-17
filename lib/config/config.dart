class Config {
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://inquireai-backend.onrender.com');

  static const String wsBaseUrl = String.fromEnvironment('WS_BASE_URL',
      defaultValue: 'wss://inquireai-backend.onrender.com');

  static String get chatWebSocketUrl => '$wsBaseUrl/ws/chat';
  static String get chatHttpUrl => '$apiBaseUrl/chat';
}

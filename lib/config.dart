class Config {
  static const bool isSessionMocked = bool.fromEnvironment(
    "MOCK_SESSION",
    defaultValue: false,
  );
}

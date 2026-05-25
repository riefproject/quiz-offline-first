class Config {
  static const bool isSessionMocked = bool.fromEnvironment(
    "MOCK_SESSION",
    defaultValue: false,
  );

  static const bool useLan = bool.fromEnvironment(
    "USE_LAN",
    defaultValue: true,
  );
}

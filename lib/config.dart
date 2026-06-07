class Config {
  static bool? mockSessionOverride;

  static bool get isSessionMocked => 
      mockSessionOverride ?? 
      bool.fromEnvironment("MOCK_SESSION", defaultValue: false);
}

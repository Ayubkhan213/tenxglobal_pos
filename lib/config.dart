class AppConfig {
  static const String type =
      String.fromEnvironment('TYPE', defaultValue: 'debug');
  // Your live POS URL
  // static const String posSmashUrl = 'https://smashngrubpos.10xglobal.co.uk';
  static const String posUrl =
      // type == 'debug'
      // ? 'https://posdemo.10xglobal.co.uk'
      // :
      'https://smashngrubpos.10xglobal.co.uk';
  // static const String posUrl = 'https://YOUR_POS_URL_HERE';
  // HTTP server port for print agent
  static const int printServerPort = 8085;
}

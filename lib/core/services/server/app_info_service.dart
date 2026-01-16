import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  // Private constructor
  AppInfoService._internal();

  // Single instance
  static final AppInfoService instance = AppInfoService._internal();

  late final PackageInfo _packageInfo;

  /// Call this ONCE in main()
  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  // Exposed getters
  String get appName => _packageInfo.appName;
  String get packageName => _packageInfo.packageName;
  String get version => _packageInfo.version;
  String get buildNumber => _packageInfo.buildNumber;

  String get fullVersion =>
      "${_packageInfo.version}+${_packageInfo.buildNumber}";
}

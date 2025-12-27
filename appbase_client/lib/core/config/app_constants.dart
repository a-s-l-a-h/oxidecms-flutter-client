class AppConstants {
  static late String domain;
  static late String appBaseUrl;

  static void initialize() {
    domain = const String.fromEnvironment(
      'APP_DOMAIN',
      defaultValue: 'your-diy-hub.com',
    );
    
    if (domain.startsWith('localhost')) {
      appBaseUrl = 'http://$domain';
    } else {
      appBaseUrl = 'https://$domain';
    }
  }
}
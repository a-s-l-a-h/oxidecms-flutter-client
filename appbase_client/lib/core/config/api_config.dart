// lib/core/config/api_config.dart

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static late final String baseUrl;

  static void initialize() {
    // Default to 'automatic' if no command-line argument is provided.
    const String baseUrlFromEnv = String.fromEnvironment('BASE_URL', defaultValue: 'automatic');

    if (baseUrlFromEnv.toLowerCase() == 'automatic') {
      if (kIsWeb) {
        // For web, dynamically use the origin of the page. This is the 'automatic' behavior.
        // It will correctly resolve to http://localhost:PORT or https://yourdomain.com.
        baseUrl = Uri.base.origin;
      } else {
        // For mobile or desktop, 'automatic' is not supported as there's no 'origin'.
        // Throw an informative error to force the developer to provide a URL.
        throw UnsupportedError(
          'The "automatic" BASE_URL is not supported on non-web platforms. '
          'You must provide a URL via --dart-define=BASE_URL=https://your-api.com'
        );
      }
    } else {
      // If a specific URL is provided via --dart-define, use it.
      baseUrl = baseUrlFromEnv;
    }
  }
}
/*
// lib/core/config/api_config.dart

class ApiConfig {
  // This variable will hold the final URL after initialization.
  static late final String baseUrl;

  // The initialize() method is called once when the app starts.
  static void initialize() {
    // --- SET YOUR DESIRED DEFAULT API URL HERE ---
    // The app will ALWAYS use this value.
    // The --dart-define flag will have no effect with this setup.
    baseUrl = 'http://127.0.0.1:8080'; 
  }
}


// lib/core/config/api_config.dart

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // This will hold the final, configured base URL for the entire app.
  static late final String baseUrl;

  // This method must be called from main.dart when the app starts.
  static void initialize() {
    // 1. Read the 'BASE_URL' variable from the command-line arguments.
    //    If the flag isn't provided, it defaults to the string 'automatic'.
    const String urlFromEnv = String.fromEnvironment('BASE_URL', defaultValue: 'automatic');

    // 2. Check if a specific URL was provided via the command line.
    //    Anything other than 'automatic' is treated as a direct command.
    if (urlFromEnv.toLowerCase() != 'automatic') {
      // PRIORITY 1: A command-line argument was given. Use it directly.
      baseUrl = urlFromEnv;
    } else {
      // PRIORITY 2: No command-line argument was given. Use automatic detection.
      if (kIsWeb) {
        // For web builds, 'automatic' means using the same domain the app is hosted on.
        // This correctly resolves to http://localhost:PORT during development
        // or https://your-deployed-app.com in production.
        baseUrl = Uri.base.origin;
      } else {
        // For mobile or desktop, 'automatic' is not supported because there is no
        // web origin to refer to. The app must be explicitly told where the API is.
        // We throw an error to make this requirement clear to the developer.
        throw UnsupportedError(
          'Automatic API URL detection is not supported on this platform. '
          'You must specify the API server address when running the app, for example:\n'
          'flutter run --dart-define=BASE_URL=http://192.168.1.10:8080'
        );
      }
    }
  }
}
*/
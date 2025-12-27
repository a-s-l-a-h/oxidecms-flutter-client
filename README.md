
# OxideCMS Flutter Client

Welcome to the official Flutter client for **OxideCMS**, a modern, fast, and offline-first mobile application designed to deliver a seamless and native content experience on both Android and iOS.

## ✨ Features

*   **Native Performance**: Built with Flutter for smooth, high-performance animations and a truly native feel.
*   **Robust State Management**: Uses [Riverpod](https://riverpod.dev/) for a scalable and maintainable state management solution.
*   **Offline First**: Articles, including their full content and images, can be saved locally for offline reading using a powerful [Hive](https://hivedb.dev/) database.
*   **Advanced Caching**: Implements `cached_network_image` and `flutter_cache_manager` to intelligently cache images, reducing network usage and load times.
*   **Clean Architecture**: Organized into a feature-first directory structure, making the codebase easy to navigate and extend.
*   **Dynamic Filtering & Search**: Filter posts by tags and use a debounced search to find content quickly.
*   **Force Update Mechanism**: Includes a built-in check to prompt users to update to the latest version of the app from the app stores.

> **Note**: This is the front-end client. For details on the backend that powers these features (API, search logic, etc.), please visit the **[OxideCMS Core Backend repository](https://github.com/a-s-l-a-h/oxidecms-core-backend)**.



## 🌐 Project Ecosystem

The OxideCMS project is composed of multiple repositories that work together.

| Repository                                                                      | Description                                  |
| ------------------------------------------------------------------------------- | -------------------------------------------- |
| 📍 **[oxidecms-flutter-client](https://github.com/a-s-l-a-h/oxidecms-flutter-client)** (You are here) | The native Flutter mobile client for Android & iOS. |
| ⚙️ **[oxidecms-core-backend](https://github.com/a-s-l-a-h/oxidecms-core-backend)** | The core backend server that provides the API. |
| 🖥️ **[oxidecms-web](https://github.com/a-s-l-a-h/oxidecms-web)**                  | The Preact-based PWA web client.             |


## 🚀 Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/)
*   **State Management**: [Riverpod](https://riverpod.dev/)
*   **Local Database**: [Hive CE](https://pub.dev/packages/hive_ce)
*   **Networking**: [http](https://pub.dev/packages/http)
*   **Routing**: [go_router](https://pub.dev/packages/go_router)
*   **Markdown Rendering**: [flutter_markdown](https://pub.dev/packages/flutter_markdown)
*   **Image Caching**: [cached_network_image](https://pub.dev/packages/cached_network_image)
*   **Code Generation**: [build_runner](https://pub.dev/packages/build_runner)

## 📂 Project Structure

The repository contains the Flutter project within a subdirectory named `appbase_client`. All development work and commands should be run from inside that directory.

```
/ (repository root: oxidecms-flutter-client)
└── appbase_client/      # <== THIS IS THE FLUTTER PROJECT DIRECTORY
    ├── assets/          # Static assets like images and icons
    ├── lib/             # Main application source code
    │   ├── core/        # Shared code: config, models, repositories, services
    │   ├── features/    # Feature-specific code (posts, settings, etc.)
    │   ├── routing/     # Navigation setup using go_router
    │   └── main.dart    # The main entry point of the application
    ├── android/         # Android-specific files
    ├── ios/             # iOS-specific files
    └── pubspec.yaml     # Project dependencies and metadata
```

## 🏁 Getting Started

Follow these instructions to get a local copy of the project up and running for development.

### 1. Backend Setup (Required)

This mobile app **requires** the backend server to be running to fetch data. Please visit the **[oxidecms-core-backend repository](https://github.com/a-s-l-a-h/oxidecms-core-backend)**, clone it, and follow its `README.md` to get the server running first.

### 2. Frontend (Flutter) Setup

#### Prerequisites

*   You must have the **Flutter SDK** installed. For instructions, see the [official Flutter documentation](https://flutter.dev/docs/get-started/install).
*   An editor like **VS Code** with the Flutter extension or **Android Studio**.

#### Installation

1.  **Clone this repository:**
    ```sh
    git clone https://github.com/a-s-l-a-h/oxidecms-flutter-client.git
    ```

2.  **Navigate to the Flutter project directory:**
    ```sh
    cd oxidecms-flutter-client/appbase_client
    ```

3.  **Get the Flutter dependencies:**
    ```sh
    flutter pub get
    ```

### 3. Configuration

You must configure the base URL of your backend API.

1.  Open the file: `appbase_client/lib/core/config/api_config.dart`.
2.  Change the `_devBaseUrl` and `_prodBaseUrl` static variables to point to your backend server.

    ```dart
    // appbase_client/lib/core/config/api_config.dart

    class ApiConfig {
      // For local development, change this to your computer's IP address
      // if you are testing on a physical device.
      static const String _devBaseUrl = 'http://localhost:8080';

      // For production builds
      static const String _prodBaseUrl = 'https://';

      // ... rest of the file
    }
    ```
    > **Tip**: If you are running the app on a physical Android device and your backend is on `localhost`, you must use your computer's local IP address (e.g., `http://192.168.1.10:8080`) instead of `localhost`.

### 4. Code Generation (Important!)

This project uses `build_runner` to generate type adapters for the Hive database. After any changes to the `Post` model (`post_model.dart`), you must run this command from the `appbase_client` directory to update the generated files.

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📜 Available Scripts

**Important**: All Flutter commands must be run from within the `oxidecms-flutter-client/appbase_client` directory.

### Run the app in debug mode

Connect a device or start an emulator, then run:
```sh
flutter run
```

### Build the app for production

#### Android (APK)

```sh
flutter build apk --release
```
The output file will be located at `appbase_client/build/app/outputs/flutter-apk/app-release.apk`.

#### iOS

```sh
flutter build ipa
```
This requires a configured Apple Developer account. For more details, follow the [official guide to build and release an iOS app](https://docs.flutter.dev/deployment/ios).

### Optional: Update App Icons & Splash Screen

If you change the app icon or splash screen image in the `assets/images/` folder, you need to run the following commands to apply the changes across all platforms.

**Update Launcher Icons:**
```sh
flutter pub run flutter_launcher_icons:main
```

**Update Native Splash Screen:**
```sh
flutter pub run flutter_native_splash:create
```

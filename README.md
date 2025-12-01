# flutter_idle_detector

A Flutter plugin that provides **native-level idle user detection** with:

- 🔄 **start() / stop()**
- ⏱ **reset()**
- ⏳ configurable **timeout: Duration**
- 🖐 works with **WebView**, **InAppWebView**, **PlatformViews**
- 📱 works with external iOS/Android SDK screens
- ⚡ perfect for **auto-logout**, **session timeout**, **security apps**

---

## 🚀 Features

| Feature                           | Status |
| --------------------------------- | ------ |
| Idle detection                    | ✅     |
| Duration-based timeout            | ✅     |
| Start/Stop monitoring             | ✅     |
| Manual reset                      | ✅     |
| Touch detection inside WebView    | ✅     |
| iOS UIKit global touch swizzle    | ✅     |
| Android Window.Callback intercept | ✅     |

---

## 📦 Installation

```yaml
dependencies:
  flutter_idle_detector: ^X.X.X
```

Run the following command to install the package:

```sh
flutter pub add flutter_idle_detector
```

## Usage

Import the necessary components:

```dart
import 'package:flutter_idle_detector/flutter_idle_detector.dart';
```

1. Initialize

```dart
IdleTimer.initialize(
timeout: const Duration(minutes: 2),
onIdle: () {
Navigator.pushNamed(context, "/idle");
},
);
```

2. Start monitoring

```dart
IdleTimer.start();
```

3. Stop monitoring

```dart
IdleTimer.stop();
```

4. Reset timer manually

```dart
IdleTimer.reset();
```

## 🧪 Example

In your example/lib/main.dart:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  IdleTimer.initialize(
    timeout: Duration(seconds: 20),
    onIdle: () {
      print("User is idle!");
    },
  );

  runApp(const MyApp());
}

```

Start when needed:

```dart
IdleTimer.start();
```

## Additional Information

- **Contributing**: Contributions are welcome! Feel free to submit issues or pull requests.
- **License**: This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
- **Support**: For any issues or feature requests, please open an issue on [GitHub](https://github.com/aswintbbc/flutter_idle_detector/issues).

Happy coding! I don't want coffee 😊

[contact us](https://mindster.com/)

<img src="https://github.com/mindsterapps/chaty/blob/main/screenshots/mindster.png?raw=true" alt="logo" />

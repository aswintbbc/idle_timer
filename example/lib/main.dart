import 'package:flutter/material.dart';
import 'package:flutter_idle_detector/flutter_idle_detector.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterIdleDetector.initialize(
    onIdle: () {
      navigatorKey.currentState?.pushNamed("/idle");
    },
  );

  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/': (_) => const HomeScreen(),
        '/idle': (_) => const IdleScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Idle Timer Example")),
      body: const Center(
        child: Text("Interact with the app to avoid idle trigger"),
      ),
    );
  }
}

class IdleScreen extends StatelessWidget {
  const IdleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("User is idle!", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

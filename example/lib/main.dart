import 'package:flutter/material.dart';
import 'package:flutter_idle_detector/flutter_idle_detector.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  IdleTimer.initialize(
    timeout: Duration(seconds: 5),
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
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                print('tap');

                IdleTimer.start();
              },
              child: Text("start ${IdleTimer.isChecking}"),
            ),
            ElevatedButton(
              onPressed: () {
                print('tap');

                IdleTimer.stop();
              },
              child: Text("stop"),
            ),
          ],
        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          IdleTimer.reset();
          navigatorKey.currentState?.pushNamed("/");
        },
        child: Icon(Icons.home),
      ),
    );
  }
}

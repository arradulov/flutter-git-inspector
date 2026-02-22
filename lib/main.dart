import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:window_manager/window_manager.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(700, 540),       
    center: true,                
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 248, 245, 245),
        scaffoldBackgroundColor: Color.fromRGBO(11, 26, 42, 1.0),
      ),
      home: const HomePage(),
    );
  }
}
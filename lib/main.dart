import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:pomodoro_windows/app/theme.dart';
import 'package:pomodoro_windows/firebase_options.dart';
import 'package:pomodoro_windows/presentation/display/display_controller.dart';
import 'package:pomodoro_windows/presentation/display/display_screen.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_isDesktop) {
    await _initDesktopWindow();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PomodoroWindowsApp());
}

bool get _isDesktop =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux);

Future<void> _initDesktopWindow() async {
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1920, 1080),
    center: true,
    backgroundColor: Color(0xFF0D1B12),
    title: 'Pomodoro Display',
    fullScreen: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class PomodoroWindowsApp extends StatelessWidget {
  const PomodoroWindowsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => createDisplayController(),
      child: MaterialApp(
        title: 'Pomodoro Display',
        debugShowCheckedModeBanner: false,
        theme: buildDisplayTheme(),
        home: const DisplayScreen(),
      ),
    );
  }
}

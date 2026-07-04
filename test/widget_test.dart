import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_windows/app/theme.dart';

void main() {
  test('Display theme builds without error', () {
    final theme = buildDisplayTheme();
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, isNotNull);
  });
}

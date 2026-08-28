import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/database_initializer.dart';
import 'app/app.dart';

void main() {
  runApp(const ProviderScope(child: FinTrackApp()));
}

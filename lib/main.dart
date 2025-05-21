import 'package:flutter/material.dart';
import 'package:macos_note_statusbar/provider/note_provider.dart';
import 'package:macos_note_statusbar/utils/db.dart';
import 'package:provider/provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB().init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => NoteProvider(),
      child: const QuickNotesApp(),
    ),
  );
}

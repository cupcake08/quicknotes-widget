import 'package:flutter/material.dart';
import 'package:macos_note_statusbar/note_popup.dart';

class QuickNotesApp extends StatelessWidget {
  const QuickNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
      theme: ThemeData.light(),
      home: const NotePopup(),
    );
  }
}
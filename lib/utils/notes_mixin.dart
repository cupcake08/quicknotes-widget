import 'package:flutter/material.dart';
import 'package:macos_note_statusbar/provider/note_provider.dart';
import 'package:macos_note_statusbar/utils/db.dart';
import 'package:macos_note_statusbar/utils/debouncer.dart';
import 'package:macos_note_statusbar/utils/extensions.dart';
import 'package:macos_note_statusbar/utils/throttler.dart';
import 'package:provider/provider.dart';

mixin NotesMixin<T extends StatefulWidget> on State<T> {
  late final Debouncer _noteDebouncer = Debouncer(1000.milliseconds);
  late final Throttler _throttler = Throttler(500.milliseconds);

  void saveNote(String key, String value) {
    _noteDebouncer.call(() {
      DB().addNote(key, value);
    });
  }

  void loadNote(String key, {immediateCall = false}) async =>
      _throttler.call(() => context.read<NoteProvider>().loadNote(key),
          immediateCall: key.day == DateTime.now().day ? true : immediateCall);

  @override
  void dispose() {
    _noteDebouncer.reset();
    _throttler.reset();
    super.dispose();
  }
}

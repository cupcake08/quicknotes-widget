import 'package:flutter/material.dart';
import 'package:macos_note_statusbar/utils/db.dart';

class NoteProvider extends ChangeNotifier {
  String _latestNote = "";
  bool _isEditing = false;

  String get latestNote => _latestNote;
  bool get editing => _isEditing;

  void loadNote(String key) async {
    _latestNote = await DB().fetchNote(key) ?? "";
    notifyListeners();
  }

  void changeMode(bool mode) {
    _isEditing = mode;
    notifyListeners();
  }
}

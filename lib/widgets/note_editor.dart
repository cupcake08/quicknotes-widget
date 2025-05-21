import 'package:flutter/material.dart';
import 'package:macos_note_statusbar/provider/note_provider.dart';
import 'package:macos_note_statusbar/utils/colors.dart';
import 'package:macos_note_statusbar/utils/extensions.dart';
import 'package:macos_note_statusbar/widgets/animated_text.dart';
import 'package:provider/provider.dart';

class NoteEditor extends StatelessWidget {
  final DateTime selectedDate;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String, String) onSave;

  const NoteEditor({
    super.key,
    required this.selectedDate,
    required this.controller,
    required this.focusNode,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        if (selectedDate.day == DateTime.now().day && (provider.editing || provider.latestNote.isEmpty)) {
          if (provider.latestNote.isNotEmpty) {
            controller.text = provider.latestNote;
          }
        }
        return AnimatedCrossFade(
          firstChild: TextRevealAnimationWidget(
            text: provider.latestNote,
            shouldAnimate: true,
            noteKey: selectedDate.noteKey,
            emptyText: selectedDate.day > DateTime.now().day
                ? "No sneaking into the future-write about today's slay! 🌟"
                : "Past slay is history—drop today's mood! 📜✨",
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.noteTextColor,
              fontFamily: "SpaceGrotesk",
            ),
            onTap: () => selectedDate.day != DateTime.now().day ? null : provider.changeMode(true),
          ),
          secondChild: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth,
                ),
                child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    scrollPhysics: const BouncingScrollPhysics(),
                    scrollPadding: EdgeInsets.zero,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.noteTextColor,
                      fontFamily: "SpaceGrotesk",
                    ),
                    cursorOpacityAnimates: true,
                    keyboardType: TextInputType.multiline,
                    cursorRadius: Radius.circular(5.0),
                    cursorWidth: 3.0,
                    cursorHeight: 20.0,
                    cursorColor: AppColors.noteTextColor.withValues(alpha: 0.5),
                    decoration: const InputDecoration(
                      hintText: "Spill the tea—what's on your mind? 🍵",
                      border: InputBorder.none,
                      hintFadeDuration: Duration(milliseconds: 100),
                      contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                      hintStyle: TextStyle(color: AppColors.selectedDateTextColor),
                    ),
                    onChanged: (value) => onSave(selectedDate.noteKey, value)),
              );
            },
          ),
          crossFadeState: selectedDate.day == DateTime.now().day && (provider.editing || provider.latestNote.isEmpty)
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstCurve: Curves.easeInOut,
          secondCurve: Curves.easeInOut,
          sizeCurve: Curves.easeInOut,
          duration: 100.milliseconds,
        );
      },
    );
  }
}

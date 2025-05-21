import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:macos_note_statusbar/utils/colors.dart';
import 'package:macos_note_statusbar/utils/extensions.dart';

class NoteHeader extends StatelessWidget {
  final DateTime selectedDate;
  final List<String> dates;
  final void Function(String) onDateChanged;

  const NoteHeader({
    super.key,
    required this.selectedDate,
    required this.dates,
    required this.onDateChanged,
  });

  String _getMonthName(String date) {
    final month = int.parse(date.split('-')[1]);
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              _getMonthName(selectedDate.noteKey),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.selectedDateTextColor,
              ),
            ),
            const SizedBox(width: 5.0),
            AnimatedFlipCounter(
              value: selectedDate.day,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.selectedDateTextColor,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          decoration: const ShapeDecoration(
            shape: CircleBorder(),
            color: AppColors.scrollBackgroundWhite,
          ),
          padding: const EdgeInsets.all(5.0),
          alignment: Alignment.center,
          child: InkWell(
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.selectedDateTextColor,
            ),
            onTap: () {
              final currentIndex = dates.indexOf(selectedDate.noteKey);
              if (currentIndex > 0) {
                onDateChanged(dates[currentIndex - 1]);
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: const ShapeDecoration(
            shape: CircleBorder(),
            color: AppColors.scrollBackgroundWhite,
          ),
          padding: const EdgeInsets.all(5.0),
          alignment: Alignment.center,
          child: InkWell(
            onTap: () {
              final currentIndex = dates.indexOf(selectedDate.noteKey);
              if (currentIndex < dates.length - 1) {
                onDateChanged(dates[currentIndex + 1]);
              }
            },
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.selectedDateTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
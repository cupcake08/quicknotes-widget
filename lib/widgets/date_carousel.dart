import 'package:flutter/material.dart';
import 'package:macos_note_statusbar/utils/colors.dart';
import 'package:macos_note_statusbar/utils/extensions.dart';

class DateCarousel extends StatelessWidget {
  final List<String> dates;
  final DateTime selectedDate;
  final ScrollController scrollController;
  final void Function(String) onDateSelected;

  const DateCarousel({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.scrollController,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          // side: BorderSide(color: AppColors.noteTextColor.withValues(alpha: 0.2)),
        ),
        color: AppColors.scrollBackgroundWhite,
        // shadows: [
        //   BoxShadow(
        //     color: AppColors.noteTextColor.(0.1), // Shadow color
        //     offset: const Offset(0, 4), // Shadow position (below the container)
        //     blurRadius: 8, // Blur for a soft shadow
        //     spreadRadius: 2, // Slight spread for a more realistic elevation
        //   ),
        // ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        gradient: LinearGradient(
          colors: [
            AppColors.dateTextColor.withValues(alpha: 0.6),
            AppColors.dateTextColor.withValues(alpha: 0.0),
            AppColors.dateTextColor.withValues(alpha: 0.0),
            AppColors.dateTextColor.withValues(alpha: 0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
      child: ListView.builder(
        controller: scrollController,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date == selectedDate.noteKey;
          final day = date.day;
          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              height: 36,
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.selectedDateColor : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: isSelected ? 17 : 17,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.selectedDateTextColor : AppColors.dateTextColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

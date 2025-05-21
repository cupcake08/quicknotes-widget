import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:macos_note_statusbar/provider/note_provider.dart';
import 'package:macos_note_statusbar/utils/colors.dart';
import 'package:macos_note_statusbar/utils/debouncer.dart';
import 'package:macos_note_statusbar/utils/extensions.dart';
import 'package:macos_note_statusbar/utils/notes_mixin.dart';
import 'package:macos_note_statusbar/utils/throttler.dart';
import 'package:provider/provider.dart';
import 'widgets/date_carousel.dart';
import 'widgets/note_header.dart';
import 'widgets/note_editor.dart';

class NotePopup extends StatefulWidget {
  const NotePopup({super.key});

  @override
  State<NotePopup> createState() => _NotePopupState();
}

class _NotePopupState extends State<NotePopup> with NotesMixin {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isProgrammaticScroll = false;

  List<String> _dates = [];
  DateTime _startDate = DateTime(2024, 4, 1);
  DateTime _endDate = DateTime(2030, 6, 30);

  final double itemHeight = 40.0;

  final Throttler _centerthrottle = Throttler(2000.milliseconds);
  final Debouncer _centerDebounce = Debouncer(10.milliseconds);

  @override
  void initState() {
    super.initState();
    _generateInitialDates();
    loadNote(_selectedDate.noteKey);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _centerSelectedDate();
    });

    _scrollController.addListener(() {
      // if (_scrollController.hasClients && !_isCentered) {
      //   _centerSelectedDate();
      //   _isCentered = true;
      // }
      if (!_isProgrammaticScroll && _scrollController.hasClients) {
        _checkForMonthExtension();
        _centerDebounce.call(() {
          _updateSelectedDateFromScroll();
          if (_scrollController.position.userScrollDirection == ScrollDirection.idle) {
            _centerSelectedDate();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _centerthrottle.reset();
    _centerDebounce.reset();
    super.dispose();
  }

  void _generateInitialDates() {
    _dates = [];
    DateTime currentDate = DateTime.now();
    DateTime start = DateTime(currentDate.year, currentDate.month - 1, 1);
    DateTime end = DateTime(currentDate.year, currentDate.month + 2, 0);

    _startDate = start;
    _endDate = end;

    DateTime current = start;
    while (!current.isAfter(end)) {
      _dates.add(current.noteKey);
      current = current.add(const Duration(days: 1));
    }
  }

  void _checkForMonthExtension() {
    if (!_scrollController.hasClients) return;

    final scrollOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final threshold = 5 * itemHeight;

    if (scrollOffset < threshold) {
      setState(() {
        DateTime newStart = DateTime(_startDate.year, _startDate.month - 1, 1);
        DateTime tempDate = newStart;
        List<String> newDates = [];

        while (tempDate.isBefore(_startDate)) {
          newDates.add(tempDate.noteKey);
          tempDate = tempDate.add(const Duration(days: 1));
        }

        final addedItems = newDates.length;
        _dates.insertAll(0, newDates);
        _startDate = newStart;

        _isProgrammaticScroll = true;
        _scrollController.jumpTo(scrollOffset + (addedItems * itemHeight));
        _isProgrammaticScroll = false;
      });
    }

    if (scrollOffset > maxScrollExtent - threshold) {
      setState(() {
        DateTime newEnd = DateTime(_endDate.year, _endDate.month + 2, 0);
        DateTime tempDate = _endDate.add(const Duration(days: 1));
        List<String> newDates = [];

        while (!tempDate.isAfter(newEnd)) {
          newDates.add(tempDate.toIso8601String().split('T')[0]);
          tempDate = tempDate.add(const Duration(days: 1));
        }

        _dates.addAll(newDates);
        _endDate = newEnd;
      });
    }
  }

  void _centerSelectedDate() {
    final index = _dates.indexOf(_selectedDate.noteKey);
    if (index != -1 && _scrollController.hasClients) {
      final viewportHeight = _scrollController.position.viewportDimension;
      final targetOffset = (index * itemHeight) - (viewportHeight / 2) + (itemHeight / 2);

      _isProgrammaticScroll = true;
      _scrollController
          .animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        _isProgrammaticScroll = false;
      });
    }
  }

  void _updateSelectedDateFromScroll() {
    if (_scrollController.hasClients) {
      final viewportHeight = _scrollController.position.viewportDimension;
      final scrollOffset = _scrollController.offset;

      final middleOffset = scrollOffset + (viewportHeight / 2);
      int middleIndex = (middleOffset / itemHeight).round().clamp(0, _dates.length - 1);

      final newSelectedDate = _dates[middleIndex];
      if (newSelectedDate != _selectedDate.noteKey) {
        setState(() {
          loadNote(newSelectedDate);
          _selectedDate = newSelectedDate.date;
          _focusNode.requestFocus();
        });
      }
    }
  }

  void _selectDate(String date, {bool immediateCall = false}) {
    setState(() {
      context.read<NoteProvider>().changeMode(false);
      _selectedDate = date.date;
      loadNote(date, immediateCall: immediateCall);
      _centerSelectedDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 360,
          height: 300,
          color: AppColors.backgroundColor,
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              DateCarousel(
                dates: _dates,
                selectedDate: _selectedDate,
                scrollController: _scrollController,
                onDateSelected: (date) => _selectDate(date, immediateCall: true),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0).copyWith(bottom: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NoteHeader(
                        selectedDate: _selectedDate,
                        dates: _dates,
                        onDateChanged: (date) => _selectDate(date, immediateCall: true),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: NoteEditor(
                          selectedDate: _selectedDate,
                          controller: _controller,
                          focusNode: _focusNode,
                          onSave: (key, value) => saveNote(key, value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

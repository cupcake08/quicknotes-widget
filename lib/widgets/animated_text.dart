import 'package:flutter/material.dart';
import 'package:macos_note_statusbar/utils/colors.dart';

class TextRevealAnimationWidget extends StatefulWidget {
  final String text;
  final bool shouldAnimate;
  final VoidCallback? onTap;
  final TextStyle textStyle;
  final String emptyText;
  final String noteKey;

  const TextRevealAnimationWidget({
    super.key,
    required this.text,
    required this.textStyle,
    required this.emptyText,
    this.shouldAnimate = true,
    this.onTap,
    required this.noteKey,
  });

  @override
  State<TextRevealAnimationWidget> createState() => _TextRevealAnimationWidgetState();
}

class _TextRevealAnimationWidgetState extends State<TextRevealAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _opacityAnimations;
  late List<Animation<double>> _slideAnimations;
  bool _hasAnimated = false;
  List<String> _characters = [];
  List<List<int>> _lineCharacterIndices = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    if (widget.shouldAnimate && !_hasAnimated) {
      _controller.forward();
      _hasAnimated = true;
    }
  }

  @override
  void didUpdateWidget(TextRevealAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.textStyle != widget.textStyle) {
      _controller.reset();
      _hasAnimated = false;
      if (widget.shouldAnimate && !_hasAnimated) {
        _controller.forward();
        _hasAnimated = true;
      }
    }
  }

  void _setupCharactersAndAnimations(double maxWidth) {
    _characters = [];
    _lineCharacterIndices = [];

    final textToUse = widget.text.isEmpty ? widget.emptyText : widget.text;

    // Split text by explicit newlines
    final lines = textToUse.split('\n');
    int charIndex = 0;

    // Process each line for word wrapping
    for (var line in lines) {
      if (line.isEmpty) {
        _characters.add('\n');
        _lineCharacterIndices.add([charIndex]);
        charIndex++;
        continue;
      }

      List<int> currentLineIndices = [];
      int startOffset = 0;

      while (startOffset < line.length) {
        // Use TextPainter to determine where the text wraps within the available width
        final remainingText = line.substring(startOffset);
        final textPainter = TextPainter(
          text: TextSpan(text: remainingText, style: widget.textStyle),
          textDirection: TextDirection.ltr,
          maxLines: null,
        );
        textPainter.layout(maxWidth: maxWidth);

        // Get the position where the text would wrap
        final endPosition = textPainter.getPositionForOffset(Offset(maxWidth, 0));
        int endOffset = startOffset + endPosition.offset;

        // Clamp endOffset to the line length to prevent range errors
        endOffset = endOffset.clamp(startOffset, line.length);

        if (endOffset == startOffset) {
          // If no characters fit, force at least one character to avoid infinite loop
          endOffset = startOffset + 1;
        }

        // Find the last space before the wrap point to avoid splitting words
        if (endOffset < line.length) {
          final subLine = line.substring(startOffset, endOffset);
          final lastSpace = subLine.lastIndexOf(' ');
          if (lastSpace != -1) {
            endOffset = startOffset + lastSpace;
          }
        }

        // Extract the wrapped line
        final wrappedLine = line.substring(startOffset, endOffset);
        for (var char in wrappedLine.characters) {
          _characters.add(char);
          currentLineIndices.add(charIndex);
          charIndex++;
        }

        // Add a newline character to represent the wrap
        // if (endOffset < line.length || lines.indexOf(line) < lines.length - 1) {
        //   _characters.add('\n');
        //   currentLineIndices.add(charIndex);
        //   charIndex++;
        // }

        _lineCharacterIndices.add(List.from(currentLineIndices));

        currentLineIndices.clear();
        startOffset = endOffset;

        // Skip the space if we wrapped at a space
        if (startOffset < line.length && line[startOffset] == ' ') {
          startOffset++;
        }
      }
    }

    // Calculate stagger delay based on text length to fit within 0.0 to 1.0
    const double animationDurationPerCharacter = 0.33;
    double characterDelay;
    if (_characters.length <= 1) {
      characterDelay = 0.0;
    } else {
      characterDelay = (1.0 - animationDurationPerCharacter) / (_characters.length - 1);
    }

    _opacityAnimations = List.generate(
      _characters.length,
      (index) {
        final begin = index * characterDelay;
        final end = begin + animationDurationPerCharacter;
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              begin,
              end.clamp(0.0, 1.0),
              curve: Curves.easeIn,
            ),
          ),
        );
      },
    );

    _slideAnimations = List.generate(
      _characters.length,
      (index) {
        final begin = index * characterDelay;
        double end = begin + animationDurationPerCharacter;
        if (index == _characters.length - 1) {
          end = 1.0;
        }
        return Tween<double>(begin: 10.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              begin,
              end.clamp(0.0, 1.0),
              curve: Curves.ease,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: LayoutBuilder(
        key: ValueKey('editing-${widget.noteKey}'),
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth - 20.0;
          _setupCharactersAndAnimations(maxWidth);
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.noteTextColor,
                  AppColors.noteTextColor,
                  Colors.transparent,
                ],
                stops: [0.0, 0.05, 0.95, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _lineCharacterIndices.map((lineIndices) {
                      if (lineIndices.length == 1 && _characters[lineIndices[0]] == '\n') {
                        return Text("", style: widget.textStyle);
                      }
                      return Container(
                        constraints: BoxConstraints(maxWidth: maxWidth + 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: lineIndices.map((index) {
                            return Opacity(
                              opacity: _opacityAnimations[index].value,
                              child: Transform.translate(
                                offset: Offset(0, _slideAnimations[index].value),
                                child: Text(
                                  _characters[index],
                                  style: widget.text.isEmpty
                                      ? widget.textStyle.copyWith(color: AppColors.selectedDateTextColor)
                                      : widget.textStyle,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

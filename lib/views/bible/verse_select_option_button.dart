import 'package:flutter/material.dart';
import '../../core/stylesheet.dart';

class VerseSelectOptionButton extends StatelessWidget {
  const VerseSelectOptionButton({
    super.key,
    required this.newCard,
    required this.verseText,
    this.onTap,
  });

  final String verseText;
  final bool newCard;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60),
        decoration: newCard ? Stylesheet.whiteCardDecoration : Stylesheet.blueCardDecoration,
        child: newCard
            ? Column(
                spacing: 10,
                children: [
                  const Text(
                    '말씀 추가하기',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Stylesheet.label,
                    ),
                  ),
                  Text(verseText, style: const TextStyle(fontSize: 14, color: Stylesheet.theme)),
                ],
              )
            : Column(
                spacing: 10,
                children: [
                  const Text(
                    '말씀 읽기',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Stylesheet.primary,
                    ),
                  ),
                  Text(verseText, style: const TextStyle(fontSize: 14, color: Stylesheet.primary)),
                ],
              ),
      ),
    );
  }
}

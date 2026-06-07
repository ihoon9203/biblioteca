import 'package:flutter/material.dart';
import 'book_list_screen.dart';

class BibleNavigator extends StatelessWidget {
  const BibleNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => const BookListScreen(),
      ),
    );
  }
}

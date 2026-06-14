import 'package:flutter/material.dart';

class NewNoteScreen extends StatelessWidget {
  final String book;
  final String chapter;
  final String verse;
  const NewNoteScreen({super.key, required this.book, required this.chapter, required this.verse});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('NewNoteScreen')));
  }
}

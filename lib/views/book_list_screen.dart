import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bible_viewmodel.dart';
import 'chapter_screen.dart';
import 'verse_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final vm = context.read<BibleViewModel>();
    await vm.loadBooks();
    if (!mounted) return;

    final lastRead = await vm.getLastRead();
    if (lastRead == null || !mounted) return;

    try {
      final book = vm.books.firstWhere((b) => b.korean == lastRead.bookKorean);
      await vm.selectBook(book);
      if (!mounted) return;

      final chapter = vm.chapters.firstWhere((c) => c.chapterNum == lastRead.chapterNum);
      await vm.selectChapter(chapter);
      if (!mounted) return;

      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChapterScreen()));
      Navigator.push(context, MaterialPageRoute(builder: (_) => const VerseScreen()));
    } catch (_) {
      // 저장된 위치가 유효하지 않으면 무시
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('성경')),
      body: Consumer<BibleViewModel>(
        builder: (context, vm, _) {
          if (vm.state == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.state == ViewState.error) {
            return Center(child: Text(vm.error ?? '오류가 발생했습니다'));
          }
          return ListView.builder(
            itemCount: vm.books.length,
            itemBuilder: (context, index) {
              final book = vm.books[index];
              return ListTile(
                title: Text(book.korean),
                subtitle: Text(book.english),
                trailing: Text(book.testament),
                onTap: () async {
                  await vm.selectBook(book);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChapterScreen()),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/stylesheet.dart';
import '../../domain/entities/bible_book.dart';
import '../../domain/entities/chapter.dart';
import '../../viewmodels/bible_viewmodel.dart';

class BibleNavigationSheet extends StatefulWidget {
  const BibleNavigationSheet({super.key, required this.vm});

  final BibleViewModel vm;

  @override
  State<BibleNavigationSheet> createState() => _BibleNavigationSheetState();
}

class _BibleNavigationSheetState extends State<BibleNavigationSheet> {
  late BibleBook _previewBook;
  final ScrollController _bookScroll = ScrollController();
  final ScrollController _chapterScroll = ScrollController();

  static const double _itemHeight = 52.0;

  @override
  void initState() {
    super.initState();
    _previewBook = widget.vm.selectedBook!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToBook(_previewBook);
      _jumpToChapter(widget.vm.selectedChapter?.chapterNum);
    });
  }

  void _jumpToBook(BibleBook book) {
    final int index = widget.vm.books.indexWhere((b) => b.korean == book.korean);
    if (index >= 0) _bookScroll.jumpTo(index * _itemHeight);
  }

  void _jumpToChapter(String? chapterNum) {
    if (chapterNum == null) return;
    final int index = _previewBook.chapters.indexWhere((c) => c.chapterNum == chapterNum);
    if (index >= 0) _chapterScroll.jumpTo(index * _itemHeight);
  }

  void _onBookTap(BibleBook book) {
    setState(() => _previewBook = book);
    if (_chapterScroll.hasClients) _chapterScroll.jumpTo(0);
  }

  Future<void> _onChapterTap(Chapter chapter) async {
    final BibleViewModel vm = widget.vm;
    Navigator.pop(context);
    if (_previewBook.korean != vm.selectedBook!.korean) {
      await vm.selectBook(_previewBook);
    }
    await vm.selectChapter(chapter);
  }

  @override
  void dispose() {
    _bookScroll.dispose();
    _chapterScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BibleViewModel vm = widget.vm;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Stylesheet.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E9ED),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
            child: Row(
              children: [
                const Text(
                  '성경',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Stylesheet.label,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20, color: Stylesheet.secondaryLabel),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE6E9ED)),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    controller: _bookScroll,
                    itemCount: vm.books.length,
                    itemExtent: _itemHeight,
                    itemBuilder: (context, index) {
                      final BibleBook book = vm.books[index];
                      final isPreviewing = book.korean == _previewBook.korean;
                      final isCurrentlyRead = book.korean == vm.selectedBook!.korean;

                      return InkWell(
                        onTap: () => _onBookTap(book),
                        child: Container(
                          color: isPreviewing ? Stylesheet.noteBackground : Colors.transparent,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            book.korean,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isPreviewing || isCurrentlyRead
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isPreviewing
                                  ? Stylesheet.blue
                                  : isCurrentlyRead
                                  ? Stylesheet.blue.withOpacity(0.5)
                                  : Stylesheet.label,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(width: 1, color: const Color(0xFFE6E9ED)),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    controller: _chapterScroll,
                    itemCount: _previewBook.chapters.length,
                    itemExtent: _itemHeight,
                    itemBuilder: (context, index) {
                      final Chapter chapter = _previewBook.chapters[index];
                      final isSameBook = _previewBook.korean == vm.selectedBook!.korean;
                      final bool isSelected =
                          isSameBook && chapter.chapterNum == vm.selectedChapter?.chapterNum;

                      return InkWell(
                        onTap: () => _onChapterTap(chapter),
                        child: Container(
                          color: isSelected ? Stylesheet.noteBackground : Colors.transparent,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '${chapter.chapterNum}장',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? Stylesheet.blue : Stylesheet.label,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../domain/entities/bible_book.dart';
import '../domain/entities/chapter.dart';
import '../viewmodels/bible_viewmodel.dart';

class BibleNavigationSheet extends StatefulWidget {
  final BibleViewModel vm;

  const BibleNavigationSheet({super.key, required this.vm});

  @override
  State<BibleNavigationSheet> createState() => _BibleNavigationSheetState();
}

class _BibleNavigationSheetState extends State<BibleNavigationSheet> {
  late String? _expandedBookKorean;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _expandedBookKorean = widget.vm.selectedBook?.korean;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToExpanded());
  }

  void _scrollToExpanded() {
    if (_expandedBookKorean == null) return;
    if (!_scrollController.hasClients) return;
    final index = widget.vm.books.indexWhere((b) => b.korean == _expandedBookKorean);
    if (index <= 0) return;
    final offset = (index * 57.0).clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return Column(
      children: [
        const _SheetHandle(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('성경 이동', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: vm.books.length,
            itemBuilder: (context, index) {
              final book = vm.books[index];
              final isExpanded = book.korean == _expandedBookKorean;

              return _BookAccordionItem(
                book: book,
                isExpanded: isExpanded,
                vm: vm,
                onHeaderTap: () => setState(() {
                  _expandedBookKorean = isExpanded ? null : book.korean;
                }),
                onChapterTap: (chapter) async {
                  await vm.selectBook(book);
                  await vm.selectChapter(chapter);
                  if (context.mounted) Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookAccordionItem extends StatelessWidget {
  final BibleBook book;
  final bool isExpanded;
  final BibleViewModel vm;
  final VoidCallback onHeaderTap;
  final Future<void> Function(Chapter) onChapterTap;

  const _BookAccordionItem({
    required this.book,
    required this.isExpanded,
    required this.vm,
    required this.onHeaderTap,
    required this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOT = book.testament == 'OT';
    final isCurrentBook = book.korean == vm.selectedBook?.korean;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onHeaderTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOT ? Colors.blue.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isOT ? '구약' : '신약',
                    style: TextStyle(
                      fontSize: 11,
                      color: isOT ? Colors.blue.shade700 : Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    book.korean,
                    style: TextStyle(
                      fontWeight: isCurrentBook ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentBook ? colorScheme.primary : null,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down, size: 20),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: isExpanded
              ? _ChapterGrid(book: book, vm: vm, onChapterTap: onChapterTap)
              : const SizedBox(width: double.infinity),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _ChapterGrid extends StatelessWidget {
  final BibleBook book;
  final BibleViewModel vm;
  final Future<void> Function(Chapter) onChapterTap;

  const _ChapterGrid({
    required this.book,
    required this.vm,
    required this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: book.chapters.map((chapter) {
          final isSelected = book.korean == vm.selectedBook?.korean &&
              chapter.chapterNum == vm.selectedChapter?.chapterNum;

          return Material(
            color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              splashColor: colorScheme.onPrimary.withValues(alpha: 0.2),
              onTap: () => onChapterTap(chapter),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Text(
                    chapter.chapterNum,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

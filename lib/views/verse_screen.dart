import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/entities/verse.dart';
import '../viewmodels/bible_viewmodel.dart';
import '../viewmodels/note_viewmodel.dart';
import 'bible_navigation_sheet.dart';
import 'verse_memo_sheet.dart';

class VerseScreen extends StatelessWidget {
  const VerseScreen({super.key});

  void _openNavigationSheet(BuildContext context, BibleViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: BibleNavigationSheet(vm: vm),
      ),
    );
  }

  void _openVerseMemoSheet(BuildContext context, BibleViewModel bibleVm, Verse verse) {
    final noteVm = context.read<NoteViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: VerseMemoSheet(
          noteVm: noteVm,
          books: bibleVm.books,
          book: bibleVm.selectedBook!,
          initialChapterNum: bibleVm.selectedChapter!.chapterNum,
          initialVerseNum: verse.verseNum,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleViewModel>(
      builder: (context, vm, _) {
        final title =
            '${vm.selectedBook?.korean ?? ''} ${vm.selectedChapter?.chapterNum ?? ''}장';

        return Scaffold(
          appBar: AppBar(
            title: ActionChip(
              avatar: const Icon(Icons.menu_book_outlined, size: 16),
              label: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () => _openNavigationSheet(context, vm),
            ),
          ),
          body: vm.state == ViewState.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  key: ValueKey('${vm.selectedBook?.korean}_${vm.selectedChapter?.chapterNum}'),
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.verses.length,
                  itemBuilder: (context, index) {
                    final verse = vm.verses[index];
                    return Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _openVerseMemoSheet(context, vm, verse),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 32,
                                child: Text(
                                  verse.verseNum,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              Expanded(child: Text(verse.text)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: vm.hasPreviousChapter
                        ? OutlinedButton.icon(
                            onPressed: vm.goToPreviousChapter,
                            icon: const Icon(Icons.chevron_left),
                            label: const Text('이전 장'),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: vm.hasNextChapter
                        ? FilledButton.icon(
                            onPressed: vm.goToNextChapter,
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.chevron_right),
                            label: const Text('다음 장'),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

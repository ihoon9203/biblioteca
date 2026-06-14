import 'package:biblioteca/core/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biblioteca/core/stylesheet.dart';
import 'package:biblioteca/domain/entities/verse.dart';
import 'package:biblioteca/viewmodels/bible_viewmodel.dart';
import 'package:biblioteca/viewmodels/note_viewmodel.dart';
import 'package:biblioteca/views/bible/verse_select_option_button.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed, required this.isLeft});

  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), fixedSize: const Size.fromHeight(36), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
      child: isLeft
          ? Row(
              spacing: 4,
              children: [
                Icon(icon, size: 20, color: onPressed != null ? Stylesheet.blue : Stylesheet.theme.withOpacity(0.3)),
                Text(isLeft ? '이전  장' : '다음 장', style: TextStyle(fontSize: 12, color: onPressed != null ? Stylesheet.theme : Stylesheet.theme.withOpacity(0.3))),
              ],
            )
          : Row(
              spacing: 4,
              children: [
                Text('다음 장', style: TextStyle(fontSize: 12, color: onPressed != null ? Stylesheet.theme : Stylesheet.theme.withOpacity(0.3))),
                Icon(icon, size: 20, color: onPressed != null ? Stylesheet.blue : Stylesheet.theme.withOpacity(0.3)),
              ],
            ),
    );
  }
}

class _BibleScreenState extends State<BibleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final vm = context.read<BibleViewModel>();
    await vm.loadBooks();
    if (!mounted || vm.books.isEmpty) return;

    final lastRead = await vm.getLastRead();
    if (!mounted) return;

    if (lastRead != null) {
      try {
        final book = vm.books.firstWhere((b) => b.korean == lastRead.bookKorean);
        await vm.selectBook(book);
        if (!mounted) return;
        final chapter = vm.chapters.firstWhere((c) => c.chapterNum == lastRead.chapterNum);
        await vm.selectChapter(chapter);
        return;
      } catch (_) {}
    }

    // 최초 진입: 창세기 1장
    await vm.selectBook(vm.books.first);
    if (!mounted || vm.chapters.isEmpty) return;
    await vm.selectChapter(vm.chapters.first);
  }

  void _openNavigationSheet(BuildContext context, BibleViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Stylesheet.primary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SizedBox(height: MediaQuery.of(context).size.height * 0.75),
    );
  }

  void _openVerseMemoSheet(BuildContext context, BibleViewModel bibleVm, Verse verse) {
    final noteVm = context.read<NoteViewModel>();
    final verseText = '${bibleVm.selectedBook!.korean} ${bibleVm.selectedChapter!.chapterNum}장 ${verse.verseNum}절';
    final hasNote = noteVm.hasNoteForVerse(bibleVm.selectedBook!.korean, bibleVm.selectedChapter!.chapterNum, verse.verseNum);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: IntrinsicHeight(
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: VerseSelectOptionButton(
                  newCard: true,
                  verseText: verseText,
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed(AppRoute.newNote, queryParameters: {'bookKorean': bibleVm.selectedBook!.korean, 'chapterNum': bibleVm.selectedChapter!.chapterNum, 'verseNum': verse.verseNum});
                  },
                ),
              ),
              if (hasNote)
                Expanded(
                  child: VerseSelectOptionButton(
                    newCard: false,
                    verseText: verseText,
                    onTap: () {
                      Navigator.pop(context);
                      noteVm.openNoteForVerse(context, bibleVm.selectedBook!.korean, bibleVm.selectedChapter!.chapterNum, verse.verseNum);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleViewModel>(
      builder: (context, vm, _) {
        if (vm.selectedBook == null) {
          return const Scaffold(
            backgroundColor: Stylesheet.primary,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final chipLabel = '${vm.selectedBook!.korean}: ${vm.selectedChapter?.chapterNum ?? ''}장';

        return Scaffold(
          backgroundColor: Stylesheet.primary,
          appBar: AppBar(
            backgroundColor: Stylesheet.primary,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: GestureDetector(
              onTap: () => _openNavigationSheet(context, vm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: Stylesheet.noteBackground, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  chipLabel,
                  style: const TextStyle(color: Stylesheet.theme, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  height: 36,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: Stylesheet.noteBackground, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepperButton(icon: Icons.chevron_left, onPressed: vm.hasPreviousChapter ? vm.goToPreviousChapter : null, isLeft: true),
                      Container(width: 1, height: 20, color: Stylesheet.blue.withOpacity(0.2)),
                      _StepperButton(icon: Icons.chevron_right, onPressed: vm.hasNextChapter ? vm.goToNextChapter : null, isLeft: false),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: vm.state == ViewState.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  key: ValueKey('${vm.selectedBook?.korean}_${vm.selectedChapter?.chapterNum}'),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: vm.verses.length,
                  itemBuilder: (context, index) {
                    final verse = vm.verses[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _openVerseMemoSheet(context, vm, verse),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                verse.verseNum,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Stylesheet.theme),
                              ),
                            ),
                            Expanded(
                              child: Text(verse.text, style: const TextStyle(fontSize: 16, color: Stylesheet.label, height: 1.6)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

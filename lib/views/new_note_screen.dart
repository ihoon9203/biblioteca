import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/stylesheet.dart';
import '../domain/entities/bible_book.dart';
import '../domain/entities/note.dart';
import '../viewmodels/bible_viewmodel.dart';
import '../viewmodels/note_viewmodel.dart';

enum _RangeField { startChapter, startVerse, endChapter, endVerse }

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({super.key, required this.book, required this.chapter, required this.verse});
  final String book;
  final String chapter;
  final String verse;

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final _titleController = TextEditingController();
  MemoType? _selectedType;

  late String _startBook;
  late String _endBook;
  final _startChapterCtrl = TextEditingController();
  final _startVerseCtrl = TextEditingController();
  final _endChapterCtrl = TextEditingController();
  final _endVerseCtrl = TextEditingController();

  final _startChapterKey = GlobalKey<_NumberFieldState>();
  final _startVerseKey = GlobalKey<_NumberFieldState>();
  final _endChapterKey = GlobalKey<_NumberFieldState>();
  final _endVerseKey = GlobalKey<_NumberFieldState>();

  @override
  void initState() {
    super.initState();
    _startBook = widget.book;
    _endBook = widget.book;
    _startChapterCtrl.text = widget.chapter;
    _startVerseCtrl.text = widget.verse;

    final BibleViewModel vm = context.read<BibleViewModel>();
    if (vm.books.isEmpty) vm.loadBooks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startChapterCtrl.dispose();
    _startVerseCtrl.dispose();
    _endChapterCtrl.dispose();
    _endVerseCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final NoteViewModel noteVm = context.read<NoteViewModel>();

    final String title = _titleController.text.trim();
    final note = Note(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.isEmpty ? '제목 없음' : title,
      bookKorean: _startBook,
      chapterNum: _startChapterCtrl.text.trim(),
      verseRanges: [
        VerseRange(
          bookKorean: _startBook,
          startChapterNum: _startChapterCtrl.text.trim(),
          startVerseNum: _startVerseCtrl.text.trim(),
          endChapterNum: _endChapterCtrl.text.trim().isEmpty
              ? _startChapterCtrl.text.trim()
              : _endChapterCtrl.text.trim(),
          endVerseNum: _endVerseCtrl.text.trim().isEmpty
              ? _startVerseCtrl.text.trim()
              : _endVerseCtrl.text.trim(),
        ),
      ],
      memoType: _selectedType,
      // content / audioPath stay null for now — UI frame only.
      createdAt: DateTime.now(),
    );

    await noteVm.saveNote(note);
    if (mounted) context.pop();
  }

  void _showBookPicker(String current, ValueChanged<String> onSelected) {
    final List<BibleBook> books = context.read<BibleViewModel>().books;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView.builder(
        itemCount: books.length,
        itemBuilder: (ctx, i) => ListTile(
          title: Text(books[i].korean),
          selected: books[i].korean == current,
          selectedColor: Stylesheet.theme,
          onTap: () {
            onSelected(books[i].korean);
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  // ── Verse range validation ──────────────────────────────────────────────
  BibleBook? _bookByName(String korean) {
    for (final BibleBook b in context.read<BibleViewModel>().books) {
      if (b.korean == korean) return b;
    }
    return null;
  }

  int _bookIndex(String korean) =>
      context.read<BibleViewModel>().books.indexWhere((b) => b.korean == korean);

  int _maxChapter(String bookKorean) {
    final BibleBook? book = _bookByName(bookKorean);
    if (book == null || book.chapters.isEmpty) return 1;
    return book.chapters.length;
  }

  int _maxVerse(String bookKorean, int chapter) {
    final BibleBook? book = _bookByName(bookKorean);
    if (book == null || book.chapters.isEmpty) return 1;
    final int idx = chapter.clamp(1, book.chapters.length) - 1;
    return book.chapters[idx].verses.length;
  }

  int _readInt(TextEditingController c) => int.tryParse(c.text.trim()) ?? 1;

  /// Writes [value] into [ctrl] and flashes its field — only when it actually changes.
  void _setField(TextEditingController ctrl, int value, GlobalKey<_NumberFieldState> key) {
    final str = value.toString();
    if (ctrl.text == str) return;
    ctrl.text = str;
    key.currentState?.flash();
  }

  void _clampField(TextEditingController ctrl, int max, GlobalKey<_NumberFieldState> key) {
    final String text = ctrl.text.trim();
    if (text.isEmpty) return;
    final int? value = int.tryParse(text);
    if (value == null || value < 1) {
      _setField(ctrl, 1, key);
    } else if (value > max) {
      _setField(ctrl, max, key);
    }
  }

  /// Re-validates a field when it loses focus: clamps to the book's real
  /// chapter/verse counts (flashing on correction), then keeps the two rows ordered.
  void _commit(_RangeField field) {
    if (!mounted) return;
    final BibleViewModel vm = context.read<BibleViewModel>();
    if (vm.books.isEmpty) return;

    switch (field) {
      case _RangeField.startChapter:
        _clampField(_startChapterCtrl, _maxChapter(_startBook), _startChapterKey);
        _clampField(
          _startVerseCtrl,
          _maxVerse(_startBook, _readInt(_startChapterCtrl)),
          _startVerseKey,
        );
      case _RangeField.startVerse:
        _clampField(
          _startVerseCtrl,
          _maxVerse(_startBook, _readInt(_startChapterCtrl)),
          _startVerseKey,
        );
      case _RangeField.endChapter:
        _clampField(_endChapterCtrl, _maxChapter(_endBook), _endChapterKey);
        _clampField(_endVerseCtrl, _maxVerse(_endBook, _readInt(_endChapterCtrl)), _endVerseKey);
      case _RangeField.endVerse:
        _clampField(_endVerseCtrl, _maxVerse(_endBook, _readInt(_endChapterCtrl)), _endVerseKey);
    }

    final bool editedEnd = field == _RangeField.endChapter || field == _RangeField.endVerse;
    _syncRangeOrder(editedEnd: editedEnd);
  }

  /// Keeps the end position >= the start position. When out of order, the row the
  /// user just edited wins and the other row is matched to it.
  void _syncRangeOrder({required bool editedEnd}) {
    if (_startChapterCtrl.text.trim().isEmpty ||
        _startVerseCtrl.text.trim().isEmpty ||
        _endChapterCtrl.text.trim().isEmpty ||
        _endVerseCtrl.text.trim().isEmpty) {
      return;
    }

    final List<int> start = [
      _bookIndex(_startBook),
      _readInt(_startChapterCtrl),
      _readInt(_startVerseCtrl),
    ];
    final List<int> end = [
      _bookIndex(_endBook),
      _readInt(_endChapterCtrl),
      _readInt(_endVerseCtrl),
    ];
    if (_comparePos(start, end) <= 0) return; // already ordered

    if (editedEnd) {
      // End was moved before start → pull start back to end.
      if (_startBook != _endBook) setState(() => _startBook = _endBook);
      _setField(_startChapterCtrl, end[1], _startChapterKey);
      _setField(_startVerseCtrl, end[2], _startVerseKey);
    } else {
      // Start was moved past end → push end forward to start.
      if (_endBook != _startBook) setState(() => _endBook = _startBook);
      _setField(_endChapterCtrl, start[1], _endChapterKey);
      _setField(_endVerseCtrl, start[2], _endVerseKey);
    }
  }

  int _comparePos(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return a[i].compareTo(b[i]);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        scrolledUnderElevation: 0,
        leadingWidth: 90,
        leading: GestureDetector(
          onTap: () => context.pop(),
          behavior: HitTestBehavior.opaque,
          child: const Row(
            children: [
              SizedBox(width: 4),
              Icon(Icons.chevron_left_rounded, color: Stylesheet.theme, size: 26),
              Text(
                '성경',
                style: TextStyle(
                  color: Stylesheet.theme,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _save,
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 6, bottom: 6),
              width: 44,
              height: 44,
              decoration: Stylesheet.iconButtonBlueDecoration,
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Stylesheet.label,
              ),
              decoration: const InputDecoration(
                hintText: '제목',
                hintStyle: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCBD5E0),
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '활동 유형을 선택해 주세요',
              style: TextStyle(fontSize: 14, color: Stylesheet.secondaryLabel),
            ),
            const SizedBox(height: 10),
            Row(
              children: MemoType.values.asMap().entries.map((entry) {
                final int i = entry.key;
                final MemoType type = entry.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < MemoType.values.length - 1 ? 8 : 0),
                    child: _ActivityTypeButton(
                      label: type.label,
                      isSelected: _selectedType == type,
                      onTap: () =>
                          setState(() => _selectedType = _selectedType == type ? null : type),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('구절 범위', style: TextStyle(fontSize: 14, color: Stylesheet.secondaryLabel)),
            const SizedBox(height: 12),
            _VerseRangeRow(
              selectedBook: _startBook,
              chapterController: _startChapterCtrl,
              verseController: _startVerseCtrl,
              chapterKey: _startChapterKey,
              verseKey: _startVerseKey,
              onChapterCommit: () => _commit(_RangeField.startChapter),
              onVerseCommit: () => _commit(_RangeField.startVerse),
              onBookTap: () => _showBookPicker(_startBook, (v) {
                setState(() => _startBook = v);
                _commit(_RangeField.startChapter);
              }),
            ),
            Center(
              child: Container(
                width: 4,
                height: 20,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: Stylesheet.themeLight,
              ),
            ),
            _VerseRangeRow(
              selectedBook: _endBook,
              chapterController: _endChapterCtrl,
              verseController: _endVerseCtrl,
              chapterKey: _endChapterKey,
              verseKey: _endVerseKey,
              onChapterCommit: () => _commit(_RangeField.endChapter),
              onVerseCommit: () => _commit(_RangeField.endVerse),
              onBookTap: () => _showBookPicker(_endBook, (v) {
                setState(() => _endBook = v);
                _commit(_RangeField.endChapter);
              }),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: switch (_selectedType) {
                MemoType.sermon => const _SermonSection(key: ValueKey(MemoType.sermon)),
                // QT & 공부 share one key so switching between them updates the
                // label in place (no transition); only sermon↔content animates.
                MemoType.qt => const _ContentSection(
                  key: ValueKey('content'),
                  label: 'QT 내용 추가하기',
                ),
                MemoType.study => const _ContentSection(
                  key: ValueKey('content'),
                  label: '공부 내용 추가하기',
                ),
                null => const SizedBox.shrink(key: ValueKey('none')),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTypeButton extends StatelessWidget {
  const _ActivityTypeButton({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: isSelected
            ? Stylesheet.selectedButtonDecoration
            : Stylesheet.unselectedButtonDecoration,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Stylesheet.secondary,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _VerseRangeRow extends StatelessWidget {
  const _VerseRangeRow({
    required this.selectedBook,
    required this.chapterController,
    required this.verseController,
    required this.chapterKey,
    required this.verseKey,
    required this.onChapterCommit,
    required this.onVerseCommit,
    required this.onBookTap,
  });
  final String selectedBook;
  final TextEditingController chapterController;
  final TextEditingController verseController;
  final GlobalKey<_NumberFieldState> chapterKey;
  final GlobalKey<_NumberFieldState> verseKey;
  final VoidCallback onChapterCommit;
  final VoidCallback onVerseCommit;
  final VoidCallback onBookTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Stylesheet.rangeTextFieldDecoration,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBookTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedBook.isEmpty ? '책 선택' : selectedBook,
                  style: const TextStyle(
                    color: Stylesheet.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Stylesheet.secondary,
                  size: 20,
                ),
              ],
            ),
          ),
          const Spacer(),
          _NumberField(key: chapterKey, controller: chapterController, onCommit: onChapterCommit),
          const SizedBox(width: 6),
          const Text('장', style: TextStyle(color: Stylesheet.label, fontSize: 15)),
          const SizedBox(width: 16),
          _NumberField(key: verseKey, controller: verseController, onCommit: onVerseCommit),
          const SizedBox(width: 6),
          const Text('절', style: TextStyle(color: Stylesheet.label, fontSize: 15)),
        ],
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({super.key, required this.controller, required this.onCommit});
  final TextEditingController controller;
  final VoidCallback onCommit;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) widget.onCommit();
  }

  /// Briefly flashes the field's background — used when its value is auto-corrected.
  void flash() {
    _flashController.forward(from: 0).then((_) {
      if (mounted) _flashController.reverse();
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flashController,
      builder: (context, child) {
        final double t = Curves.easeOut.transform(_flashController.value);
        final Color color = Color.lerp(Stylesheet.noteBackground, Stylesheet.numberFieldFlash, t)!;
        return Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: Stylesheet.numberTextFieldDecoration.copyWith(
            color: color,
            border: Border.all(color: color),
          ),
          alignment: Alignment.center,
          child: child,
        );
      },
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onSubmitted: (_) => widget.onCommit(),
        style: const TextStyle(fontSize: 14, color: Stylesheet.label),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _SermonSection extends StatelessWidget {
  const _SermonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '설교 녹음 하기',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Stylesheet.label),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ContentModeButton(icon: Icons.mic_rounded, isBlue: true, onTap: () {}),
              const SizedBox(width: 20),
              _ContentModeButton(icon: Icons.description_rounded, isBlue: false, onTap: () {}),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            '녹음을 시작하면 메모 화면으로 이동할 수 있어요',
            style: TextStyle(color: Stylesheet.label, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _ContentSection extends StatefulWidget {
  const _ContentSection({super.key, required this.label});
  final String label;

  @override
  State<_ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<_ContentSection> {
  final bool _cameraMode = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Stylesheet.label,
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ContentModeButton(
                icon: Icons.camera_alt_rounded,
                isBlue: false,
                onTap: () => setState(() {}),
              ),
              const SizedBox(width: 16),
              _ContentModeButton(
                icon: Icons.description_rounded,
                isBlue: true,
                onTap: () => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            '내용을 촬영하거나 직접 입력하세요',
            style: TextStyle(color: Stylesheet.theme, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _ContentModeButton extends StatelessWidget {
  const _ContentModeButton({required this.icon, required this.isBlue, required this.onTap});
  final IconData icon;
  final bool isBlue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: isBlue ? Stylesheet.theme : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: isBlue ? Stylesheet.blueCardShadow : Stylesheet.whiteCardShadow,
        ),
        child: Icon(icon, color: isBlue ? Colors.white : Stylesheet.secondary, size: 36),
      ),
    );
  }
}

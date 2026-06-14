import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/bible_book.dart';
import '../domain/entities/note.dart';
import '../viewmodels/note_viewmodel.dart';

enum _RecordState { idle, recording, recorded }
enum _PickerType { book, start, end }

class VerseMemoSheet extends StatefulWidget {
  final NoteViewModel noteVm;
  final List<BibleBook> books;
  final BibleBook book;
  final String initialChapterNum;
  final String initialVerseNum;

  const VerseMemoSheet({
    super.key,
    required this.noteVm,
    required this.books,
    required this.book,
    required this.initialChapterNum,
    required this.initialVerseNum,
  });

  @override
  State<VerseMemoSheet> createState() => _VerseMemoSheetState();
}

class _VerseMemoSheetState extends State<VerseMemoSheet> {
  // ── 폼 상태 ───────────────────────────────────────────────
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late List<VerseRange> _ranges;
  MemoType? _selectedMemoType;

  // ── 녹음 상태 ─────────────────────────────────────────────
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  _RecordState _recordState = _RecordState.idle;
  String? _audioPath;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  bool _isPlaying = false;
  bool _isSaving = false;

  // ── 인라인 피커 상태 ──────────────────────────────────────
  bool _pickerOpen = false;
  int _pickerRangeIndex = 0;
  _PickerType _pickerType = _PickerType.start;
  late BibleBook _pickerBook;
  String _pickerChapter = '1';
  String _pickerVerse = '1';

  final ScrollController _pickerBookCtrl = ScrollController();
  final ScrollController _pickerChapterCtrl = ScrollController();
  final ScrollController _pickerVerseCtrl = ScrollController();

  static const _itemH = 48.0;

  // ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _titleController = TextEditingController(text: _buildDefaultTitle(now));
    _contentController = TextEditingController();
    _pickerBook = widget.book;
    _ranges = [
      VerseRange(
        bookKorean: widget.book.korean,
        startChapterNum: widget.initialChapterNum,
        startVerseNum: widget.initialVerseNum,
        endChapterNum: widget.initialChapterNum,
        endVerseNum: widget.initialVerseNum,
      ),
    ];
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _recordTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
    _pickerBookCtrl.dispose();
    _pickerChapterCtrl.dispose();
    _pickerVerseCtrl.dispose();
    super.dispose();
  }

  // ── 유틸 ─────────────────────────────────────────────────

  String _buildDefaultTitle(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} 말씀';

  bool _isAfter(String c1, String v1, String c2, String v2) {
    final ch1 = int.parse(c1), ch2 = int.parse(c2);
    if (ch1 != ch2) return ch1 > ch2;
    return int.parse(v1) > int.parse(v2);
  }

  void _scrollPickerTo(ScrollController ctrl, int index) {
    if (!ctrl.hasClients) return;
    final offset =
        (_itemH * index - _itemH * 2).clamp(0.0, ctrl.position.maxScrollExtent);
    ctrl.jumpTo(offset);
  }

  // ── 범위 관리 ─────────────────────────────────────────────

  void _addRange() => setState(() => _ranges.add(VerseRange(
        bookKorean: widget.book.korean,
        startChapterNum: widget.initialChapterNum,
        startVerseNum: widget.initialVerseNum,
        endChapterNum: widget.initialChapterNum,
        endVerseNum: widget.initialVerseNum,
      )));

  void _removeRange(int index) => setState(() => _ranges.removeAt(index));

  // ── 피커 ─────────────────────────────────────────────────

  void _openPicker(int rangeIndex, _PickerType type) {
    // 같은 칩을 다시 누르면 닫기
    if (_pickerOpen &&
        _pickerRangeIndex == rangeIndex &&
        _pickerType == type) {
      _closePicker();
      return;
    }

    final r = _ranges[rangeIndex];
    final book = widget.books.firstWhere((b) => b.korean == r.bookKorean);
    final isEnd = type == _PickerType.end;

    setState(() {
      _pickerRangeIndex = rangeIndex;
      _pickerType = type;
      _pickerBook = book;
      _pickerChapter = isEnd ? r.endChapterNum : r.startChapterNum;
      _pickerVerse = isEnd ? r.endVerseNum : r.startVerseNum;
      _pickerOpen = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookIdx =
          widget.books.indexWhere((b) => b.korean == _pickerBook.korean);
      final chIdx =
          book.chapters.indexWhere((c) => c.chapterNum == _pickerChapter);
      final verses =
          book.chapters.firstWhere((c) => c.chapterNum == _pickerChapter).verses;
      final vIdx = verses.indexWhere((v) => v.verseNum == _pickerVerse);
      _scrollPickerTo(_pickerBookCtrl, bookIdx);
      _scrollPickerTo(_pickerChapterCtrl, chIdx);
      _scrollPickerTo(_pickerVerseCtrl, vIdx);
    });
  }

  void _closePicker() => setState(() => _pickerOpen = false);

  void _selectPickerBook(BibleBook book) {
    final firstChapter = book.chapters.first;
    final firstVerse = firstChapter.verses.first.verseNum;
    setState(() {
      _pickerBook = book;
      _pickerChapter = firstChapter.chapterNum;
      _pickerVerse = firstVerse;
    });
    _pickerChapterCtrl.jumpTo(0);
    _pickerVerseCtrl.jumpTo(0);
  }

  void _selectPickerChapter(String chapterNum) {
    final firstVerse = _pickerBook.chapters
        .firstWhere((c) => c.chapterNum == chapterNum)
        .verses
        .first
        .verseNum;
    setState(() {
      _pickerChapter = chapterNum;
      _pickerVerse = firstVerse;
    });
    _pickerVerseCtrl.jumpTo(0);
  }

  void _confirmPicker() {
    final r = _ranges[_pickerRangeIndex];
    final bookChanged = _pickerBook.korean != r.bookKorean;
    final VerseRange updated;

    if (_pickerType != _PickerType.end) {
      // start 또는 book 칩: start 갱신, 책이 바뀌거나 start > end이면 end도 동기화
      if (bookChanged ||
          _isAfter(_pickerChapter, _pickerVerse, r.endChapterNum, r.endVerseNum)) {
        updated = VerseRange(
          bookKorean: _pickerBook.korean,
          startChapterNum: _pickerChapter,
          startVerseNum: _pickerVerse,
          endChapterNum: _pickerChapter,
          endVerseNum: _pickerVerse,
        );
      } else {
        updated = VerseRange(
          bookKorean: _pickerBook.korean,
          startChapterNum: _pickerChapter,
          startVerseNum: _pickerVerse,
          endChapterNum: r.endChapterNum,
          endVerseNum: r.endVerseNum,
        );
      }
    } else {
      // end 칩: end 갱신, 책이 바뀌거나 end < start이면 start도 동기화
      if (bookChanged ||
          _isAfter(r.startChapterNum, r.startVerseNum, _pickerChapter, _pickerVerse)) {
        updated = VerseRange(
          bookKorean: _pickerBook.korean,
          startChapterNum: _pickerChapter,
          startVerseNum: _pickerVerse,
          endChapterNum: _pickerChapter,
          endVerseNum: _pickerVerse,
        );
      } else {
        updated = VerseRange(
          bookKorean: _pickerBook.korean,
          startChapterNum: r.startChapterNum,
          startVerseNum: r.startVerseNum,
          endChapterNum: _pickerChapter,
          endVerseNum: _pickerVerse,
        );
      }
    }

    setState(() {
      _ranges[_pickerRangeIndex] = updated;
      _pickerOpen = false;
    });
  }

  // ── 녹음 ─────────────────────────────────────────────────

  Future<void> _toggleRecording() async {
    if (_recordState == _RecordState.recording) {
      _recordTimer?.cancel();
      final path = await _recorder.stop();
      setState(() {
        _audioPath = path;
        _recordState = _RecordState.recorded;
      });
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('마이크 권한이 필요합니다.')),
          );
        }
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: filePath);
      setState(() {
        _recordSeconds = 0;
        _recordState = _RecordState.recording;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordSeconds++);
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
    } else if (_audioPath != null) {
      await _player.play(DeviceFileSource(_audioPath!));
      setState(() => _isPlaying = true);
    }
  }

  void _deleteRecording() => setState(() {
        _audioPath = null;
        _recordState = _RecordState.idle;
        _recordSeconds = 0;
      });

  String _formatDuration(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // ── 저장 ─────────────────────────────────────────────────

  Future<void> _save() async {
    if (_isSaving) return;
    if (_pickerOpen) _closePicker();
    if (_recordState == _RecordState.recording) {
      _recordTimer?.cancel();
      _audioPath = await _recorder.stop();
      if (mounted) setState(() => _recordState = _RecordState.recorded);
    }
    setState(() => _isSaving = true);
    final now = DateTime.now();
    final titleText = _titleController.text.trim();
    final note = Note(
      id: const Uuid().v4(),
      title: titleText.isEmpty ? _buildDefaultTitle(now) : titleText,
      bookKorean: widget.book.korean,
      chapterNum: widget.initialChapterNum,
      verseRanges: List.from(_ranges),
      memoType: _selectedMemoType,
      content: _contentController.text.trim().isEmpty
          ? null
          : _contentController.text.trim(),
      audioPath: _audioPath,
      createdAt: now,
    );
    await widget.noteVm.saveNote(note);
    if (mounted) Navigator.of(context).pop();
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pickerH = MediaQuery.of(context).size.height * 0.38;

    return Column(
      children: [
        // 드래그 핸들
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // 폼 콘텐츠
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                TextField(
                  controller: _titleController,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: _buildDefaultTitle(DateTime.now()),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Divider(color: colorScheme.outlineVariant),

                // 구절 범위
                _SectionHeader(
                    icon: Icons.menu_book_outlined, label: '구절 범위'),
                const SizedBox(height: 8),
                ...List.generate(
                  _ranges.length,
                  (i) => _VerseRangeRow(
                    range: _ranges[i],
                    onBookTap: () => _openPicker(i, _PickerType.book),
                    onStartTap: () => _openPicker(i, _PickerType.start),
                    onEndTap: () => _openPicker(i, _PickerType.end),
                    onRemove:
                        _ranges.length > 1 ? () => _removeRange(i) : null,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addRange,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('범위 추가'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),

                // 구절 범위 바로 아래 인라인 피커
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _pickerOpen
                      ? _buildPickerPanel(colorScheme, pickerH)
                      : const SizedBox.shrink(),
                ),

                Divider(color: colorScheme.outlineVariant),

                // 메모 종류
                _SectionHeader(icon: Icons.label_outline, label: '메모 종류'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: MemoType.values
                      .map((type) => ChoiceChip(
                            label: Text(type.label),
                            selected: _selectedMemoType == type,
                            onSelected: (selected) => setState(
                              () => _selectedMemoType =
                                  selected ? type : null,
                            ),
                          ))
                      .toList(),
                ),
                Divider(color: colorScheme.outlineVariant),

                // 메모 내용
                _SectionHeader(
                    icon: Icons.edit_note_outlined, label: '메모'),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                ),
                Divider(color: colorScheme.outlineVariant),

                // 녹음
                _SectionHeader(icon: Icons.mic_outlined, label: '녹음'),
                const SizedBox(height: 8),
                _buildRecordingSection(colorScheme),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('저장'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 인라인 피커 패널 ──────────────────────────────────────

  Widget _buildPickerPanel(ColorScheme colorScheme, double height) {
    const headerH = 48.0;
    const labelsH = 30.0;
    const buffer = 4.0;
    final listsH = height - headerH - labelsH - 1.0 - buffer;

    final verses = _pickerBook.chapters
        .firstWhere((c) => c.chapterNum == _pickerChapter)
        .verses;

    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant),
            bottom: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더
            SizedBox(
              height: headerH,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                child: Row(
                  children: [
                    Text(
                      '${_pickerBook.korean} $_pickerChapter장 $_pickerVerse절',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _closePicker,
                      icon: const Icon(Icons.close, size: 20),
                      visualDensity: VisualDensity.compact,
                      color: colorScheme.outline,
                    ),
                  ],
                ),
              ),
            ),

            // 컬럼 레이블
            SizedBox(
              height: labelsH,
              child: Row(
                children: [
                  _PickerColumnLabel('책', colorScheme),
                  _PickerDivider(colorScheme),
                  _PickerColumnLabel('장', colorScheme),
                  _PickerDivider(colorScheme),
                  _PickerColumnLabel('절', colorScheme),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),

            // 책 / 장 / 절 목록
            SizedBox(
              height: listsH,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 책 목록
                  Expanded(
                    child: ListView.builder(
                      controller: _pickerBookCtrl,
                      itemExtent: _itemH,
                      itemCount: widget.books.length,
                      itemBuilder: (_, i) {
                        final b = widget.books[i];
                        final selected = b.korean == _pickerBook.korean;
                        return _PickerItem(
                          label: b.korean,
                          selected: selected,
                          colorScheme: colorScheme,
                          onTap: () => _selectPickerBook(b),
                        );
                      },
                    ),
                  ),
                  _PickerDivider(colorScheme),

                  // 장 목록
                  Expanded(
                    child: ListView.builder(
                      controller: _pickerChapterCtrl,
                      itemExtent: _itemH,
                      itemCount: _pickerBook.chapters.length,
                      itemBuilder: (_, i) {
                        final chap = _pickerBook.chapters[i];
                        final selected = chap.chapterNum == _pickerChapter;
                        return _PickerItem(
                          label: '${chap.chapterNum}장',
                          selected: selected,
                          colorScheme: colorScheme,
                          onTap: () => _selectPickerChapter(chap.chapterNum),
                        );
                      },
                    ),
                  ),
                  _PickerDivider(colorScheme),

                  // 절 목록
                  Expanded(
                    child: ListView.builder(
                      controller: _pickerVerseCtrl,
                      itemExtent: _itemH,
                      itemCount: verses.length,
                      itemBuilder: (_, i) {
                        final v = verses[i].verseNum;
                        final selected = v == _pickerVerse;
                        return _PickerItem(
                          label: '$v절',
                          selected: selected,
                          colorScheme: colorScheme,
                          onTap: () {
                            setState(() => _pickerVerse = v);
                            _confirmPicker();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 녹음 UI ───────────────────────────────────────────────

  Widget _buildRecordingSection(ColorScheme colorScheme) {
    if (_recordState == _RecordState.recorded) {
      return Row(
        children: [
          IconButton.filled(
            onPressed: _togglePlayback,
            icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
          ),
          const SizedBox(width: 8),
          Text(_formatDuration(_recordSeconds),
              style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          IconButton(
            onPressed: _deleteRecording,
            icon: const Icon(Icons.delete_outline),
            color: colorScheme.error,
          ),
        ],
      );
    }

    return Row(
      children: [
        IconButton.filled(
          onPressed: _toggleRecording,
          style: _recordState == _RecordState.recording
              ? IconButton.styleFrom(backgroundColor: colorScheme.error)
              : null,
          icon: Icon(
            _recordState == _RecordState.recording ? Icons.stop : Icons.mic,
          ),
        ),
        const SizedBox(width: 12),
        if (_recordState == _RecordState.recording) ...[
          Text(_formatDuration(_recordSeconds)),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),
        ] else
          Text('녹음 시작', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 구절 범위 행
// ──────────────────────────────────────────────────────────────

class _VerseRangeRow extends StatelessWidget {
  final VerseRange range;
  final VoidCallback onBookTap;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;
  final VoidCallback? onRemove;

  const _VerseRangeRow({
    required this.range,
    required this.onBookTap,
    required this.onStartTap,
    required this.onEndTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // 책 칩
          _RangeChip(
            label: range.bookKorean,
            colorScheme: colorScheme,
            onTap: onBookTap,
          ),
          const SizedBox(width: 6),
          // 시작 칩
          _RangeChip(
            label: '${range.startChapterNum}장 ${range.startVerseNum}절',
            colorScheme: colorScheme,
            onTap: onStartTap,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('~',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          // 끝 칩
          _RangeChip(
            label: '${range.endChapterNum}장 ${range.endVerseNum}절',
            colorScheme: colorScheme,
            onTap: onEndTap,
          ),
          const Spacer(),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 18),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              color: colorScheme.outline,
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 피커 내부 공통 위젯
// ──────────────────────────────────────────────────────────────

class _PickerItem extends StatelessWidget {
  final String label;
  final bool selected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _PickerItem({
    required this.label,
    required this.selected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          selected ? colorScheme.primaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? colorScheme.onPrimaryContainer : null,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerColumnLabel extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;

  const _PickerColumnLabel(this.label, this.colorScheme);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 0, 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

class _PickerDivider extends StatelessWidget {
  final ColorScheme colorScheme;
  const _PickerDivider(this.colorScheme);

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 1, child: ColoredBox(color: colorScheme.outlineVariant));
}

// ──────────────────────────────────────────────────────────────
// 공통 위젯
// ──────────────────────────────────────────────────────────────

class _RangeChip extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSecondaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down,
                  size: 16, color: colorScheme.onSecondaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 15, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: colorScheme.primary),
        ),
      ],
    );
  }
}

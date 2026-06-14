import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/stylesheet.dart';
import '../domain/entities/note.dart';
import '../viewmodels/note_viewmodel.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteViewModel>().loadNotes();
    });
  }

  List<_ListItem> _buildItems(List<Note> notes) {
    if (notes.isEmpty) return [];
    final result = <_ListItem>[];
    String? currentMonth;
    for (final note in notes) {
      final month = '${note.createdAt.year}년 ${note.createdAt.month}월';
      if (month != currentMonth) {
        result.add(_HeaderItem(month));
        currentMonth = month;
      }
      result.add(_NoteItem(note));
    }
    return result;
  }

  String _rangeLabel(Note note) {
    if (note.verseRanges.isEmpty) return '';
    final r = note.verseRanges.first;
    return '${r.bookKorean}: ${r.startChapterNum}:${r.startVerseNum}'
        ' ~ ${r.endChapterNum}:${r.endVerseNum}';
  }

  String _dateLabel(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteViewModel>(
      builder: (context, vm, _) {
        final items = _buildItems(vm.notes);

        return Scaffold(
          backgroundColor: Stylesheet.primary,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: Stylesheet.rangeTextFieldDecoration,
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: '검색',
                              suffixIcon: Icon(
                                Icons.search_rounded,
                                color: Stylesheet.secondaryLabel,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 11),
                              hintStyle:
                                  TextStyle(color: Stylesheet.secondaryLabel),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Row(
                        children: [
                          Text(
                            '시간순',
                            style: TextStyle(
                              color: Stylesheet.label,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.sort_rounded,
                              size: 16, color: Stylesheet.label),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text(
                            '저장된 말씀노트가 없습니다',
                            style: TextStyle(color: Stylesheet.secondaryLabel),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            if (item is _HeaderItem) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    top: 8, bottom: 12),
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Stylesheet.label,
                                  ),
                                ),
                              );
                            }
                            final note = (item as _NoteItem).note;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: Stylesheet.cardPadding,
                                decoration: Stylesheet.cardDecoration,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            note.title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Stylesheet.label,
                                            ),
                                          ),
                                          if (note.content != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              note.content!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color:
                                                    Stylesheet.secondaryLabel,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                _dateLabel(note.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Stylesheet.secondaryLabel,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                _rangeLabel(note),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Stylesheet.secondaryLabel,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Stylesheet.secondaryLabel,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

abstract class _ListItem {}

class _HeaderItem extends _ListItem {
  final String label;
  _HeaderItem(this.label);
}

class _NoteItem extends _ListItem {
  final Note note;
  _NoteItem(this.note);
}

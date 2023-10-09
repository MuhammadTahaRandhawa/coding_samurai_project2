import 'package:coding_samurai_project_2/note_model.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(path.join(dbPath, 'notes.db'),
      onCreate: (db, version) {
    return db.execute(
        'CREATE TABLE user_notes(id TEXT PRIMARY KEY , title TEXT , note TEXT , dateTime TEXT)');
  }, version: 1);
  return db;
}

class NoteNotifier extends StateNotifier<List<Note>> {
  NoteNotifier() : super([]);

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_notes');
    final notes = data.map((row) {
      return Note(
          note: row['note'] as String,
          dateTime: DateTime.parse(row['dateTime'] as String),
          title: row['title'] as String,
          id: row['id'] as String);
    }).toList();

    notes.sort((a, b) => b.dateTime.compareTo(a.dateTime),);
    state = notes;
    await db.close();
  }

  void addNote(Note note) async {
    final db = await _getDatabase();
    await db.insert('user_notes', {
      'id': note.id,
      'title': note.title,
      'note': note.note,
      'dateTime': note.dateTime.toString(),
    });
    await db.close();
    state = [note, ...state];
  }

  void updateNote({required Note oldNote, required Note updatedNote}) async {
    if (state.contains(oldNote)) {
      state.remove(oldNote);
    }
    deleteNote(oldNote);
    addNote(updatedNote);
  }

  void deleteNote(Note note) async {
    final db = await _getDatabase();

    await db.delete('user_notes', where: 'id = ?', whereArgs: [note.id]);
    db.close();
  }
}

final noteProvider =
    StateNotifierProvider<NoteNotifier, List<Note>>((ref) => NoteNotifier());

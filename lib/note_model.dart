import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Note {
  Note({this.title, required this.note, required this.dateTime , id})
      : id = id ?? uuid.v4();
  final String? id;
  final String? title;
  final String note;
  final DateTime dateTime;
}

List<Note> notesList = [];

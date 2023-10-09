import 'package:coding_samurai_project_2/note_model.dart';
import 'package:coding_samurai_project_2/notes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key, required this.note, this.modify = false});

  final Note note;
  final bool modify;
  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController.text = widget.note.title!;
    notesController.text = widget.note.note;
  }

  var titleController = TextEditingController();
  var notesController = TextEditingController();

  void onSaved() {
    if (FocusScope.of(context).hasPrimaryFocus) {
      FocusScope.of(context).unfocus();
    }
    if (notesController.text == '') {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Note can\'t be empty')));
      return;
    }
    if (widget.modify == true) {
      ref.read(noteProvider.notifier).updateNote(
          oldNote: widget.note,
          updatedNote: Note(
              note: notesController.text,
              dateTime: DateTime.now(),
              title: titleController.text));
      Navigator.pop(context);
    } else {
      ref.read(noteProvider.notifier).addNote(Note(
          note: notesController.text,
          dateTime: DateTime.now(),
          title: titleController.text));
      Navigator.of(context).pop();
    }
  }

  String getDateTime(DateTime dateTime) {
    return DateFormat('d MMMM h:mm a E').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: onSaved, icon: const Icon(Icons.check))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Title',
                  hintStyle:
                      TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  getDateTime(widget.note.dateTime),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              TextField(
                controller: notesController,
                style: const TextStyle(fontSize: 20),
                minLines: 40,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Write note here...',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:coding_samurai_project_2/add_note_screen.dart';
import 'package:coding_samurai_project_2/note_model.dart';
import 'package:coding_samurai_project_2/notes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
 late  Future<void> _futureNotes;
  @override
  void initState(){
    super.initState();
    _futureNotes = ref.read(noteProvider.notifier).loadPlaces();
  }


  List<Note> notes = [];

  void deleteNote(Note note) {
    var undo = false;
    var index = notes.indexOf(note);
    setState(() {
      notes.remove(note);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: const Text('Note was Deleted'),
      action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            undo = true;
            setState(() {
              ref.read(noteProvider).insert(index, note);
            });
          }),
    ));

    Timer(const Duration(seconds: 4), () {
      if(undo == false)
      {
        ref.read(noteProvider.notifier).deleteNote(note);
      }
    });

  }

  void addNote() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddNoteScreen(
          note: Note(note: '', dateTime: DateTime.now(), title: '')),
    ));
  }

  String dateFormat(DateTime dateTime) {
    var today = DateFormat.yMd().format(DateTime.now());
    var date = DateFormat.yMd().format(dateTime);
    if (today == date) {
      return DateFormat.jm().format(dateTime);
    } else {
      return DateFormat('d MMMM h:mm a E').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    notes = ref.watch(noteProvider);
    Widget body;
    if (notes.isEmpty) {
      body = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
                height: 300,
                image: AssetImage(
                    'lib/assets/cute-woman-writes-some-notes-in-notepad-young-student-girl-is-thoughtful-with-pencil-in-hand-on-yellow-background-flat-style-design-illustrations-vector-removebg-preview.png')),
            Text(
              'No Note',
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      );
    } else {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
        child: ListView.builder(
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Dismissible(
              direction: DismissDirection.endToStart,
              background: Container(
                padding: EdgeInsets.only(right: 15),
                alignment: Alignment.centerRight,
                color: Colors.red.shade500,
                child: Icon(Icons.delete),
              ),
              key: ValueKey(notes[index].id),
              onDismissed: (direction) {
                deleteNote(notes[index]);
              },
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                tileColor: Colors.lightGreenAccent.shade100.withOpacity(0.4),
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddNoteScreen(
                      note: notes[index],
                      modify: true,
                    ),
                  ));
                },
                title: Text(
                  notes[index].title ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      notes[index].note,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(dateFormat(notes[index].dateTime)),
                  ],
                ),
              ),
            ),
          ),
          itemCount: notes.length,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(fontSize: 30),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: addNote,
          child: const Icon(
            Icons.add,
            size: 40,
          )),
      body: FutureBuilder(builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting)
          {
            return const Center(child: CircularProgressIndicator(),);
          }
        else{
          return body;
        }
      },future: _futureNotes),
    );
  }
}

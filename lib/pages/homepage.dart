import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firebase_functions.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseServices firestoreServices = FirebaseServices();

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void openDialogToAddNote({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'New note',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (docID == null) {
                firestoreServices.addNotes(_controller.text);

                _controller.clear();

                Navigator.pop(context);
              } else {
                firestoreServices.updateNotes(docID, _controller.text);

                _controller.clear();

                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.add_box_sharp),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _notes = FirebaseFirestore.instance
        .collection('notes')
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text("NOTES"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notes,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                String documentID = document.id;

                String noteText = data["title"];

                return SizedBox(
                  height: 130,
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    child: Center(
                      child: ListTile(
                        title: Text(noteText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                openDialogToAddNote(docID: documentID);
                              },
                              icon: Icon(Icons.settings),
                            ),
                            IconButton(
                              onPressed: () {
                                firestoreServices.deleteNotes(documentID);
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text("Loading"));
          }

          return Center(child: Text("No data"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialogToAddNote();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

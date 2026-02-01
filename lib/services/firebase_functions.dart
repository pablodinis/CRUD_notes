import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  CollectionReference notes = FirebaseFirestore.instance.collection('notes');

  // ADD NOTES
  Future<void> addNotes(String titleNote) {
    return notes.add({'title': titleNote});
  }

  // READ NOTES
  Stream<QuerySnapshot> getNotes() {
    final notes = FirebaseFirestore.instance.collection('notes').snapshots();

    return notes;
  }

  // UPDATE NOTES
  Future<void> updateNotes(String documentID, String newName) {
    return notes.doc(documentID).update({'title': newName});
  }

  // DELETE NOTES
  Future<void> deleteNotes(String documentID) {
    return notes.doc(documentID).delete();
  }
}

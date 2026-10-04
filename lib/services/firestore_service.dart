import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('No hay ningún usuario autenticado.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _notes {
    return _firestore.collection('users').doc(_userId).collection('notes');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchNotes() {
    return _notes.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addNote(String title) async {
    final cleanTitle = title.trim();

    if (cleanTitle.isEmpty) {
      throw ArgumentError('El título no puede estar vacío.');
    }

    await _notes.add({
      'title': cleanTitle,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote(String noteId, String title) async {
    final cleanTitle = title.trim();

    if (cleanTitle.isEmpty) {
      throw ArgumentError('El título no puede estar vacío.');
    }

    await _notes.doc(noteId).update({
      'title': cleanTitle,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String noteId) async {
    await _notes.doc(noteId).delete();
  }
}

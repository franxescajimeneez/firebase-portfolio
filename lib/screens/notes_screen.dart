import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _showNoteDialog({
    String? noteId,
    String initialTitle = '',
  }) async {
    var draftTitle = initialTitle;

    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(noteId == null ? 'Nueva nota' : 'Editar nota'),
          content: TextFormField(
            initialValue: initialTitle,
            autofocus: true,
            onChanged: (value) => draftTitle = value,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, draftTitle),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (!mounted || title == null || title.trim().isEmpty) {
      return;
    }

    try {
      if (noteId == null) {
        await _firestoreService.addNote(title);
      } else {
        await _firestoreService.updateNote(noteId, title);
      }
    } catch (_) {
      _showError('No se pudo guardar la nota. Inténtalo de nuevo.');
    }
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      await _firestoreService.deleteNote(noteId);
    } catch (_) {
      _showError('No se pudo eliminar la nota. Inténtalo de nuevo.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Portfolio'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Sesión: ${user?.email ?? 'Usuario'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestoreService.watchNotes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notes = snapshot.data?.docs ?? [];

                if (notes.isEmpty) {
                  return const Center(
                    child: Text(
                      'Todavía no hay notas.\nCrea la primera.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final data = note.data();
                    final title = data['title'] as String? ?? 'Sin título';

                    return Card(
                      child: ListTile(
                        title: Text(title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              onPressed: () => _showNoteDialog(
                                noteId: note.id,
                                initialTitle: title,
                              ),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              onPressed: () => _deleteNote(note.id),
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva nota'),
      ),
    );
  }
}

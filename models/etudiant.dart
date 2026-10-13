// ============================================================================
// COUCHE MODÈLE (models)
// ----------------------------------------------------------------------------
// Classe Etudiant : spécialisation (HÉRITAGE) de Personne.
//
// ENCAPSULATION : la liste des notes (_notes) est privée. On n'y accède
// jamais directement depuis l'extérieur : on passe soit par le getter
// public en lecture seule `notes`, soit par la méthode `ajouterNote()`.
// ============================================================================

import '../extensions/extensions.dart';
import 'note.dart';
import 'personne.dart';

class Etudiant extends Personne {
  // Liste privée : aucune classe extérieure ne peut faire
  // `etudiant._notes.add(...)`, ce qui protège l'intégrité des données.
  final List<Note> _notes = <Note>[];

  Etudiant({required super.id, required super.nom, required super.age});

  /// Getter public en LECTURE SEULE : on retourne une copie non modifiable
  /// (`List.unmodifiable`) pour empêcher tout appelant externe de faire
  /// `etudiant.notes.add(...)` et de contourner l'encapsulation.
  List<Note> get notes => List.unmodifiable(_notes);

  /// Seul point d'entrée autorisé pour ajouter une note à cet étudiant.
  void ajouterNote(Note note) => _notes.add(note);

  /// Calcule la moyenne individuelle de l'étudiant.
  /// Retourne 0.0 si l'étudiant n'a encore aucune note (évite une division
  /// par zéro).
  double get moyenne {
    if (_notes.isEmpty) return 0.0;
    final double somme = _notes.fold(0.0, (acc, n) => acc + n.valeur);
    return somme / _notes.length;
  }

  @override
  String toString() =>
      "[$id] $nom ($age ans) — Moyenne : ${moyenne.formatee} (${moyenne.appreciation})";
}

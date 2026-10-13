// ============================================================================
// COUCHE MODÈLE (models)
// ----------------------------------------------------------------------------
// Classe Note : représente la note d'un étudiant dans une matière donnée.
//
// ENCAPSULATION : la valeur est stockée dans un champ privé `_valeur` et ne
// peut être définie qu'au moment de la construction, après validation
// (0.0 <= valeur <= 20.0). Impossible de créer une Note invalide : c'est le
// principe de "validation au constructeur" (fail-fast).
// ============================================================================

import '../extensions/extensions.dart';

class Note {
  final String matiere;
  final double _valeur;

  Note({required this.matiere, required double valeur}) : _valeur = _valider(valeur);

  /// Contrôle d'accès : vérifie que la note est bien comprise entre 0 et 20.
  /// Lève une ArgumentError si ce n'est pas le cas (constructeur "fail-fast").
  static double _valider(double valeur) {
    if (valeur < 0.0 || valeur > 20.0) {
      throw ArgumentError(
        "La note doit être comprise entre 0.0 et 20.0 (valeur reçue : $valeur).",
      );
    }
    return valeur;
  }

  /// Getter public en lecture seule : aucun setter n'est exposé, la note
  /// est immuable une fois créée.
  double get valeur => _valeur;

  @override
  String toString() => "$matiere : ${valeur.formatee} (${valeur.appreciation})";
}

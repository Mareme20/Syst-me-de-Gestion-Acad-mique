// ============================================================================
// EXTENSIONS (Dart Moderne)
// ----------------------------------------------------------------------------
// Regroupe les méthodes d'extension utilisées dans tout le projet.
// Une extension permet d'ajouter des membres (getters, méthodes) à un type
// existant (ici `double`) SANS le modifier ni créer de sous-classe.
// ============================================================================

extension UtilitairesNote on double {
  /// Formate une note/moyenne pour l'affichage : ex. 15.5 => "15.50/20".
  String get formatee => "${toStringAsFixed(2)}/20";

  /// PATTERN MATCHING (switch expression, Dart 3+) : attribue une
  /// appréciation littéraire selon la valeur numérique.
  ///
  /// Les gardes (`&&`) combinées à des opérateurs de relation dans les
  /// `case` sont une fonctionnalité des "pattern relationnels" de Dart 3.
  String get appreciation => switch (this) {
        >= 16 && <= 20 => "Excellent",
        >= 14 && < 16 => "Bien",
        >= 12 && < 14 => "Assez Bien",
        >= 10 && < 12 => "Passable",
        _ => "Insuffisant",
      };
}

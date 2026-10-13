// ============================================================================
// COUCHE MODÈLE (models)
// ----------------------------------------------------------------------------
// Classe ABSTRAITE Personne : socle commun à toute entité "personne" du
// système (ici seul Etudiant en hérite, mais on pourrait imaginer
// Professeur, Administrateur, etc. plus tard sans dupliquer ce code).
//
// Une classe abstraite ne peut pas être instanciée directement
// (`Personne(...)` est interdit) : elle sert uniquement de base à
// l'héritage (`extends`).
// ============================================================================

abstract class Personne {
  final String id; // identifiant unique, immuable
  String nom;
  int _age; // encapsulé : accessible uniquement via le getter/setter ci-dessous

  Personne({required this.id, required this.nom, required int age})
      : _age = _validerAge(age);

  /// L'âge doit être strictement positif (RG du modèle).
  static int _validerAge(int age) {
    if (age <= 0) {
      throw ArgumentError("L'âge doit être strictement positif (valeur reçue : $age).");
    }
    return age;
  }

  int get age => _age;

  /// Setter contrôlé : toute modification de l'âge repasse par la même
  /// validation que le constructeur.
  set age(int nouvelAge) => _age = _validerAge(nouvelAge);
}

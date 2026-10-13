// ============================================================================
// COUCHE REPOSITORY — INTERFACE (abstraction)
// ----------------------------------------------------------------------------
// Principe SOLID appliqué ici : le "D" de SOLID, DIP (Dependency Inversion
// Principle) : "Il faut dépendre d'abstractions, pas d'implémentations
// concrètes."
//
// `RepositoryEtudiant` est une classe ABSTRAITE qui définit le CONTRAT
// (les méthodes) que tout mécanisme de stockage doit respecter, sans dire
// COMMENT les données sont stockées.
//
// La couche Service ne dépendra QUE de cette interface, jamais d'une
// implémentation concrète (comme InMemoryRepository). Cela permet de
// remplacer le stockage en mémoire par une vraie base de données plus
// tard SANS modifier une seule ligne de la couche Service.
// ============================================================================

import '../models/etudiant.dart';

abstract class RepositoryEtudiant {
  /// Enregistre un nouvel étudiant.
  Future<void> ajouter(Etudiant etudiant);

  /// Retourne la liste de tous les étudiants enregistrés.
  Future<List<Etudiant>> lister();

  /// Recherche un étudiant par son identifiant. Retourne `null` si absent.
  Future<Etudiant?> trouverParId(String id);

  /// Supprime un étudiant par son identifiant.
  /// Retourne `true` si la suppression a eu lieu, `false` si l'étudiant
  /// n'existait pas.
  Future<bool> supprimer(String id);
}

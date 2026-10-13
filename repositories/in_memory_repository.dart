// ============================================================================
// COUCHE REPOSITORY — IMPLÉMENTATION CONCRÈTE
// ----------------------------------------------------------------------------
// `InMemoryRepository` est UNE implémentation possible du contrat défini par
// `RepositoryEtudiant` (`implements`). Elle stocke les étudiants dans une
// simple `List` en mémoire, mais respecte scrupuleusement l'interface : le
// reste de l'application ne sait même pas que c'est "juste une liste" —
// elle ne voit que le type `RepositoryEtudiant`.
//
// Chaque méthode simule une latence d'accès (Future.delayed) comme le
// ferait un vrai accès disque/réseau.
// ============================================================================

import '../models/etudiant.dart';
import 'repository_etudiant.dart';

class InMemoryRepository implements RepositoryEtudiant {
  final List<Etudiant> _etudiants = <Etudiant>[];

  @override
  Future<void> ajouter(Etudiant etudiant) async {
    await Future.delayed(const Duration(seconds: 1)); // latence simulée
    _etudiants.add(etudiant);
  }

  @override
  Future<List<Etudiant>> lister() async {
    await Future.delayed(const Duration(milliseconds: 500)); // latence simulée
    return List.unmodifiable(_etudiants);
  }

  @override
  Future<Etudiant?> trouverParId(String id) async {
    await Future.delayed(const Duration(milliseconds: 500)); // latence simulée
    for (final e in _etudiants) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<bool> supprimer(String id) async {
    await Future.delayed(const Duration(milliseconds: 500)); // latence simulée
    final int tailleAvant = _etudiants.length;
    _etudiants.removeWhere((e) => e.id == id);
    return _etudiants.length < tailleAvant;
  }
}

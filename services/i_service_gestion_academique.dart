// ============================================================================
// COUCHE SERVICE — INTERFACE (abstraction, DIP)
// ----------------------------------------------------------------------------
// Comme pour le Repository, on applique le DIP : la couche Présentation
// (UI) ne dépendra que de cette interface `IServiceGestionAcademique`,
// jamais de l'implémentation concrète `ServiceGestionAcademique`.
// ============================================================================

import '../models/etudiant.dart';

abstract class IServiceGestionAcademique {
  /// Flux (Broadcast Stream) diffusant un message de log à chaque fois
  /// qu'une note est ajoutée à un étudiant. "Broadcast" = plusieurs
  /// écouteurs (listeners) peuvent s'y abonner simultanément.
  Stream<String> get flotNotifications;

  Future<(bool success, String message)> ajouterEtudiant({
    required String nom,
    required int age,
  });

  Future<List<Etudiant>> listerEtudiants();

  Future<(bool success, String message)> ajouterNote({
    required String idEtudiant,
    required String matiere,
    required double valeur,
  });

  Future<Etudiant?> obtenirEtudiant(String id);

  Future<(bool success, String message)> supprimerEtudiant(String id);

  /// Calcul délégué à un Isolate séparé (ne bloque pas l'Event Loop).
  Future<Etudiant?> meilleurEtudiant();

  /// Calcul délégué à un Isolate séparé (ne bloque pas l'Event Loop).
  Future<double> moyenneGeneraleClasse();
}

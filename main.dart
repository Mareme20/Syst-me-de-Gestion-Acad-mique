// ============================================================================
// POINT D'ENTRÉE (main.dart)
// ----------------------------------------------------------------------------
// "Composition root" : le seul endroit de l'application où l'on choisit
// quelles implémentations CONCRÈTES utiliser derrière chaque abstraction.
//
//   RepositoryEtudiant (interface)  <—implémenté par—  InMemoryRepository
//   IServiceGestionAcademique (interface)  <—implémenté par—  ServiceGestionAcademique
//
// Chaque couche ne reçoit que des interfaces dans son constructeur : c'est
// la mise en pratique concrète du DIP (Dependency Inversion Principle).
//
// Lancer avec : dart run main.dart
// ============================================================================

import 'repositories/in_memory_repository.dart';
import 'repositories/repository_etudiant.dart';
import 'services/i_service_gestion_academique.dart';
import 'services/journal_service.dart';
import 'services/service_gestion_academique.dart';
import 'ui/menu_cli.dart';

Future<void> main() async {
  // 1. Repository : on choisit ICI l'implémentation en mémoire, mais
  //    n'importe quelle autre classe respectant `RepositoryEtudiant`
  //    pourrait la remplacer sans toucher au reste du code.
  final RepositoryEtudiant repository = InMemoryRepository();

  // 2. Service : reçoit l'interface `RepositoryEtudiant`, pas
  //    `InMemoryRepository` directement.
  final IServiceGestionAcademique service = ServiceGestionAcademique(repository: repository);

  // 3. Service de journalisation : s'abonne au flux broadcast du service —
  //    c'est le PREMIER écouteur (le second est celui de MenuCli, abonné
  //    dans son propre constructeur). Les deux tournent en parallèle.
  final journal = JournalService();
  journal.ecouter(service.flotNotifications);

  // 4. Présentation : reçoit l'interface `IServiceGestionAcademique`.
  final menu = MenuCli(service: service, journal: journal);

  // 5. Lancement de la boucle interactive.
  await menu.demarrer();
}

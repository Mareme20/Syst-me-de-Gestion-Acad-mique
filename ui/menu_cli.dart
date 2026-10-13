// ============================================================================
// COUCHE PRÉSENTATION (ui)
// ----------------------------------------------------------------------------
// Gère uniquement l'interaction console. Dépend de l'ABSTRACTION
// `IServiceGestionAcademique` (DIP), jamais de l'implémentation concrète
// `ServiceGestionAcademique` — on pourrait injecter un faux service pour
// tester cette classe indépendamment du reste.
// ============================================================================

import 'dart:io';

import '../services/i_service_gestion_academique.dart';
import '../services/journal_service.dart';

class MenuCli {
  final IServiceGestionAcademique _service;
  final JournalService _journal;

  MenuCli({required IServiceGestionAcademique service, required JournalService journal})
      : _service = service,
        _journal = journal {
    // Deuxième écouteur du Stream broadcast : affichage console en direct
    // dès qu'une note est ajoutée (le premier écouteur est celui de
    // `JournalService`, abonné séparément dans main.dart).
    _service.flotNotifications.listen((message) {
      print("\n🔔 [Notification] $message");
    });
  }

  Future<void> demarrer() async {
    bool continuer = true;

    while (continuer) {
      _afficherMenu();
      final String? choix = stdin.readLineSync();

      // switch expression moderne (Dart 3) pour aiguiller vers l'action.
      switch (choix) {
        case "1":
          await _gererAjoutEtudiant();
        case "2":
          await _gererAffichageEtudiants();
        case "3":
          await _gererAjoutNote();
        case "4":
          await _gererAffichageNotesAvecAppreciation();
        case "5":
          await _gererSuppressionEtudiant();
        case "6":
          await _gererMeilleurEtudiant();
        case "7":
          await _gererMoyenneGenerale();
        case "8":
          _journal.afficherJournal();
          print("👋 Fin de la session. À bientôt !");
          continuer = false;
        default:
          print("⚠️  Choix invalide, veuillez réessayer.");
      }
    }
  }

  void _afficherMenu() {
    print("");
    print("** Menu Gestion Académique **");
    print("1. Ajouter un étudiant");
    print("2. Afficher les étudiants");
    print("3. Ajouter une note à un étudiant");
    print("4. Afficher les notes d'un étudiant avec appréciation");
    print("5. Supprimer un étudiant");
    print("6. Afficher le meilleur étudiant de la classe");
    print("7. Afficher la moyenne générale de la classe");
    print("8. Quitter");
    stdout.write("Votre choix : ");
  }

  Future<void> _gererAjoutEtudiant() async {
    stdout.write("Nom de l'étudiant : ");
    final String nom = stdin.readLineSync() ?? "";

    stdout.write("Âge : ");
    final int age = int.tryParse(stdin.readLineSync() ?? "") ?? -1;

    print("⏳ Enregistrement en cours...");
    final (success, message) = await _service.ajouterEtudiant(nom: nom, age: age);
    print(message);
  }

  Future<void> _gererAffichageEtudiants() async {
    print("⏳ Chargement des étudiants...");
    final etudiants = await _service.listerEtudiants();

    if (etudiants.isEmpty) {
      print("ℹ️  Aucun étudiant enregistré pour le moment.");
      return;
    }

    print("\n--- Liste des étudiants ---");
    for (final e in etudiants) {
      print(e);
    }
  }

  Future<void> _gererAjoutNote() async {
    stdout.write("Identifiant de l'étudiant : ");
    final String id = stdin.readLineSync() ?? "";

    stdout.write("Matière : ");
    final String matiere = stdin.readLineSync() ?? "";

    stdout.write("Note (0 à 20) : ");
    final double valeur = double.tryParse(stdin.readLineSync() ?? "") ?? -1;

    print("⏳ Enregistrement de la note en cours...");
    final (success, message) = await _service.ajouterNote(
      idEtudiant: id,
      matiere: matiere,
      valeur: valeur,
    );
    print(message);
  }

  Future<void> _gererAffichageNotesAvecAppreciation() async {
    stdout.write("Identifiant de l'étudiant : ");
    final String id = stdin.readLineSync() ?? "";

    final etudiant = await _service.obtenirEtudiant(id);
    if (etudiant == null) {
      print("❌ Aucun étudiant trouvé avec l'identifiant $id.");
      return;
    }

    if (etudiant.notes.isEmpty) {
      print("ℹ️  ${etudiant.nom} n'a encore aucune note.");
      return;
    }

    print("\n--- Notes de ${etudiant.nom} ---");
    // `Note.toString()` inclut déjà l'appréciation (via l'extension).
    for (final note in etudiant.notes) {
      print(note);
    }
  }

  Future<void> _gererSuppressionEtudiant() async {
    stdout.write("Identifiant de l'étudiant à supprimer : ");
    final String id = stdin.readLineSync() ?? "";

    print("⏳ Suppression en cours...");
    final (success, message) = await _service.supprimerEtudiant(id);
    print(message);
  }

  Future<void> _gererMeilleurEtudiant() async {
    print("⏳ Calcul du meilleur étudiant (via Isolate)...");
    final meilleur = await _service.meilleurEtudiant();

    if (meilleur == null) {
      print("ℹ️  Aucun étudiant enregistré pour le moment.");
      return;
    }

    print("🏆 Meilleur étudiant de la classe : $meilleur");
  }

  Future<void> _gererMoyenneGenerale() async {
    print("⏳ Calcul de la moyenne générale (via Isolate)...");
    final moyenne = await _service.moyenneGeneraleClasse();
    print("📊 Moyenne générale de la classe : ${moyenne.toStringAsFixed(2)}/20");
  }
}

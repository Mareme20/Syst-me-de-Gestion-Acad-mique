// ============================================================================
// SERVICE DE JOURNALISATION (services)
// ----------------------------------------------------------------------------
// Démontre l'intérêt d'un Stream BROADCAST : ce service s'abonne au même
// flux `flotNotifications` que la couche console (voir ui/menu_cli.dart),
// de façon totalement indépendante. Les deux écouteurs reçoivent chaque
// événement, sans se gêner l'un l'autre.
// ============================================================================

class JournalService {
  final List<String> _entrees = <String>[];

  /// S'abonne au flux de notifications et archive chaque message avec un
  /// horodatage, sans jamais l'afficher directement à l'écran (ce n'est
  /// pas son rôle : il journalise, il n'affiche pas).
  void ecouter(Stream<String> flot) {
    flot.listen((message) {
      _entrees.add("${DateTime.now()} — $message");
    });
  }

  List<String> get entrees => List.unmodifiable(_entrees);

  void afficherJournal() {
    if (_entrees.isEmpty) {
      print("ℹ️  Journal vide, aucun événement enregistré pour le moment.");
      return;
    }
    print("\n--- 📔 Journal des événements ---");
    for (final entree in _entrees) {
      print(entree);
    }
  }
}

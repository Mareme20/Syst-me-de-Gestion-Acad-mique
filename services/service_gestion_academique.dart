// ============================================================================
// COUCHE SERVICE — IMPLÉMENTATION
// ----------------------------------------------------------------------------
// Contient toute la logique métier (cas d'utilisation) de l'application.
// Dépend UNIQUEMENT de l'abstraction `RepositoryEtudiant` (DIP), reçue par
// injection de dépendances dans le constructeur — jamais d'un
// `InMemoryRepository` concret.
//
// Deux mécanismes d'asynchronisme avancés y sont démontrés :
//   - Stream (broadcast) : notifie chaque ajout de note à plusieurs
//     écouteurs simultanés (console + journalisation).
//   - Isolate.run() : déporte les calculs coûteux (moyenne de classe,
//     recherche du meilleur étudiant) dans un isolate séparé pour ne
//     jamais bloquer l'Event Loop principal.
// ============================================================================

import 'dart:async';
import 'dart:isolate';

import '../models/etudiant.dart';
import '../models/note.dart';
import '../repositories/repository_etudiant.dart';
import 'i_service_gestion_academique.dart';

class ServiceGestionAcademique implements IServiceGestionAcademique {
  final RepositoryEtudiant _repository;

  // StreamController broadcast : autorise PLUSIEURS abonnements
  // simultanés (contrairement à un stream "single subscription" classique
  // qui n'accepte qu'un seul `listen()`).
  final StreamController<String> _controleurNotifications =
      StreamController<String>.broadcast();

  int _compteurId = 0; // sert à générer des identifiants uniques simples

  ServiceGestionAcademique({required RepositoryEtudiant repository}) : _repository = repository;

  @override
  Stream<String> get flotNotifications => _controleurNotifications.stream;

  /// Génère un identifiant unique simple (ex: "E1", "E2", ...).
  String _genererId() {
    _compteurId++;
    return "E$_compteurId";
  }

  @override
  Future<(bool, String)> ajouterEtudiant({required String nom, required int age}) async {
    if (nom.isEmpty) {
      return (false, "❌ Le nom de l'étudiant est obligatoire.");
    }

    try {
      // La validation de l'âge (> 0) est faite dans le constructeur de
      // `Personne` : si elle échoue, une ArgumentError est levée et
      // interceptée ci-dessous.
      final etudiant = Etudiant(id: _genererId(), nom: nom, age: age);
      await _repository.ajouter(etudiant);
      return (true, "✅ Étudiant ${etudiant.nom} ajouté avec l'identifiant ${etudiant.id}.");
    } on ArgumentError catch (e) {
      return (false, "❌ ${e.message}");
    }
  }

  @override
  Future<List<Etudiant>> listerEtudiants() => _repository.lister();

  @override
  Future<Etudiant?> obtenirEtudiant(String id) => _repository.trouverParId(id);

  @override
  Future<(bool, String)> ajouterNote({
    required String idEtudiant,
    required String matiere,
    required double valeur,
  }) async {
    final etudiant = await _repository.trouverParId(idEtudiant);
    if (etudiant == null) {
      return (false, "❌ Aucun étudiant trouvé avec l'identifiant $idEtudiant.");
    }

    if (matiere.isEmpty) {
      return (false, "❌ Le nom de la matière est obligatoire.");
    }

    try {
      // La validation (0.0 <= valeur <= 20.0) est faite dans le
      // constructeur de `Note`.
      final note = Note(matiere: matiere, valeur: valeur);

      // Simule la latence d'un enregistrement en base.
      await Future.delayed(const Duration(seconds: 1));
      etudiant.ajouterNote(note);

      // Diffusion de l'événement sur le flux broadcast : tous les
      // écouteurs abonnés (console, journalisation, ...) reçoivent le
      // message.
      _controleurNotifications.add(
        "📝 Nouvelle note ajoutée à ${etudiant.nom} (${etudiant.id}) : $note",
      );

      return (true, "✅ Note ajoutée avec succès à ${etudiant.nom}.");
    } on ArgumentError catch (e) {
      return (false, "❌ ${e.message}");
    }
  }

  @override
  Future<(bool, String)> supprimerEtudiant(String id) async {
    final supprime = await _repository.supprimer(id);
    if (!supprime) {
      return (false, "❌ Aucun étudiant trouvé avec l'identifiant $id.");
    }
    return (true, "✅ Étudiant $id supprimé avec succès.");
  }

  @override
  Future<Etudiant?> meilleurEtudiant() async {
    final etudiants = await _repository.lister();
    if (etudiants.isEmpty) return null;

    // On extrait des données 100% primitives (Records de String/double)
    // avant de les envoyer à l'Isolate : un Isolate tourne dans un espace
    // mémoire séparé, il ne peut recevoir que des données "transférables"
    // (primitifs, collections de primitifs, Records de primitifs...), pas
    // des instances arbitraires de nos classes métier.
    final donnees = etudiants.map((e) => (id: e.id, nom: e.nom, moyenne: e.moyenne)).toList();

    // Isolate.run() exécute la fonction dans un isolate séparé (donc sur
    // un autre thread) et attend le résultat sans bloquer l'Event Loop
    // principal de l'application — utile si le calcul devient volumineux
    // (ex: des milliers d'étudiants).
    final meilleur = await Isolate.run(() => _trouverMeilleur(donnees));

    if (meilleur == null) return null;
    return _repository.trouverParId(meilleur.id);
  }

  @override
  Future<double> moyenneGeneraleClasse() async {
    final etudiants = await _repository.lister();
    if (etudiants.isEmpty) return 0.0;

    final moyennes = etudiants.map((e) => e.moyenne).toList();

    // Le calcul de la moyenne générale est lui aussi déporté dans un
    // Isolate séparé.
    return Isolate.run(() => _calculerMoyenne(moyennes));
  }
}

// ----------------------------------------------------------------------------
// FONCTIONS EXÉCUTÉES DANS L'ISOLATE
// ----------------------------------------------------------------------------
// Ces fonctions ne manipulent QUE des types primitifs/Records : c'est une
// condition nécessaire pour qu'elles puissent tourner dans un Isolate
// séparé (pas d'accès à `_repository`, aucun état partagé avec le thread
// principal — chaque Isolate a sa propre mémoire isolée, d'où son nom).
// ----------------------------------------------------------------------------

/// Recherche l'étudiant ayant la meilleure moyenne parmi une liste de
/// Records (id, nom, moyenne).
({String id, String nom, double moyenne})? _trouverMeilleur(
  List<({String id, String nom, double moyenne})> donnees,
) {
  if (donnees.isEmpty) return null;
  var meilleur = donnees.first;
  for (final e in donnees.skip(1)) {
    if (e.moyenne > meilleur.moyenne) meilleur = e;
  }
  return meilleur;
}

/// Calcule la moyenne arithmétique d'une liste de moyennes individuelles.
double _calculerMoyenne(List<double> moyennes) {
  if (moyennes.isEmpty) return 0.0;
  final double somme = moyennes.reduce((a, b) => a + b);
  return somme / moyennes.length;
}

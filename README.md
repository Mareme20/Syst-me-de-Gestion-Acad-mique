# 📌 Séquence 2 : Système de Gestion Académique
### POO • SOLID • Dart Moderne • Asynchronisme avancé (Stream, Isolate)

## 🧱 Arborescence

``` 
gestion_academique/
├── main.dart                             → Composition root (injection de dépendances)
│
├── models/                               → COUCHE MODÈLE
│   ├── note.dart                            Note (validation 0–20 au constructeur)
│   ├── personne.dart                        Classe ABSTRAITE Personne (âge > 0)
│   └── etudiant.dart                        Etudiant extends Personne
│
├── repositories/                         → COUCHE ACCÈS DONNÉES
│   ├── repository_etudiant.dart             INTERFACE (abstraction, DIP)
│   └── in_memory_repository.dart            Implémentation en mémoire
│
├── services/                             → COUCHE MÉTIER
│   ├── i_service_gestion_academique.dart    INTERFACE (abstraction, DIP)
│   ├── service_gestion_academique.dart      Implémentation (Stream + Isolate)
│   └── journal_service.dart                 2ᵉ écouteur du Stream broadcast
│
├── extensions/
│   └── extensions.dart                      double.formatee / double.appreciation
│
└── ui/
    └── menu_cli.dart                        COUCHE PRÉSENTATION (menu 1 à 8)
```

## 🔑 Où sont les interfaces (abstractions) ?

Le sujet demande explicitement une interface de Repository, et le DIP pour
la couche service. Il y a donc **deux interfaces** dans ce projet :

| Interface (abstraction)              | Implémentation concrète         | Rôle                                    |
|---------------------------------------|----------------------------------|------------------------------------------|
| `RepositoryEtudiant`                  | `InMemoryRepository`             | Contrat d'accès aux données              |
| `IServiceGestionAcademique`           | `ServiceGestionAcademique`       | Contrat des cas d'utilisation métier     |

**Règle appliquée partout (DIP) :** une couche ne dépend JAMAIS d'une classe
concrète d'une autre couche, seulement de son interface.
- `ServiceGestionAcademique` reçoit un `RepositoryEtudiant` (pas un
  `InMemoryRepository`) dans son constructeur.
- `MenuCli` reçoit un `IServiceGestionAcademique` (pas un
  `ServiceGestionAcademique`) dans son constructeur.
- Le seul endroit où les classes concrètes sont choisies est `main.dart`
  (la "composition root").

Grâce à cela, on pourrait demain écrire `SqlRepository implements
RepositoryEtudiant` (une vraie base de données) et ne changer qu'UNE seule
ligne dans `main.dart` — aucune autre couche ne serait impactée.

## 🧬 POO : Encapsulation & Héritage

- **`Personne`** est une classe **abstraite** (`abstract class`) : on ne
  peut jamais faire `Personne(...)`, seulement `Etudiant(...)` qui en
  hérite via `extends` et appelle son constructeur via `super`.
- **Encapsulation** : `Note._valeur`, `Personne._age` et `Etudiant._notes`
  sont **privés** (préfixe `_`). Ils ne sont accessibles que via des
  getters publics contrôlés, avec validation systématique dans le
  constructeur (fail-fast : impossible de créer un objet invalide).

## 🆕 Dart Moderne

- **Records** : toutes les opérations métier (`ajouterEtudiant`,
  `ajouterNote`, `supprimerEtudiant`) retournent
  `(bool success, String message)`.
- **Pattern Matching / switch expression** : `double.appreciation` dans
  `extensions/extensions.dart` utilise des gardes relationnelles
  (`>= 16 && <= 20 => "Excellent"`, etc.).
- **Extension Methods** : `double.formatee` et `double.appreciation`.

## ⏱️ Asynchronisme avancé

- **Future/async/await** : chaque accès au repository simule une latence
  (`Future.delayed`).
- **Stream broadcast** : `ServiceGestionAcademique.flotNotifications` est
  un `StreamController.broadcast()`. Deux écouteurs indépendants s'y
  abonnent :
  1. `JournalService` (dans `main.dart`) → archive chaque événement avec
     horodatage.
  2. `MenuCli` (dans son constructeur) → affiche l'événement en direct
     dans la console.
- **Isolate (`Isolate.run()`)** : le calcul du **meilleur étudiant**
  (option 6) et de la **moyenne générale** (option 7) sont déportés dans
  un Isolate séparé, pour ne jamais bloquer l'Event Loop principal. Comme
  un Isolate a sa propre mémoire isolée, on ne lui transmet que des
  données 100 % primitives (Records de `String`/`double`), jamais nos
  instances `Etudiant` directement.

## ▶️ Exécution

```bash
dart run main.dart
```

## ✅ Menu (8 options, conforme au sujet)

```
** Menu Gestion Académique **
1. Ajouter un étudiant
2. Afficher les étudiants
3. Ajouter une note à un étudiant
4. Afficher les notes d'un étudiant avec appréciation
5. Supprimer un étudiant
6. Afficher le meilleur étudiant de la classe
7. Afficher la moyenne générale de la classe
8. Quitter
```

# StatusDesk — Documentation complète

## A. Présentation générale

StatusDesk est une application Flutter de monitoring de disponibilité de services HTTP. Elle sonde périodiquement huit endpoints publics, mesure leur temps de réponse, classe leur état, affiche une synthèse opérationnelle et conserve les derniers résultats afin de rester utile hors connexion.

La branche documentée est `service_test` du dépôt `Fenohasina08/statusdesk`.

Objectifs principaux :

- centraliser l’état de services externes dans une interface mobile claire ;
- mesurer le code HTTP et la latence de chaque endpoint ;
- détecter les indisponibilités et les réponses lentes ;
- rafraîchir automatiquement les données toutes les 15 secondes ;
- afficher les données en cache quand le réseau ou une API n’est pas disponible ;
- conserver un historique court des contrôles pour chaque service ;
- fournir une architecture séparant présentation, état, accès aux données et infrastructure.

## B. Technologies et dépendances

Le projet est une application Flutter/Dart. Les éléments visibles dans l’architecture sont notamment :

- Flutter Material pour l’interface ;
- `provider` et `ChangeNotifier` pour la gestion d’état actuelle ;
- `http` pour les requêtes réseau ;
- Hive pour la persistance locale ;
- Google Fonts, dont la police Abel dans le design system ;
- les plateformes Flutter standard Android, iOS, Web, Linux, macOS et Windows.

La configuration des dépendances et des scripts se trouve dans `pubspec.yaml`. Les règles d’analyse Dart sont dans `analysis_options.yaml`.

## C. Architecture et organisation des dossiers

Le code applicatif est sous `lib/` et suit une séparation inspirée de Clean Architecture :

```text
lib/
├── core/
├── main.dart
├── models/
├── pages/
├── providers/
├── repositories/
├── services/
└── utils/
```

### C.1 Core / configuration

`lib/core/` contient les briques transversales et de configuration. La configuration Hive est notamment portée par `core/storage/hive_config.dart`. Elle initialise la persistance locale avant le démarrage de l’interface.

### C.2 Models

`lib/models/` contient les objets métier échangés entre l’API, le repository, le provider et les écrans. Le modèle central est `Service`, accompagné de l’énumération `ServiceStatus`. Les modèles de résultat de ping, lorsqu’ils sont utilisés par la version concernée, représentent les mesures d’un contrôle individuel.

### C.3 Pages / présentation

`lib/pages/` contient les écrans Flutter et les composants visuels liés aux parcours utilisateur : accueil, dashboard, liste des services, détails d’un service et écrans d’incidents selon les fichiers présents dans la branche.

### C.4 Providers

`lib/providers/service_provider.dart` expose l’état observable de l’application via `ChangeNotifier`. Il possède la liste courante, les indicateurs de chargement, l’erreur éventuelle, la date de synchronisation, le timer de polling et l’historique par URL.

### C.5 Repositories

`lib/repositories/service_repository.dart` est la frontière entre le provider et les sources de données. Il demande les contrôles live à `ServiceApi`, valide que les huit services sont présents, sauvegarde les résultats dans le cache et tente de restituer un cache complet en cas d’échec.

### C.6 Services

`lib/services/` regroupe les adaptateurs d’infrastructure :

- `service_api.dart` : sondage HTTP des endpoints ;
- `cache_service.dart` : lecture et écriture du cache Hive ;
- autres services transversaux présents dans la branche.

### C.7 Utils

`lib/utils/` contient les exceptions et utilitaires partagés, notamment les exceptions API utilisées pour fournir un message explicite au provider.

## D. Démarrage de l’application

`lib/main.dart` effectue les opérations suivantes :

1. initialise le binding Flutter ;
2. initialise la configuration Hive ;
3. initialise `CacheService` ;
4. construit le `ServiceProvider` avec un `ServiceRepository` et un `ServiceApi` ;
5. lance `initialize()` afin de charger d’abord le cache puis les données live ;
6. démarre le polling périodique ;
7. monte l’application et son dashboard.

L’initialisation du cache avant la création des écrans est importante : elle évite de demander à l’interface de lire une boîte Hive qui ne serait pas encore ouverte.

## E. Les huit endpoints surveillés

La liste déclarée dans `ServiceApi.monitoredEndpoints` est :

| Nom | URL | Rôle |
|---|---|---|
| GitHub API | `https://api.github.com` | Endpoint de l’API GitHub |
| FreeOpenAPI | `https://freeopenapi.dev` | API publique de test |
| Cloudflare | `https://www.cloudflare.com` | Site/infrastructure Cloudflare |
| Test HTTP 200 | `https://httpbin.org/status/200` | Réponse nominale de référence |
| Test indisponible | `https://httpbin.org/status/503` | Simulation d’indisponibilité |
| FakeStore API | `https://fakestoreapi.com/products` | Catalogue e-commerce simulé |
| DummyJSON Products | `https://dummyjson.com/products` | Produits e-commerce simulés |
| Platzi Fake Store | `https://api.escuelajs.co/api/v1/products` | API e-commerce pédagogique |

Chaque endpoint est sondé indépendamment. Une erreur sur un endpoint ne doit pas empêcher la production d’un résultat pour les autres : le probe transforme les erreurs réseau et les timeouts en service marqué indisponible.

## F. Sondage HTTP et classification

`ServiceApi` utilise un client HTTP et ajoute un en-tête `User-Agent` `StatusDesk-monitor/1.0`. Chaque requête est chronométrée par un `Stopwatch` et soumise à un timeout par défaut de 30 secondes.

La classification suit ces règles :

### F.1 Opérationnel

Un service est `operational` lorsque :

- le code HTTP est compris entre 200 inclus et 300 exclu ;
- le temps de réponse est strictement inférieur à 800 ms.

### F.2 Dégradé

Un service est `degraded` lorsque :

- il renvoie un code 400 ou supérieur mais inférieur à 500 ; ou
- il répond avec un code 2xx mais atteint au moins 800 ms ; ou
- il tombe dans le cas de classification de repli.

### F.3 Indisponible

Un service est `down` lorsque :

- le code HTTP est supérieur ou égal à 500 ;
- une requête expire ;
- une `SocketException` survient ;
- une autre exception empêche d’obtenir une réponse valide.

Le endpoint HTTP 503 est donc volontairement classé `down`, tandis que HTTP 200 est nominal si sa latence reste sous 800 ms.

## G. Modèles de données

### G.1 Service

`Service` représente un résultat exploitable par l’interface. Il contient au minimum :

- `name` : nom lisible ;
- `url` : endpoint sondé ;
- `status` : valeur `ServiceStatus` ;
- `responseTime` : durée en millisecondes ;
- `lastChecked` : date et heure du dernier contrôle.

### G.2 ServiceStatus

`ServiceStatus` comporte les états :

- `operational` ;
- `degraded` ;
- `down`.

Les écrans utilisent cette valeur pour choisir le libellé, la couleur, l’icône et les compteurs.

### G.3 PingResult

Lorsque le modèle `PingResult` est présent dans la branche, il représente une mesure de ping isolée : résultat, latence, code ou métadonnées temporelles. Le repository/provider convertit ou agrège ces résultats en objets `Service` destinés à l’interface. `Service` reste le contrat d’affichage principal.

## H. Repository et validation de complétude

Le repository attend exactement l’ensemble logique des huit noms de services. Il ne se contente pas d’une liste non vide : il vérifie que tous les services configurés sont présents.

Après un sondage live réussi :

1. le repository récupère les huit résultats ;
2. il vérifie l’ensemble des noms attendus ;
3. il tente d’enregistrer les résultats dans Hive ;
4. il renvoie les résultats live au provider.

Si le cache échoue mais que le live est valide, le résultat live reste prioritaire. Si le live échoue, le repository essaie de charger un cache complet. Un cache partiel ne doit pas être traité comme une synchronisation complète.

## I. Polling et cycle de vie

L’intervalle de polling est :

```dart
Duration(seconds: 15)
```

`startPolling()` crée un `Timer.periodic`. Il ne crée pas de deuxième timer si un timer existe déjà. À chaque tick, il appelle `fetchServices()`.

`fetchServices()` empêche les appels concurrents grâce à `_isLoading`. Il met à jour les états dans cet ordre général :

1. ignore l’appel si un chargement est déjà en cours ;
2. active `_isLoading` ;
3. indique si le polling est actif ;
4. efface l’erreur précédente ;
5. notifie les listeners ;
6. demande les données au repository ;
7. remplace la liste courante ;
8. ajoute les résultats à l’historique ;
9. met à jour `lastSync` ;
10. capture les erreurs ;
11. désactive les indicateurs et notifie à nouveau.

Lors de la destruction du provider, `dispose()` annule le timer et libère les ressources liées au polling. La protection contre les appels concurrents évite que deux séries de sondages écrasent l’état l’une de l’autre.

## J. Persistance locale et fonctionnement offline

La persistance repose sur Hive et `CacheService`.

Au lancement, Hive est initialisé avant `CacheService.init()`. Le provider tente ensuite de charger les services mis en cache. Si des données existent :

- elles sont affichées immédiatement ;
- elles alimentent l’historique ;
- `lastSync` est dérivé du dernier contrôle cache ;
- une synchronisation live est ensuite demandée.

En cas d’échec réseau ou d’exception repository, l’application conserve les dernières données disponibles et expose le message :

> Mode hors connexion : dernières données conservées.

Le cache est un secours, pas un remplacement silencieux d’un résultat live valide. La validation des huit services évite d’afficher comme complet un cache incomplet.

## K. Gestion d’état

La gestion d’état actuelle est basée sur `provider` et `ChangeNotifier`.

Le provider expose notamment :

- `services` ;
- `isLoading` ;
- `isPolling` ;
- `error` ;
- `lastSync` ;
- `historyFor(url)`.

Les widgets observent le provider avec `context.watch<ServiceProvider>()` lorsqu’ils doivent se reconstruire et utilisent `context.read<ServiceProvider>()` pour déclencher une action ou lire sans abonnement.

### Transition vers Riverpod

La structure actuelle est suffisamment séparée pour permettre une transition vers Riverpod : le repository conserverait son rôle, `ServiceApi` et `CacheService` resteraient des dépendances injectables, et le `ChangeNotifier` serait remplacé par un `Notifier` ou `AsyncNotifier`. Cette transition n’est pas à confondre avec le fonctionnement actuel : sur la branche documentée, Provider/ChangeNotifier reste la source d’état active.

## L. Design system — Style Carré

Le design system est décrit comme un “Style Carré”, reconnaissable par :

- `borderRadius: 0.0` lorsque le composant suit strictement le style carré ;
- élévation `0.0` pour limiter les effets de carte flottante ;
- hiérarchie visuelle compacte et utilitaire ;
- emploi de GoogleFonts, notamment `GoogleFonts.abel` ;
- palette sombre basée notamment sur `#263238` ;
- contrastes forts entre fond, surface, texte et état ;
- couleurs sémantiques constantes pour opérationnel, dégradé et indisponible.

La palette d’état généralement utilisée est :

- vert `#28A745` : opérationnel ;
- orange `#FF9800` : dégradé ;
- rouge `#DC3545` : indisponible ;
- bleu `#2196F3` : action principale et navigation ;
- bleu-gris sombre `#263238` : base sombre du système ;
- gris clair proche de `#F7F8FA` ou `#F8F9FA` : fonds d’écran.

Les écrans affichent à la fois une couleur et un libellé afin que l’état ne dépende pas uniquement de la couleur.

## M. Pages et écrans

### M.1 Accueil

`lib/pages/Accueil.dart` est la synthèse principale. Il présente :

- le titre StatusDesk ;
- l’action de rafraîchissement ;
- une bannière globale d’état ;
- les compteurs opérationnels, dégradés et indisponibles ;
- une recherche par nom ;
- un filtre “problèmes seulement” ;
- la liste des services ;
- un état de chargement ;
- un état d’erreur avec bouton de nouvelle tentative ;
- la navigation vers le détail d’un service.

La page utilise `RefreshIndicator` pour permettre une actualisation par geste.

### M.2 Dashboard

`dashboard_screen.dart` orchestre la navigation entre les pages principales. Il expose notamment l’onglet Accueil et l’onglet Services, avec une barre de navigation basse.

### M.3 Services

`services_screen.dart` ou `Services.dart` présente la liste des services monitorés. Il reprend les indicateurs d’état et permet d’ouvrir le détail d’une ressource.

### M.4 Détail d’un service

`service_details_screen.dart` affiche :

- le nom du service ;
- l’icône et la couleur de l’état ;
- le temps de réponse ;
- la disponibilité affichée ;
- la date de dernière vérification ;
- l’URL endpoint ;
- une description adaptée à chaque endpoint ;
- l’historique des derniers contrôles ;
- un bouton de retour.

Le détail cherche la version la plus récente du service dans le provider par URL avant d’afficher les métriques.

### M.5 Incidents

`incidents_screen.dart`, lorsqu’il est présent dans la branche, regroupe les services dégradés ou indisponibles. Il sert de vue orientée incident et réutilise `ServiceStatus` pour filtrer et classer les problèmes.

### M.6 États transversaux

Les pages doivent prévoir les états suivants :

- chargement initial ;
- données live affichées ;
- données cache affichées ;
- erreur avec données conservées ;
- erreur sans données ;
- liste vide ;
- service indisponible mais résultat de contrôle disponible.

## N. Flux complet d’une synchronisation

```text
main()
  -> HiveConfig.init()
  -> CacheService.init()
  -> ServiceProvider.initialize()
       -> cache.getCachedServices()
       -> affichage immédiat éventuel
       -> repository.getServices()
            -> api.fetchServices()
                 -> probe des 8 URLs
            -> validation des 8 noms
            -> cache.saveServices()
       -> provider.services = résultats
       -> notifyListeners()
  -> startPolling()
       -> toutes les 15 secondes : fetchServices()
```

## O. Gestion des erreurs

Les exceptions réseau sont converties en résultat `down` au niveau du probe afin que les autres endpoints continuent d’être mesurés. Les erreurs applicatives remontent ensuite au repository puis au provider.

Le provider distingue les exceptions API connues, dont il peut exposer le message, et les erreurs génériques, pour lesquelles il utilise le message offline de secours.

L’interface ne doit jamais supposer que la liste est remplie. Elle doit examiner `isLoading`, `error` et `services` pour choisir le bon état visuel.

## P. Sécurité et limites

L’application interroge des endpoints publics et n’embarque pas de secret d’authentification pour le monitoring décrit. Les données locales sont des résultats de disponibilité et non des données sensibles de compte.

Limites fonctionnelles actuelles :

- un code HTTP valide ne garantit pas la validité métier du contenu ;
- la latence dépend de la plateforme, du réseau et de la région ;
- la disponibilité calculée est une observation ponctuelle ;
- un timeout de 30 secondes est nettement plus long que le seuil de dégradation à 800 ms ;
- les APIs publiques peuvent changer de comportement ou de disponibilité.

## Q. Historique

Le provider conserve au maximum 10 entrées par URL (`maxHistoryEntries = 10`). À chaque nouveau contrôle, l’entrée correspondant au même `lastChecked` est retirée avant insertion en tête. L’historique est donc ordonné du plus récent au plus ancien et limité en taille.

## R. Tests et qualité

Le projet contient un dossier `test/` et une configuration d’analyse Dart. Les tests importants à maintenir sont :

- classification HTTP 2xx rapide ;
- classification 2xx lente à partir de 800 ms ;
- classification 4xx ;
- classification 5xx ;
- timeout et SocketException ;
- présence obligatoire des huit services ;
- repli vers un cache complet ;
- rejet d’un cache incomplet ;
- absence de polling concurrent ;
- limitation de l’historique à 10 éléments.

## S. Guide de maintenance

Pour ajouter un endpoint :

1. l’ajouter à `monitoredEndpoints` ;
2. ajouter son nom à l’ensemble attendu du repository ;
3. ajouter sa description dans l’écran de détail ;
4. mettre à jour les tests ;
5. mettre à jour cette documentation ;
6. vérifier le cache et les compteurs.

Pour modifier le seuil de latence, changer la règle dans `_statusFor` et mettre à jour les tests, les libellés et la documentation. Pour modifier le polling, changer `pollingInterval` et vérifier le cycle de vie du timer.

## T. Dépannage

### Aucun service n’apparaît

Vérifier l’initialisation Hive, la présence des huit endpoints dans `ServiceApi`, la validation du repository et la valeur de `provider.error`.

### Le message offline apparaît constamment

Vérifier la connectivité, les certificats, les URLs, le timeout, les exceptions HTTP et le fait que la réponse contient bien les huit noms attendus.

### L’historique est vide

Vérifier que les résultats passent bien par `_recordHistory`, que le détail utilise la même URL et que `ServiceProvider` n’est pas recréé à chaque reconstruction de widget.

### Les résultats semblent trop lents

Comparer `responseTime` au seuil de 800 ms. Le classement est basé sur la durée mesurée côté client, pas sur un SLA fourni par le fournisseur externe.

## U. Glossaire

- API : interface de programmation appelée par l’application.
- Cache : copie locale de résultats précédemment obtenus.
- Hive : base locale clé-valeur utilisée pour la persistance.
- Polling : interrogation répétée à intervalle fixe.
- Probe : contrôle individuel d’un endpoint.
- Provider : couche d’état observable basée ici sur `ChangeNotifier`.
- Repository : couche qui coordonne API et cache.
- SLA : engagement de niveau de service ; StatusDesk mesure ici une observation et non un SLA contractuel.

## V. Conclusion

StatusDesk combine un monitoring HTTP simple, une classification explicite, une interface orientée incidents, un polling court et une résilience offline. La séparation `ServiceApi` / `ServiceRepository` / `ServiceProvider` / pages permet de faire évoluer indépendamment le réseau, le stockage, l’état et l’interface. La branche `service_test` constitue la référence fonctionnelle pour les huit endpoints, l’historique, le cache Hive et les vues de présentation décrites ici.

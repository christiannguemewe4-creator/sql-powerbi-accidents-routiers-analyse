# Analyse des accidents de la route en France (2024) — SQL

Analyse des accidents corporels de la circulation routière survenus en France en 2024, réalisée avec **MySQL**. Le projet part de six questions posées par un manager et y répond par des requêtes SQL commentées, avec une conclusion chiffrée et une recommandation pour chaque question.

## Données

Source : base annuelle des accidents corporels de la circulation routière, publiée sur [data.gouv.fr](https://www.data.gouv.fr) (fichiers 2024).

| Table | Contenu | Lignes |
|---|---|---|
| `caract` | Caractéristiques de l'accident : date, heure, lumière, météo, agglomération, département | 54 402 |
| `lieux` | Lieu de l'accident : catégorie de route, vitesse maximale autorisée | 70 248 |
| `vehicules` | Véhicules impliqués : catégorie de véhicule | 92 677 |
| `usagers` | Personnes impliquées : catégorie, gravité, sexe, année de naissance | 125 187 |

Les tables sont reliées par `num_acc` (identifiant de l'accident) et `id_vehicule` (lien entre un usager et son véhicule).

**Indicateur principal** : le taux de mortalité, c'est-à-dire la part des usagers impliqués qui sont tués (`tués / usagers impliqués`).

## Outils

- MySQL 8 et MySQL Workbench
- Techniques SQL : `LOAD DATA`, `CASE WHEN`, jointures (`JOIN ... USING`), `GROUP BY` / `HAVING`, CTE (`WITH`), fonctions de date (`HOUR`, `WEEKDAY`, `STR_TO_DATE`), nettoyage de texte (`TRIM`, `REPLACE`, `CAST`)

## Démarche

1. **Import** des 4 fichiers CSV (séparateur `;`) dans des tables brutes avec `LOAD DATA LOCAL INFILE`.
2. **Nettoyage** : conversion des codes en libellés lisibles (lumière, météo, routes, véhicules…), reconstitution de la date et de l'heure, conversion des coordonnées GPS (virgule décimale), calcul de l'âge, gestion des valeurs manquantes (`-1` → `NULL`).
3. **Contrôle de cohérence** : à chaque analyse, la somme des tués est vérifiée par rapport au total réel (3 432).
4. **Analyse** des six questions du manager.

### Un problème de données détecté et corrigé

En croisant les zones et les types de route, le total des tués atteignait **3 952 au lieu de 3 432**. La cause : la table `lieux` contient **plusieurs lignes pour 15 645 accidents** (accidents aux carrefours), ce qui dupliquait les usagers lors de la jointure.

J'ai créé une table `lieux_unique` avec **une seule ligne par accident**, en gardant la route la plus importante du carrefour (`MIN` du code de route) et la vitesse maximale autorisée la plus élevée (`MAX`). Le total est revenu à 3 432.

Le même piège a été évité pour les véhicules, en joignant `usagers` et `vehicules` sur `id_vehicule` plutôt que sur `num_acc`.

## Résultats

### Q1 — Quand ont lieu les accidents les plus meurtriers ?

- Le pic d'accidents est à **17h** (4 607), mais leur taux de mortalité reste bas en journée (1,93 % à 2,75 %).
- **La nuit est la plus meurtrière** : à 5h, le taux (6,35 %) est **3 fois plus élevé** qu'à 13h (1,93 %).
- Croisement jour × heure : la nuit est **aussi meurtrière en semaine (4,57 %) que le week-end (4,47 %)**. Le week-end est plus meurtrier parce qu'il compte **2 fois plus d'accidents de nuit** en proportion (23,8 % contre 10,8 %).

### Q2 — Les conditions rendent-elles les accidents plus graves ?

- La **nuit sans éclairage public** est **2,6 fois plus meurtrière** que le plein jour (6,15 % contre 2,37 %).
- Le **brouillard** est la condition météo la plus dangereuse (6,51 %, soit 2,4 fois la météo normale).
- Surprise : la pluie légère (2,23 %) est moins meurtrière que la météo normale (2,73 %), sans doute parce que les conducteurs ralentissent.
- **76,6 % des tués meurent par temps normal** : la météo n'est pas la cause principale.

### Q3 — Où les accidents sont-ils les plus graves ?

- Hors agglomération : **38 % des accidents, mais 68 % des tués** ; un usager impliqué y a **3,2 fois plus** de risque de mourir qu'en ville.
- Les **routes départementales hors agglomération** concentrent **46,4 % des tués** pour 19 % des accidents.
- L'autoroute est **3,7 fois moins meurtrière** que la départementale, malgré les 130 km/h.
- Les routes limitées à **80 km/h** sont les plus meurtrières (7,14 %, et 34,7 % des tués) : le risque dépend du type de route plus que de la vitesse autorisée.

### Q4 — Qui sont les victimes ?

- Les **piétons** ont **2 fois plus de risque** d'être tués que les conducteurs (5,30 % contre 2,67 %).
- Les **hommes** représentent 77,6 % des tués, avec un risque **1,6 fois plus élevé** que les femmes.
- Les **65 ans et plus** ont **3 fois plus de risque** de mourir que les 25-44 ans (6,61 % contre 2,17 %) et représentent 27,6 % des tués.

### Q5 — Quels véhicules sont les plus dangereux pour leurs usagers ?

- Les **deux-roues motorisés** : 4,11 % de taux de mortalité, soit **1,8 fois plus** qu'en voiture ; 16,9 % des usagers mais 27,4 % des tués.
- Le **vélo** est presque aussi meurtrier (3,95 %) : comme le motard, le cycliste n'a aucune carrosserie pour le protéger.
- En nombre, la voiture reste la première cause de décès (55,8 % des tués).

### Q6 — Quels départements sont les plus touchés ?

- En **nombre de tués**, les départements très peuplés sont en tête : Bouches-du-Rhône (115), Gironde (83), Nord et Seine-et-Marne (71).
- En **taux de mortalité**, ce sont les départements **ruraux** : en Vendée, le risque de mourir est **3,15 fois plus élevé** que dans les Bouches-du-Rhône.
- Le **Gard** est le seul département présent dans les deux classements.

## Recommandations

1. **Priorité aux routes départementales hors agglomération**, en particulier celles limitées à 80 km/h : contrôles de vitesse, aménagement des virages et des carrefours.
2. **Renforcer la sécurité de nuit** : éclairage des routes non éclairées et contrôles nocturnes, renforcés le week-end.
3. **Protéger les usagers vulnérables** : piétons (surtout âgés), deux-roues motorisés et cyclistes.
4. **Agir en priorité dans le Gard**, puis répartir l'effort entre départements peuplés (volume de victimes) et départements ruraux (gravité).

## Limites

- Une seule année de données (2024) : pas d'analyse de tendance.
- Sans données de population ni de trafic, on ne peut pas calculer un risque par habitant ou par kilomètre parcouru.
- Certains groupes sont trop petits pour conclure (vent fort, parcs de stationnement…) ; ils sont signalés dans les fichiers.
- Valeurs manquantes : 2 579 usagers sans âge, 2 395 sans sexe et 972 accidents sans vitesse autorisée, sans tué parmi les usagers concernés pour l'âge et le sexe.

## Fichiers

| Fichier | Contenu |
|---|---|
| `01_import_donnees.sql` | Import des fichiers CSV |
| `02_nettoyage.sql` | Nettoyage, création des tables propres et de `lieux_unique` |
| `03_q1_quand.sql` | Q1 : mois, jours, heures, croisement jour × heure |
| `04_q2_conditions.sql` | Q2 : lumière et météo |
| `05_q3_ou.sql` | Q3 : agglomération, type de route, vitesse autorisée |
| `06_q4_qui.sql` | Q4 : catégorie d'usager, sexe, âge |
| `07_q5_vehicules.sql` | Q5 : type de véhicule |
| `08_q6_departements.sql` | Q6 : départements |

Chaque fichier contient les requêtes et la conclusion de l'analyse en commentaires.
## Tableau de bord Power BI

Prolongement de l'analyse SQL : les mêmes données (accidents corporels 2024, data.gouv.fr) sont présentées dans un tableau de bord Power BI de 3 pages, pensé pour un responsable de la sécurité routière.

📄 [Voir le tableau de bord en PDF](dashboard_accidents_2024.pdf) · 📊 [Fichier Power BI (.pbix)](   (accident%20bi.pbix)

> **Deux indicateurs de gravité** : les pages 1 et 2 utilisent le nombre de **tués pour 100 accidents** (moyenne : 6,31), adapté pour comparer des lieux et des conditions. La page 3 utilise les **tués pour 100 usagers impliqués** (moyenne : 2,74), le même indicateur que l'analyse SQL, adapté pour comparer des profils de victimes.

### Page 1 — Quand ?

![Page 1](page1_quand.png)

- **54 402 accidents**, **22 558 victimes graves** et **3 432 tués** en 2024.
- **Saisonnalité** : de février à juillet, les accidents augmentent de 37,4 % et les victimes graves de 55,3 %. L'été cumule plus d'accidents et des accidents plus graves.
- **Semaine** : pics à 8h et à 17h–18h, liés aux trajets domicile-travail.
- **Week-end** : vers 1h du matin, environ deux fois plus d'accidents qu'en semaine.

### Page 2 — Où et dans quelles conditions ?

![Page 2](page2_conditions.png)

- **Météo** : 16,1 tués pour 100 accidents par brouillard (2,5× la moyenne) et 15,4 par vent fort.
- **Routes** : 11,39 hors agglomération contre 3,26 en agglomération (3,5×), et 15,16 sur les départementales hors agglomération.
- **Départements** : les plus mortels sont ruraux (Dordogne 21,71, Jura 21,21, Haute-Marne 19,44).

### Page 3 — Qui sont les victimes ?

![Page 3](page3_victimes.png)

- **Âge** : 6,61 tués pour 100 usagers chez les 65 ans et plus, contre 2,17 chez les 25-44 ans.
- **Véhicule (hors piétons)** : 4,11 en deux-roues motorisé et 3,95 à vélo, contre 2,26 en voiture. Les poids lourds et les transports en commun sont peu meurtriers pour leurs occupants : leur danger concerne surtout les piétons qu'ils percutent.
- **Rôle** : 5,30 pour les piétons, contre 2,67 pour les conducteurs.
- Ces usagers vulnérables sont plus nombreux en été, ce qui explique que les victimes graves augmentent plus vite que les accidents.

### Démarche technique

- **Import** : 4 tables exportées en CSV depuis MySQL (`caract`, `lieux_unique`, `usagers`, `vehicules`), en reprenant la table `lieux` dédoublonnée lors de l'analyse SQL.
- **Modèle** : relations par `num_acc` et `id_vehicule`, mesures DAX regroupées dans une table `_Mesures`.
- **Mesures DAX** : nombre d'accidents, de tués, de victimes graves et d'usagers, taux de mortalité par accident et par usager (`DIVIDE`), taux hors piétons (`CALCULATE`).
- **Colonnes calculées** : jour, heure, mois (avec colonnes de tri), tranches d'âge (`SWITCH(TRUE())`) identiques à celles de l'analyse SQL.
- **Carte** : table de correspondance des départements créée pour corriger le géocodage automatique (un département français était placé en Suisse).
- **Contrôle qualité** : tous les chiffres du tableau de bord ont été recoupés avec les résultats SQL. Ce recoupement a permis de corriger une mesure erronée et d'aligner le graphique des véhicules sur la définition SQL (piétons exclus, car ils sont rattachés au véhicule qui les a percutés).

### Outils

MySQL Workbench · Power BI Desktop · DAX

## Auteur

**Christian Nguemewe**, Junior Data Analyst
[LinkedIn](https://www.linkedin.com/in/christian-nguemewe) · [GitHub](https://github.com/christiannguemewe4-creator)

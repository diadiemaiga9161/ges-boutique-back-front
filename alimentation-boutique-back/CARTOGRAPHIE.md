# CARTOGRAPHIE — alimentation-boutique-back (Spring Boot)

## Infos générales
- **Framework** : Spring Boot 3.2.0
- **Java** : 17
- **Build** : Maven
- **Artefact** : `com.ges:boutique:1.0.0`
- **Port** : 8080
- **BDD** : MySQL 8 — base `alimentation` (localhost:3306)
- **Auth** : JWT (JJWT 0.11.5) — expiration 24h / refresh 7j
- **Swagger** : http://localhost:8080/swagger-ui.html
- **API docs** : http://localhost:8080/api-docs

---

## Structure des dossiers

```
alimentation-boutique-back/
├── boutique/                        ← Projet Spring Boot principal
│   ├── pom.xml
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/ges/boutique/
│   │   │   │   ├── BoutiqueApplication.java     ← Point d'entrée
│   │   │   │   ├── DataInitializer.java          ← Init données au démarrage
│   │   │   │   ├── HomeController.java           ← Route racine (SPA fallback)
│   │   │   │   │
│   │   │   │   ├── avance/           ← Avances clients
│   │   │   │   ├── boutique/         ← Paramètres boutique
│   │   │   │   ├── caisse/           ← Gestion caisse & opérations
│   │   │   │   ├── client/           ← CRUD clients
│   │   │   │   ├── compte/           ← Comptes bancaires & opérations
│   │   │   │   ├── config/           ← Configuration Spring (Security, CORS, JWT...)
│   │   │   │   ├── dette/            ← Dettes anciennes & règlements
│   │   │   │   ├── exception/        ← Handlers d'exceptions globaux
│   │   │   │   ├── facture/          ← Factures & lignes facture
│   │   │   │   ├── fournisseur/      ← Fournisseurs, achats, paiements, retours
│   │   │   │   ├── inventaire/       ← Inventaire & mouvements de stock
│   │   │   │   ├── produit/          ← Produits, catégories, import Excel
│   │   │   │   ├── rapport/          ← Rapports journalier/hebdo/mensuel
│   │   │   │   ├── securite/         ← JWT (JwtUtil, JwtFilter, AuthController)
│   │   │   │   ├── utilisateur/      ← Utilisateurs & rôles
│   │   │   │   └── vente/            ← Ventes, lignes vente, retours, crédits
│   │   │   │
│   │   │   └── resources/
│   │   │       └── application.properties
│   │   └── test/
│   └── target/                       ← Build (ignoré)
│
├── logs/                             ← Logs applicatifs
└── CARTOGRAPHIE.md                   ← Ce fichier
```

---

## Modules métier (packages)

| Package | Entité principale | Controller | Service | Repository |
|---|---|---|---|---|
| `avance` | `AvanceClient` | `AvanceClientController` | `AvanceClientService/Impl` | `AvanceClientRepository` |
| `boutique` | `Boutique` | `BoutiqueController` | `BoutiqueService` | `BoutiqueRepository` |
| `caisse` | `Caisse`, `OperationCaisse`, `TransfertCaisseBanque` | `CaisseController` | `CaisseService/Impl` | `CaisseRepository`, `OperationCaisseRepository` |
| `client` | `Client` | `ClientController` | `ClientService/Impl` | `ClientRepository` |
| `compte` | `Compte`, `OperationCompte` | `CompteController` | `CompteService/Impl` | `CompteRepository`, `OperationCompteRepository` |
| `dette` | `DetteAncienne`, `ReglementDetteAncienne` | `DetteAncienneController` | `DetteAncienneService/Impl` | `DetteAncienneRepository`, `ReglementDetteAncienneRepository` |
| `facture` | `Facture`, `LigneFacture` | `FactureController` | `FactureService/Impl` | `FactureRepository`, `LigneFactureRepository` |
| `fournisseur` | `Fournisseur`, `AchatFournisseur`, `PaiementFournisseur`, `RetourAchat`, `AvanceFournisseur` | `FournisseurAchatController`, `AvanceFournisseurController`, `RetourAchatController` | `AvanceFournisseurService/Impl`, `FournisseurComptableService`, `RetourAchatServiceImpl` | `FournisseurRepository`, `AchatFournisseurRepository`, `PaiementFournisseurRepository`, `RetourAchatRepository` |
| `inventaire` | `Inventaire`, `MouvementStock` | `InventaireController` | `InventaireService/Impl` | `InventaireRepository`, `MouvementStockRepository` |
| `produit` | `Produit`, `Categorie` | `ProduitController` | `ProduitService/Impl`, `CategorieService/Impl`, `ExcelImportService` | `ProduitRepository`, `CategorieRepository` |
| `rapport` | `RapportJournalier`, `RapportHebdomadaire`, `RapportMensuel`, `Statistiques` | `RapportController` | `RapportService/Impl` | — |
| `securite` | — | `AuthController` | `JwtUtil`, `JwtFilter` | — |
| `utilisateur` | `Utilisateur` (+ `RoleUtilisateur`) | `UtilisateurController` | `UtilisateurService/Impl` | `UtilisateurRepository` |
| `vente` | `Vente`, `LigneVente`, `RetourVente` | `VenteController`, `RetourVenteController` | `VenteService/Impl`, `RetourVenteServiceImpl` | `VenteRepository`, `LigneVenteRepository`, `RetourVenteRepository` |
| `employe` | `Employe`, `PaiementEmploye` | `EmployeController`, `PaiementEmployeController` | `EmployeService/Impl`, `PaiementEmployeService/Impl` | `EmployeRepository`, `PaiementEmployeRepository` |

---

## Configuration (`config/`)

| Fichier | Rôle |
|---|---|
| `SecurityConfig.java` | Spring Security + CORS + filtre JWT |
| `JacksonConfig.java` | Sérialisation JSON (ObjectMapper) |
| `AppConfig.java` | Beans généraux |
| `PasswordConfig.java` | Bean BCryptPasswordEncoder |
| `WebConfig.java` | Configuration MVC / ressources statiques |
| `MultipartConfig.java` / `MultipartFilter.java` | Upload fichiers (max 10 MB) |

---

## Exceptions (`exception/`)

| Classe | Usage |
|---|---|
| `GlobalExceptionHandler` | Handler `@ControllerAdvice` centralisé |
| `RessourceIntrouvableException` | 404 — entité introuvable |
| `SoldeInsuffisantException` | Solde caisse/compte insuffisant |
| `StockInsuffisantException` | Stock produit insuffisant |
| `ValidationException` | Erreurs de validation métier |

---

## Énumérations clés

| Enum | Valeurs / Package |
|---|---|
| `RoleUtilisateur` | utilisateur/ |
| `ModePaiement` | vente/ |
| `ModePaiementCaisse` | caisse/ |
| `TypeOperationCaisse` | caisse/ |
| `OperationCaisse` | caisse/ |
| `TypeMouvement` | inventaire/ |
| `StatutAchat` | fournisseur/ |
| `StatutAvance` | avance/ |
| `RemiseType` | vente/ |
| `TypeOperationCompte` | compte/ |

---

## Dépendances principales (pom.xml)

- `spring-boot-starter-web`
- `spring-boot-starter-data-jpa`
- `spring-boot-starter-security`
- `spring-boot-starter-validation`
- `spring-boot-starter-cache`
- `mysql-connector-j` 8.0.33
- `jjwt-api/impl/jackson` 0.11.5
- `springdoc-openapi-starter-webmvc-ui` 2.2.0
- `lombok`
- `poi` (Apache POI — import Excel)

---

## Points clés à retenir

- Le dossier racine `alimentation-boutique-back/` contient aussi un **projet Angular résiduel** (fichiers `angular.json`, `package.json`, `src/`) — ce n'est PAS le back Spring Boot, c'est probablement un ancien front copié là par erreur.
- Le vrai back Spring Boot est dans le sous-dossier `boutique/`.
- L'API tourne sur `http://localhost:8080`.
- La base MySQL s'appelle `alimentation`, créée automatiquement si absente.
- `ddl-auto=update` : Hibernate met à jour le schéma automatiquement.

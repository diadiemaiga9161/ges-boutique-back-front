# 📁 Index des Fichiers à Modifier

## 🔧 Fichiers à Créer

### 🔴 PHASE 1 - CRITIQUE

**Pas de fichiers à créer pour les correctifs critiques**
(Modifications seulement dans les fichiers existants)

### 🟡 PHASE 2 - IMPORTANT

#### 1. Exceptions Métier
```
📄 src/main/java/com/ges/boutique/exception/
├─ CaisseAlreadyExistsException.java (CRÉER)
├─ UsernameAlreadyExistsException.java (CRÉER)
└─ EmailAlreadyExistsException.java (CRÉER)
```

#### 2. Énumérations
```
📄 src/main/java/com/ges/boutique/caisse/
└─ FactureStatut.java (CRÉER)
```

### 🟢 PHASE 3 - QUALITÉ

#### 3. Utilitaires
```
📄 src/main/java/com/ges/boutique/util/
├─ MoneyUtils.java (CRÉER)
└─ ValidationUtils.java (CRÉER)
```

#### 4. Audit (optionnel mais recommandé)
```
📄 src/main/java/com/ges/boutique/audit/
├─ AuditLog.java (CRÉER - entité)
├─ AuditLogRepository.java (CRÉER - repository)
├─ AuditService.java (CRÉER - service)
└─ AuditAspect.java (CRÉER - aspect AOP)
```

---

## ✏️ Fichiers à Modifier

### 🔴 PHASE 1 - CRITIQUE

#### 1. pom.xml
```
ACTION: Mettre à jour les versions des dépendances
├─ mysql.version: 8.0.33 → 8.2.0
├─ poi: 5.2.3 → 5.4.0
└─ poi-ooxml: 5.2.3 → 5.4.0

Estimation: 5 min
```

#### 2. src/main/resources/application.properties
```
ACTION: Externaliser la clé JWT
├─ jwt.secret: "SecretSuperSecure..." → ${JWT_SECRET:}
└─ Ajouter commentaire sur l'utilisation des variables d'env

Estimation: 5 min
```

#### 3. src/main/java/com/ges/boutique/securite/JwtUtil.java
```
ACTIONS:
├─ Supprimer System.out.println (lignes 31-34)
├─ Remplacer par log.debug("JWT initialized successfully")
├─ Améliorer la gestion des erreurs
└─ Ajouter documentation

Estimation: 10 min
```

### 🟡 PHASE 2 - IMPORTANT

#### 4. src/main/java/com/ges/boutique/caisse/CaisseServiceImpl.java
```
ACTIONS:
├─ Ligne 51: RuntimeException → CaisseAlreadyExistsException
├─ Ligne 125: RuntimeException → Custom exception
├─ Lignes 1303-1332: String statuts → FactureStatut enum
└─ Arrondir() où nécessaire vers BigDecimal (futur)

Estimation: 20 min
```

#### 5. src/main/java/com/ges/boutique/utilisateur/UtilisateurServiceImpl.java
```
ACTIONS:
├─ Ligne 24: RuntimeException → UsernameAlreadyExistsException  
├─ Ligne 27: RuntimeException → EmailAlreadyExistsException
├─ Ligne 45: RuntimeException → EmailAlreadyExistsException
└─ Ajouter logging additionnel

Estimation: 15 min
```

#### 6. src/main/java/com/ges/boutique/vente/VenteServiceImpl.java
```
ACTIONS:
├─ Ligne 76: RuntimeException → VenteException (custom)
└─ Ajouter validations supplémentaires

Estimation: 10 min
```

#### 7. src/main/java/com/ges/boutique/securite/AuthController.java
```
ACTIONS:
├─ Ligne 49: Ajouter vérification getAuthorities().isEmpty()
├─ Ajouter handling d'exception approprié
└─ Améliorer logging

Estimation: 15 min
```

#### 8. src/main/java/com/ges/boutique/securite/JwtFilter.java
```
ACTIONS:
├─ Supprimer lignes 34-39 (CORS headers)
├─ Garder seulement la gestion du JWT
└─ Ajouter commentaire: "CORS is configured in SecurityConfig"

Estimation: 10 min
```

### 🟢 PHASE 3 - QUALITÉ

#### 9. src/main/java/com/ges/boutique/config/SecurityConfig.java
```
ACTION: Vérifier et étendre la configuration CORS si nécessaire
└─ Externaliser les origines autorisées

Estimation: 10 min
```

#### 10. Tous les fichiers Service (* ServiceImpl.java)
```
ACTIONS:
├─ Ajouter @Transactional(readOnly=true) sur les GET
├─ Améliorer la gestion des exceptions
└─ Ajouter pagination aux méthodes list()

Estimation: 2-3 jours (progressif)

Fichiers affectés:
├─ CaisseServiceImpl.java
├─ VenteServiceImpl.java  
├─ ClientServiceImpl.java
├─ UtilisateurServiceImpl.java
├─ InventaireServiceImpl.java
└─ RapportServiceImpl.java
```

---

## 📋 Tableau de Synthèse des Modifications

```
┌──────────────────────────────────────────────────────────────┐
│                    SOMMAIRE DES MODIFICATIONS                │
└──────────────────────────────────────────────────────────────┘

FICHIERS À CRÉER (7 fichiers)
├─ Phase 2:
│  ├─ CaisseAlreadyExistsException.java      (30 lignes)
│  ├─ UsernameAlreadyExistsException.java    (30 lignes)
│  ├─ EmailAlreadyExistsException.java       (30 lignes)
│  └─ FactureStatut.java                     (20 lignes)
└─ Phase 3:
   ├─ MoneyUtils.java                     (50 lignes)
   └─ ValidationUtils.java (optionnel)   (30 lignes)

FICHIERS À MODIFIER (10 fichiers majeurs)
├─ Phase 1:
│  ├─ pom.xml                           (3 lignes)
│  ├─ application.properties             (1 ligne)
│  └─ JwtUtil.java                      (4 lignes)
├─ Phase 2:
│  ├─ CaisseServiceImpl.java             (5 lignes + imports)
│  ├─ UtilisateurServiceImpl.java        (3 lignes + imports)
│  ├─ VenteServiceImpl.java              (1 ligne + imports)
│  ├─ AuthController.java               (10 lignes)
│  └─ JwtFilter.java                    (6 lignes)
└─ Phase 3:
   └─ 6 x *ServiceImpl.java             (20-50 lignes chacun)

TOTAL: 
├─ Lignes à créer: ~200 lignes
├─ Lignes à modifier: ~100 lignes
└─ Imports à ajouter: ~15 imports
```

---

## 🎯 Ordre de Modification Recommandé

### Jour 1 - Matin (Phase 1)
1. ✏️ Modifier `pom.xml` - MySQL Connector + Apache POI
2. ✏️ Modifier `application.properties` - Externaliser JWT secret
3. ✏️ Modifier `JwtUtil.java` - Supprimer logs sensibles
4. 🧪 Tester: `mvn clean compile`

### Jour 1 - Après-midi (Phase 2 Part 1)
5. 📄 Créer `CaisseAlreadyExistsException.java`
6. 📄 Créer `UsernameAlreadyExistsException.java`
7. 📄 Créer `EmailAlreadyExistsException.java`
8. ✏️ Modifier `CaisseServiceImpl.java`
9. ✏️ Modifier `UtilisateurServiceImpl.java`

### Jour 2 - Matin (Phase 2 Part 2)
10. ✏️ Modifier `VenteServiceImpl.java`
11. ✏️ Modifier `AuthController.java`
12. ✏️ Modifier `JwtFilter.java`
13. 🧪 Tests complets

### Jour 2 - Après-midi (Phase 2 Part 3)
14. 📄 Créer `FactureStatut.java`
15. ✏️ Modifier `CaisseServiceImpl.java` - Utiliser enum
16. 🧪 Tests complets

### Jour 3+ (Phase 3 - Progressive)
17. 📄 Créer `MoneyUtils.java`
18. ✏️ Migrer services vers BigDecimal (progressif)
19. ✏️ Ajouter pagination
20. 📄 Créer système d'audit (optionnel)

---

## 🚀 Commandes de Deployment

### Après Phase 1 (Critique)
```bash
cd boutique
mvn clean compile
mvn test
mvn package
```

### Après Phase 2 (Important)
```bash
mvn clean package
# Vérifier tous les tests passent
java -jar target/boutique-1.0.0.jar
```

### Après Phase 3 (Quality)
```bash
# Déploiement en staging
mvn clean package -DskipTests
# Exécuter les tests de performance
```

---

## ⚠️ Points d'Attention

- [ ] Garder une copie de sauvegarde avant modifications
- [ ] Tester après chaque phase
- [ ] Vérifier la compilation à chaque étape
- [ ] Valider les changements avec l'équipe
- [ ] Mettre à jour la documentation
- [ ] Mettre les variables d'environnement en place avant déploiement

---

## 📞 Contacts & Ressources

### Pour Questions Spécifiques:
- **Maven/Dependencies:** Vérifier `mvn dependency:tree`
- **Security:** OWASP Top 10, Spring Security Docs
- **Best Practices:** Spring Framework Documentation

### Fichiers de Référence:
- Spring Security: https://spring.io/projects/spring-security
- JWT: https://jwt.io/
- Maven Guide: https://maven.apache.org/

---

**Document généré:** 2 mai 2026  
**Validité:** Jusqu'à fin de Phase 3 (environ 3 semaines)  
**Responsable:** GitHub Copilot


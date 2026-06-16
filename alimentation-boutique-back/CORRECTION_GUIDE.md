# 🔧 Guide de Correction des Problèmes Critiques

## 1. Vulnérabilités des Dépendances

### 🔴 Mise à jour de pom.xml

**Fichier:** `pom.xml`

```xml
<!-- AVANT (Version vulnérable) -->
<dependency>
    <groupId>com.mysql</groupId>
    <artifactId>mysql-connector-j</artifactId>
    <version>${mysql.version}</version>
    <scope>runtime</scope>
</dependency>

<!-- APRÈS (Version sécurisée) -->
<dependency>
    <groupId>com.mysql</groupId>
    <artifactId>mysql-connector-j</artifactId>
    <version>8.2.0</version>
    <scope>runtime</scope>
</dependency>
```

Dans les propriétés:
```xml
<!-- AVANT -->
<mysql.version>8.0.33</mysql.version>

<!-- APRÈS -->
<mysql.version>8.2.0</mysql.version>
```

Pour Apache POI:
```xml
<!-- AVANT (5.2.3) -->
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi</artifactId>
    <version>5.2.3</version>
</dependency>
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi-ooxml</artifactId>
    <version>5.2.3</version>
</dependency>

<!-- APRÈS (5.4.0) -->
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi</artifactId>
    <version>5.4.0</version>
</dependency>
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi-ooxml</artifactId>
    <version>5.4.0</version>
</dependency>
```

---

## 2. JWT Secret Exposé

### 🔴 Correction dans JwtUtil.java

**AVANT (Exposé):**
```java
@Value("${jwt.secret:SecretSuperSecurePourSignatureJWTPourApplicationBoutique2024}")
private String secret;

@PostConstruct
public void init() {
    System.out.println("========== JWT INITIALIZATION ==========");
    System.out.println("Secret: " + secret);  // ⚠️ DANGER!
    System.out.println("Expiration: " + expiration + " ms");
    System.out.println("========================================");
    
    byte[] keyBytes = secret.getBytes();
    // ...
}
```

**APRÈS (Sécurisé):**
```java
@Value("${jwt.secret}")
private String secret;

@Value("${jwt.expiration:86400000}")
private long expiration;

private Key signingKey;

@PostConstruct
public void init() {
    // Ne pas exposer le secret en logs!
    log.debug("JWT initialized successfully"); // Avant était System.out.println
    
    byte[] keyBytes = secret.getBytes();
    if (keyBytes.length < 32) {
        byte[] padded = new byte[32];
        System.arraycopy(keyBytes, 0, padded, 0, Math.min(keyBytes.length, 32));
        this.signingKey = Keys.hmacShaKeyFor(padded);
    } else {
        this.signingKey = Keys.hmacShaKeyFor(keyBytes);
    }
}
```

### 🔴 Modification dans application.properties

**AVANT:**
```properties
jwt.secret=SecretSuperSecurePourSignatureJWTPourApplicationBoutique2024
jwt.expiration=86400000
```

**APRÈS - En Développement:**
```properties
# Utiliser un secret suffisamment long (minimum 32 caractères pour HS256)
jwt.secret=${JWT_SECRET:}
jwt.expiration=86400000
```

**EN PRODUCTION - Utiliser une variable d'environnement:**
```bash
export JWT_SECRET="VotreSecretTrèsLongEtComplexeDe32CaractèresOuPlus"
```

---

## 3. Centraliser la Configuration CORS

### 🟡 Nettoyage de JwtFilter.java

**AVANT (JwtFilter.java - Problématique):**
```java
@Override
protected void doFilterInternal(
        @NonNull HttpServletRequest request,
        @NonNull HttpServletResponse response,
        @NonNull FilterChain filterChain
) throws ServletException, IOException {

    // Ajouter les headers CORS - DUPLIQUÉ!
    response.setHeader("Access-Control-Allow-Origin", "http://localhost:4200");
    response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Max-Age", "3600");
    response.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type, X-Requested-With");
    response.setHeader("Access-Control-Expose-Headers", "Authorization");
    response.setHeader("Access-Control-Allow-Credentials", "true");
    
    // ... reste du code
}
```

**APRÈS (JwtFilter.java - Nettoyé):**
```java
@Override
protected void doFilterInternal(
        @NonNull HttpServletRequest request,
        @NonNull HttpServletResponse response,
        @NonNull FilterChain filterChain
) throws ServletException, IOException {

    // Les headers CORS sont gérés par SecurityConfig
    // Ne pas les répéter ici!
    
    // Gérer les requêtes OPTIONS (preflight)
    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_OK);
        return;
    }

    final String authHeader = request.getHeader("Authorization");
    final String jwt;
    final String username;

    if (authHeader == null || !authHeader.startsWith("Bearer ")) {
        filterChain.doFilter(request, response);
        return;
    }

    jwt = authHeader.substring(7);
    username = jwtUtil.extractUsername(jwt);

    if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
        UserDetails userDetails = this.userDetailsService.loadUserByUsername(username);

        if (jwtUtil.validateToken(jwt, userDetails)) {
            UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                    userDetails,
                    null,
                    userDetails.getAuthorities()
            );
            authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
            SecurityContextHolder.getContext().setAuthentication(authToken);
        }
    }
    filterChain.doFilter(request, response);
}
```

---

## 4. Créer des Exceptions Métier

### 🟡 Créer de nouvelles classes d'exception

**Fichier à créer:** `src/main/java/com/ges/boutique/exception/CaisseAlreadyExistsException.java`
```java
package com.ges.boutique.exception;

public class CaisseAlreadyExistsException extends RuntimeException {
    public CaisseAlreadyExistsException(String message) {
        super(message);
    }

    public CaisseAlreadyExistsException(String message, Throwable cause) {
        super(message, cause);
    }
}
```

**Fichier à créer:** `src/main/java/com/ges/boutique/exception/UsernameAlreadyExistsException.java`
```java
package com.ges.boutique.exception;

public class UsernameAlreadyExistsException extends RuntimeException {
    public UsernameAlreadyExistsException(String message) {
        super(message);
    }

    public UsernameAlreadyExistsException(String message, Throwable cause) {
        super(message, cause);
    }
}
```

**Fichier à créer:** `src/main/java/com/ges/boutique/exception/EmailAlreadyExistsException.java`
```java
package com.ges.boutique.exception;

public class EmailAlreadyExistsException extends RuntimeException {
    public EmailAlreadyExistsException(String message) {
        super(message);
    }

    public EmailAlreadyExistsException(String message, Throwable cause) {
        super(message, cause);
    }
}
```

### Utilisation dans CaisseServiceImpl.java

**AVANT:**
```java
if (caisseRepository.existsByNumeroCaisse(numeroCaisse)) {
    throw new RuntimeException("Une caisse avec ce numéro existe déjà: " + numeroCaisse);
}
```

**APRÈS:**
```java
if (caisseRepository.existsByNumeroCaisse(numeroCaisse)) {
    throw new CaisseAlreadyExistsException("Une caisse avec ce numéro existe déjà: " + numeroCaisse);
}
```

### Utilisation dans UtilisateurServiceImpl.java

**AVANT:**
```java
if (utilisateurRepository.existsByUsername(utilisateur.getUsername())) {
    throw new RuntimeException("Le nom d'utilisateur existe déjà");
}
if (utilisateurRepository.existsByEmail(utilisateur.getEmail())) {
    throw new RuntimeException("L'email existe déjà");
}
```

**APRÈS:**
```java
if (utilisateurRepository.existsByUsername(utilisateur.getUsername())) {
    throw new UsernameAlreadyExistsException("Le nom d'utilisateur existe déjà: " + utilisateur.getUsername());
}
if (utilisateurRepository.existsByEmail(utilisateur.getEmail())) {
    throw new EmailAlreadyExistsException("L'email existe déjà: " + utilisateur.getEmail());
}
```

---

## 5. Correction du Null Pointer Exception

### 🟡 AuthController.java

**AVANT:**
```java
String token = jwtUtil.generateTokenWithId(
        userDetails.getUsername(),
        userDetails.getAuthorities().iterator().next().getAuthority(),  // ⚠️ Peut lever NoSuchElementException
        utilisateur.getId()
);
```

**APRÈS:**
```java
// Vérifier que l'utilisateur a au moins un rôle
if (userDetails.getAuthorities().isEmpty()) {
    log.error("Utilisateur {} n'a pas de rôle associé", userDetails.getUsername());
    throw new IllegalStateException("Utilisateur sans rôle assigné");
}

String role = userDetails.getAuthorities()
        .stream()
        .findFirst()
        .map(GrantedAuthority::getAuthority)
        .orElseThrow(() -> new IllegalStateException("Aucun rôle trouvé pour l'utilisateur"));

String token = jwtUtil.generateTokenWithId(
        userDetails.getUsername(),
        role,
        utilisateur.getId()
);
```

---

## 6. Créer une Enum pour les Statuts de Facture

### 🟡 Créer FactureStatut.java

**Fichier à créer:** `src/main/java/com/ges/boutique/caisse/FactureStatut.java`
```java
package com.ges.boutique.caisse;

public enum FactureStatut {
    BROUILLON("Brouillon"),
    VALIDE("Validée"),
    ANNULE("Annulée");

    private final String label;

    FactureStatut(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
```

### Utilisation dans CaisseServiceImpl.java

**AVANT:**
```java
if (!"BROUILLON".equals(facture.getStatut())) {
    throw new IllegalStateException("La facture n'est pas en brouillon");
}
facture.setStatut("VALIDE");

if ("ANNULE".equals(facture.getStatut())) {
    throw new IllegalStateException("La facture est déjà annulée");
}
facture.setStatut("ANNULE");
```

**APRÈS:**
```java
if (!FactureStatut.BROUILLON.name().equals(facture.getStatut())) {
    throw new IllegalStateException("La facture n'est pas en brouillon");
}
facture.setStatut(FactureStatut.VALIDE.name());

if (FactureStatut.ANNULE.name().equals(facture.getStatut())) {
    throw new IllegalStateException("La facture est déjà annulée");
}
facture.setStatut(FactureStatut.ANNULE.name());
```

---

## 7. Utiliser BigDecimal pour les Montants

### 🟡 Migration de Double vers BigDecimal

Cette modification est plus complexe et devrait être faite graduellement:

**Stratégie:**
1. Créer des méthodes utilitaires pour la conversion
2. Modifier les entités JPA
3. Mettre à jour les services
4. Tester les calculs

**Exemple de classe utilitaire:**
```java
public class MoneyUtils {
    private static final int SCALE = 2;
    private static final RoundingMode ROUNDING_MODE = RoundingMode.HALF_UP;

    public static BigDecimal round(BigDecimal value) {
        if (value == null) {
            return BigDecimal.ZERO;
        }
        return value.setScale(SCALE, ROUNDING_MODE);
    }

    public static BigDecimal round(Double value) {
        if (value == null) {
            return BigDecimal.ZERO;
        }
        return BigDecimal.valueOf(value).setScale(SCALE, ROUNDING_MODE);
    }

    public static Double toDouble(BigDecimal value) {
        return value == null ? 0.0 : value.doubleValue();
    }
}
```

---

## 📋 Commandes de Déploiement des Mises à Jour

```bash
# 1. Mettre à jour les dépendances
mvn clean compile

# 2. Exécuter les tests (si existants)
mvn test

# 3. Build l'application
mvn clean package

# 4. Avec les variables d'environnement de sécurité
export JWT_SECRET="VotreSecretDe32CaractèresOuPlus"
export DATABASE_PASSWORD="VotreMotDePasse"

# 5. Lancer l'application
java -jar boutique-1.0.0.jar
```

---

## 🎯 Priorité des Corrections

| # | Correction | Impact | Temps Estimé | Priorité |
|---|-----------|--------|--------------|----------|
| 1 | Mettre à jour MySQL Connector | HIGH | 5 min | 🔴 IMMÉDIAT |
| 2 | Mettre à jour Apache POI | MEDIUM | 5 min | 🔴 IMMÉDIAT |
| 3 | Externaliser JWT Secret | CRITICAL | 15 min | 🔴 IMMÉDIAT |
| 4 | Supprimer System.out.println | MEDIUM | 5 min | 🔴 IMMÉDIAT |
| 5 | Centraliser CORS | LOW | 10 min | 🟡 COURT TERME |
| 6 | Créer exceptions métier | MEDIUM | 20 min | 🟡 COURT TERME |
| 7 | Fixer Null Pointer | MEDIUM | 10 min | 🟡 COURT TERME |
| 8 | Créer Enum Statuts | LOW | 15 min | 🟡 COURT TERME |
| 9 | Migrer vers BigDecimal | HIGH | 2-3 jours | 🟢 MOYEN TERME |

---

**Total Temps Estimé pour Phase 1:** ~45 minutes  
**Total Temps Estimé pour Phase 2:** ~1 heure  
**Total Temps Estimé pour Phase 3+:** ~2-3 jours


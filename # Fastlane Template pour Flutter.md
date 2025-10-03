# Fastlane Template pour Flutter

Ce template est basé sur la configuration Fastlane du projet POD Mobile et fournit une structure complète pour automatiser le déploiement d'applications Flutter.

## 🚀 Fonctionnalités

- **Déploiement multi-environnement** : Support pour int, qa, uat, mco, ppr, prod
- **Multi-plateforme** : iOS, Android, ou les deux
- **Intégration Firebase App Distribution** : Distribution automatique aux testeurs
- **Gestion des certificats iOS** : Vérification automatique de l'expiration + support Match
- **Profils de provisioning** : Vérification et téléchargement automatique via Match ou manuel
- **Système de logs complet** : Récapitulatif détaillé de chaque déploiement
- **Gestion des versions Flutter** : Support FVM pour choisir la version Flutter
- **Génération automatique de changelog** : Basé sur les commits Git

## 📋 Prérequis

### Outils requis
- **Fastlane** : `gem install fastlane`
- **Flutter** : Installation avec FVM recommandée
- **Firebase CLI** : `npm install -g firebase-tools`

### Comptes et accès
- Compte Firebase avec App Distribution activé
- Compte Apple Developer (pour iOS)

## 🛠️ Installation

### 1. Copie des fichiers template
```bash
# Copier le Fastfile principal
cp Fastfile.template fastlane/Fastfile

# Copier les fichiers de configuration
cp Appfile.template fastlane/Appfile
cp Pluginfile.template fastlane/Pluginfile

# Copier les templates d'environnement
cp env.template .env.int
cp env.template .env.qa
cp env.template .env.prod
# ... pour chaque environnement

# Copier et configurer le fichier secret
cp secret.template .env.secret
```

### 2. Installation des plugins
```bash
cd fastlane
bundle install
fastlane install_plugins
```

### 3. Configuration des environnements

#### Fichier `.env.secret` (SENSIBLE - à ne jamais commiter)
```bash
# Firebase
FIREBASE_CLI_TOKEN=your_firebase_cli_token


# Apple (optionnel)
APPLE_ID=your.email@example.com
APPLE_PASSWORD=your_app_specific_password
```

#### Fichiers par environnement (`.env.int`, `.env.prod`, etc.)
```bash
# Flutter
FLAVOR=int
FLUTTER_TARGET=lib/main.dart
SCHEME=Debug-int

# Firebase
FIREBASE_APP=1:123456789:android:abcdef
FIREBASE_APP_IOS=1:123456789:ios:abcdef
TESTER_GROUPS=developers,qa-team

# iOS
EXPORT_OPTIONS=ios/export_options_int.plist

```

### 4. Configuration du projet

#### Android (`android/app/build.gradle`)
Assurez-vous d'avoir des flavors configurés :
```gradle
flavorDimensions "default"
productFlavors {
    int {
        dimension "default"
        applicationIdSuffix ".int"
    }
    prod {
        dimension "default"
    }
}
```

#### iOS (Xcode)
- Créer des schemes pour chaque environnement
- Configurer les ExportOptions.plist pour chaque environnement
- Configurer les profils de provisioning

#### Match (Optionnel - Gestion automatique des certificats)
- Créer un repository Git privé pour stocker les certificats
- Configurer les variables `MATCH_*` dans vos fichiers d'environnement
- Première utilisation : `fastlane setup_certificates`

## 🎯 Utilisation

### Commandes principales

#### Déploiement complet
```bash
# Déployer sur l'environnement int pour Android seulement
fastlane deployment env:int target:android

# Déployer sur prod pour iOS et Android
fastlane deployment env:prod target:both

# Déployer avec une version Flutter spécifique
fastlane deployment env:qa target:ios fvm:3.24.7

# Déployer en utilisant match pour la gestion des certificats
fastlane deployment env:prod target:ios use_match:true
```

#### Autres commandes utiles
```bash
# Lancer seulement les tests
fastlane test

# Vérifier les certificats et profils
fastlane check_all

# Nettoyer et reconstruire les dépendances
fastlane clean

# Configurer les certificats avec match (première utilisation)
fastlane setup_certificates type:appstore

# Configurer tous les types de certificats
fastlane setup_all_certificates

# Synchroniser les certificats (pour CI/CD)
fastlane sync_certificates type:enterprise

# Vérifier certificats ET configurer avec match
fastlane check_all use_match:true

```

### Paramètres disponibles

#### `deployment`
- **env** (requis) : Environnement cible (int, qa, uat, mco, ppr, prod)
- **target** (optionnel) : Plateforme (ios, android, both) - défaut: both
- **fvm** (optionnel) : Version Flutter FVM - défaut: 3.24.5

## 📁 Structure des fichiers

```
fastlane/
├── Fastfile                    # Configuration principale et lanes
├── Appfile                     # Identifiants de l'app
├── Pluginfile                  # Plugins requis
└── actions/                    # Modules fonctionnels
    ├── recap_system.rb         # Système de logs et récapitulatifs
    ├── deployment.rb           # Fonctions de déploiement et build
    ├── certificate_management.rb # Gestion des certificats (Match + traditionnel)
    └── utility_functions.rb    # Fonctions utilitaires (versions, changelog)

.env.secret                     # Variables sensibles (à ne pas commiter)
.env.int                        # Configuration environnement int
.env.qa                         # Configuration environnement qa
.env.prod                       # Configuration environnement prod
```

## 🏗️ Architecture modulaire

Le template est organisé en modules fonctionnels pour faciliter la maintenance :

### **recap_system.rb**
- Système de logs avec timestamps
- Catégories : SUCCESS, WARNING, ERROR, INFO
- Récapitulatif complet en fin de déploiement

### **deployment.rb**
- Validation des environnements et plateformes
- Fonctions de build Android et iOS
- Distribution Firebase App Distribution
- Gestion des pods CocoaPods

### **certificate_management.rb**
- **Match** : Gestion automatique des certificats
- **Traditionnel** : Vérification de l'expiration
- Support provisioning profiles
- Compatibilité enterprise/app-store

### **utility_functions.rb**
- Gestion des versions et changelog Git
- Calcul automatique des build numbers
- Support FVM pour Flutter
- Génération de code Flutter

## 🔧 Personnalisation

### Adapter à votre projet

1. **Environnements** : Modifier la liste dans `deployment.rb` → `validate_environment()`
2. **Flavors Android** : Adapter selon vos flavors dans `build.gradle`
3. **Schemes iOS** : Adapter selon vos schemes Xcode
4. **Pattern de version** : Modifier le regex dans `utility_functions.rb` → `get_commits_output()`
5. **Certificats** : Adapter le type de certificat dans `certificate_management.rb`
6. **Logs personnalisés** : Modifier les catégories dans `recap_system.rb`

### Actions personnalisées

Vous pouvez ajouter vos propres modules dans le dossier `fastlane/actions/`. Exemples :

```ruby
# fastlane/actions/custom_notifications.rb
def send_slack_notification(message)
  # Votre logique de notification
end

# Dans le Fastfile principal
import 'fastlane/actions/custom_notifications.rb'
```

## 🔐 Sécurité

### Bonnes pratiques
1. **Jamais commiter** `.env.secret`
2. **Ajouter à `.gitignore`** :
   ```
   .env.secret
   fastlane/report.xml
   fastlane/README.md
   ```
3. **Utiliser App Store Connect API** au lieu d'Apple ID/mot de passe
4. **Rotation régulière** des tokens
5. **Environnements séparés** pour dev/staging/prod

### Variables sensibles à protéger
- `FIREBASE_CLI_TOKEN`
- `APPLE_PASSWORD`
- Clés API App Store Connect

## 🐛 Dépannage

### Erreurs courantes

#### "No version commit found"
- Vérifiez que vos commits de version suivent le pattern `Version X.X.X`
- Adaptez le regex dans `get_commits_output()` si nécessaire

#### "Certificate expired"
- Renouvelez vos certificats de distribution
- Mettez à jour vos profils de provisioning

#### "Firebase token invalid"
- Regénérez le token : `firebase login:ci`
- Mettez à jour `FIREBASE_CLI_TOKEN` dans `.env.secret`

#### "VPN connection issues"
- Déconnectez-vous du VPN d'entreprise avant le déploiement
- Vérifiez la connectivité Firebase

### Logs et debugging
- Tous les événements sont loggés avec timestamp
- Récapitulatif complet à la fin de chaque déploiement
- Catégories : SUCCESS, WARNING, ERROR, INFO

## 📚 Documentation additionnelle

- [Fastlane Flutter Plugin](https://github.com/dotdoom/fastlane-plugin-flutter)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)

## 🤝 Contribution

Ce template est basé sur l'expérience du projet POD Mobile. N'hésitez pas à l'adapter selon vos besoins spécifiques et à partager vos améliorations.

## 📄 Licence

Ce template est fourni tel quel, sans garantie. Adaptez-le selon vos besoins et votre environnement de développement.

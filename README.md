# 🚀 Fastlane Template for Flutter - Modular Architecture

A comprehensive, modular Fastlane template for Flutter applications with multi-environment deployment, certificate management, and automated distribution.

## 📁 Project Structure

```
fastlane_template/
├── Fastfile                              # Main configuration file with lanes
├── fastlane/
│   └── actions/                          # Modular feature files
│       ├── recap_system.rb               # Logging and recap system
│       ├── deployment.rb                 # Deployment and build functions
│       ├── certificate_management.rb     # Certificate management (Match + traditional)
│       └── utility_functions.rb          # Utility functions (versions, changelog)
├── ExportOptions.plist.template          # Comprehensive ExportOptions template
├── ExportOptions-AppStore.plist          # App Store distribution template
├── ExportOptions-Enterprise.plist        # Enterprise distribution template
├── ExportOptions-AdHoc.plist             # Ad-hoc distribution template
├── ExportOptions-Development.plist       # Development distribution template
├── # ExportOptions Templates Guide.md    # ExportOptions documentation
├── # Environment Configuration Template.ini
├── # Secret Environment Variables Template.md
├── # Fastlane Appfile Template
├── # Fastlane Pluginfile Template
├── # Fastlane Template pour Flutter.md   # Detailed French documentation
├── Fastfile.old.monolithic              # Original monolithic file (preserved)
└── README.md                            # This file
```

## 🏗️ Modular Architecture

### Core Files

- **`Fastfile`** - Main entry point with lanes and imports
- **`recap_system.rb`** - Comprehensive logging with timestamps and categories
- **`deployment.rb`** - Platform-specific deployment logic
- **`certificate_management.rb`** - Certificate handling (Match + traditional verification)
- **`utility_functions.rb`** - Helper functions for versions, changelog, and build numbers

### Template Files

- **Environment Configuration** - Template for environment-specific variables
- **Secret Variables** - Template for sensitive credentials
- **Appfile Template** - Basic app identifier configuration
- **Pluginfile Template** - Required gems and plugins

## ✨ Features

- **Multi-environment deployment** (int, qa, uat, mco, ppr, prod)
- **Multi-platform support** (iOS, Android, both)
- **Firebase App Distribution** integration
- **Certificate management** with Match or traditional verification
- **Comprehensive logging** with timestamped recap system
- **Flutter version management** with FVM support
- **Automated changelog** generation from Git commits
- **Modular architecture** for easy maintenance and customization

## 🚀 Quick Start

1. **Copy the main Fastfile**:
   ```bash
   cp Fastfile path/to/your/project/fastlane/
   ```

2. **Copy the actions directory**:
   ```bash
   cp -r fastlane/actions path/to/your/project/fastlane/
   ```

3. **Set up configuration files**:
   ```bash
   # Copy and customize templates
   cp "# Environment Configuration Template.ini" .env.prod
   cp "# Secret Environment Variables Template.md" .env.secret
   cp "# Fastlane Appfile Template" fastlane/Appfile
   cp "# Fastlane Pluginfile Template" fastlane/Pluginfile
   ```

4. **Install dependencies**:
   ```bash
   cd fastlane && bundle install && fastlane install_plugins
   ```

## 📖 Usage Examples

```bash
# Standard deployment
fastlane deployment env:prod target:both

# iOS deployment with Match certificate management
fastlane deployment env:prod target:ios use_match:true

# Certificate management
fastlane setup_certificates type:appstore
fastlane check_all use_match:true

# Utility commands
fastlane test
fastlane clean
```

## 🔧 Customization

Each module can be customized independently:

- **Environments**: Modify `validate_environment()` in `deployment.rb`
- **Certificate types**: Update defaults in `certificate_management.rb`
- **Version patterns**: Adjust regex in `utility_functions.rb`
- **Logging**: Customize categories in `recap_system.rb`

## 📚 Documentation

For detailed setup instructions, configuration options, and advanced usage, see:
- `# Fastlane Template pour Flutter.md` - Comprehensive French documentation

## 🤝 Contributing

This template is based on production experience from POD Mobile. Feel free to adapt it to your specific needs and share improvements.

## 📄 License

This template is provided as-is, without warranty. Adapt it according to your needs and development environment.

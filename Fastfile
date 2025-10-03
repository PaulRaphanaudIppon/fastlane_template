fastlane_require 'dotenv'

# ============================================================================
# FASTLANE TEMPLATE FOR FLUTTER APPS - MAIN FILE
# ============================================================================
# This template is based on the POD Mobile Fastfile structure
# 
# FEATURES:
# - Multi-environment deployment (int, qa, uat, mco, ppr, prod)
# - Multi-platform support (iOS, Android, both)
# - Firebase App Distribution integration
# - Match and traditional certificate management
# - Comprehensive logging and recap system
# - Flutter version management with FVM
# - Automated changelog generation
# ============================================================================

# Import all feature modules
import 'fastlane/actions/recap_system.rb'
import 'fastlane/actions/deployment.rb'
import 'fastlane/actions/certificate_management.rb'
import 'fastlane/actions/utility_functions.rb'

# ============================================================================
# SETUP AND CONFIGURATION
# ============================================================================

before_all do
  # Clear any previous recap messages
  clear_recap
  
  secretFile = '.env.secret'

  if (!File.exist?(secretFile)) then
    raise "Secret file doesn't exists at #{File.expand_path(secretFile)}"
  end

  Dotenv.overload secretFile
end

default_platform(:android)

# ============================================================================
# MAIN DEPLOYMENT LANE
# ============================================================================

desc "Deploy app to Firebase App Distribution"
desc "Parameters:"
desc "- env: Environment (int, qa, uat, mco, ppr, prod) - REQUIRED"
desc "- target: Platform target (ios, android, both) - OPTIONAL (default: both)"
desc "- fvm: Choose the fvm version to use (3.24.5, 3.24.6, 3.24.7) - OPTIONAL (default: 3.24.5)"
desc "- use_match: Use match for certificate management instead of manual verification - OPTIONAL (default: false)"
lane :deployment do |options|
  begin
    # Clear recap at start of deployment
    clear_recap
    
    # Display VPN warning
    add_to_recap("⚠️ BE CAREFUL, YOU NEED TO BE SIGNED OFF COMPANY'S VPN OR THE DEPLOYMENT USING THIS TOOL WILL NOT WORK ⚠️", "WARNING")
    add_to_recap("📁 Current directory: #{Dir.pwd}")
    
    # Validate and set parameters
    env = validate_environment(options[:env])
    target = validate_target(options[:target])
    use_match = options[:use_match] || false
    
    add_to_recap("🚀 Starting deployment for environment: #{env.upcase}, target: #{target.upcase}")
    
    # Set environment configuration
    setup_environment(env)
    
    # Find version commit and generate changelog
    version_commit = find_version_commit()
    changelog = get_changelog(version_commit)
    version_number = extract_version_number()
    
    add_to_recap("📝 Changelog generated from version commit: #{version_commit[0..7]}", "SUCCESS")

    # Generate dart code and setup fvm
    fvm_version = options[:fvm] || "3.24.5"
    generate(fvm_version: fvm_version)

    add_to_recap("📝 flutter code generated", "SUCCESS")

    build_number = next_build_number()
    add_to_recap("🔢 Build number determined: #{build_number}")

    # Run tests
    run_tests()

    # Deploy based on target
    case target
    when "android"
      deploy_android(build_number, changelog)
    when "ios"
      deploy_ios(version_number, build_number, changelog, use_match)
    when "both"
      deploy_android(build_number, changelog)
      deploy_ios(version_number, build_number, changelog, use_match)
    end
    
    add_to_recap("✅ DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉", "SUCCESS")
    
    # Display the recap at the end
    display_recap
    
  rescue => error
    add_to_recap("❌ Deployment failed: #{error.message}", "ERROR")
    display_recap
    UI.user_error!("❌ Deployment failed: #{error.message}".red)
  end
end

# ============================================================================
# ADDITIONAL LANES (CUSTOMIZE AS NEEDED)
# ============================================================================

desc "Generate Flutter code"
lane :generate do |options|
  fvm_version = options[:fvm_version]
  setup_fvm(fvm_version)
  flutter_generate()
end

desc "Run only tests without deployment"
lane :test do
  run_tests()
end

desc "Check all certificates and profiles"
desc "Parameters:"
desc "- use_match: Also setup certificates using match - OPTIONAL (default: false)"
lane :check_all do |options|
  use_match = options[:use_match] || false
  
  # Always check existing certificates and profiles
  check_certificates()
  check_provisioning_profiles()
  
  # Optionally setup certificates using match
  if use_match
    setup_all_certificates()
  end
end

desc "Clean and rebuild dependencies"
lane :clean do
  flutter(args: %w(clean))
  flutter(args: %w(pub get))
  install_ios_pods()
end

# ============================================================================
# TEMPLATE CONFIGURATION NOTES
# ============================================================================
# 
# TO USE THIS TEMPLATE:
# 
# 1. Copy this file to your project as `Fastfile`
# 2. Create the following environment files:
#    - .env.secret (with sensitive data)
#    - .env.int, .env.qa, .env.uat, .env.mco, .env.ppr, .env.prod
# 
# 3. Required environment variables in your .env files:
#    - FLAVOR: Android flavor name
#    - FLUTTER_TARGET: Target file (e.g., lib/main.dart)
#    - SCHEME: iOS scheme name
#    - EXPORT_OPTIONS: Path to ExportOptions.plist
#    - FIREBASE_APP: Firebase App ID for Android
#    - FIREBASE_APP_IOS: Firebase App ID for iOS
#    - FIREBASE_CLI_TOKEN: Firebase CLI token
#    - TESTER_GROUPS: Firebase App Distribution tester groups
#    - APP_STORE_CONNECT_API_KEY_ID: App Store Connect API key ID
#    - APP_STORE_CONNECT_ISSUER_ID: App Store Connect issuer ID
#    - APP_STORE_CONNECT_API_KEY_CONTENT: Path to API key file
#    - MATCH_GIT_URL: Git repository URL for match certificates storage
#    - MATCH_APP_IDENTIFIER: App identifier for match (optional, uses Appfile if not set)
#    - MATCH_GIT_BRANCH: Git branch for match storage (optional, defaults to cert type)
#    - MATCH_STORAGE_MODE: Storage mode for match (optional, defaults to git)
#    - MATCH_KEYCHAIN_NAME: Keychain name for match (optional, defaults to login)
#    - MATCH_KEYCHAIN_PASSWORD: Keychain password for match (optional)
# 
# 4. Create your Pluginfile with required gems:
#    gem 'fastlane-plugin-flutter'
#    gem 'fastlane-plugin-firebase_app_distribution'
# 
# 5. Create your Appfile with package name:
#    package_name("com.yourcompany.yourapp")
# 
# 6. Customize the TODO comments throughout this file for your specific needs
# 
# USAGE EXAMPLES:
#   fastlane deployment env:int target:android
#   fastlane deployment env:prod target:both fvm:3.24.7
#   fastlane deployment env:prod target:ios use_match:true
#   fastlane test
#   fastlane check_all
#   fastlane check_all use_match:true
#   fastlane setup_certificates type:appstore
#   fastlane setup_all_certificates
#   fastlane sync_certificates type:enterprise
#   fastlane clean
# 
# ============================================================================

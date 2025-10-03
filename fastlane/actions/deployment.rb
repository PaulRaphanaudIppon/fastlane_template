# ============================================================================
# DEPLOYMENT FUNCTIONS
# ============================================================================

# ============================================================================
# VALIDATION AND SETUP
# ============================================================================

def validate_environment(env)
  # TODO: Customize your valid environments here
  valid_envs = ['int', 'qa', 'uat', 'mco', 'ppr', 'prod']
  
  if env.nil? || env.empty?
    UI.user_error!("❌ Environment parameter is required. Valid values: #{valid_envs.join(', ')}")
  end
  
  unless valid_envs.include?(env.downcase)
    UI.user_error!("❌ Invalid environment '#{env}'. Valid values: #{valid_envs.join(', ')}")
  end
  
  add_to_recap("🎯 Environment validated: #{env.downcase}")
  env.downcase
end

def validate_target(target)
  valid_targets = ['ios', 'android', 'both']
  target = target&.downcase || 'both'
  
  unless valid_targets.include?(target)
    UI.user_error!("❌ Invalid target '#{target}'. Valid values: #{valid_targets.join(', ')}")
  end
  
  add_to_recap("🎯 Target platform validated: #{target}")
  target
end

def setup_environment(env)
  # Load environment-specific configuration
  env_file = ".env.#{env}"
  
  if File.exist?(env_file)
    Dotenv.overload env_file
    add_to_recap("📁 Loaded environment configuration: #{env_file}", "SUCCESS")
  else
    add_to_recap("⚠️  Environment file #{env_file} not found, using default configuration", "WARNING")
  end
end

# ============================================================================
# PLATFORM-SPECIFIC DEPLOYMENT
# ============================================================================

def deploy_android(build_number, changelog)
  add_to_recap("🤖 Starting Android Deployment")
  
  begin
    add_to_recap("📱 Android build number: #{build_number}")
    
    # Build Android app
    build_android_app(build_number)
    
    # Distribute to Firebase
    distribute_android(changelog)
    
    add_to_recap("✅ Android deployment completed successfully!", "SUCCESS")
    
  rescue => error
    add_to_recap("❌ Android deployment failed: #{error.message}", "ERROR")
    UI.user_error!("❌ Android deployment failed: #{error.message}")
  end
end

def deploy_ios(version_number, build_number, changelog, use_match = false)
  add_to_recap("🍎 Starting iOS Deployment")
  
  begin
    # Install CocoaPods dependencies
    install_ios_pods()

    add_to_recap("📱 iOS build number: #{build_number}")
    
    if use_match
      # Use match for certificate management
      add_to_recap("🔐 Using match for certificate management")
      sync_certificates()
    else
      # Use traditional certificate verification
      add_to_recap("🔍 Using traditional certificate verification")
      check_certificates()
      check_provisioning_profiles()
    end

    # Build iOS app
    build_ios_app(build_number, version_number)

    # Distribute to Firebase
    distribute_ios(changelog)
    
    add_to_recap("✅ iOS deployment completed successfully!", "SUCCESS")
    
  rescue => error
    UI.user_error!("❌ iOS deployment failed: #{error.message}")
  end
end

# ============================================================================
# BUILD FUNCTIONS
# ============================================================================

def run_tests()
  add_to_recap("🧪 Running Flutter tests...")
  
  begin
    sh('dart analyze')
    flutter(args: %w(test --coverage))
    add_to_recap("✅ All tests passed!", "SUCCESS")
  rescue => error
    UI.user_error!("❌ Tests failed: #{error.message}")
  end
end

def build_android_app(build_number)
  add_to_recap("🔨 Building Android app with build number: #{build_number}...")
  
  build_args = [
    '--flavor', ENV['FLAVOR'],
    '-t', ENV['FLUTTER_TARGET'],
  ]
  
  flutter_build(
    debug: ENV['FLUTTER_DEBUG'] || false,
    build_number: build_number,
    build_args: build_args,
  )
  
  add_to_recap("✅ Android app build completed", "SUCCESS")
end

def build_ios_app(build_number, version_number)
  add_to_recap("🔨 Building iOS app with build_number: #{build_number}...")
  
  flavor = ENV['FLAVOR']
  scheme = ENV['SCHEME']
  export_options = ENV['EXPORT_OPTIONS']
  
  # Update build and version numbers
  increment_build_number(
    build_number: build_number,
    xcodeproj: "./ios/Runner.xcodeproj",
  )
  
  if version_number
    increment_version_number(
      version_number: version_number,
      xcodeproj: "./ios/Runner.xcodeproj",
    )
  end

  gym(
    configuration: scheme,
    workspace: "./ios/Runner.xcworkspace",
    scheme: scheme,
    archive_path: "./build/ios/Runner.xcarchive",
    output_name: "app-#{flavor}-release.ipa",
    export_method: "enterprise", # TODO: Change to your export method (app-store, ad-hoc, enterprise, development)
    export_options: export_options,
  )
  
  add_to_recap("✅ iOS app build completed", "SUCCESS")
end

# ============================================================================
# DISTRIBUTION FUNCTIONS
# ============================================================================

def distribute_android(changelog)
  add_to_recap("📤 Distributing Android app to Firebase...")
  
  flavor = ENV['FLAVOR']
  firebase_app = ENV['FIREBASE_APP']
  
  if firebase_app.nil? || firebase_app.empty?
    UI.user_error!("❌ FIREBASE_APP environment variable not set for Android")
  end

  firebase_app_distribution(
    app: firebase_app,
    android_artifact_type: 'APK',
    android_artifact_path: "./build/app/outputs/flutter-apk/app-#{flavor}-release.apk",
    firebase_cli_token: ENV['FIREBASE_CLI_TOKEN'],
    groups: ENV['TESTER_GROUPS'],
    release_notes: changelog,
  )
  
  add_to_recap("✅ Android app distributed to Firebase successfully", "SUCCESS")
end

def distribute_ios(changelog)
  add_to_recap("📤 Distributing iOS app to Firebase...")
  
  firebase_app = ENV['FIREBASE_APP_IOS']
  
  if firebase_app.nil? || firebase_app.empty?
    UI.user_error!("❌ FIREBASE_APP_IOS environment variable not set for iOS")
  end

  firebase_app_distribution(
    app: firebase_app,
    firebase_cli_token: ENV['FIREBASE_CLI_TOKEN'],
    groups: ENV['TESTER_GROUPS'],
    release_notes: changelog,
  )
  
  add_to_recap("✅ iOS app distributed to Firebase successfully", "SUCCESS")
end

def install_ios_pods()
  add_to_recap("📦 Installing CocoaPods dependencies...")

  begin
   cocoapods(
     clean_install:true,
     verbose:true,
     repo_update:true,
     podfile:"./ios/Podfile"
   )
  add_to_recap("✅ CocoaPods dependencies installed successfully!", "SUCCESS")
  rescue => error
    UI.user_error!("❌ Failed to install CocoaPods dependencies: #{error.message}")
  end
end

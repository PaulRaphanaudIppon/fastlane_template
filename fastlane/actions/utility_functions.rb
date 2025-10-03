# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# ============================================================================
# VERSION AND CHANGELOG MANAGEMENT
# ============================================================================

def get_commits_output()
  # TODO: Customize your version commit pattern if needed
  # Get all commits in current branch with their messages
  commits_output = sh("git log --oneline --grep=\"Version [0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\" --basic-regexp", log: false)

  if commits_output.strip.empty?
    UI.user_error!("❌ No version commit found matching pattern 'Version X.X.X'")
  end
  return commits_output
end

def find_version_commit()
  begin
    # Get all commits in current branch with their messages
    commits_output = get_commits_output()
    
    # Extract the first (most recent) commit hash
    first_commit_line = commits_output.strip.split("\n").first
    commit_hash = first_commit_line.split(' ').first
    
    add_to_recap("🔍 Found version commit: #{commit_hash}")
    return commit_hash
    
  rescue => error
    UI.user_error!("❌ Failed to find version commit: #{error.message}")
  end
end

def extract_version_number()
  begin
    # Get all commits in current branch with their messages
    commits_output = get_commits_output()

    # Extract the first (most recent) commit message
    first_commit_line = commits_output.strip.split("\n").first
    commit_message = first_commit_line.split(' ', 2)[1]

    # Extract version number using regex
    version_match = commit_message.match(/Version (\d+\.\d+\.\d+)/)
    if version_match
      version_number = version_match[1]
      add_to_recap("🏷️  Found version number: #{version_number}")
      return version_number
    else
      UI.user_error!("❌ Could not extract version number from commit message: #{commit_message}")
    end
  rescue => error
    UI.user_error!("❌ Failed to extract version number: #{error.message}")
  end
end

def get_changelog(commit)
  changelog = changelog_from_git_commits(
    between: [commit, "HEAD"],
  )
  return changelog
end

# ============================================================================
# BUILD NUMBER MANAGEMENT
# ============================================================================

def next_build_number()
  firebase_app = ENV['FIREBASE_APP']
  firebase_app_ios = ENV['FIREBASE_APP_IOS']
  build_number = nil

  if firebase_app
    latest_release_android = firebase_app_distribution_get_latest_release(
      app: firebase_app,
      firebase_cli_token: ENV['FIREBASE_CLI_TOKEN'],
    )
  end

  if firebase_app_ios
    latest_release_ios = firebase_app_distribution_get_latest_release(
      app: firebase_app_ios,
      firebase_cli_token: ENV['FIREBASE_CLI_TOKEN'],
    )
  end

  android_build_number = latest_release_android && latest_release_android[:buildVersion].to_i
  ios_build_number = latest_release_ios && latest_release_ios[:buildVersion].to_i

  build_number = [android_build_number, ios_build_number].max

  calculated_build_number = (build_number && build_number + 1) || 1
  add_to_recap("🔢 Next build number calculated: #{calculated_build_number}")
  
  return calculated_build_number
end

# ============================================================================
# FLUTTER VERSION MANAGEMENT
# ============================================================================

def setup_fvm(fvm_version)
  # TODO: Customize your FVM installation path if needed
  fvm_path = File.expand_path("~/fvm/versions/#{fvm_version}/bin/flutter")
  UI.message("🔍 FVM path: #{fvm_path}")

  # Check if FVM is installed
  unless File.exist?(fvm_path)
    UI.user_error!("FVM is not installed or the specified version is not configured")
  end

  # Set environment variable to use FVM
  ENV["FLUTTER_ROOT"] = File.dirname(File.dirname(fvm_path))
end

def flutter_generate()
  add_to_recap("🛠️  Generating Flutter code...")
  
  begin
    flutter(args: %w(packages get))
    flutter(args: %w(packages pub run build_runner build --delete-conflicting-outputs))
    add_to_recap("✅ Flutter code generation completed", "SUCCESS")
  rescue => error
    add_to_recap("❌ Flutter code generation failed: #{error.message}", "ERROR")
    UI.user_error!("❌ Flutter code generation failed: #{error.message}")
  end
end

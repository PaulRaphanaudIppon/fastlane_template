# Secret Environment Variables Template
# 
# This file contains sensitive information and should be added to .gitignore
# Copy this file to .env.secret and fill in your actual values
# 
# NEVER commit this file to version control!

# ============================================================================
# FIREBASE CONFIGURATION
# ============================================================================

# Firebase CLI token for authentication
# Get this by running: firebase login:ci
FIREBASE_CLI_TOKEN=your_firebase_cli_token_here


# ============================================================================
# APPLE DEVELOPER CONFIGURATION (for iOS)
# ============================================================================

# Apple ID for developer account (optional, for legacy auth)
APPLE_ID=your.email@example.com

# App-specific password for Apple ID (optional, for legacy auth)
# Generate at: https://appleid.apple.com/account/manage
APPLE_PASSWORD=your_app_specific_password

# ============================================================================
# MATCH CERTIFICATE MANAGEMENT (optional)
# ============================================================================

# Git repository access token or SSH key passphrase for match
# Only needed if using private repositories that require authentication
# MATCH_GIT_BASIC_AUTHORIZATION=your_git_token_here

# Keychain password for match (optional)
# Only set this if you need a specific keychain password
# MATCH_KEYCHAIN_PASSWORD=your_keychain_password

# Match encryption passphrase for encrypting certificates (highly recommended)
# Generate a strong random passphrase and store it securely
MATCH_PASSWORD=your_strong_match_encryption_passphrase

# ============================================================================
# OTHER SENSITIVE CONFIGURATION
# ============================================================================

# Add other sensitive tokens, API keys, or credentials here
# Examples:
# SLACK_URL=https://hooks.slack.com/services/...
# TESTFLIGHT_API_KEY=your_testflight_api_key
# HOCKEY_API_TOKEN=your_hockey_api_token

# ============================================================================
# SECURITY NOTES
# ============================================================================
#
# 1. Always add .env.secret to your .gitignore file
# 2. Use App Store Connect API keys instead of Apple ID/password when possible
# 3. Rotate tokens regularly for security
# 4. Use environment-specific secrets for different deployment environments
# 5. Consider using a secure secret management system for production

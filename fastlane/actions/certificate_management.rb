# ============================================================================
# CERTIFICATE MANAGEMENT
# ============================================================================

# ============================================================================
# MATCH CERTIFICATE MANAGEMENT
# ============================================================================

desc "Setup certificates and provisioning profiles using match"
desc "Parameters:"
desc "- type: Certificate type (development, adhoc, appstore, enterprise) - OPTIONAL (default: enterprise)"
desc "- readonly: Read-only mode, don't create new certificates - OPTIONAL (default: false)"
lane :setup_certificates do |options|
  begin
    cert_type = options[:type] || "enterprise" # TODO: Change default to your preferred type
    readonly = options[:readonly] || false
    
    add_to_recap("🔐 Setting up certificates using match...")
    add_to_recap("📋 Certificate type: #{cert_type}")
    add_to_recap("👁️  Read-only mode: #{readonly}")
    
    # Validate certificate type
    valid_types = ['development', 'adhoc', 'appstore', 'enterprise']
    unless valid_types.include?(cert_type)
      UI.user_error!("❌ Invalid certificate type '#{cert_type}'. Valid values: #{valid_types.join(', ')}")
    end
    
    match(
      type: cert_type,
      app_identifier: ENV['MATCH_APP_IDENTIFIER'] || CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
      git_url: ENV['MATCH_GIT_URL'],
      git_branch: ENV['MATCH_GIT_BRANCH'] || cert_type,
      storage_mode: ENV['MATCH_STORAGE_MODE'] || "git",
      readonly: readonly,
      keychain_name: ENV['MATCH_KEYCHAIN_NAME'] || "login",
      keychain_password: ENV['MATCH_KEYCHAIN_PASSWORD'],
      force_for_new_devices: true
    )
    
    add_to_recap("✅ Certificates and provisioning profiles set up successfully!", "SUCCESS")
    
  rescue => error
    add_to_recap("❌ Failed to setup certificates: #{error.message}", "ERROR")
    UI.user_error!("❌ Failed to setup certificates: #{error.message}")
  end
end

desc "Setup certificates for all certificate types"
lane :setup_all_certificates do
  begin
    add_to_recap("🔐 Setting up all certificate types...")
    
    # Setup development certificates
    setup_certificates(type: "development", readonly: false)
    
    # Setup distribution certificates (change to appstore if not using enterprise)
    setup_certificates(type: "enterprise", readonly: false) # TODO: Change to 'appstore' if needed
    
    add_to_recap("✅ All certificates set up successfully!", "SUCCESS")
    
  rescue => error
    add_to_recap("❌ Failed to setup all certificates: #{error.message}", "ERROR")
    UI.user_error!("❌ Failed to setup all certificates: #{error.message}")
  end
end

desc "Sync certificates in read-only mode (for CI/CD)"
lane :sync_certificates do |options|
  cert_type = options[:type] || "enterprise" # TODO: Change default to your preferred type
  
  begin
    add_to_recap("🔄 Syncing certificates in read-only mode...")
    
    setup_certificates(type: cert_type, readonly: true)
    
    add_to_recap("✅ Certificates synced successfully!", "SUCCESS")
    
  rescue => error
    add_to_recap("❌ Failed to sync certificates: #{error.message}", "ERROR")
    UI.user_error!("❌ Failed to sync certificates: #{error.message}")
  end
end

# ============================================================================
# TRADITIONAL CERTIFICATE VERIFICATION
# ============================================================================

desc "Check iPhone Distribution certificate expiry"
lane :check_certificates do
  check_certificate_expiry
end

def check_certificate_expiry
  require 'time'
  
  add_to_recap("🔑 Checking iPhone Distribution certificate expiry...")
  
  begin
    # Find all code signing certificates
    result = sh("security find-identity -v -p codesigning", log: false)
    
    if result.strip.empty?
      UI.user_error!("❌ No code signing certificates found!")
      return
    end
    
    # Parse certificate identities and filter for iPhone Distribution only
    certificates = []
    result.each_line do |line|
      # Extract certificate hash and name from output like:
      # "  1) ABCD1234... "iPhone Distribution: Company Name (TEAM123)""
      if match = line.match(/\s*\d+\)\s+([A-F0-9]+)\s+"([^"]+)"/)
        hash = match[1]
        name = match[2]
        
        # Filter for iPhone Distribution certificates only
        if name.downcase.include?("iphone distribution")
          certificates << { hash: hash, name: name }
        end
      end
    end
    
    if certificates.empty?
      UI.user_error!("❌ No iPhone Distribution certificates found!")
      return
    end
    
    UI.message("🔍 Found #{certificates.count} iPhone Distribution certificate(s)")
    
    certificates.each do |cert|
      check_individual_certificate(cert[:hash], cert[:name])
    end
    
  rescue => error
    add_to_recap("❌ Failed to check certificates: #{error.message}", "ERROR")
    UI.user_error!("❌ Failed to check certificates: #{error.message}")
  end
end

def check_individual_certificate(cert_hash, cert_name)
  begin
    UI.message("📄 Checking certificate: #{cert_name}")
    
    # Get certificate details using the hash
    cert_data = sh("security find-certificate -c '#{cert_name}' -p", log: false)
    
    if cert_data.strip.empty?
      UI.error("❌ Could not retrieve certificate data for: #{cert_name}")
      return
    end
    
    # Save certificate to temporary file for parsing
    temp_cert_file = "/tmp/temp_cert_#{cert_hash}.pem"
    File.write(temp_cert_file, cert_data)
    
    # Extract certificate information using openssl
    cert_info = sh("openssl x509 -in '#{temp_cert_file}' -noout -dates", log: false)
    
    # Parse the expiration date
    expiry_match = cert_info.match(/notAfter=(.+)/)
    if expiry_match
      expiry_string = expiry_match[1].strip
      # Parse the date (format: "Jan  1 12:00:00 2025 GMT")
      expiration_date = Time.parse(expiry_string)
      
      UI.message("🗓️  Certificate expiration: #{expiration_date}")
      
      # Calculate days until expiry
      days_until_expiry = ((expiration_date - Time.now) / (24 * 60 * 60)).to_i
      
      if days_until_expiry < 0
        UI.user_error!("❌ #{cert_name} - EXPIRED #{days_until_expiry.abs} days ago".red)
      elsif days_until_expiry <= 30
        UI.user_error!("⚠️  #{cert_name} - Expires in #{days_until_expiry} days".yellow)
      elsif days_until_expiry <= 90
        UI.user_error!("⚠️  #{cert_name} - Expires in #{days_until_expiry} days (less than 3 months)".yellow)
      else
        add_to_recap("✅ #{cert_name} - Expires in #{days_until_expiry} days", "SUCCESS")
      end
    else
      add_to_recap("❌ Could not parse expiration date for: #{cert_name}", "ERROR")
    end
    
  rescue => error
    add_to_recap("❌ Error checking certificate #{cert_name}: #{error.message}", "ERROR")
  ensure
    # Cleanup temporary certificate file
    if defined?(temp_cert_file) && File.exist?(temp_cert_file)
      File.delete(temp_cert_file)
    end
  end
end

# ============================================================================
# PROVISIONING PROFILE MANAGEMENT
# ============================================================================

desc "Check provisioning profile expiry for all environments"
lane :check_provisioning_profiles do
  check_profile_expiry
end

def get_profile_name_from_export_options(export_options_path)
  unless File.exist?(export_options_path)
    UI.user_error!("ExportOptions.plist not found at #{export_options_path}")
  end

  export_options = Plist.parse_xml(export_options_path)
  provisioning_profiles = export_options['provisioningProfiles']
  if provisioning_profiles.nil? || provisioning_profiles.empty?
    UI.user_error!("No provisioningProfiles found in ExportOptions.plist")
  end

  # Get the first profile name (assuming only one)
  profile_name = provisioning_profiles.values.first
  return profile_name
end

def get_bundle_identifier_from_export_options(export_options_path)
  unless File.exist?(export_options_path)
    UI.user_error!("ExportOptions.plist not found at #{export_options_path}")
  end
  export_options = Plist.parse_xml(export_options_path)
  provisioning_profiles = export_options['provisioningProfiles']
  
  if provisioning_profiles.nil? || provisioning_profiles.empty?
    UI.user_error!("No provisioningProfiles found in ExportOptions.plist")
  end
  
  # Get the first bundle identifier (the key in provisioningProfiles)
  bundle_identifier = provisioning_profiles.keys.first
  return bundle_identifier
end

def check_profile_expiry
  require 'plist'
  require 'time'

  export_options = "../#{ENV['EXPORT_OPTIONS']}"
  profile_name = get_profile_name_from_export_options(export_options)
  bundle_identifier = get_bundle_identifier_from_export_options(export_options)
  UI.message("🔑 Bundle identifier: #{bundle_identifier}")
  UI.message("🔑 Profile name: #{profile_name}")
  download_provisioning_profile(bundle_identifier, profile_name)
  
  profile_path = "../#{profile_name}.mobileprovision"
  UI.message("📄 Provisioning profile downloaded: #{profile_path}")
  
  begin
    # Use the actual downloaded profile path
    xml = `security cms -D -i "#{profile_path}"`
    plist = Plist.parse_xml(xml)
    expiration_date = plist['ExpirationDate']
    UI.message("🗓️  Expiration date: #{expiration_date}")
    
    days_until_expiry = (expiration_date - Date.today).to_i

    if days_until_expiry < 0
      UI.user_error!("❌ - EXPIRED #{days_until_expiry.abs} days ago".red)
    elsif days_until_expiry <= 90
      UI.user_error!("⚠️ - Expires in #{days_until_expiry} days".yellow)
    else
      add_to_recap("✅ Provisioning profile is valid for more than 3 months.", "SUCCESS")
    end
  ensure
    # Always cleanup the downloaded provisioning profile
    if File.exist?(profile_path)
      File.delete(profile_path)
      UI.message("🗑️  Cleaned up downloaded provisioning profile: #{profile_path}")
    end
  end
end

def download_provisioning_profile(app_identifier, profile_name)
  api_key = app_store_connect_api_key(
    key_id: ENV['APP_STORE_CONNECT_API_KEY_ID'],
    issuer_id: ENV['APP_STORE_CONNECT_ISSUER_ID'],
    key_filepath: ENV['APP_STORE_CONNECT_API_KEY_CONTENT'],
    duration: 1200,
    in_house: true, # TODO: Set to false if not using enterprise certificates
  )
  
  profile_path = sigh(
    app_identifier: app_identifier,
    api_key: api_key,
    skip_install: true,
    filename: "#{profile_name}.mobileprovision",
  )
  UI.message("📄 Provisioning profile downloaded: #{profile_path}")

  return profile_path
end

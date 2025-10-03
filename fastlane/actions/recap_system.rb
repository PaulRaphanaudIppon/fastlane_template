# ============================================================================
# RECAP LOGGING SYSTEM
# ============================================================================

# Global array to store recap messages
$recap_messages = []

# Add a message to the recap with timestamp and optional category
def add_to_recap(message, category = "INFO")
  timestamp = Time.now.strftime("%H:%M:%S")
  formatted_message = "[#{timestamp}] [#{category}] #{message}"
  $recap_messages << formatted_message
  
  # Also log to console immediately
  case category
  when "SUCCESS"
    UI.success(message)
  when "WARNING"
    UI.important(message.yellow)
  when "ERROR"
    UI.error(message.red)
  else
    UI.message(message)
  end
end

# Display the complete recap at the end
def display_recap
  return if $recap_messages.empty?
  
  UI.header("📋 DEPLOYMENT RECAP")
  UI.message("═" * 80)
  
  $recap_messages.each do |message|
    UI.message(message)
  end
  
  UI.message("═" * 80)
  UI.message("📝 Total events: #{$recap_messages.count}")
  
  # Count different categories
  success_count = $recap_messages.count { |msg| msg.include?("[SUCCESS]") }
  warning_count = $recap_messages.count { |msg| msg.include?("[WARNING]") }
  error_count = $recap_messages.count { |msg| msg.include?("[ERROR]") }
  
  if success_count > 0
    UI.message("✅ Successful operations: #{success_count}")
  end
  if warning_count > 0
    UI.message("⚠️  Warnings: #{warning_count}")
  end
  if error_count > 0
    UI.message("❌ Errors: #{error_count}")
  end
  
  UI.message("═" * 80)
end

# Clear recap messages (useful for multiple runs)
def clear_recap
  $recap_messages.clear
end

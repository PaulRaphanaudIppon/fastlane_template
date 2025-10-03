# ExportOptions.plist Templates Guide

This guide explains how to use the ExportOptions.plist templates for iOS app distribution.

## 📁 Available Templates

| File | Distribution Method | Use Case |
|------|-------------------|----------|
| `ExportOptions.plist.template` | Comprehensive template | Base template with all options documented |
| `ExportOptions-AppStore.plist` | App Store | Production App Store releases |
| `ExportOptions-Enterprise.plist` | Enterprise | Internal company distribution |
| `ExportOptions-AdHoc.plist` | Ad-Hoc | Limited device testing |
| `ExportOptions-Development.plist` | Development | Development builds |

## 🛠️ Setup Instructions

### 1. Choose the Right Template

Select the template that matches your distribution method:

- **App Store**: For production releases to the App Store
- **Enterprise**: For internal company apps (requires Apple Enterprise Program)
- **Ad-Hoc**: For testing with specific devices (up to 100 devices)
- **Development**: For development and debugging

### 2. Copy and Customize

```bash
# Example: Copy enterprise template for production environment
cp ExportOptions-Enterprise.plist ios/export_options_prod.plist

# Copy ad-hoc template for QA environment
cp ExportOptions-AdHoc.plist ios/export_options_qa.plist
```

### 3. Update Required Fields

Edit the copied file and update these **REQUIRED** fields:

```xml
<!-- Replace with your Apple Developer Team ID -->
<key>teamID</key>
<string>YOUR_TEAM_ID_HERE</string>

<!-- Replace with your app's bundle identifier and provisioning profile name -->
<key>provisioningProfiles</key>
<dict>
    <key>com.yourcompany.yourapp</key>
    <string>Your Actual Provisioning Profile Name</string>
</dict>
```

### 4. Update Environment Configuration

Update your `.env.*` files to reference the correct ExportOptions:

```bash
# .env.prod
EXPORT_OPTIONS=ios/export_options_prod.plist

# .env.qa
EXPORT_OPTIONS=ios/export_options_qa.plist
```

## 🔧 Configuration Options Explained

### Distribution Methods

| Method | Description | Certificate Type | Use Case |
|--------|-------------|------------------|----------|
| `app-store` | App Store distribution | iPhone Distribution | Production releases |
| `enterprise` | Enterprise distribution | iPhone Distribution (Enterprise) | Internal company apps |
| `ad-hoc` | Ad-hoc distribution | iPhone Distribution | Testing with registered devices |
| `development` | Development distribution | iPhone Developer | Development builds |

### Key Settings

#### **compileBitcode**
- `true`: Enable bitcode compilation (recommended for App Store)
- `false`: Disable bitcode (faster builds, required for some libraries)

#### **uploadSymbols**
- `true`: Upload symbols for crash reporting
- `false`: Don't upload symbols (enterprise/development)

#### **thinning**
- `<thin-for-all-supported-variants>`: Optimize for all devices (App Store)
- `<none>`: No thinning (enterprise/ad-hoc)

#### **signingStyle**
- `manual`: Use specific provisioning profiles (recommended)
- `automatic`: Let Xcode manage signing

## 📱 Environment-Specific Examples

### Production (App Store)
```xml
<key>method</key>
<string>app-store</string>
<key>compileBitcode</key>
<true/>
<key>uploadSymbols</key>
<true/>
<key>thinning</key>
<string>&lt;thin-for-all-supported-variants&gt;</string>
```

### QA/UAT (Ad-Hoc)
```xml
<key>method</key>
<string>ad-hoc</string>
<key>compileBitcode</key>
<true/>
<key>uploadSymbols</key>
<false/>
<key>thinning</key>
<string>&lt;none&gt;</string>
```

### Development/Integration
```xml
<key>method</key>
<string>development</string>
<key>compileBitcode</key>
<false/>
<key>uploadSymbols</key>
<false/>
<key>stripSwiftSymbols</key>
<false/>
```

## 🏢 Enterprise Distribution Setup

For enterprise distribution, you'll also need to configure the manifest:

```xml
<key>manifest</key>
<dict>
    <key>appURL</key>
    <string>https://yourcompany.com/apps/yourapp.ipa</string>
    <key>displayImageURL</key>
    <string>https://yourcompany.com/apps/icon-57.png</string>
    <key>fullSizeImageURL</key>
    <string>https://yourcompany.com/apps/icon-512.png</string>
</dict>
```

### Required Assets for Enterprise
- **IPA file**: The signed application
- **57x57 icon**: Display icon for installation
- **512x512 icon**: Full-size icon
- **Installation page**: HTML page with installation links

## 🔍 Finding Your Team ID

You can find your Team ID in several ways:

### Apple Developer Portal
1. Go to [developer.apple.com](https://developer.apple.com)
2. Sign in and go to "Account"
3. Look for "Team ID" in the membership details

### Keychain Access
1. Open Keychain Access
2. Find your distribution certificate
3. Double-click and look for "Organizational Unit"

### Xcode
1. Open your project in Xcode
2. Go to project settings → Signing & Capabilities
3. Team ID is shown next to your team name

## 🐛 Common Issues

### "No matching provisioning profiles found"
- Verify the bundle identifier matches exactly
- Check that the provisioning profile name is correct
- Ensure the certificate is properly installed

### "Bitcode compilation failed"
- Set `compileBitcode` to `false` if using libraries without bitcode support
- For App Store, try to update dependencies to support bitcode

### "Export failed with signingStyle manual"
- Ensure the certificate name matches exactly (e.g., "iPhone Distribution")
- Check that the provisioning profile is properly installed

## ✅ Validation Checklist

Before using your ExportOptions.plist:

- [ ] Team ID is correct
- [ ] Bundle identifier matches your app
- [ ] Provisioning profile name is exact
- [ ] Certificate name matches keychain
- [ ] Distribution method is appropriate
- [ ] File is referenced correctly in environment config

## 🔗 Integration with Fastlane

The templates work seamlessly with the modular fastlane setup:

```ruby
# In deployment.rb
gym(
  configuration: scheme,
  workspace: "./ios/Runner.xcworkspace",
  scheme: scheme,
  export_options: ENV['EXPORT_OPTIONS'], # Points to your customized plist
)
```

This allows different environments to use different export configurations automatically.

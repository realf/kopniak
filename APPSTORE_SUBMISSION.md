# Kopniak - AppStore Submission Guide

This guide covers all steps needed to submit Kopniak to the macOS AppStore.

## Completed Setup

✅ **Privacy Manifest** - `Kopniak/PrivacyInfo.xcprivacy`
✅ **Entitlements File** - `Kopniak/Kopniak.entitlements`
✅ **Code Signing** - Configured for AppStore distribution
✅ **Build Configuration** - Release build tested successfully

---

## Current Project Settings

```
Bundle Identifier:      org.realf.Kopniak
Product Name:           Kopniak
Marketing Version:      1.0
Build Number:           4
Team ID:                6HXQVJ34RS
Deployment Target:      macOS 15.0
Signing Style:          Automatic
App Sandbox:           Enabled
Hardened Runtime:      Enabled
```

---

## Next Steps to Submit

### Step 1: Update Version Numbers (if needed)

Before submission, decide on version numbers:

**Current versions:**
- Marketing Version: `1.0`
- Build Number: `4`

**To update in Xcode:**
1. Select target "Kopniak"
2. Build Settings tab
3. Search for "Marketing Version" and "Current Project Version"
4. Update as needed (e.g., `1.0.1` marketing, `5` build)

**In project.pbxproj:**
- Look for `MARKETING_VERSION = 1.0;` and `CURRENT_PROJECT_VERSION = 4;`

---

### Step 2: Create App ID in AppStore Connect

1. Go to [AppStore Connect](https://appstoreconnect.apple.com)
2. Apps → New App
3. Select:
   - **Platform:** macOS
   - **Name:** Kopniak
   - **Primary Language:** English
   - **Bundle ID:** org.realf.Kopniak (should match in Xcode)
   - **SKU:** kopniak-menu-bar (any unique identifier)

---

### Step 3: Fill in App Information

#### General Info
- **App Name:** Kopniak
- **Subtitle (optional):** Break Reminder for Mac
- **Description:**
  ```
  Kopniak is a macOS menu bar utility that reminds you to take breaks from computer work.
  Send periodic reminders with customizable intervals, pause/resume functionality, and
  launch-at-login behavior. Perfect for maintaining healthy computing habits.
  ```
- **Keywords:** break, reminder, health, menu bar, productivity
- **Support URL:** https://github.com/yourusername/kopniak

#### Pricing & Availability
- **Price:** Free (or set a price if desired)
- **Available:** Select all regions
- **Availability Date:** Immediate (or your preferred date)

#### App Privacy
- **Privacy Policy:** Create a simple one:
  ```
  Kopniak does not collect, transmit, or store any user data.
  The app operates entirely locally on your Mac and does not
  communicate with external servers. No personal information
  is gathered or shared.
  ```

#### Age Rating
- Complete the questionnaire (should be straightforward for this utility)
- Expected: 4+ years

---

### Step 4: Prepare Screenshots

You need at least 1 screenshot for macOS (11" or larger).

**Recommended screenshots (in order):**

1. **Menu Bar Icon & Reminder Popup** (Main Feature)
   - Show the menu bar with Kopniak icon and countdown timer
   - Include the reminder popup with motivational message

2. **Settings Window** (Customization)
   - Show reminder interval settings
   - Show pause/resume controls
   - Show launch-at-login option

3. **Menu Options** (Controls)
   - Show the menu bar dropdown with all options

**Screenshot Guidelines:**
- Size: 1024 × 768 pixels (minimum)
- Format: PNG or JPG
- No advertisements or third-party content
- Make sure UI is clear and readable

**To take screenshots:**
1. Run the app
2. Use Cmd+Shift+5 to take a screenshot
3. Crop as needed to show the key features
4. Upload to AppStore Connect

---

### Step 5: Build for AppStore Distribution

#### Option A: Build in Xcode (Recommended)

1. Select Product → Scheme → Kopniak
2. Product → Destination → Any Mac
3. Product → Build For → Archiving
4. Product → Archive

#### Option B: Build from Command Line

```bash
cd /Users/alf/dev/kopniak/Kopniak

# Build archive
xcodebuild archive \
  -scheme Kopniak \
  -configuration Release \
  -archivePath ~/Desktop/Kopniak.xcarchive

# Export for distribution
xcodebuild -exportArchive \
  -archivePath ~/Desktop/Kopniak.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath ~/Desktop/Kopniak-AppStore
```

**ExportOptions.plist** (create this file):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-appstore</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string>6HXQVJ34RS</string>
</dict>
</plist>
```

---

### Step 6: Notarization (Required for AppStore)

Apple requires notarization for all macOS apps distributed via AppStore.

**Option A: Via Xcode Organizer**
1. Product → Archive
2. Window → Organizer
3. Select your archive
4. "Distribute App"
5. Choose "macOS AppStore"
6. Follow prompts

**Option B: Command Line**

```bash
# Get your app-specific password from:
# https://appleid.apple.com → Security → App-Specific Passwords

# Submit for notarization
xcrun notarytool submit ~/Desktop/Kopniak.dmg \
  --apple-id your-apple-id@example.com \
  --password your-app-specific-password \
  --team-id 6HXQVJ34RS

# Wait for confirmation, then staple the notarization
xcrun stapler staple ~/Desktop/Kopniak.app
```

---

### Step 7: Submit via Transporter

1. **Download Transporter** from the App Store (free)
2. Open Transporter
3. Sign in with Apple ID
4. Click + to add your app package
5. Select your `.ipa` or `.pkg` file
6. Review the submission
7. Click "Deliver"

---

### Step 8: App Review Preparation

**Common review guidelines for menu bar apps:**

- ✅ Ensure the app behaves as described in the App Store listing
- ✅ Verify all promised features work correctly
- ✅ Test on a clean macOS installation
- ✅ Ensure no console errors during use
- ✅ Confirm the Privacy Manifest is accurate
- ✅ Test launch-at-login functionality
- ✅ Verify all menu options work

**Potential Issues:**
- **Rejected for accessing accessibility features:** Not an issue - Kopniak uses standard NSWorkspace notifications
- **Rejected for not functioning as described:** Ensure your App Store description matches actual behavior
- **Rejected for collecting data:** Kopniak doesn't, so this should not be an issue

---

### Step 9: Monitor App Review Status

1. AppStore Connect → Builds
2. Check "Submitted for Review" status
3. App review typically takes 24-48 hours

**If rejected:**
- Read the rejection reason carefully
- Address the issue
- Increment build number
- Resubmit

---

## File Checklist

Required files created:

- ✅ `Kopniak/PrivacyInfo.xcprivacy` - Privacy manifest
- ✅ `Kopniak/Kopniak.entitlements` - App entitlements
- ✅ Updated `Kopniak.xcodeproj/project.pbxproj` - Signing configuration

---

## Important Notes

### Entitlements
Your app uses minimal entitlements:
- `com.apple.security.app-sandbox` - Sandboxing enabled
- `com.apple.security.files.user-selected.read-only` - User-selected files (read-only)

**Note:** The `com.apple.security.get-task-allow` entitlement is auto-added by Xcode for development. This will be removed in the AppStore build automatically.

### Privacy & Data Collection
Kopniak:
- Does NOT collect user data
- Does NOT require internet connectivity
- Does NOT access sensitive APIs requiring user permission
- Uses only standard system notifications for idle detection

This makes submission straightforward with minimal compliance requirements.

### macOS Compatibility
- **Deployment Target:** macOS 15.0
- **Minimum Supported:** macOS 13.0+ (recommended for AppStore apps)
- Consider lowering to 13.0 for broader compatibility:
  ```
  MACOSX_DEPLOYMENT_TARGET = 13.0;
  ```

---

## Troubleshooting

### Build Fails with Entitlements Error
- Verify `CODE_SIGN_ENTITLEMENTS = Kopniak/Kopniak.entitlements;` is in project.pbxproj
- Check entitlements file is valid XML

### Code Signing Fails
- Verify team ID: `xcodebuild -showBuildSettings | grep TEAM_ID`
- Ensure "Automatically manage signing" is checked in Xcode
- Clear derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/Kopniak-*`

### Notarization Fails
- Ensure app is properly code-signed before notarization
- Check Apple ID credentials and app-specific password
- Verify internet connection is stable

### App Review Rejection
- Common reason: Description not matching functionality
- Solution: Ensure App Store description exactly matches what your app does

---

## Timeline

Typical AppStore submission timeline:
- **Preparation:** 1-2 hours
- **Building & Signing:** 15-30 minutes
- **Notarization:** 5-15 minutes
- **Upload via Transporter:** 5-10 minutes
- **App Review:** 24-48 hours
- **Availability:** Immediately after approval

---

## Commands Reference

```bash
# Build for AppStore
xcodebuild archive -scheme Kopniak -configuration Release

# Check code signing
codesign -dv /path/to/Kopniak.app

# Check entitlements
codesign -d --entitlements :- /path/to/Kopniak.app

# View build settings
xcodebuild -showBuildSettings | grep -E "(TEAM|BUNDLE|VERSION|MARKETING)"

# Validate archive
spctl -a -vvv -t open --context context:primary-signature /path/to/Kopniak.app
```

---

## Resources

- [AppStore Connect](https://appstoreconnect.apple.com)
- [Apple macOS App Distribution Guide](https://developer.apple.com/macos/distribution/)
- [Notarization Documentation](https://developer.apple.com/documentation/notarization)
- [App Sandbox Documentation](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/)

---

## Next Actions

1. Update version numbers if desired
2. Create AppStore Connect app entry
3. Prepare screenshots and descriptions
4. Build and test locally
5. Archive for distribution
6. Notarize the archive
7. Submit via Transporter
8. Monitor app review status
9. Celebrate launch! 🎉

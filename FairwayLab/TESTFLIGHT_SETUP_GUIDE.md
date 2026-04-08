# TestFlight Distribution Setup Guide

## Issues to Fix

Based on your upload error, you need to fix:

1. ❌ Missing `CFBundleIconName` in Info.plist
2. ❌ Missing app icon for iPad (152x152px)
3. ❌ Missing app icon for iPhone (120x120px)

---

## 🎨 Fix 1: Add App Icons

Apple requires specific icon sizes for TestFlight distribution. Here's how to add them:

### Step 1: Create Icon Sizes

You need to create PNG icons at these sizes:
- **iPhone/iPod Touch (120x120)** - App icon at 2x for iOS 11+
- **iPad (152x152)** - App icon at 2x for iOS 11+
- **App Store (1024x1024)** - Required for all apps

**Quick way to generate icons:**
1. Create a square icon at 1024x1024 pixels
2. Use an online tool like [appicon.co](https://appicon.co) or [makeappicon.com](https://makeappicon.com)
3. Upload your 1024x1024 icon and download all sizes

### Step 2: Add Icons to Xcode

1. **Open** your project in Xcode
2. **Navigate** to the project navigator (left sidebar)
3. **Find** `Assets.xcassets` (usually in the GolfX folder)
4. **Click** on `AppIcon` in the asset catalog
5. **Drag and drop** your icons into the appropriate slots:
   - iPhone App 60pt @2x → 120x120
   - iPhone App 60pt @3x → 180x180
   - iPad App 76pt @2x → 152x152
   - App Store → 1024x1024

**Important:** The icons must be:
- ✅ PNG format
- ✅ No transparency (alpha channel)
- ✅ Square (width = height)
- ✅ Exact pixel dimensions

### Alternative: Use Xcode's Icon Generator

If you only have a 1024x1024 icon:

1. Add it to the **App Store** slot in AppIcon
2. Right-click on the AppIcon set
3. Select **"All Sizes from App Store Icon"** (if available in your Xcode version)
4. Xcode will generate all required sizes

---

## 📝 Fix 2: Add CFBundleIconName to Info.plist

### Using Xcode UI

1. **Open** `Info.plist` in Xcode (in the GolfX folder)
2. **Click** the `+` button or right-click → "Add Row"
3. **Enter:**
   - **Key:** `CFBundleIconName` (or type "Application Icon Name")
   - **Type:** String
   - **Value:** `AppIcon`
4. **Save** (⌘S)

### Using Source Code Editor

1. **Right-click** `Info.plist` → "Open As" → "Source Code"
2. **Add** this line inside the main `<dict>` tag:

```xml
<key>CFBundleIconName</key>
<string>AppIcon</string>
```

3. **Save** (⌘S)

---

## 🏗️ Complete Info.plist for TestFlight

Your Info.plist should include these keys:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Bundle Information -->
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    
    <key>CFBundleDisplayName</key>
    <string>GolfX</string>
    
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    
    <!-- ⭐️ ADD THIS FOR TESTFLIGHT ⭐️ -->
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    
    <key>CFBundleVersion</key>
    <string>1</string>
    
    <!-- UI Configuration -->
    <key>UILaunchScreen</key>
    <dict/>
    
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <true/>
    </dict>
    
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    
    <!-- API Key (from previous setup) -->
    <key>GOLF_API_KEY</key>
    <string>LLOACD7TDCZ66UQVAOQFUWHRLM</string>
    
</dict>
</plist>
```

---

## 🚀 Step-by-Step Upload to TestFlight

### 1. Prepare Your Build

```bash
# Clean build folder
⇧⌘K (Shift + Command + K)

# Select "Any iOS Device (arm64)" as destination
# Do NOT select a simulator
```

### 2. Archive the App

1. **Product** → **Archive**
2. Wait for the build to complete
3. The **Organizer** window will open automatically

### 3. Validate the Archive

Before uploading, validate to catch errors:

1. In Organizer, **select** your archive
2. Click **Validate App**
3. Choose your team/account
4. Select **automatic signing** (recommended)
5. Wait for validation
6. Fix any errors that appear

### 4. Upload to TestFlight

1. Click **Distribute App**
2. Select **TestFlight Internal Only** (or **App Store Connect** for full TestFlight)
3. Choose distribution options:
   - ✅ Upload app symbols (recommended for crash reports)
   - ✅ Manage version and build number (if desired)
4. Select **Automatic Signing**
5. Review and **Upload**

### 5. Wait for Processing

- Upload takes 5-15 minutes depending on size
- Processing in App Store Connect can take 10-60 minutes
- You'll get an email when it's ready for testing

---

## 📋 Pre-Upload Checklist

Before archiving, verify:

### Project Settings
- [ ] Bundle Identifier is unique (e.g., `com.yourname.GolfX`)
- [ ] Version number is set (e.g., 1.0)
- [ ] Build number is set (e.g., 1)
- [ ] Deployment target is iOS 17.0 or higher
- [ ] All schemes are set to Release mode for Archive

### Info.plist
- [ ] `CFBundleIconName` = `AppIcon`
- [ ] `CFBundleDisplayName` is set
- [ ] `CFBundleShortVersionString` is set
- [ ] `GOLF_API_KEY` is present (if needed)

### App Icons
- [ ] 120x120 PNG (iPhone 2x)
- [ ] 180x180 PNG (iPhone 3x)
- [ ] 152x152 PNG (iPad 2x)
- [ ] 167x167 PNG (iPad Pro)
- [ ] 1024x1024 PNG (App Store)
- [ ] All icons have no transparency
- [ ] All icons are exactly square

### Signing & Capabilities
- [ ] Team is selected
- [ ] Signing certificate is valid
- [ ] Provisioning profile is valid
- [ ] All capabilities are configured (if any)

### Code
- [ ] All tests pass (⌘U)
- [ ] No compiler warnings (ideally)
- [ ] App runs on device without crashes

---

## 🛠️ Quick App Icon Template

If you need a placeholder icon quickly:

```swift
// Create this in SF Symbols or use a design tool
// Suggested design for GolfX:
// - Green background (#34A853)
// - White golf flag icon
// - "GX" monogram
```

**Free icon resources:**
- [Canva](https://canva.com) - Free app icon templates
- [Figma](https://figma.com) - Design tools
- [SF Symbols](https://developer.apple.com/sf-symbols/) - Apple's icon library

---

## 🔧 Common Issues & Solutions

### Issue: "Missing required icon file"

**Solution:**
1. Check that icons are in `AppIcon` asset catalog
2. Verify sizes match exactly (120x120, not 119x119)
3. Ensure PNG format, not JPG or JPEG
4. Remove any transparency/alpha channel

### Issue: "CFBundleIconName missing"

**Solution:**
- Add the key to Info.plist as shown above
- Value must be exactly `AppIcon` (case-sensitive)

### Issue: "Code signing failed"

**Solution:**
1. Open Xcode → Preferences → Accounts
2. Verify your Apple ID is signed in
3. Click "Download Manual Profiles"
4. In project settings, select your team
5. Enable "Automatically manage signing"

### Issue: "No such module 'GolfX'"

**Solution:**
- This happens with test targets
- Make sure you're archiving the app target, not test target
- Clean build folder (⇧⌘K) and try again

### Issue: "Archive disabled / greyed out"

**Solution:**
- Make sure you selected "Any iOS Device (arm64)" as build destination
- You cannot archive when a simulator is selected

---

## 📱 TestFlight Internal Testing

Once uploaded:

### Add Internal Testers

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **TestFlight** tab
4. Under **Internal Testing**, click the **+** to add testers
5. Select users from your team (must have App Store Connect access)

### Add External Testers (Optional)

1. In TestFlight tab, go to **External Testing**
2. Create a new test group
3. Add email addresses of testers
4. Requires **App Review** (1-2 days)

### Invite Testers

1. Testers will receive an email invitation
2. They install the **TestFlight** app from the App Store
3. They open the invitation email and accept
4. They can install and test your app

---

## 🎯 Quick Fix Summary

**To fix your current errors:**

1. **Add app icons** to Assets.xcassets/AppIcon
   - Minimum: 120x120, 152x152, 1024x1024
   
2. **Add to Info.plist:**
   ```xml
   <key>CFBundleIconName</key>
   <string>AppIcon</string>
   ```

3. **Clean and Archive:**
   - ⇧⌘K (clean)
   - Product → Archive
   - Validate
   - Upload to TestFlight

---

## 📞 Need Help?

If you're still stuck:

1. Check Xcode console for detailed error messages
2. Run Product → Analyze to find potential issues
3. Try archiving for simulator first (won't upload, but validates build)
4. Make sure your Apple Developer account is active

---

**Status:** Ready for TestFlight once icons and Info.plist are fixed  
**Time to fix:** ~15 minutes  
**Time to upload:** ~15-30 minutes  
**Time for App Store processing:** ~30-60 minutes

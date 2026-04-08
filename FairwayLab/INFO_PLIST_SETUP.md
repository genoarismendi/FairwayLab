# ⚠️ IMPORTANT: Info.plist Configuration

## Golf Course API Key Setup

For the course search to work, you **MUST** add the API key to your `Info.plist` file.

---

## 📋 Step-by-Step Instructions

### Option 1: Using Xcode UI (Recommended)

1. **Open** `Info.plist` in Xcode (it should be in the `GolfX` folder)
2. **Right-click** anywhere in the property list
3. **Select** "Add Row"
4. **Enter** these values:
   - **Key:** `GOLF_API_KEY`
   - **Type:** `String` (should be default)
   - **Value:** `LLOACD7TDCZ66UQVAOQFUWHRLM`
5. **Save** the file (⌘S)

### Option 2: Using Source Code Editor

1. **Right-click** `Info.plist` in Project Navigator
2. **Select** "Open As" → "Source Code"
3. **Add** this entry inside the `<dict>` tag:

```xml
<key>GOLF_API_KEY</key>
<string>LLOACD7TDCZ66UQVAOQFUWHRLM</string>
```

4. **Save** the file (⌘S)

---

## ✅ Verify It's Working

After adding the key:

1. **Clean Build Folder** (⇧⌘K)
2. **Build** the project (⌘B)
3. **Run** the app
4. Check console - you should NOT see: `⚠️ GOLF_API_KEY not found in Info.plist`

---

## 🔍 Complete Info.plist Example

Your `Info.plist` should look something like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>GolfX</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <true/>
    </dict>
    
    <!-- ⭐️ ADD THIS KEY ⭐️ -->
    <key>GOLF_API_KEY</key>
    <string>LLOACD7TDCZ66UQVAOQFUWHRLM</string>
    
</dict>
</plist>
```

---

## 🚨 Common Issues

### **Issue: API calls fail with "Missing API key"**
**Solution:** Make sure you added the key to `Info.plist` and rebuilt the app

### **Issue: Can't find Info.plist**
**Solution:** It's usually at `GolfX/Info.plist` in your project folder

### **Issue: Key is there but still not working**
**Solution:** 
1. Clean build folder (⇧⌘K)
2. Delete app from simulator/device
3. Build and run again

### **Issue: Wrong target**
**Solution:** Make sure you're editing the `GolfX` app's Info.plist, not a test target's

---

## 🔐 Security Note

**For Production:**

If you're planning to publish this app or share the code publicly, you should:

1. **Never commit** API keys to version control
2. **Use environment variables** or a secure configuration system
3. **Consider** using a backend service to proxy API calls
4. **Rotate** the API key if it's been exposed

**For Development:**

The current setup is fine for local development and testing.

---

## 📞 API Documentation

- **Provider:** Golf Course API
- **Base URL:** `https://api.golfcourseapi.com`
- **Authentication:** API Key in header as `Key {your-key}`
- **Endpoints Used:**
  - `GET /v1/search?search_query={query}` - Search courses
  - `GET /v1/courses/{id}` - Get course details

---

## ✅ Checklist

Before you can use course search:

- [ ] Info.plist file exists in GolfX folder
- [ ] `GOLF_API_KEY` added to Info.plist
- [ ] Value is `LLOACD7TDCZ66UQVAOQFUWHRLM`
- [ ] Build is clean (⇧⌘K)
- [ ] App has been rebuilt (⌘B)
- [ ] No warnings in console about missing API key

Once all checked, you're ready to search for courses! 🏌️‍♂️

---

## 🆘 Still Not Working?

If you've followed all steps and it's still not working:

1. Check the Xcode console for error messages
2. Verify the Info.plist file location
3. Make sure you're running the GolfX target (not tests)
4. Try adding the key as a String type, not any other type
5. Check that the key has no extra spaces or newlines

The API client will print helpful debug messages to the console! 

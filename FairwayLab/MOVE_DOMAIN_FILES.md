# 🚨 CRITICAL: Domain Files in Wrong Folder

## The Problem

All your domain files are currently in the **`GolfXUITests`** folder!

Looking at the build log:
```
/Users/g/Documents/projects/GolfX/GolfXUITests/DomainModelsRoundDefinition.swift
/Users/g/Documents/projects/GolfX/GolfXUITests/DomainUtilitiesMockCourseData.swift
/Users/g/Documents/projects/GolfX/GolfXUITests/DomainModelsCalculationInput.swift
/Users/g/Documents/projects/GolfX/GolfXUITests/DomainServicesSkinsCalculator.swift
/Users/g/Documents/projects/GolfX/GolfXUITests/DomainServicesStablefordCalculator.swift
... and many more
```

**These files are in the UI Tests folder, which is completely wrong!**

---

## ✅ What I Already Fixed

I've added `import Combine` to `AppState.swift`. That's done! ✅

---

## 🔧 What YOU Need to Do Now

### Move ALL Domain Files Out of GolfXUITests Folder

**In Finder (easier) or Xcode:**

1. **Open Finder**
2. Navigate to: `/Users/g/Documents/projects/GolfX/GolfXUITests/`
3. **Select ALL files starting with `Domain`**
4. **Move them** to: `/Users/g/Documents/projects/GolfX/GolfX/`

### Files to Move (ALL of these):

From `GolfXUITests/` → to `GolfX/`:

- `DomainModelsRoundDefinition.swift`
- `DomainModelsCalculationInput.swift`
- `DomainServicesKPCalculator.swift`
- `DomainServicesCaraEPerroCalculator.swift`
- `DomainModelsCourse.swift`
- `DomainModelsGameType.swift`
- `DomainModelsPlayer.swift`
- `DomainModelsHandicapMode.swift`
- `DomainModelsTee.swift`
- `DomainModelsRoundState.swift`
- `DomainServicesCalculationInputMapper.swift`
- `DomainServicesSkinsCalculator.swift`
- `DomainServicesStablefordCalculator.swift`
- `DomainServicesHandicapCalculator.swift`
- `DomainServicesNassauCalculator.swift`
- `DomainModelsHoleDefinition.swift`
- `DomainUtilitiesHoleBuilder.swift`
- `DomainUtilitiesMockCourseData.swift`

**Move ALL files that start with `Domain`!**

---

## 📋 Step-by-Step in Finder

1. Open two Finder windows side-by-side
2. **Left window:** Navigate to `/Users/g/Documents/projects/GolfX/GolfXUITests/`
3. **Right window:** Navigate to `/Users/g/Documents/projects/GolfX/GolfX/`
4. In left window, select all `Domain*.swift` files
5. **Drag them** to the right window (GolfX folder)
6. Choose "Move" when prompted (not copy!)

---

## 📋 Alternative: Do It in Xcode

1. In Xcode Project Navigator, find all the `Domain*.swift` files
2. They're probably under the `GolfXUITests` group
3. **Drag each one** to the `GolfX` group
4. When prompted, choose "Move" (not copy)
5. In File Inspector (⌥⌘1), verify Target Membership:
   ```
   ☑ GolfX          ← Should be checked
   ☐ GolfXTests     ← Should be unchecked
   ☐ GolfXUITests   ← Should be unchecked
   ```

---

## 🎯 Expected Result

After moving, your folder structure should be:

```
/Users/g/Documents/projects/GolfX/
├── GolfX/                          ← Domain files should be HERE!
│   ├── GolfXApp.swift
│   ├── AppState.swift
│   ├── DomainModelsPlayer.swift         ✅
│   ├── DomainModelsCourse.swift         ✅
│   ├── DomainModelsTee.swift            ✅
│   ├── DomainModelsHoleDefinition.swift ✅
│   ├── DomainServicesHandicapCalculator.swift ✅
│   ├── DomainServicesSkinsCalculator.swift ✅
│   ├── (all other Domain*.swift files)  ✅
│   └── (all UI files)
│
├── GolfXTests/                     ← Test files
│   ├── GolfXTests.swift
│   ├── TestsHandicapCalculatorTests.swift
│   └── (other test files)
│
└── GolfXUITests/                   ← Should be mostly empty!
    └── GolfXUITests.swift
```

**GolfXUITests folder should NOT contain any Domain files!**

---

## 🔍 Quick Terminal Check

After moving, verify with:

```bash
# Should show NOTHING or very few files:
ls /Users/g/Documents/projects/GolfX/GolfXUITests/Domain*.swift

# Should show ALL domain files:
ls /Users/g/Documents/projects/GolfX/GolfX/Domain*.swift
```

---

## ⚠️ Why This Happened

Somehow all your domain files ended up in the UI tests folder. This might have happened when:
- Files were created in wrong location
- Files were accidentally moved during organization
- Target membership was set incorrectly

**GolfXUITests is ONLY for UI testing files, not domain code!**

---

## 🎯 After Moving Files

1. **Clean build folder** (`⇧⌘K`)
2. **Close Xcode completely** 
3. **Reopen the project**
4. **Build** (`⌘B`)
5. Should work! 🎉

---

## 🆘 If Xcode Shows Red Files After Moving

If files show in red (can't find them):

1. Select the red file in Xcode
2. Open File Inspector (`⌥⌘1`)
3. Click the folder icon next to "Location"
4. Navigate to the new location: `GolfX/` folder
5. Select the file
6. Xcode will reconnect it

---

## Summary

✅ **Done:** Added `import Combine` to AppState.swift

🔧 **You need to do:** Move ALL `Domain*.swift` files from `GolfXUITests/` to `GolfX/`

Then clean, reopen Xcode, and build! 🚀

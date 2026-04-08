# 📸 Screenshot Reference - What You Should See

## When You Open File Inspector (⌥⌘1)

### ✅ CORRECT - Test File Configuration

```
┌────────────────────────────────────────────────────┐
│  File Inspector                                    │
├────────────────────────────────────────────────────┤
│                                                    │
│  Identity and Type                                 │
│    Name: TestsHandicapCalculatorTests.swift        │
│    Type: Swift Source                              │
│    Location: GolfXTests                            │
│                                                    │
│  Target Membership                                 │
│    ☐ GolfX                ← UNCHECKED              │
│    ☑ GolfXTests           ← CHECKED ✅             │
│    ☐ GolfXUITests         ← UNCHECKED              │
│                                                    │
└────────────────────────────────────────────────────┘
```

### ❌ WRONG - What You Currently Have

```
┌────────────────────────────────────────────────────┐
│  File Inspector                                    │
├────────────────────────────────────────────────────┤
│                                                    │
│  Identity and Type                                 │
│    Name: TestsHandicapCalculatorTests.swift        │
│    Type: Swift Source                              │
│    Location: GolfX                  ← WRONG FOLDER │
│                                                    │
│  Target Membership                                 │
│    ☑ GolfX                ← CHECKED (WRONG!)       │
│    ☐ GolfXTests           ← UNCHECKED (WRONG!)     │
│    ☐ GolfXUITests         ← UNCHECKED (OK)         │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## Project Navigator Structure

### ✅ CORRECT Structure

```
GolfX Project
│
├─ 📁 GolfX (App)
│  ├─ 📁 App
│  │  ├─ GolfXApp.swift
│  │  └─ AppState.swift
│  │
│  ├─ 📁 Domain
│  │  ├─ 📁 Models
│  │  │  ├─ Player.swift
│  │  │  ├─ Course.swift
│  │  │  ├─ Tee.swift
│  │  │  └─ HoleDefinition.swift
│  │  │
│  │  ├─ 📁 Services
│  │  │  └─ HandicapCalculator.swift
│  │  │
│  │  └─ 📁 Utilities
│  │     ├─ HoleBuilder.swift
│  │     └─ MockCourseData.swift
│  │
│  └─ 📁 UI
│     └─ (views and viewmodels)
│
├─ 📁 GolfXTests (Unit Tests) ✅
│  ├─ GolfXTests.swift
│  ├─ TestsHandicapCalculatorTests.swift
│  ├─ TestsHoleBuilderTests.swift
│  ├─ TestsSkinsCalculatorTests.swift
│  └─ TestsStablefordCalculatorTests.swift
│
└─ 📁 GolfXUITests (UI Tests) ℹ️ ignore this
   └─ GolfXUITests.swift
```

### ❌ WRONG Structure (What You Might Have)

```
GolfX Project
│
├─ 📁 GolfX (App)
│  ├─ GolfXApp.swift
│  ├─ Player.swift
│  ├─ TestsHandicapCalculatorTests.swift  ❌ WRONG PLACE!
│  ├─ TestsHoleBuilderTests.swift         ❌ WRONG PLACE!
│  └─ ... (other files mixed together)
│
├─ 📁 GolfXTests
│  └─ GolfXTests.swift (only this one)
│
└─ 📁 GolfXUITests
   └─ GolfXUITests.swift
```

---

## Xcode Scheme Selector (Top Left)

### ✅ This is NORMAL (not duplicates!)

```
┌────────────────────────────────────┐
│  GolfX ▼  >  iPhone 15 Pro ▼      │
└────────────────────────────────────┘

When you click "GolfX ▼" you'll see:
  • GolfX          ← Run app
  • GolfXTests     ← Run unit tests
  • GolfXUITests   ← Run UI tests
```

**These are NOT duplicates!** They're different build schemes.

### ❌ This Would Be a Problem

```
When you click "GolfX ▼" you see:
  • GolfX
  • GolfX 2        ← DUPLICATE - DELETE THIS
  • GolfApp        ← DUPLICATE - DELETE THIS
  • GolfXTests
```

---

## Project Targets (When You Click Blue Project Icon)

### ✅ CORRECT - Should Have Exactly 3 Targets

```
┌────────────────────────────────────────────┐
│  PROJECT                                   │
│    ▼ GolfX                                 │
│                                            │
│  TARGETS                                   │
│    ▼ GolfX          ← Main app             │
│    ▼ GolfXTests     ← Unit tests           │
│    ▼ GolfXUITests   ← UI tests             │
│                                            │
└────────────────────────────────────────────┘
```

### ❌ WRONG - Too Many Targets

```
┌────────────────────────────────────────────┐
│  TARGETS                                   │
│    ▼ GolfX                                 │
│    ▼ GolfX 2        ← DELETE THIS          │
│    ▼ GolfApp        ← DELETE THIS          │
│    ▼ GolfXTests                            │
│    ▼ GolfXTests 2   ← DELETE THIS          │
│    ▼ GolfXUITests                          │
│                                            │
└────────────────────────────────────────────┘
```

---

## How to Delete Duplicate Targets

1. Click the **blue project icon** at top of Project Navigator
2. Look at **TARGETS** list
3. **Right-click** duplicate target (like "GolfX 2")
4. Choose **"Delete"**
5. Confirm **"Move to Trash"** (not just "Remove Reference")

---

## Test File Locations in Finder

Open Terminal and run:

```bash
cd /Users/g/Documents/projects/GolfX
find . -name "*.swift" -path "*Tests*" -not -path "*UITests*"
```

### ✅ Should show:

```
./GolfXTests/GolfXTests.swift
./GolfXTests/TestsHandicapCalculatorTests.swift
./GolfXTests/TestsHoleBuilderTests.swift
./GolfXTests/TestsSkinsCalculatorTests.swift
./GolfXTests/TestsStablefordCalculatorTests.swift
```

All in `GolfXTests/` folder!

### ❌ If you see:

```
./GolfX/TestsHandicapCalculatorTests.swift        ← Wrong folder!
./GolfX/TestsHoleBuilderTests.swift               ← Wrong folder!
```

Then files are in wrong physical location.

---

## Quick Actions

### To Fix File in Wrong Folder:

**Option 1: In Xcode (Recommended)**
1. Select file in Project Navigator
2. Drag it into the `GolfXTests` group
3. Choose "Move" when prompted

**Option 2: In Finder + Xcode**
1. Quit Xcode
2. In Finder, move file from `GolfX/` to `GolfXTests/`
3. Open Xcode
4. If file shows in red, right-click → "Show in Finder" → relocate
5. Fix target membership (⌥⌘1)

---

## Summary Checklist

After your changes, verify:

- [ ] All 5 test files are in `GolfXTests` group in Xcode
- [ ] All 5 test files have only `GolfXTests` checked in Target Membership
- [ ] No test files have `GolfX` checked
- [ ] Only 3 targets exist: GolfX, GolfXTests, GolfXUITests
- [ ] No duplicate schemes or targets
- [ ] Files are physically in `GolfXTests/` folder (verify in Finder)

Then:
- [ ] ⇧⌘K (Clean)
- [ ] ⌘B (Build)
- [ ] Should build successfully!

---

## Still Not Sure?

**Run this diagnostic:**

```bash
cd /Users/g/Documents/projects/GolfX

echo "=== CURRENT TEST FILE LOCATIONS ==="
find . -name "Tests*.swift" -type f

echo "\n=== PROJECT STRUCTURE ==="
ls -la

echo "\n=== TARGETS ==="
xcodebuild -list -project GolfX.xcodeproj 2>/dev/null | grep -A 10 "Targets:"
```

Share the output and I'll tell you exactly what's wrong!

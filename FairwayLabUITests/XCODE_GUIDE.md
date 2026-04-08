# Xcode Project Organization Guide

## File Structure in Xcode

When adding files to your Xcode project, organize them in groups matching this structure:

```
GolfX/
├── App/
│   ├── GolfXApp.swift
│   ├── AppState.swift
│   └── ContentView.swift (legacy)
│
├── Domain/
│   ├── Models/
│   │   ├── Player.swift
│   │   ├── Course.swift
│   │   ├── Tee.swift
│   │   ├── HoleDefinition.swift
│   │   ├── GameType.swift
│   │   ├── HandicapMode.swift
│   │   ├── RoundDefinition.swift
│   │   ├── RoundState.swift
│   │   └── CalculationInput.swift
│   │
│   ├── Services/
│   │   ├── HandicapCalculator.swift
│   │   ├── StablefordCalculator.swift
│   │   ├── SkinsCalculator.swift
│   │   ├── NassauCalculator.swift
│   │   ├── KPCalculator.swift
│   │   ├── CaraEPerroCalculator.swift
│   │   └── CalculationInputMapper.swift
│   │
│   └── Utilities/
│       ├── HoleBuilder.swift
│       └── MockCourseData.swift
│
├── UI/
│   ├── Views/
│   │   ├── HomeView.swift
│   │   │
│   │   ├── Setup/
│   │   │   ├── SetupWizardView.swift
│   │   │   ├── PlayersSetupView.swift
│   │   │   ├── RoundDetailsSetupView.swift
│   │   │   ├── GamesSetupView.swift
│   │   │   └── ReviewSetupView.swift
│   │   │
│   │   ├── Play/
│   │   │   └── RoundPlayView.swift
│   │   │
│   │   └── Results/
│   │       ├── ResultsHubView.swift
│   │       ├── KPDetailView.swift
│   │       ├── NassauDetailView.swift
│   │       └── CaraEPerroDetailView.swift
│   │
│   └── ViewModels/
│       ├── SetupWizardViewModel.swift
│       └── ResultsViewModel.swift
│
├── Tests/
│   ├── HandicapCalculatorTests.swift
│   ├── StablefordCalculatorTests.swift
│   ├── SkinsCalculatorTests.swift
│   ├── HoleBuilderTests.swift
│   └── CaraEPerroCalculatorTests.swift
│
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

## Adding Files to Xcode

### Method 1: Create Groups First
1. Right-click on GolfX folder in Project Navigator
2. Select "New Group"
3. Name it (e.g., "Domain")
4. Repeat for all groups
5. Drag files from Finder into appropriate groups

### Method 2: Import with Folder Structure
1. File → Add Files to "GolfX"
2. Select the Domain folder
3. Check "Create groups"
4. Click Add

### Important Settings

When adding files, ensure:
- ✅ **Target Membership**: GolfX (main app target)
- ✅ **Test files**: GolfXTests target
- ✅ **Group**: Matches folder structure
- ✅ **Location**: Relative to project

## File Headers

All Swift files should have this header:

```swift
//
//  FileName.swift
//  GolfX
//
//  Brief description of file purpose
//
```

## Naming Conventions

### Files
- **Models**: Noun, singular (Player.swift, Course.swift)
- **Services**: Noun + Calculator/Mapper (HandicapCalculator.swift)
- **Views**: Noun + View (HomeView.swift)
- **ViewModels**: Noun + ViewModel (SetupWizardViewModel.swift)
- **Tests**: FileName + Tests (HandicapCalculatorTests.swift)

### Types
- **Structs**: PascalCase (Player, RoundState)
- **Enums**: PascalCase (GameType, HandicapMode)
- **Protocols**: PascalCase, often ends in -able or -ing
- **Classes**: PascalCase (AppState)

### Variables/Functions
- **Properties**: camelCase (handicapMode, isNineHole)
- **Functions**: camelCase, verb-based (calculateHandicap, buildHoles)
- **Constants**: camelCase (sampleTee1)
- **Static/Class**: camelCase (MockCourseData.allCourses)

## Target Configuration

### Main App Target (GolfX)
Include:
- App/
- Domain/
- UI/

Exclude:
- Tests/

### Test Target (GolfXTests)
Include:
- Tests/
- Need access to app code: Set "Enable Testing" on main target

### Build Settings

**Deployment Target**: iOS 17.0
**Swift Version**: Swift 5
**Optimization**: 
- Debug: None
- Release: Optimize for Speed

## Scheme Configuration

### GolfX Scheme
- **Build**: All targets
- **Run**: Debug configuration
- **Test**: Run all test plans
- **Archive**: Release configuration

## Dependencies

**None!** This project has:
- ✅ Zero external dependencies
- ✅ Pure SwiftUI
- ✅ Standard library only
- ✅ No CocoaPods
- ✅ No SPM packages
- ✅ No Carthage

## Info.plist Keys

Recommended additions:

```xml
<key>UILaunchScreen</key>
<dict>
    <key>UIImageName</key>
    <string>LaunchIcon</string>
</dict>

<key>CFBundleDisplayName</key>
<string>GolfX</string>

<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arm64</string>
</array>
```

## Assets Catalog

Recommended organization:

```
Assets.xcassets/
├── AppIcon.appiconset/
├── AccentColor.colorset/
├── Icons/
│   ├── Golf.imageset/
│   └── Scorecard.imageset/
└── Colors/
    ├── Primary.colorset/
    └── Secondary.colorset/
```

## Code Signing

**Development**:
- Team: Your Apple Developer Team
- Signing: Automatic
- Provisioning Profile: Automatic

**Distribution**:
- Archive with Release configuration
- Export for App Store or Ad Hoc

## Build Phases

Standard phases:
1. Dependencies
2. Compile Sources
3. Link Binary
4. Copy Bundle Resources

No custom scripts needed!

## Testing Configuration

### Test Plan
- All tests enabled
- Code coverage enabled
- Diagnostics: Address Sanitizer (optional)

### Coverage Targets
- Domain layer: >90%
- Services: >95%
- UI: Not measured (manual testing)

## Performance Optimization

### Recommended Settings
- **Whole Module Optimization**: Enabled (Release)
- **LTO**: Incremental (Release)
- **Dead Code Stripping**: Yes
- **Strip Swift Symbols**: Yes (Release)

### Build Time Optimization
- **Incremental Builds**: Enabled
- **Build Active Architecture Only**: Yes (Debug)
- **Parallel Build**: Yes

## Common Issues

### "Cannot find type X in scope"
- Check file is in correct target
- Clean build folder (Cmd+Shift+K)
- Rebuild (Cmd+B)

### "Duplicate symbol"
- Check file isn't added twice
- Check no duplicate imports
- Clean derived data

### Tests not running
- Verify test target membership
- Check scheme includes tests
- Enable testing on main target

## Quick Commands

```bash
# Clean build folder
Cmd+Shift+K

# Build
Cmd+B

# Run
Cmd+R

# Test
Cmd+U

# Clean derived data
Xcode → Preferences → Locations → Derived Data → Delete
```

## Git Setup

### .gitignore

```gitignore
# Xcode
*.xcodeproj/project.xcworkspace/xcuserdata/
*.xcodeproj/xcuserdata/
*.xcworkspace/xcuserdata/
DerivedData/
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.build/
Packages/
Package.pins
Package.resolved

# CocoaPods (not used, but just in case)
Pods/

# Fastlane (if added later)
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output
```

## Recommended Xcode Settings

### Preferences → Text Editing
- ✅ Line numbers
- ✅ Code folding ribbon
- ✅ Page guide at column: 100
- ✅ Automatically trim trailing whitespace
- ✅ Including whitespace-only lines

### Preferences → Navigation
- ✅ Uses Focused Editor
- ✅ Double Click Navigation: Uses Primary Editor

### Preferences → Behaviors
- On Build Success: Show tab "Build"
- On Build Failed: Show tab "Build"
- On Test Success: Show tab "Test"
- On Test Failed: Show tab "Test" + Show debugger

## Documentation

Use DocC for documentation:

```swift
/// Calculate course handicap for a player
///
/// Uses the standard USGA formula:
/// `handicapIndex × slope / 113 + (courseRating - par)`
///
/// - Parameters:
///   - handicapIndex: Player's handicap index
///   - slope: Course slope rating
///   - courseRating: Course rating
///   - par: Par for the course
/// - Returns: Calculated course handicap, rounded to nearest integer
static func calculateCourseHandicap(
    handicapIndex: Double,
    slope: Int,
    courseRating: Double,
    par: Int
) -> Int
```

## Build & Archive

### Creating a Build
1. Product → Archive
2. Window → Organizer
3. Select archive
4. Distribute App
5. Choose method (App Store, Ad Hoc, etc.)

### Version Numbering
- **Version**: 1.0.0 (semantic versioning)
- **Build**: Auto-increment for each archive

---

This organization keeps the project clean, maintainable, and easy to navigate!

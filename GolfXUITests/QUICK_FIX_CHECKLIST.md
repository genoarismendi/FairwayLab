# 🚨 QUICK FIX CHECKLIST

## Your Error
```
error: Unable to find module dependency: 'XCTest'
```

## Root Cause
**Test files are in the app target instead of test target**

---

## 🎯 SIMPLE ANSWER: Use GolfXTests (NOT GolfXUITests)

You asked about **GolfXTests** vs **GolfXUITests**:

```
✅ GolfXTests      ← Use THIS ONE for all your test files
❌ GolfXUITests    ← Ignore this, it's for UI testing only
```

**All 5 test files belong in the `GolfXTests` target.**

---

## 5-Minute Fix

### For Each Test File:

#### Files to Fix:
1. `GolfXTests.swift`
2. `TestsHandicapCalculatorTests.swift`
3. `TestsHoleBuilderTests.swift`
4. `TestsSkinsCalculatorTests.swift` ⚠️ Also needs code conversion
5. `TestsStablefordCalculatorTests.swift` ⚠️ Also needs code conversion

#### Steps:
1. ✅ Click file in Project Navigator
2. ✅ Open File Inspector (`⌥⌘1`)
3. ✅ Find "Target Membership"
4. ✅ **UNCHECK** `GolfX`
5. ✅ **CHECK** `GolfXTests` (the one WITHOUT "UI" in the name)
6. ✅ **UNCHECK** `GolfXUITests` (if it's checked)

---

## Additional: Convert Remaining Test Files

### TestsSkinsCalculatorTests.swift

**Open the file and change:**

```swift
// BEFORE
import Testing
@testable import GolfX

@Suite("Skins Calculator Tests")
struct SkinsCalculatorTests {
    
    @Test("Calculate skins with ties")
    func testSkinsWithTies() async throws {
        // test code...
        #expect(result.totalSkins[player1] == 5)
    }
}
```

```swift
// AFTER
import XCTest
@testable import GolfX

final class SkinsCalculatorTests: XCTestCase {
    
    func testSkinsWithTies() async throws {
        // test code...
        XCTAssertEqual(result.totalSkins[player1], 5)
    }
}
```

### TestsStablefordCalculatorTests.swift

**Same replacements:**
- `import Testing` → `import XCTest`
- `@Suite("...")` → Delete
- `struct` → `final class XCTestCase`
- `@Test("...")` → Delete decorator
- `#expect(a == b)` → `XCTAssertEqual(a, b)`
- `#expect(condition)` → `XCTAssertTrue(condition)`

---

## Verify Fix

```bash
⇧⌘K  # Clean
⌘B   # Build - should succeed now
⌘U   # Run tests
```

**Expected:** ✅ Build succeeds, tests run

---

## If Still Broken

1. Check **all 5 test files** have correct target membership
2. Verify none have **both** targets checked
3. Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/GolfX*`
4. Restart Xcode
5. Try again

---

## Key Insight

```
App Target:      ❌ Cannot import XCTest
Test Target:     ✅ Can import XCTest
```

Your test files are currently in the App Target (wrong place).

---

See `XCODE_TARGET_MEMBERSHIP_GUIDE.md` for detailed visual guide.

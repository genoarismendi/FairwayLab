# ✨ Auto-Scroll Feature for Score Entry

## 🎯 Overview

I've added an **automatic scrolling feature** to the score entry screen that automatically moves focus and scrolls to the next input field when you enter a value. This is perfect for your Python script automation!

---

## 📝 What Was Added

### **1. Focus Management**
```swift
@FocusState private var focusedField: String?
```
- Tracks which TextField is currently focused
- Each field has a unique identifier like `"strokes-{holeID}-{playerID}"`

### **2. Scroll Position Control**
```swift
ScrollViewReader { proxy in
    // List content
}
```
- Wraps the List in a ScrollViewReader
- Provides a proxy to programmatically scroll to any section

### **3. Auto-Advance Logic**
When a value is entered:
1. **Strokes field** → Moves to **Putts field** (same player)
2. **Putts field** → Moves to **Strokes field** (next player)
3. **Last player's putts** → Scrolls to **next hole**

---

## 🔄 How It Works

### **Flow Example:**

```
Player 1 Strokes → Player 1 Putts
                     ↓
Player 2 Strokes → Player 2 Putts
                     ↓
Player 3 Strokes → Player 3 Putts
                     ↓
[Scroll to Next Hole] → Player 1 Strokes (Hole 2)
```

---

## 🤖 Perfect for Your Python Script!

When your Python script pastes values into the fields, the app will:

✅ **Automatically advance** to the next field  
✅ **Auto-scroll** to keep the active field visible  
✅ **Navigate** through all players smoothly  
✅ **Jump to next hole** when current hole is complete

---

## 🎮 User Experience

### **Manual Entry:**
- Tap a field → Enter score → Automatically moves to next field
- No need to manually tap each field
- Smooth scrolling keeps everything visible

### **Script Entry:**
- Script pastes value → Field automatically advances
- Screen scrolls to show the next input
- Fast, efficient data entry

---

## ⚡ Technical Details

### **Field Identifiers:**
Each field has a unique ID:
- Strokes: `"strokes-{holeID}-{playerID}"`
- Putts: `"putts-{holeID}-{playerID}"`
- Hole sections: `"hole-{holeID}"`

### **Timing:**
```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    // Move focus to next field
}
```
- Small delay (0.1s) ensures UI updates smoothly
- Prevents race conditions with keyboard

### **Scrolling:**
```swift
withAnimation {
    scrollProxy.scrollTo("hole-{holeID}", anchor: .top)
}
```
- Animated scroll to next section
- Anchor at top for best visibility

---

## 📱 Usage

### **For Python Script:**

Your script can simply:
1. **Paste** stroke value → App auto-advances to putts
2. **Paste** putts value → App auto-advances to next player
3. **Repeat** for all players
4. **Auto-scroll** to next hole happens automatically

### **No Extra Code Needed!**

The app handles all navigation automatically when values are changed.

---

## 🎯 Benefits

✅ **Faster data entry** - No manual navigation  
✅ **Better UX** - Smooth, intuitive flow  
✅ **Script-friendly** - Works perfectly with automation  
✅ **Always visible** - Auto-scrolls to keep active field on screen  
✅ **Smart navigation** - Knows when to move to next hole  

---

## 🔍 Code Changes

### **Files Modified:**
- `UIViewsPlayRoundPlayView.swift`

### **Key Additions:**
1. `@FocusState` for focus tracking
2. `ScrollViewReader` for scroll control
3. Auto-advance logic in `scrollToNextField()`
4. Field ID system for unique identification

---

## ✨ Future Enhancements (Optional)

You could add:
- **"Previous" button** to go back a field
- **Shake to undo** last entry
- **Voice input** with auto-advance
- **Quick-fill buttons** (par, birdie, bogey) with auto-advance
- **Swipe gestures** to navigate holes

---

## 🎉 Result

**Now when you use your Python script** to paste scores, the app will automatically flow through all the fields, scrolling as needed to keep everything visible!

Try it out! 🏌️‍♂️⛳

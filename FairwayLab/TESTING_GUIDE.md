# Testing Guide for Cara 'e Perro Modifications

## Overview
This guide provides step-by-step testing scenarios to verify all new features work correctly.

---

## ✅ Test Scenarios

### Test 1: Zero Putts Bonus

**Objective**: Verify that players receive +1 point for holing out with 0 putts

**Steps**:
1. Start a new round with 2+ players
2. On Hole 1:
   - Player A: 4 strokes, 0 putts
   - Player B: 5 strokes, 2 putts
3. Calculate results
4. View Cara 'e Perro details

**Expected Results**:
- ✅ Player A should show +1 bonus for zero putts in hole detail
- ✅ Zero putt bonus should be included in hole points
- ✅ Player A total points = base points + 1

**Pass/Fail**: ___________

---

### Test 2: Front Nine Winner Bonus

**Objective**: Verify front nine winner gets +1 point based on NET score

**Setup**: 18-hole round with 2+ players having different handicaps

**Steps**:
1. Enter scores for holes 1-9
   - Example: Player A (HCP 10): Net 38
   - Example: Player B (HCP 15): Net 40
2. Enter scores for holes 10-18
3. Calculate results
4. View Cara 'e Perro results

**Expected Results**:
- ✅ "Nine Winners" section appears
- ✅ Front nine winner is correctly identified (lowest net score)
- ✅ Winner receives +1 point shown in breakdown
- ✅ If tie, no winner awarded

**Pass/Fail**: ___________

---

### Test 3: Back Nine Winner Bonus

**Objective**: Verify back nine winner gets +1 point based on NET score

**Setup**: 18-hole round with 2+ players

**Steps**:
1. Enter scores for all 18 holes
   - Ensure different net scores for holes 10-18
2. Calculate results

**Expected Results**:
- ✅ Back nine winner shown in "Nine Winners" section
- ✅ Winner receives +1 point
- ✅ If tie, no winner awarded
- ✅ For 9-hole rounds, only relevant nine shows winner

**Pass/Fail**: ___________

---

### Test 4: Snake Penalty (End of Round)

**Objective**: Verify player with most putts awards 1 point to all others

**Steps**:
1. Start round with 3 players
2. Enter varied putt counts:
   - Player A: Total 25 putts
   - Player B: Total 30 putts (most)
   - Player C: Total 28 putts
3. Calculate results

**Expected Results**:
- ✅ "Snake Penalty" section appears in results
- ✅ Player B identified as snake holder
- ✅ Player A receives +1 point (from snake)
- ✅ Player C receives +1 point (from snake)
- ✅ Player B does NOT receive extra points
- ✅ If tie for most putts, no snake holder

**Pass/Fail**: ___________

---

### Test 5: Snake Visual Indicator (Live)

**Objective**: Verify 🐍 emoji appears next to player with most putts

**Steps**:
1. Start new round with 2 players
2. On Hole 1:
   - Player A: 3 putts
   - Player B: 1 putt
3. Scroll to Hole 2
4. On Hole 2:
   - Player A: 1 putt (total: 4)
   - Player B: 4 putts (total: 5)
5. Scroll to Hole 3

**Expected Results**:
- ✅ After Hole 1: Player A shows 🐍
- ✅ After Hole 2: Player B shows 🐍
- ✅ Snake emoji updates in real-time
- ✅ If tie for most putts, no 🐍 shown
- ✅ Snake emoji appears on every hole section

**Pass/Fail**: ___________

---

### Test 6: Pig Indicator - Front Nine

**Objective**: Verify 🐷 appears when player doesn't make par on front nine

**Steps**:
1. Start 18-hole round
2. Player A on holes 1-9: All scores > par
3. Player B on holes 1-9: One score = par, others > par
4. Navigate through holes and observe

**Expected Results**:
- ✅ Player A shows 🐷 after failing to make par
- ✅ Player B does NOT show 🐷 after making one par
- ✅ Pig appears on all holes once condition is met
- ✅ Pig disappears when player makes par

**Pass/Fail**: ___________

---

### Test 7: Pig Indicator - Both Nines

**Objective**: Verify 🐷🐷 for failing to make par on both nines

**Steps**:
1. 18-hole round
2. Player A: No par on holes 1-9, no par on holes 10-18
3. Player B: No par on holes 1-9, one par on holes 10-18
4. Player C: One par on holes 1-9, no par on holes 10-18

**Expected Results**:
- ✅ Player A shows 🐷 after hole 9, then 🐷🐷 after hole 18
- ✅ Player B shows 🐷 after hole 9, keeps only 🐷 after making par on back
- ✅ Player C never shows pig on front, shows 🐷 on back nine
- ✅ For 9-hole rounds, only one pig maximum

**Pass/Fail**: ___________

---

### Test 8: Picker Wheel UI - Strokes

**Objective**: Verify strokes picker works correctly

**Steps**:
1. Start new round
2. Navigate to Hole 1, Player 1
3. Interact with Strokes picker:
   - Scroll through values
   - Select "-" (0)
   - Select "7"
   - Select "15"

**Expected Results**:
- ✅ Picker displays values from "-" to "15"
- ✅ Picker is ~80pt wide
- ✅ Picker is ~100pt tall
- ✅ Selecting "-" sets value to nil
- ✅ Selected value persists when scrolling away and back
- ✅ Wheel style picker (not menu/segmented)

**Pass/Fail**: ___________

---

### Test 9: Picker Wheel UI - Putts

**Objective**: Verify putts picker works correctly

**Steps**:
1. Navigate to any hole
2. Interact with Putts picker:
   - Scroll through values
   - Select "-" 
   - Select "0"
   - Select "8"

**Expected Results**:
- ✅ Picker displays values from "-" and "0" to "8"
- ✅ Picker is ~60pt wide (smaller than strokes)
- ✅ Picker is ~100pt tall
- ✅ Selecting "-" sets value to nil
- ✅ Value "0" is valid (for chip-ins)
- ✅ Selected value persists

**Pass/Fail**: ___________

---

### Test 10: Combined Points Calculation

**Objective**: Verify all point sources combine correctly

**Setup**: 18-hole round, 3 players

**Scenario**:
- Player A:
  - Base points: +5
  - Zero putts on hole 3: +1
  - Front nine winner: +1
  - Snake penalty received: +1
  - **Expected Total: +8**

- Player B:
  - Base points: +3
  - Back nine winner: +1
  - Snake penalty received: +1
  - **Expected Total: +5**

- Player C (snake holder):
  - Base points: +4
  - Most putts (30 total)
  - Gives points to A and B (no bonus for self)
  - **Expected Total: +4**

**Steps**:
1. Enter scores matching scenario
2. Calculate results
3. Verify point totals

**Expected Results**:
- ✅ All point sources shown in detail view
- ✅ Final totals match expected values
- ✅ Nine winner bonuses applied
- ✅ Snake penalty applied correctly

**Pass/Fail**: ___________

---

## 🧪 Edge Cases to Test

### Edge Case 1: Tie for Front Nine Winner
- Two players with same net score on front nine
- **Expected**: No front nine bonus awarded to anyone

### Edge Case 2: Tie for Snake
- Multiple players with same highest putt count
- **Expected**: No snake holder, no penalty applied, no 🐍 shown

### Edge Case 3: 9-Hole Round (Front)
- Only 9 holes played (holes 1-9)
- **Expected**: 
  - Front nine winner can be awarded
  - Back nine winner section not shown
  - Only one 🐷 possible

### Edge Case 4: 9-Hole Round (Back)
- Only 9 holes played (holes 10-18)
- **Expected**: 
  - Back nine winner can be awarded
  - Front nine winner section not shown

### Edge Case 5: All Players Make Par
- Every player makes at least one par on each nine
- **Expected**: No 🐷 emojis shown for anyone

### Edge Case 6: Player With Zero Putts on Multiple Holes
- Player A gets 0 putts on holes 3, 7, and 12
- **Expected**: +1 bonus for each hole (total +3 bonus points)

---

## 📋 Checklist Summary

### Core Features
- [ ] Zero putts bonus (+1 point per hole)
- [ ] Front nine winner bonus (+1 point)
- [ ] Back nine winner bonus (+1 point)
- [ ] Snake penalty (most putts gives 1 to others)
- [ ] Snake visual indicator 🐍 (live updates)
- [ ] Pig indicator 🐷 (no par on front nine)
- [ ] Pig indicator 🐷🐷 (no par on both nines)
- [ ] Strokes picker wheel (1-15)
- [ ] Putts picker wheel (0-8)

### UI/UX
- [ ] Emojis display correctly
- [ ] Pickers are appropriately sized
- [ ] Scores persist when navigating
- [ ] Real-time indicator updates
- [ ] Detail view shows all bonuses/penalties
- [ ] Nine winners section appears when applicable

### Edge Cases
- [ ] Ties handled correctly (no winner)
- [ ] 9-hole rounds work properly
- [ ] Multiple zero-putt holes accumulate bonuses
- [ ] Par tracking works correctly per nine

---

## 🐛 Bug Reporting Template

If you find an issue, document it here:

**Bug #**: ___
**Feature**: _______________
**Description**: 


**Steps to Reproduce**:
1. 
2. 
3. 

**Expected Behavior**: 


**Actual Behavior**: 


**Screenshot/Video**: 


**Priority**: [ ] High [ ] Medium [ ] Low

---

## 📝 Notes

- Test on both 9-hole and 18-hole rounds
- Test with various handicap combinations
- Test with 2, 3, and 4 players
- Verify calculations match manual calculations
- Check performance with rapid picker scrolling
- Ensure emojis display on all device sizes

---

**Test Date**: _____________
**Tester Name**: _____________
**Version**: 1.0
**Platform**: iOS ___  /  iPadOS ___
**Device**: _____________
**Overall Result**: [ ] PASS [ ] FAIL [ ] NEEDS REVIEW

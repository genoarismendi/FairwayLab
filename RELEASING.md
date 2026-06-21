# TestFlight Release Procedure

Quick reference for publishing a new version to TestFlight from Xcode.

---

## Before you start

Two numbers matter for every release:

| Field | Where it shows | Rule |
|-------|---------------|------|
| **Marketing Version** (e.g. 1.2) | Shown to testers in TestFlight | Increment when you want users to see a new version number |
| **Build Number** (e.g. 3) | Internal only | Must be higher than the previous upload — Apple rejects duplicates |

---

## Step-by-step

### 1. Bump the version numbers in Xcode

1. In the Project Navigator, click the **FairwayLab** project (top of the list, blue icon)
2. Under **Targets**, select **FairwayLab**
3. Open the **General** tab
4. Under **Identity**:
   - Set **Version** → `1.2`
   - Set **Build** → next integer (e.g. if last upload was build 2, set `3`)

### 2. Select a real device destination

In the scheme selector at the top of the Xcode window (next to the play/stop buttons), change the destination from any simulator to:

```
Any iOS Device (arm64)
```

You cannot archive for a simulator.

### 3. Archive the app

```
Product → Archive
```

This builds a release version of the app. It takes a minute or two. When it finishes, the **Organizer** window opens automatically.

### 4. Distribute from Organizer

1. Your new archive appears at the top of the list (sorted by date)
2. Click **Distribute App**
3. Choose **App Store Connect** → **Next**
4. Choose **Upload** → **Next**
5. Leave the default options (bitcode, symbols) → **Next**
6. Review the summary → **Upload**
7. Wait for the upload confirmation (~1 min)

### 5. Wait for processing in App Store Connect

Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com):

1. Select your app → **TestFlight** tab
2. The new build appears under **iOS Builds** with status **"Processing"**
3. Processing takes ~5–15 minutes. Apple sends an email when it's ready.
4. If prompted about **Export Compliance**, answer the encryption question (usually "No" for a golf scoring app)

### 6. Enable the build for testing

**Internal testers** (your Apple Developer team, up to 100 people):
- No review required
- Click the build → toggle on **Enable for Internal Testing**
- Testers get a notification in the TestFlight app

**External testers** (anyone with a link or email invite, up to 10,000):
- Requires **Beta App Review** (~24 hours, first time per app)
- Go to **External Groups** → add the build → **Submit for Review**

---

## Version history

| Version | Build | Date | Notes |
|---------|-------|------|-------|
| 1.0 | 1 | — | Initial release |
| 1.1 | 2 | — | Name update |
| 1.2 | 3 | 2026-06-21 | Cara 'e Perro bonuses, wheel pickers, snake/pig indicators, persistence, player defaults |

---

## Common issues

| Problem | Fix |
|---------|-----|
| "Archive" is greyed out | Destination must be a real device, not a simulator |
| Build rejected — duplicate build number | Increment the Build number and re-archive |
| Build stuck on "Processing" | Normal, wait up to 15 min. Check email for error notification |
| Testers don't see the new build | Make sure you clicked "Enable for Internal Testing" on the specific build |

Build [


================================================================================
              FLASHY — FLUTTER MOBILE APP MASTER PROMPT v2.0
         A Modern File Manager + Google Drive Virtual Disk for Android & iOS
================================================================================

VERSION: 2.0 (Firebase Auth Edition)
FRAMEWORK: Flutter (Dart) — Cross-platform Android & iOS
AUTH: Firebase Authentication (Google Sign-In) — NO other Firebase services used
STORAGE: Google Drive API v3 (user's own 15GB free Drive)
BACKEND: NONE — fully local + Google APIs only

================================================================================
                    SECTION 0: FIREBASE PROJECT CREDENTIALS
================================================================================

The app is already registered on Firebase. Use these exact credentials.
DO NOT change the package name or any IDs below.

ANDROID — google-services.json:
Place this file at: android/app/google-services.json

EXACT CONTENT OF google-services.json:
{
  "project_info": {
    "project_number": "358745552808",
    "project_id": "flashy-647b2",
    "storage_bucket": "flashy-647b2.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:358745552808:android:990479a55ef5650ea74f9d",
        "android_client_info": {
          "package_name": "com.flashy.com"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIzaSyCLiobfRppuJNWjG_mlU6F0EdHNzqTJvMU"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}

ANDROID PACKAGE NAME: com.flashy.com
FIREBASE PROJECT ID: flashy-647b2
FIREBASE PROJECT NUMBER: 358745552808
APP ID (Android): 1:358745552808:android:990479a55ef5650ea74f9d

iOS — GoogleService-Info.plist:
Download from Firebase Console → Project Settings → iOS app (add iOS app if not added yet)
Place at: ios/Runner/GoogleService-Info.plist
iOS Bundle ID should match: com.flashy.com (or com.flashy.app — set in Xcode)

IMPORTANT SETUP STEPS (developer does once):
  1. In Firebase Console (console.firebase.google.com) → flashy-647b2 project
  2. Go to Authentication → Sign-in method → Enable "Google"
  3. Set project support email
  4. In Google Cloud Console → same project → Enable "Google Drive API"
  5. In OAuth consent screen → add Drive scope:
     https://www.googleapis.com/auth/drive.file
  6. That's it — no other Firebase services needed (no Firestore, no Storage, nothing)

ANDROID build.gradle SETUP:

  android/build.gradle (project level) — add to dependencies:
    classpath 'com.google.gms:google-services:4.4.2'

  android/app/build.gradle (app level):
    - applicationId must be: "com.flashy.com"
    - minSdkVersion: 23
    - Add at BOTTOM of file: apply plugin: 'com.google.gms.google-services'

================================================================================
                         SECTION 1: CORE CONCEPT
================================================================================

Build a mobile app called "Flashy" — a minimal, modern file manager that gives
users TWO things in ONE app:

  1. A full LOCAL DEVICE FILE MANAGER (like ZArchiver but cleaner and modern)
  2. A "Flashy Disk" — a virtual cloud disk powered by the user's FREE Google
     Drive storage (15GB), shown at the TOP of the app like a special drive

The app must feel NATIVE, SMOOTH, and FAST. Zero gradients. Flat solid colors.
Buttery animations. Minimal UI. Every pixel intentional.

KEY PHILOSOPHY:
  - Firebase used ONLY for Google Sign-In authentication
  - NO Firestore, NO Firebase Storage, NO Firebase Realtime Database
  - All files live in user's own Google Drive (their 15GB free storage)
  - Local file management works 100% OFFLINE
  - Cloud (Flashy Disk) gracefully shows warnings when offline
  - No custom server, no backend — fully self-contained app

App name: Flashy
App tagline: "Your files. Lightning fast."
App icon: Lightning bolt, solid electric blue (#2563EB), flat design, no gradient

================================================================================
                      SECTION 2: TECH STACK (MANDATORY)
================================================================================

AUTHENTICATION (Firebase — login only):
  firebase_core: ^3.x
  firebase_auth: ^5.x
  google_sign_in: ^6.x

GOOGLE DRIVE ACCESS:
  googleapis: ^12.x              — Drive API v3 Dart client
  extension_google_sign_in_as_googleapis_auth: ^2.x
    (converts GoogleSignIn auth to googleapis HTTP client — the official bridge)

FILE SYSTEM (local files):
  path_provider: ^2.x
  permission_handler: ^11.x
  file_picker: ^8.x
  open_file: ^3.x
  share_plus: ^9.x
  archive: ^3.x                  — ZIP/TAR compression and extraction

LOCAL CACHE (no Firebase DB — pure local SQLite):
  sqflite: ^2.x                  — SQLite for Drive metadata cache
  shared_preferences: ^2.x       — Settings and preferences
  flutter_secure_storage: ^9.x   — Encrypted token/session storage

UI & ANIMATION:
  animations: ^2.x               — Material motion (container transform)
  flutter_animate: ^4.x          — Chainable declarative animations
  lottie: ^3.x                   — Lottie JSON for loading/empty states
  shimmer: ^3.x                  — Skeleton loading shimmer effect
  modal_bottom_sheet: ^3.x       — Smooth cupertino + material bottom sheets

UTILITIES:
  intl: ^0.19.x                  — Date/number formatting
  mime: ^1.x                     — MIME type detection
  connectivity_plus: ^6.x        — Network status
  flutter_local_notifications: ^17.x — Upload/download notifications
  wakelock_plus: ^1.x            — Keep screen on during large transfers
  receive_sharing_intent: ^2.x   — Receive files from other apps
  cached_network_image: ^3.x     — Cached Drive thumbnails

STATE MANAGEMENT:
  flutter_riverpod: ^2.x         — All state management
  go_router: ^13.x               — Navigation/routing

================================================================================
                SECTION 3: AUTHENTICATION FLOW (FIREBASE GOOGLE SIGN-IN)
================================================================================

HOW IT WORKS:

The user sees ONE button: "Continue with Google"
Tapping it shows the NATIVE Google account picker — listing ALL Google accounts
already signed into the device. User taps their account. Done.
No password. No email field. No manual OAuth URL. Pure native experience.

IMPLEMENTATION:

  // auth_service.dart
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:google_sign_in/google_sign_in.dart';
  import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
  import 'package:googleapis/drive/v3.dart' as drive;

  class AuthService {
    
    // GoogleSignIn instance with Drive scope
    // This scope = app only accesses files IT creates (user trust ✅)
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
        drive.DriveApi.driveFileScope,
        // driveFileScope = 'https://www.googleapis.com/auth/drive.file'
      ],
    );

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    // SIGN IN — shows native account picker with all device accounts
    Future<UserCredential?> signInWithGoogle() async {
      // Trigger the native Google account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      // Get auth details from the selected account
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign into Firebase with the Google credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential;
    }

    // Get googleapis HTTP client for Drive API calls
    Future<drive.DriveApi?> getDriveApi() async {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return null;
      return drive.DriveApi(httpClient);
    }

    // SILENT SIGN IN — auto-login on app launch if previously signed in
    Future<bool> silentSignIn() async {
      try {
        final googleUser = await _googleSignIn.signInSilently();
        if (googleUser == null) return false;
        
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
        return true;
      } catch (e) {
        return false;
      }
    }

    // SIGN OUT — clears everything
    Future<void> signOut() async {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    }

    // Current user info
    User? get currentUser => _firebaseAuth.currentUser;
    Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
    
    // Google account for profile photo, email
    GoogleSignInAccount? get googleAccount => _googleSignIn.currentUser;
  }

MAIN.DART INITIALIZATION:

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      // DefaultFirebaseOptions generated by FlutterFire CLI from google-services.json
    );
    runApp(const ProviderScope(child: FlashyApp()));
  }

  // Run FlutterFire CLI to generate firebase_options.dart:
  // dart pub global activate flutterfire_cli
  // flutterfire configure --project=flashy-647b2

TOKEN REFRESH:
  google_sign_in handles token refresh automatically.
  On app launch: call silentSignIn() before showing any content.
  If silentSignIn() returns false → show login screen.
  If true → proceed directly to home screen.

AUTH STATE LISTENING (in app.dart):
  Use FirebaseAuth.instance.authStateChanges() stream.
  If user is null → show LoginScreen.
  If user is not null → show HomeScreen.
  GoRouter uses this stream for redirect logic.

ACCOUNT PICKER BEHAVIOR:
  When user taps "Continue with Google":
    - If device has 1 Google account: goes straight to permission consent
    - If device has multiple Google accounts: shows list of all accounts
      User sees: profile photo + name + email for each account
      User taps one → that account's Drive is used as Flashy Disk
    - Native Google UI — Flashy does NOT build a custom account picker
    - This is the standard Android/iOS Google account chooser

SIGN OUT FLOW:
  From Settings → Account → Sign Out
  Confirmation dialog:
    "Sign out of Flashy?"
    "[email address]"
    "Your local files stay on your device. Flashy Disk files
    remain in your Google Drive."
    [Cancel]  [Sign Out]
  On confirm:
    1. Call authService.signOut()
    2. Clear SQLite cache (all drive_files table rows)
    3. Clear all cached thumbnails from app cache directory
    4. Navigate to LoginScreen (GoRouter redirect via authStateChanges)

SWITCH ACCOUNT:
  From Settings → Account → Switch Account
  Calls _googleSignIn.signOut() then _googleSignIn.signIn()
  This re-shows the account picker → user picks different account
  App refreshes with new account's Drive

================================================================================
                      SECTION 4: LOGIN SCREEN UI
================================================================================

SCREEN LAYOUT (full screen, no app bar):

  Background: theme background color (white for light, #111827 for dark)

  Content (centered vertically and horizontally):

    [80dp gap from top]

    ⚡  ← Lightning bolt icon, 72dp × 72dp, electric blue (#2563EB)
        Built as a custom Flutter widget using Icon or SVG asset
        NOT a gradient — solid flat color only

    [16dp gap]

    "Flashy"
    Font: 32sp, FontWeight.w800 (extra bold)
    Color: theme primary text color

    [8dp gap]

    "Your files. Lightning fast."
    Font: 16sp, FontWeight.w400
    Color: theme secondary text color (#6B7280 light / #9CA3AF dark)

    [64dp gap]

    ┌────────────────────────────────────┐
    │  [G logo]  Continue with Google    │
    └────────────────────────────────────┘
    Button specs:
      Width: 280dp
      Height: 52dp
      Border radius: 12dp
      Background: WHITE (both light and dark mode — Google branding requirement)
      Border: 1dp solid #E5E7EB
      Shadow: elevation 2
      Left: Google "G" logo SVG (official colors, 20dp)
      Text: "Continue with Google", 16sp, FontWeight.w500, color #1A1A1A
      Tap animation: scale 0.97 on press (flutter_animate whileTap effect)

    [16dp gap]

    (loading state only — hidden otherwise):
    CircularProgressIndicator, 24dp, accent color
    Text: "Signing in...", 14sp, secondary color

    [16dp gap]

    (error state only — hidden otherwise):
    Container with light red background (#FEF2F2), 12dp radius, padding 12dp:
      Text: error message, 14sp, #DC2626
      Example: "Sign-in failed. Please try again."
    [Try Again] text button below

  [Bottom of screen]:
    "By continuing, you agree to our Terms of Service and Privacy Policy"
    12sp, secondary color, centered, tappable links

ANIMATION ON SCREEN LOAD:
  Lightning bolt: .fadeIn(duration: 400ms).scale(begin: 0.8)
  "Flashy" text: .fadeIn(delay: 100ms, duration: 400ms).slideY(begin: 0.2)
  Tagline: .fadeIn(delay: 200ms, duration: 400ms).slideY(begin: 0.2)
  Button: .fadeIn(delay: 350ms, duration: 400ms).slideY(begin: 0.3)

SIGN-IN BUTTON STATES:
  Default: shows Google G logo + "Continue with Google"
  Loading: replace content with Row(spinner + "Signing in...")
    Use AnimatedSwitcher between states (200ms fade)
  Error: button returns to default, error banner fades in below
  Success: brief success state then GoRouter navigates to HomeScreen

================================================================================
                      SECTION 5: APP STRUCTURE & NAVIGATION
================================================================================

NAVIGATION MODEL:
  Bottom navigation bar — 3 tabs, always visible after login

  Tab 1: 🏠 Home     — Flashy Disk card + local device files
  Tab 2: ↕️ Transfers — upload/download progress and history
  Tab 3: ⚙️ Settings  — all app settings

ROUTING (go_router):

  GoRouter with redirect based on FirebaseAuth.authStateChanges():

  routes:
    /login                   → LoginScreen (shown when not authenticated)
    /                        → HomeScreen (Tab 1)
    /flashy-disk             → FlashyDiskScreen (Flashy Disk root)
    /flashy-disk/:folderId   → FlashyDiskScreen (subfolder)
    /local                   → LocalBrowserScreen (device root)
    /local/*path             → LocalBrowserScreen (any local path)
    /transfers               → TransfersScreen (Tab 2)
    /settings                → SettingsScreen (Tab 3)
    /settings/account        → AccountSettingsScreen
    /preview                 → FilePreviewScreen (args: file info)
    /search                  → SearchScreen

  redirect logic:
    if (user == null) return '/login';
    if (user != null && location == '/login') return '/';
    return null; // no redirect

NAVIGATION TRANSITIONS:
  Tab switch: FadeTransition, 200ms, curve: Curves.easeInOut
  Folder open: SharedAxisTransition (horizontal) from animations package
  Bottom sheet: spring physics, dismissible by swipe down
  Back: reverse of open transition

================================================================================
                         SECTION 6: HOME SCREEN
================================================================================

The Home screen is ONE scrollable page with TWO major sections:

APP BAR:
  Title: "⚡ Flashy" (bold, accent color bolt + black/white text)
  No subtitle
  Elevation: 0 (flat)
  Border bottom: 0.5dp, theme border color
  Right actions:
    🔍 Search icon → /search
    ⋮ More icon → dropdown: (Sort, View toggle, Select All, Refresh)

---

6A. FLASHY DISK CARD (Top of Home — most prominent element)
---

When LOGGED IN (normal state):

  Card container:
    Margin: 16dp horizontal, 16dp top, 8dp bottom
    Padding: 20dp all sides
    Border radius: 16dp
    Background: theme card color
    Elevation: 2 (Material 3 tonal elevation)
    NO gradient anywhere

  Card content:
    Row: [⚡ disk icon 40dp] [column: title + subtitle] [⋮ menu button]
    
    Icon: custom "disk chip" widget:
      Rounded rectangle 40dp × 40dp, 10dp radius
      Background: #EFF6FF (light) / #1E3A5F (dark)
      Lightning bolt icon inside: #2563EB (light) / #60A5FA (dark)
      NOT a standard folder icon — unique to Flashy Disk

    Title: "Flashy Disk", 17sp, FontWeight.w700, primary text color
    Subtitle: "[email]", 13sp, secondary text color

    [20dp vertical gap]

    Storage progress bar:
      Height: 8dp, border radius: 4dp
      Background (empty/free): #E5E7EB (light) / #374151 (dark) — solid color
      Fill (used): #2563EB (light) / #60A5FA (dark) — solid color, NO gradient
      Animate width on load: 0 → actual width, 700ms, Curves.easeOut
      
      Below bar:
      Row: "[X GB used]" left aligned, "[Y GB free]" right aligned
      13sp, secondary text color

    [16dp vertical gap]

    Row of action buttons (equal width, side by side):
      [📂 Open Disk]          [⬆️ Upload Here]
      Each: OutlinedButton, 44dp height, 12dp radius
      Icon 18dp + text 14sp
      Border: 1dp theme border color
      Tap: primary action for each

  ⋮ menu (top right of card):
    Bottom sheet:
      📂 Open Flashy Disk
      ⬆️ Upload Files Here
      📊 Storage Details
      🔄 Sync Now
      🔓 Sign Out

When NOT LOGGED IN:
  (This state should NOT occur after successful login, but handle it gracefully)
  Show "Sign in to use Flashy Disk" card with "Continue with Google" button

ONBOARDING GUIDE BANNER:
  Shown ONCE after first login, below the Flashy Disk card
  Persisted dismissal in SharedPreferences key: 'onboarding_dismissed'

  Container:
    Background: #EFF6FF (light) / #1E3A5F (dark)
    Border radius: 12dp
    Margin: 16dp horizontal
    Padding: 16dp

  Content:
    Row: [💡 icon] ["How Flashy Disk Works" bold 15sp]
                   [✕ close button]
    [8dp gap]
    Text (14sp, secondary color):
      "Your free 15GB Google Drive storage is now your personal
      Flashy Disk. Copy any file from your device and paste it
      here to store it in the cloud — no extra storage needed."
    [12dp gap]
    [Got it ✓] TextButton, accent color

  Entrance animation: .fadeIn(duration: 300ms).slideY(begin: -0.1)
  Dismiss animation: SizeTransition height → 0, FadeTransition

---

6B. DEVICE FILES SECTION (Below Flashy Disk Card)
---

Section header:
  "Device Storage", 15sp, FontWeight.w700, primary text color
  Left padding 16dp, top margin 16dp, bottom 8dp

Root locations list (ListTile style, 64dp height each):

  📱 Internal Storage
     34.2 GB used · 93.8 GB free
     → /storage/emulated/0/

  💾 SD Card (only if present — check with path_provider extended or dart:io)
     12.1 GB used · 19.9 GB free
     → detected SD path

  ⬇️ Downloads
     48 files
     → /storage/emulated/0/Download/

  🖼️ Photos & Videos
     1,234 files
     → /storage/emulated/0/DCIM/

  🎵 Music
     89 files
     → /storage/emulated/0/Music/

  📄 Documents
     23 files
     → /storage/emulated/0/Documents/

  📦 APK Files
     7 files
     → scan device for .apk files

  🗑️ Large Files
     Files over 50MB
     → scanned and sorted by size

Each ListTile:
  Leading: Icon in rounded square (40dp × 40dp, 10dp radius, type-color background)
  Title: location name, 15sp, FontWeight.w600
  Subtitle: usage or count, 13sp, secondary color
  Trailing: ChevronRight icon, secondary color
  Tap: navigate to /local/[path] or appropriate screen
  Inkwell ripple on tap (theme accent color, 20% opacity)

================================================================================
                      SECTION 7: FILE BROWSER SCREEN
================================================================================

Used for BOTH local folder browsing AND Flashy Disk folder browsing.
Same widget — different data provider (local filesystem vs Drive API).

APP BAR:
  Leading: BackButton (←)
  Title: Column:
    top: folder name (16sp, bold) — truncated if >20 chars
    bottom: path or "Flashy Disk" (12sp, secondary color)
  Actions:
    🔍 Search within folder
    ⋮ More menu

MORE MENU OPTIONS:
  Select items
  ─────────────
  Sort by Name ↑/↓
  Sort by Date ↑/↓
  Sort by Size ↑/↓
  Sort by Type
  ─────────────
  View: List / Grid / Large Grid
  ─────────────
  Show hidden files (toggle checkmark)
  ─────────────
  Refresh
  Folder properties

FLOATING ACTION BUTTON (FAB):
  Position: bottom right, 16dp from edges
  Icon: + (add)
  Extended FAB becomes SpeedDial on tap:
    Labels appear to the left of each mini-FAB
    Mini FABs animate in with staggered .scale(begin:0).fadeIn():
      📁 New Folder         (delay: 0ms)
      📄 New Text File      (delay: 50ms)
      ⬆️ Upload Files       (delay: 100ms)
      📷 Upload Photo       (delay: 150ms)
    Overlay dims background when open
    Tap outside or tap + again to close

SORT BAR (slim, below app bar):
  Shows: "Sorted by Name ↑" as a small Chip
  Tap Chip → sort options bottom sheet
  Right side: view toggle icons (list/grid icons)
  Height: 36dp, background: surfaceVariant color

---

7A. LIST VIEW (default)
---

ListView, each item height: 68dp (comfortable density)

Item layout:
  [FileIconWidget 44dp] [name+subtitle column flex-1] [⋮ 40dp]

FileIconWidget (44dp × 44dp, 12dp radius):
  Folders: folder icon, background #FEF3C7 (warm yellow)
  Flashy Disk folders: folder icon + small ☁️ overlay badge (8dp, bottom-right)
  Images: actual thumbnail (loaded async) OR image icon, background #EDE9FE
  Videos: thumbnail + play triangle overlay OR video icon, #FEE2E2
  Audio: music note icon, #D1FAE5
  PDF: PDF icon, #FEE2E2
  Archives (.zip/.rar/.7z): archive icon, #FEF9C3
  APK: android icon, #DCFCE7
  Documents (.doc/.docx/.xls/.xlsx/.ppt/.pptx): type icon, #DBEAFE
  Code files (.dart/.py/.js etc.): code icon, #E0F2FE
  Unknown: generic file icon, #F3F4F6

Name text: 15sp, FontWeight.w600, primary text color, single line, ellipsis
Subtitle text: 13sp, secondary color, single line
  For files: "[size] · [date modified]"   e.g., "4.2 MB · May 12"
  For folders: "[N items] · [date]"

⋮ button: 40dp × 40dp tap target, opens context bottom sheet for THIS file

Divider: Divider(height: 1, thickness: 0.5, indent: 68dp)
  (indent aligns with text, not icon — cleaner look)

TAP BEHAVIOR:
  Folder: navigate into folder (SharedAxisTransition horizontal)
  File: open preview if supported, else open with native app

LONG PRESS → selection mode (see Section 11)

SWIPE ACTIONS (Dismissible widget):
  Swipe LEFT reveals: [🗑️ Delete] red background
    - If swiped past 40% → confirm dialog
    - If released before 40% → snap back
  Swipe RIGHT reveals: [📋 Copy] blue background
    - Copies file to clipboard provider
  Both reveal with smooth slide animation

---

7B. GRID VIEW
---

GridView.builder, crossAxisCount: 2 (portrait) / 3 (landscape)
mainAxisSpacing: 12dp, crossAxisSpacing: 12dp
Padding: 16dp all sides

Each item: Card, border radius 12dp, elevation 1
  Image/video: thumbnail fills card aspect ratio 1:1
  Others: icon centered on type-color background, aspect 1:1
  Name: below card image area, 12sp, 2 lines max, centered, padding 8dp

---

7C. LARGE GRID VIEW
---

GridView, crossAxisCount: 1 (portrait)
Each item height: 180dp
Full width, padding 16dp horizontal

Left: type-color square 80dp × 80dp or thumbnail
Right: name (16sp bold), size, date, type label

---

LOADING STATE (shimmer):
  Skeleton items matching current view mode
  8 skeleton items
  shimmer package: shimmer effect sweeping left to right
  Duration before showing real content: show shimmer until data loads

EMPTY STATE:
  Flashy Disk empty:
    Lottie animation (empty cloud / lightning bolt idle)
    "Flashy Disk is empty"
    "Tap + to upload your first file"

  Local folder empty:
    Large folder icon (72dp, secondary color)
    "Nothing here"
    "This folder is empty"

  After search, no results:
    Magnifying glass illustration
    "No files found"
    "Try a different search term"

================================================================================
                      SECTION 8: FLASHY DISK BROWSER
================================================================================

Same as File Browser but with these specific differences:

DATA SOURCE:
  Uses DriveApi obtained from AuthService.getDriveApi()
  Lists files in /Flashy/ folder in user's Google Drive
  Files cached in SQLite (drive_files table)

CACHE-FIRST APPROACH:
  On open: immediately show cached data from SQLite
  Simultaneously: fetch fresh data from Drive API
  On fresh data received: diff against cache, animate in new/changed items
  User sees content instantly — never a blank loading screen

FLASHY DISK ROOT ICON (NOT a folder):
  Custom widget — rounded rectangle with lightning bolt
  Background: #EFF6FF (light) / #1E3A5F (dark)
  Lightning bolt: #2563EB
  44dp × 44dp, 12dp radius
  Use this ONLY for the Flashy Disk root, not subfolders

SUBFOLDER ICONS:
  Standard folder icon BUT with small cloud badge (☁️ 10dp overlay, bottom-right)
  Indicates this folder lives in the cloud

OFFLINE BANNER (only when device is offline):
  Shown at TOP of content area (not blocking, non-dismissible)
  Height: 40dp
  Background: #FEF3C7 (warning yellow)
  Row: [⚠️ icon] ["Offline — Flashy Disk unavailable"] right-aligned
  Slides down from top with 300ms spring when offline detected
  Slides back up when online

OPENING A FILE WHILE OFFLINE:
  If user taps a Flashy Disk file while offline:
  Show modal bottom sheet:
    ─────────────────────
    ⚠️  No Internet Connection
    (Icon: cloud with X, 48dp, centered)
    "You need internet to open Flashy Disk files.
    Connect to Wi-Fi or mobile data and try again."
    [OK — Got it]
    ─────────────────────

PASTING A FILE TO FLASHY DISK WHILE OFFLINE:
  Show modal bottom sheet:
    ─────────────────────
    ☁️  You're Offline
    "Upload will be queued and start automatically
    when you're back online."
    [Cancel]        [Queue Upload]
    ─────────────────────
  If "Queue Upload": save to upload_queue table in SQLite
  Show persistent banner on home screen: "3 uploads queued — connect to sync"
  On network restore: connectivity_plus detects, process queue automatically

================================================================================
                      SECTION 9: FILE OPERATIONS (ALL)
================================================================================

All operations work for BOTH local files AND Flashy Disk files.
UI operations apply instantly (optimistic updates), then sync in background.

--- OPEN ---
  Local file: open_file package → native OS handler
  Flashy Disk file:
    Small download (< 5MB): download to cache → open
    Show snackbar with progress: "Opening photo.jpg... 67%"
    Large file: show download progress bottom sheet before opening

--- RENAME ---
  Trigger: ⋮ → Rename OR long press → select → ⋮ → Rename
  Bottom sheet slides up:
    ──────────────────────────────
    Rename
    ┌────────────────────────────┐
    │ filename                   │  ← TextField, auto-focused
    └────────────────────────────┘
    .jpg  ← extension shown separately, grayed, not editable
    Error text (hidden unless invalid): "Invalid characters: / \ : * ? < >"
    [Cancel]              [Rename]
    ──────────────────────────────
  TextField: text pre-selected (without extension), keyboard opens immediately
  [Rename] disabled if empty or invalid
  On confirm: update UI instantly, then API/filesystem in background

--- DUPLICATE ---
  Creates "[Name] - Copy.[ext]" in same directory
  If exists: "[Name] - Copy (2).[ext]"
  Local: copies file bytes via dart:io
  Flashy Disk: DriveApi.files.copy() — server-side, instant

--- COPY ---
  Stores in ClipboardProvider (Riverpod): { files, operation: 'copy' }
  Copied items show subtle tinted overlay (NOT greyed out)
  Snackbar: "1 item copied" with inline [Paste here] action button

--- CUT ---
  Same as Copy but operation: 'cut'
  Cut items show 50% opacity (AnimatedOpacity 200ms transition)

--- PASTE ---
  Available from:
    FAB menu → Paste (shown only if clipboard has items)
    ⋮ more menu of current folder → Paste
    Selection mode bottom bar
  
  Local → Local: copy/move file via dart:io
  Local → Flashy Disk: triggers UPLOAD FLOW (see Section 10)
  Flashy Disk → Local: triggers DOWNLOAD FLOW
  Flashy Disk → Flashy Disk: DriveApi.files.copy() / files.update() parent

--- DELETE ---
  Single file — ⋮ → Delete:
    If "Confirm before delete" ON (default):
      AlertDialog:
        Title: "Delete [filename]?"
        Content: "This cannot be undone."
        [Cancel]     [Delete] (red colored)
    On confirm:
      Animate item OUT: SizeTransition height→0 + FadeTransition (250ms)
      Delete operation in background
      Snackbar: "Deleted [filename]" + [Undo] button (5 second window)
      Undo: restore file with animate-in

  Flashy Disk delete: DriveApi.files.trash() — recoverable from Drive trash
  Local delete: dart:io File.delete() — permanent (warn user clearly)

--- MULTI-SELECT DELETE ---
  AlertDialog:
    "Delete [N] items?"
    Scrollable list of filenames (max 5 shown, then "...and [N] more")
    [Cancel]     [Delete All]

--- COMPRESS (ZIP) ---
  ⋮ → Compress / Add to ZIP
  Bottom sheet:
    Archive Name: [TextField: "archive.zip"]
    Format: ZIP (local only — Flashy Disk = upload the zip after)
    [Create Archive]
  Uses archive package
  Progress shown for large archives
  Created in same folder as source files

--- EXTRACT ---
  On zip/rar/7z/tar files — ⋮ → Extract
  Bottom sheet:
    Extract to: [Same folder] / [Choose folder]
    [Extract Here]
  Uses archive package for zip/tar
  Progress: LinearProgressIndicator in bottom sheet
  Files appear on completion with animate-in

--- SHARE ---
  ⋮ → Share
  For local files: share_plus directly
  For Flashy Disk files: download to cache first → then share_plus
  Opens native share sheet

--- PROPERTIES ---
  ⋮ → Properties
  DraggableScrollableSheet (bottom sheet, 70% initial height, 100% max):

    Content:
    [Large file icon centered, 72dp]
    [Filename, 18sp, bold, centered]
    [12dp gap]
    Divider
    [16dp gap]

    ListTile rows:
      Type:          "PNG Image"
      Size:          "4.23 MB (4,437,218 bytes)"
      Location:      "/storage/emulated/0/DCIM/"
      Created:       "May 12, 2025, 2:34 PM"
      Modified:      "May 17, 2025, 9:12 AM"

    If Flashy Disk file, additional rows:
      Drive ID:      "[id]" with [📋 Copy] icon button
      Sync status:   "✅ Synced" / "🔄 Syncing..." / "❌ Error"

    [Close] button or swipe down to dismiss

--- MOVE TO ---
  ⋮ → Move to...
  Opens folder picker (file browser in "pick mode"):
    App bar: "Move to..." with [Move Here] button in actions
    Shows folder structure, user navigates to destination
    Tap [Move Here] to execute

--- COPY TO ---
  Same as Move To but "Copy to..."

--- ADD TO FAVORITES ---
  ⋮ → Add to Favorites
  Stores in favorites SQLite table
  Starred items appear in a "Favorites" section on Home screen (optional feature)
  ⋮ → Remove from Favorites to unstar

--- OPEN WITH ---
  ⋮ → Open With
  Android: Intent.ACTION_VIEW with chooser
  iOS: UIDocumentInteractionController

================================================================================
                      SECTION 10: MULTI-SELECT & BOTTOM ACTION BAR
================================================================================

ENTERING SELECTION MODE:
  Long press any file → selection mode activates
  That file is immediately selected (checkbox animated in, scale 0→1, spring)
  Haptic feedback: HapticFeedback.mediumImpact()

APP BAR TRANSFORMATION (AnimatedSwitcher, 300ms):
  FROM: [← Title  🔍 ⋮]
  TO:   [✕  "3 selected"  ✓ All]
  
  "3 selected" updates with animated counter (TweenAnimationBuilder on count)

ITEM VISUAL IN SELECTION MODE:
  Checkbox: appears at left, AnimatedScale from 0
  Selected item: background shifts to accent color at 12% opacity
  Checkboxes: CheckboxListTile or custom checkbox widget
  Tap = toggle selection (no need to long press again)
  Drag finger across items = selects range

BOTTOM ACTION BAR (slides up, spring animation):
  Height: 60dp
  Background: theme surface color (NOT accent — keep it clean)
  Top border: 1dp theme border color
  Box shadow: 0 -4dp 12dp rgba(0,0,0,0.08)

  Actions row (equal spacing, icon + label below):
    ✂️ Cut     📋 Copy     🗑️ Delete     ⋮ More
    
    Each: 64dp width, 44dp tap target
    Icon: 22dp, primary color
    Label: 11sp, secondary color

  ⋮ More bottom sheet:
    📁 Move to...
    📂 Copy to...
    📦 Compress / ZIP
    📤 Share
    ⭐ Add to Favorites
    ✏️ Batch Rename (only if >1 selected)
    ℹ️ Properties (only if exactly 1 selected)

SELECT ALL:
  Tap "✓ All" in app bar → all items selected, counter updates
  Tap again → deselect all, exit selection mode

EXIT SELECTION MODE:
  Tap ✕ in app bar
  Android back button
  Tap anywhere empty (where no file item is)
  All checkboxes animate out: scale 1→0 (200ms)
  Bottom bar slides back down
  App bar returns to normal

================================================================================
                      SECTION 11: UPLOAD ANIMATION & PROGRESS POPUP
================================================================================

This is the HERO FEATURE of the app.
When a file is uploaded to Flashy Disk, a FLOATING POPUP appears.

POPUP APPEARANCE:
  Position: bottom of screen, above bottom navigation bar
  Margin: 16dp from sides and bottom nav
  Border radius: 16dp
  Background: theme surface color
  Elevation: 8 (floats above all other content)
  This popup is a Stack widget at app root level — it appears on ALL screens

POPUP IS DRAGGABLE:
  User can drag it to any position on screen
  Implemented with Draggable or GestureDetector + Positioned in Stack
  Stays within screen bounds (clamp position)
  Snaps back to bottom when drag released (spring animation)

FULL SIZE POPUP (visible by default):
  ─────────────────────────────────────
  ⚡ Uploading to Flashy Disk
  ─────────────────────────────────────
  [file type icon 36dp]  photo_vacation.jpg
                         [progress bar full width, 8dp, rounded]
                         78%  ·  12.3 MB / 15.8 MB
                         Speed: 1.2 MB/s  ·  ETA: 1m 20s
  ─────────────────────────────────────
  [─ Minimize]                [✕ Cancel]
  ─────────────────────────────────────
  
  Progress bar:
    Background: #E5E7EB (solid, no gradient)
    Fill: #2563EB (solid, no gradient)
    Animated width: AnimatedContainer, duration 300ms, Curves.easeOut
  
  Percentage: TweenAnimationBuilder<double> for smooth number animation
  ETA + Speed: update every second with crossfade (AnimatedSwitcher 200ms)
  
  File icon: same FileIconWidget as file browser (44dp)
  
  Animation of popup APPEARANCE:
    Transform.translate from y: 200 → y: 0
    Opacity: 0 → 1
    Duration: 400ms, spring(stiffness: 250, damping: 25)

MINIMIZED PILL STATE:
  When user taps [─ Minimize]:
  Popup collapses to pill:
    Width: 200dp, Height: 44dp, border radius: 22dp
    Background: theme surfaceVariant
    Content: [⚡] [Uploading... 78%] [▲ expand]
    Position: bottom right, 16dp from bottom nav
    AnimatedContainer transition: 300ms spring

  Tap pill → expand back to full popup

MULTIPLE UPLOADS:
  If 2+ uploads queued/active:
  Full popup shows:
    Header: "3 uploads in progress"
    Scrollable list of transfer items (each: icon, name, mini progress bar, %)
    [View All in Transfers tab]

CANCEL UPLOAD:
  Tap [✕ Cancel]:
    AlertDialog:
      "Cancel upload?"
      "'photo.jpg' will not be saved to Flashy Disk."
      [Keep Uploading]   [Cancel Upload]
  On cancel:
    Progress bar animates to 0% (AnimatedContainer)
    Popup fades out (FadeTransition, 300ms)
    Snackbar: "Upload cancelled"

UPLOAD COMPLETE:
  Progress bar hits 100%
  Bar color: #2563EB → #16A34A (animated ColorTween, 500ms)
  Popup content changes (AnimatedSwitcher):
    ✅ Upload Complete!
    "photo.jpg is now in Flashy Disk"
    [Open File] [Dismiss]
  After 3 seconds: auto-dismiss with slide-down animation

UPLOAD COMPLETE — SYSTEM NOTIFICATION:
  flutter_local_notifications:
    Title: "Flashy"
    Body: "photo.jpg uploaded to Flashy Disk"
    Icon: app icon (lightning bolt)
    Tap notification: opens app to Flashy Disk folder containing the file

DOWNLOAD PROGRESS:
  Same popup but:
    Header: "⬇️ Downloading from Flashy Disk"
    Color: green (#16A34A) for download
    On complete: "✅ Download Complete! Opening file..."
    Then opens file with open_file package

UPLOAD IMPLEMENTATION:
  // drive_service.dart
  Future<String> uploadFile({
    required String localPath,
    required String parentFolderId,
    required Function(int sent, int total) onProgress,
  }) async {
    final file = File(localPath);
    final fileSize = await file.length();
    final mimeType = lookupMimeType(localPath) ?? 'application/octet-stream';

    final driveFile = drive.File()
      ..name = path.basename(localPath)
      ..parents = [parentFolderId];

    // Count bytes sent by wrapping stream
    int bytesSent = 0;
    final stream = file.openRead().map((chunk) {
      bytesSent += chunk.length;
      onProgress(bytesSent, fileSize);
      return chunk;
    });

    final media = drive.Media(stream, fileSize, contentType: mimeType);
    
    final result = await _driveApi!.files.create(
      driveFile,
      uploadMedia: media,
    );

    return result.id!;
  }

OFFLINE UPLOAD QUEUE PROCESSING:
  On app launch and on connectivity restore:
    1. Check upload_queue table for pending items
    2. For each pending item: start upload
    3. On success: delete from queue, add to drive_files cache
    4. On failure: increment retry_count, if >3 mark as failed

================================================================================
                      SECTION 12: TRANSFERS SCREEN (TAB 2)
================================================================================

AppBar: "Transfers", flat (elevation 0)
Action: [Clear all completed] text button (right)

SECTIONS (shown only if they have items):

  ACTIVE:
    Each item:
    [file icon 36dp] [filename bold 14sp]          [✕ cancel]
                     [progress bar, full width, 6dp]
                     [78% · 1.2 MB/s · 1m 20s left]

  QUEUED (offline queue):
    Each item:
    [file icon 36dp] [filename bold 14sp]           [✕ remove]
                     Queued — waiting for connection
                     Size: 4.2 MB

  COMPLETED (grouped by date — Today, Yesterday, Older):
    Each item:
    [file icon 36dp] [filename bold 14sp]           [✅]
                     Uploaded · 4.2 MB · 2:34 PM

  FAILED:
    Each item:
    [file icon 36dp] [filename bold 14sp]           [↺ Retry]
                     Failed: No internet · May 12

EMPTY STATE (no transfers ever):
  Lottie animation: arrows going up/down (simple, minimal)
  "No transfers yet"
  "Files you upload to Flashy Disk appear here"

================================================================================
                      SECTION 13: SEARCH SCREEN
================================================================================

Full screen with auto-focused search bar (keyboard opens immediately)

SEARCH BAR:
  Width: full, height: 48dp
  Rounded: 12dp radius
  Background: surfaceVariant color
  Leading: 🔍 icon
  Trailing: ✕ to clear
  [Cancel] button to pop screen (right of bar)

RECENT SEARCHES (when bar is empty + focused):
  "Recent" header
  Last 8 searches with 🕐 icon and ✕ to remove each
  "Clear all" at bottom (TextButton)
  
  Each recent tap → fills search bar + triggers search

SEARCH FILTERS (horizontal scroll row of FilterChip):
  [All] [📷 Images] [🎬 Videos] [📄 Documents] [🎵 Audio] [📦 Archives]
  [📅 Today] [📅 This Week] [📅 This Month]
  [📦 > 10MB] [📦 > 100MB]
  
  Active filter: filled chip with accent background
  Multiple filters combine with AND logic

RESULTS:
  Two sections with headers:
    "In Flashy Disk" — results from SQLite drive cache
    "On This Device" — results from local file scan

  Each result: same FileListItem widget as file browser
  Matching text in filename highlighted: bold + accent color

  "No results" state:
    Magnifying glass illustration (large, subtle)
    "No files found for '[query]'"
    "Try different keywords"

SEARCH LOGIC:
  Local device: recursive file scan (may be slow for large storage — show spinner)
  Flashy Disk: SQLite query: SELECT * FROM drive_files WHERE name LIKE '%query%'
  Both: filter by active FilterChips
  Debounce: 300ms after last keystroke

================================================================================
                      SECTION 14: SETTINGS SCREEN (TAB 3)
================================================================================

Standard iOS/Android settings-style screen.
No tab bar inside settings — scrollable single list with section headers.

TOP SECTION — ACCOUNT CARD:
  Card (16dp margin, 16dp radius):
    Row:
      [Profile photo — CircleAvatar 52dp, network image from Firebase user]
      Column:
        [Display name, 16sp, bold]
        [Email address, 14sp, secondary]
      [›]
    [16dp gap]
    Storage bar: "[===------] 4.2 GB of 15 GB used"
    13sp secondary color below bar
  
  Tap card → Account Settings sub-screen

SETTINGS SECTIONS (each section has header text):

─── APPEARANCE ───

  Theme
    Three cards in a row (each 90dp wide):
      [Light] [Dark] [System]
      Each: mini color preview, border if selected, tap to switch
      AnimatedTheme on root wraps entire app (300ms theme transition)
  
  Accent Color
    Row of 8 circles (32dp diameter, 8dp gap):
      Blue #2563EB · Sky #0EA5E9 · Green #16A34A · Teal #0D9488
      Purple #7C3AED · Orange #EA580C · Red #DC2626 · Pink #EC4899
    Selected: ✓ checkmark inside circle
    Tap → updates accent across entire app (Riverpod theme provider)
  
  List Item Density
    SegmentedButton: [Compact] [Normal] [Comfortable]
    Affects row heights: 52dp / 64dp / 72dp

  Icon Size
    Slider: 36dp ← → 56dp (default 44dp)

─── FILE PREFERENCES ───

  SwitchListTile: Show file extensions (default: ON)
  SwitchListTile: Show hidden files (default: OFF)
    "Files starting with '.' are considered hidden"
  SwitchListTile: Show file sizes in list (default: ON)
  SwitchListTile: Show dates in list (default: ON)
  SwitchListTile: Confirm before delete (default: ON)
  
  Default View:
    SegmentedButton: [List] [Grid] [Large]
  
  Default Sort:
    ListTile with dropdown: Name / Date / Size / Type (+ Ascending/Descending)

─── FLASHY DISK ───

  SwitchListTile: Offline upload queue (default: ON)
    "Files will upload automatically when you reconnect"
  
  SwitchListTile: Show upload progress popup (default: ON)
  
  Sync interval:
    RadioListTile options: Real-time / Every 5 min / Every 30 min / Manual
  
  Cache:
    ListTile: "Thumbnail cache" trailing: "89 MB"
    ListTile: "Download cache" trailing: "234 MB"
    [Clear thumbnail cache] TextButton (red colored)
    [Clear all cache] TextButton (red colored)
    Both show confirmation AlertDialog before clearing

─── STORAGE PERMISSIONS ───

  ListTile: "Read & Write Storage"
    Trailing: "✅ Granted" (green) OR "⚠️ Required" (amber, tap to grant)
  
  ListTile: "All Files Access"
    Subtitle: "Required for full file manager access"
    Trailing: "✅ Granted" OR "⚠️ Required"
    Tap: permission_handler → openAppSettings() for special permission

─── NOTIFICATIONS ───

  SwitchListTile: Upload complete notifications (default: ON)
  SwitchListTile: Download complete notifications (default: ON)
  SwitchListTile: Sync error alerts (default: ON)

─── ABOUT ───

  ListTile: App version "Flashy 1.0.0 (Build 1)" trailing: "Check for updates"
  ListTile: "Help & Support" → opens URL
  ListTile: "Privacy Policy" → opens URL
  ListTile: "Rate Flashy ⭐" → opens store listing
  ListTile: "Share Flashy" → share_plus

─── ACCOUNT SETTINGS SUB-SCREEN ───

  Reached by tapping account card in Settings main.

  [Profile photo 80dp circle centered]
  [Display name 20sp bold centered]
  [Email 15sp centered]
  [16dp gap]
  
  [View Google Drive storage →] ListTile (opens Drive in browser)
  
  Storage breakdown:
    Animated progress bar (same as Flashy Disk card but larger)
    "4.2 GB used of 15 GB total"
    Breakdown text: "Flashy Disk files: 3.1 GB · Other Drive: 1.1 GB"
  
  [Switch Account] OutlinedButton, full width
    → _googleSignIn.signOut() then _googleSignIn.signIn()
  
  [Sign Out] ElevatedButton, full width, red background
    → Confirmation AlertDialog → authService.signOut() → navigate to /login

================================================================================
                      SECTION 15: FILE PREVIEW SCREENS
================================================================================

IMAGE PREVIEW:
  Full screen, black background
  InteractiveViewer: pinch to zoom (min 0.5×, max 4×)
  Double tap: toggle 100% zoom / fit
  Swipe left/right: navigate to adjacent images in same folder
  Page indicator: "3 / 12" fades after 2 seconds of inactivity
  Overlay buttons (fade on tap, auto-hide 3s):
    Top: [← Back] [Share] [⋮ More]
    Bottom: [⬇️ Download] (for Flashy Disk images)

VIDEO PREVIEW:
  video_player package (add: video_player: ^2.x)
  Full screen, black background
  Controls overlay (tap to show/hide):
    Play/Pause center button (64dp)
    Bottom: seek bar, position/duration, volume
  Flashy Disk: stream URL if possible, else download first

AUDIO PREVIEW:
  audioplayers package (add: audioplayers: ^6.x)
  Screen: dark background, large album art placeholder
  Waveform: simple animated bars (CustomPainter, 20 bars pulsing to audio)
  Controls: [⏮ 15s] [⏯ Play/Pause] [⏭ 15s]
  Seek bar, elapsed time / total duration

TEXT / CODE PREVIEW:
  Scrollable, monospace font (Courier/monospace)
  Syntax highlighting: flutter_highlight package
  Actions bar: [Copy all] [Share] [Edit]
  Line numbers on left side (optional, togglable)

MARKDOWN PREVIEW:
  flutter_markdown package
  GitHub Flavored Markdown
  Code blocks with syntax highlighting
  Toggle button top right: [Preview] / [Source]
  Links tappable (opens in browser via url_launcher)

PDF PREVIEW:
  pdfx package (add: pdfx: ^2.x)
  Scrollable PDF with zoom
  Page counter: "Page 3 of 24"
  For Flashy Disk: download to cache dir first, then render

ARCHIVE PREVIEW (.zip, .rar, .7z):
  File tree of archive contents (without extracting)
  Each entry: icon, name, size (compressed / original)
  AppBar action: [Extract All]
  Long press entry: [Extract selected file only]

UNKNOWN FILE:
  Large file type icon (96dp) centered
  File name (20sp bold), size, type, created/modified dates
  [Open With...] ElevatedButton → native intent
  [Share] OutlinedButton

================================================================================
                      SECTION 16: PERMISSIONS FLOW
================================================================================

NEVER request permissions on app launch.
Request ONLY when the user tries to do something that requires permission.

PERMISSION REQUEST FLOW:

When user taps Device Files section first time:
  → Permission explanation bottom sheet:
    ─────────────────────────────────────
    📁  Access Your Files
    "To browse your device files, Flashy
    needs storage permission."
    "We only access files you choose —
    nothing is shared without you."
    [Not Now]    [Allow Access]
    ─────────────────────────────────────
  → [Allow Access]: permission_handler.request(Permission.storage)
  → If denied: show explanation ListTile with "Tap to grant"
  → If permanently denied: openAppSettings()

For Android 11+ MANAGE_EXTERNAL_STORAGE:
  Separate explanation screen (not just a dialog):
    AppBar: "Enable Full Access"
    Content:
      Icon: folder with lock (72dp)
      Title: "Full File Manager Access"
      Body: "For complete file management (like ZArchiver), Flashy needs
             'All Files Access' permission. This lets Flashy read and manage
             all files on your device."
      Note: "You can revoke this any time in Settings."
    [Grant All Files Access] → opens special permission settings

FOR iOS:
  NSPhotoLibraryUsageDescription in Info.plist
  NSDocumentsFolderUsageDescription in Info.plist
  Use permission_handler for media/files access
  Request when user first accesses Photos or Documents location

================================================================================
                      SECTION 17: ANIMATIONS SPECIFICATION
================================================================================

ALL complex animations use flutter_animate package.
Simple hover/press states use InkWell/GestureDetector with theme colors.
Theme transitions use AnimatedTheme (Flutter built-in).

FOLDER NAVIGATION (enter):
  SharedAxisTransition from animations package
  transitionType: SharedAxisTransitionType.horizontal
  Duration: 300ms
  Forward: current slides left + fades, new slides from right + fades in
  Back: reverse

FILE LIST ITEMS — STAGGERED APPEARANCE:
  When folder loads and shows content:
  Each item: .fadeIn(duration: 200ms, delay: index * 25ms).slideX(begin: 0.05)
  Max delay: 250ms (so item 10+ don't wait too long)
  Use AnimationLimiter from staggered_animations if needed

SELECTION MODE TRANSITION:
  App bar: AnimatedSwitcher, 300ms, crossfade
  Checkboxes: .scale(begin: 0, duration: 200ms, curve: Curves.elasticOut)
  Bottom bar: Transform.translate Y: 80 → 0, duration 300ms, spring
  Item backgrounds: AnimatedContainer color change, 200ms

UPLOAD POPUP:
  Enter: Transform.translate(y: 200→0) + Opacity(0→1), 400ms spring
  Minimize: AnimatedContainer width/height collapse, 300ms spring
  Dismiss: Transform.translate(y: 0→200) + Opacity(1→0), 300ms ease-in

FAB SPEED DIAL:
  FAB rotates: 0° → 45° (+ icon becomes X), 200ms
  Mini FABs appear: .scale(begin:0).fadeIn() with 50ms stagger each

SWIPE ACTIONS:
  SlideTransition revealing action buttons
  Snap-back spring: stiffness 400, damping 30
  Delete action: item height collapses with SizeTransition after confirm

FILE DELETE:
  SizeTransition (height 1→0) + Opacity (1→0), 250ms, Curves.easeInOut

SNACKBAR (SnackBar widget):
  Material 3 SnackBar — built-in slide-up animation
  Duration: 4000ms default, 8000ms for undo snackbars
  Action text: accent color

PROGRESS BARS:
  ALWAYS AnimatedContainer or TweenAnimationBuilder for width
  Duration: 300ms, curve: Curves.easeOut
  NEVER setState with instant width change

STORAGE BAR (Flashy Disk card):
  On screen mount: delay 300ms, then animate width 0→actual
  Duration: 700ms, curve: Curves.easeOut (TweenAnimationBuilder)

THEME SWITCH:
  AnimatedTheme on MaterialApp — auto-interpolates all colors
  Duration: 300ms

EMPTY STATE:
  .fadeIn(duration: 400ms).scale(begin: 0.85, curve: Curves.easeOut)

LOADING → CONTENT TRANSITION:
  AnimatedSwitcher, FadeTransition, 300ms
  Shimmer skeleton → real content

NUMBERS (percentage, count, file size):
  TweenAnimationBuilder<double> for smooth counting
  Duration: 500ms for initial values, 200ms for updates

LOTTIE ANIMATIONS (used for):
  - Empty Flashy Disk (idle animation, loops)
  - Upload complete (plays once: checkmark drawing)
  - No internet / offline state (loops: cloud with X)
  - Onboarding screen (loops: files floating)

================================================================================
                      SECTION 18: THEME SYSTEM
================================================================================

Flutter ThemeData with Material 3 (useMaterial3: true).
Theme stored in SharedPreferences: 'theme_mode' ('light'/'dark'/'system')
Accent stored: 'accent_color' (hex string)
All changes apply INSTANTLY via Riverpod theme provider.

ABSOLUTE RULE: NO LinearGradient, NO RadialGradient, NO ShaderMask gradients.
EVERY color is a flat solid color.

LIGHT THEME:
  ColorScheme.fromSeed(seedColor: accentColor, brightness: Brightness.light)
  Manual overrides:
    scaffoldBackgroundColor: #FFFFFF
    cardColor: #FFFFFF
    dividerColor: #F3F4F6
  Custom extensions:
    sidebarColor: #F8F9FA
    fileIconFolder: #FEF3C7    (amber, folders)
    fileIconImage: #EDE9FE     (purple, images)
    fileIconVideo: #FEE2E2     (red, videos)
    fileIconAudio: #D1FAE5     (green, audio)
    fileIconDoc: #DBEAFE       (blue, documents)
    fileIconArchive: #FEF9C3   (yellow, archives)
    fileIconApk: #DCFCE7       (green, APKs)
    fileIconCode: #E0F2FE      (sky, code)
    fileIconOther: #F3F4F6     (gray, unknown)

DARK THEME:
  ColorScheme.fromSeed(seedColor: accentColor, brightness: Brightness.dark)
  Manual overrides:
    scaffoldBackgroundColor: #111827
    cardColor: #1F2937
    dividerColor: #374151
  Custom extensions (dark variants):
    sidebarColor: #1F2937
    fileIconFolder: #3B2F00
    fileIconImage: #2E1065
    fileIconVideo: #450A0A
    fileIconAudio: #064E3B
    fileIconDoc: #1E3A5F
    fileIconArchive: #422006
    fileIconApk: #052E16
    fileIconCode: #0C2A3B
    fileIconOther: #1F2937

BOTTOM NAVIGATION BAR:
  NavigationBar (Material 3)
  selectedIndex: drives tab switching
  destinations: Home, Transfers, Settings
  indicatorColor: accent color at 20% opacity
  labelBehavior: always show labels
  backgroundColor: theme cardColor
  elevation: 0, border top: 1dp

DEFAULT ACCENT COLORS (user picks in settings):
  Blue:   #2563EB (default)
  Sky:    #0EA5E9
  Green:  #16A34A
  Teal:   #0D9488
  Purple: #7C3AED
  Orange: #EA580C
  Red:    #DC2626
  Pink:   #EC4899

================================================================================
                      SECTION 19: SQLITE SCHEMA
================================================================================

Database name: flashy_cache.db (via sqflite, app documents directory)
Version: 1

  CREATE TABLE drive_files (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    mime_type TEXT,
    parent_id TEXT,
    size INTEGER,
    modified_time TEXT,
    created_time TEXT,
    thumbnail_link TEXT,
    web_content_link TEXT,
    starred INTEGER DEFAULT 0,
    is_folder INTEGER DEFAULT 0,
    local_thumb_path TEXT,
    synced_at INTEGER
  );
  CREATE INDEX idx_parent ON drive_files(parent_id);
  CREATE INDEX idx_name ON drive_files(name);

  CREATE TABLE favorites (
    path TEXT PRIMARY KEY,
    name TEXT,
    is_drive INTEGER DEFAULT 0,
    added_at INTEGER
  );

  CREATE TABLE transfer_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_name TEXT,
    file_size INTEGER,
    direction TEXT,
    status TEXT,
    drive_file_id TEXT,
    local_path TEXT,
    started_at INTEGER,
    completed_at INTEGER,
    error_message TEXT
  );

  CREATE TABLE upload_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    local_path TEXT NOT NULL,
    dest_folder_id TEXT NOT NULL,
    file_name TEXT,
    file_size INTEGER,
    status TEXT DEFAULT 'pending',
    created_at INTEGER,
    retry_count INTEGER DEFAULT 0
  );

  CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT
  );

  CREATE TABLE recent_searches (
    query TEXT PRIMARY KEY,
    searched_at INTEGER
  );

================================================================================
                      SECTION 20: STATE MANAGEMENT (RIVERPOD)
================================================================================

All providers in /lib/providers/

  authProvider (StateNotifierProvider):
    State: { user: User?, googleUser: GoogleSignInAccount?, isLoading, error }
    Methods: signIn(), signOut(), silentSignIn(), switchAccount()

  driveProvider (StateNotifierProvider):
    State: { folderContents: Map<folderId, List<DriveFile>>, quota, isLoading }
    Methods: listFolder(id), refresh(id), createFolder(name, parentId)

  transferProvider (StateNotifierProvider):
    State: { active: List<Transfer>, queued, history, failed }
    Methods: startUpload(localPath, folderId), cancel(id), retry(id)

  fileSystemProvider (StateNotifierProvider):
    State: { currentPath, files: List<FileSystemEntity>, isLoading }
    Methods: navigateTo(path), goBack(), refresh()

  themeProvider (StateNotifierProvider):
    State: { mode: ThemeMode, accentColor: Color }
    Persisted in SharedPreferences on every change

  settingsProvider (StateNotifierProvider):
    State: Settings object with all settings fields
    Persisted in SharedPreferences

  clipboardProvider (StateProvider):
    State: { files: List, operation: 'copy'|'cut'|null }

  selectionProvider (StateNotifierProvider):
    State: { selectedPaths: Set<String>, isSelecting: bool }
    Methods: toggle(path), selectAll(all), clearAll()

  connectivityProvider (StreamProvider):
    Wraps connectivity_plus ConnectivityResult stream

  uploadPopupProvider (StateNotifierProvider):
    State: { isVisible, isMinimized, currentTransfer, position: Offset }
    Controls the floating upload popup widget

================================================================================
                      SECTION 21: ERROR HANDLING
================================================================================

NETWORK ERRORS:
  connectivity_plus: listen to stream, update connectivityProvider
  Offline banner appears/disappears on home screen and Flashy Disk screen
  All Drive API calls wrapped in try-catch with connectivity check first

FIREBASE AUTH ERRORS:
  PlatformException(sign_in_cancelled): silently ignore (user cancelled)
  PlatformException(sign_in_failed): show error on login screen with retry
  firebase_auth/user-disabled: "Your account has been disabled. Contact support."
  Token expired: google_sign_in handles silently via signInSilently()

DRIVE API ERRORS:
  DetailedApiRequestError status 401: call silentSignIn(), retry once
  Status 403: "Permission denied for this file"
  Status 404: remove from cache, show "File no longer exists in Flashy Disk"
  Status 429: exponential backoff (1s, 2s, 4s, 8s), show "Please wait..."
  Status 500/503: auto-retry 3 times then show "Google Drive is unavailable"

FILE SYSTEM ERRORS:
  FileSystemException (permission denied): open permission settings
  FileSystemException (no space): "Not enough storage on your device"
  FileSystemException (not found): "File was moved or deleted"

ALL USER-VISIBLE ERRORS:
  Minor: SnackBar, 4 seconds, no action or [Retry] action
  Major: AlertDialog, user must dismiss
  NEVER show: raw exception messages, stack traces, or error codes
  ALWAYS in plain English, ALWAYS with a suggested action

================================================================================
                      SECTION 22: DIRECTORY STRUCTURE
================================================================================

lib/
  main.dart                          ← Firebase.initializeApp + ProviderScope
  app.dart                           ← MaterialApp.router with GoRouter
  firebase_options.dart              ← Generated by FlutterFire CLI

  providers/
    auth_provider.dart
    drive_provider.dart
    file_system_provider.dart
    transfer_provider.dart
    theme_provider.dart
    settings_provider.dart
    clipboard_provider.dart
    selection_provider.dart
    connectivity_provider.dart
    upload_popup_provider.dart

  models/
    drive_file.dart
    local_file_item.dart
    transfer.dart
    app_settings.dart
    upload_queue_item.dart

  services/
    auth_service.dart               ← Firebase + GoogleSignIn + DriveApi client
    drive_service.dart              ← All Drive API operations
    file_service.dart               ← Local file operations (dart:io)
    transfer_service.dart           ← Upload/download + queue management
    cache_service.dart              ← SQLite operations (sqflite)
    notification_service.dart       ← flutter_local_notifications
    thumbnail_service.dart          ← Thumbnail loading + caching
    permission_service.dart         ← permission_handler wrapper
    connectivity_service.dart       ← connectivity_plus wrapper

  screens/
    onboarding/
      onboarding_screen.dart
    auth/
      login_screen.dart
    home/
      home_screen.dart
    file_browser/
      file_browser_screen.dart      ← shared for local + Drive folders
      flashy_disk_screen.dart       ← Drive root + subfolder navigation
    search/
      search_screen.dart
    transfers/
      transfers_screen.dart
    settings/
      settings_screen.dart
      account_settings_screen.dart
    preview/
      image_preview_screen.dart
      video_preview_screen.dart
      audio_preview_screen.dart
      text_preview_screen.dart
      pdf_preview_screen.dart
      archive_preview_screen.dart

  widgets/
    home/
      flashy_disk_card.dart         ← The prominent top card
      storage_bar.dart
      device_locations_list.dart
      onboarding_guide_banner.dart
    file_browser/
      file_list_view.dart
      file_grid_view.dart
      file_list_item.dart
      file_grid_item.dart
      file_icon_widget.dart         ← Type-based icon + background
      skeleton_list.dart
      skeleton_grid.dart
      empty_state_widget.dart
      sort_bar.dart
    flashy_disk/
      upload_popup.dart             ← Floating draggable upload popup
      upload_popup_minimized.dart   ← Pill state
      offline_banner.dart
      offline_warning_sheet.dart
    selection/
      selection_app_bar.dart
      selection_bottom_bar.dart
    bottom_sheets/
      file_context_sheet.dart       ← ⋮ menu for a file
      new_item_sheet.dart           ← FAB + menu
      rename_sheet.dart
      properties_sheet.dart
      sort_options_sheet.dart
      compress_sheet.dart
      extract_sheet.dart
    common/
      confirm_dialog.dart
      progress_snackbar.dart
      connectivity_banner.dart
    settings/
      theme_selector_cards.dart
      accent_color_picker.dart
      settings_section_header.dart

  utils/
    file_utils.dart                 ← Size formatting, type detection, icon mapping
    date_utils.dart
    path_utils.dart
    mime_utils.dart
    permission_utils.dart

  constants/
    app_colors.dart                 ← All color constants
    app_theme.dart                  ← ThemeData light + dark
    app_strings.dart                ← All user-visible strings
    drive_constants.dart            ← Folder names, API limits

  assets/
    lottie/
      upload_success.json
      offline.json
      empty_disk.json
      onboarding.json
    icons/
      flashy_disk_icon.svg          ← Custom disk chip icon

android/
  app/
    google-services.json            ← PASTE THE PROVIDED JSON HERE (Section 0)
    build.gradle                    ← applicationId: "com.flashy.com", minSdk: 23

ios/
  Runner/
    GoogleService-Info.plist        ← Download from Firebase Console
    Info.plist                      ← Add URL schemes for Google Sign-In

================================================================================
                      SECTION 23: IMPLEMENTATION ORDER
================================================================================

PHASE 1 — Project Setup (Day 1-2):
  1. flutter create with package name: com.flashy.com
  2. Add all packages to pubspec.yaml
  3. Place google-services.json in android/app/
  4. Run flutterfire configure to generate firebase_options.dart
  5. Initialize Firebase in main.dart
  6. Set up Riverpod ProviderScope, GoRouter
  7. Set up ThemeData (light + dark, Material 3)
  8. Build bottom navigation scaffold (3 tabs)

PHASE 2 — Authentication (Day 2-3):
  9. AuthService (Firebase + GoogleSignIn + getDriveApi)
  10. LoginScreen UI (logo, tagline, Continue with Google button)
  11. Login button states (default, loading, error)
  12. Auth state stream → GoRouter redirect
  13. Silent sign-in on app launch
  14. Sign out flow + confirmation

PHASE 3 — Home Screen (Day 3-4):
  15. Flashy Disk card widget (logged in state)
  16. Storage bar with animation
  17. Onboarding guide banner (dismissible, persisted)
  18. Device locations list (Internal, Downloads, Photos, etc.)
  19. Drive quota fetch and display

PHASE 4 — Local File Manager (Day 5-8):
  20. Permission service + first-time permission bottom sheet
  21. FileService (list dir, read, copy, move, delete, rename)
  22. File browser screen (list view)
  23. FileIconWidget (type-based icon + color)
  24. File list item (name, size, date, ⋮ button)
  25. Context bottom sheet (all file operations)
  26. Swipe actions (delete left, copy right)
  27. Navigation history (back/forward)
  28. Grid view
  29. Rename bottom sheet
  30. Delete with undo snackbar
  31. Multi-select + selection app bar + bottom action bar
  32. Folder creation
  33. Archive (compress + extract)
  34. File preview screens (image, video, text)

PHASE 5 — Flashy Disk (Day 9-13):
  35. DriveService (create /Flashy/ folder, list, create subfolder)
  36. SQLite cache (cache_service.dart)
  37. Flashy Disk browser screen (cache-first)
  38. Sync (fetch metadata, diff with cache, update)
  39. Upload flow: local → Drive with progress
  40. Upload popup widget (full + minimized, draggable)
  41. Download flow: Drive → local cache
  42. Offline detection + banner + blocking sheet
  43. Offline upload queue
  44. Upload complete notification
  45. Paste local file → Flashy Disk (core use case)

PHASE 6 — Transfers & Search (Day 14-15):
  46. Transfers screen (active, queued, completed, failed)
  47. Search screen (local + Drive, filters, recent searches)

PHASE 7 — Settings & Polish (Day 16-18):
  48. Settings screen (all sections)
  49. Account settings sub-screen
  50. Theme switching (AnimatedTheme)
  51. Accent color picker
  52. All Lottie animations
  53. All staggered list animations
  54. All shimmer skeletons
  55. Empty states for all screens

PHASE 8 — Final (Day 19-20):
  56. Full error handling pass (all screens)
  57. Accessibility (semantics, min 48dp targets)
  58. Performance: ListView.builder everywhere, image caching
  59. App icon + splash screen
  60. Test on Android (real device) + iOS simulator
  61. Fix any UI overflow issues on small screens

================================================================================
                      SECTION 24: FINAL RULES FOR AI ASSISTANT
================================================================================

1. ZERO GRADIENTS. Not one LinearGradient anywhere in the entire app.
   Every background, every bar, every button is a flat solid color.

2. FIREBASE = AUTH ONLY. No Firestore. No Firebase Storage. No Analytics.
   No Cloud Functions. No Realtime Database. ONLY Firebase Auth + Google Sign-In.

3. PACKAGE NAME IS "com.flashy.com" — use this everywhere exactly as written.

4. google-services.json IS PROVIDED IN SECTION 0. Do not create a placeholder.
   Use the exact JSON content from Section 0 in android/app/google-services.json.

5. THE UPLOAD POPUP IS ALWAYS VISIBLE ACROSS ALL SCREENS.
   It lives in the root Stack of the app, NOT inside any individual screen.
   Implemented in app.dart as a Stack over the navigator.

6. ALL FILE OPERATIONS FEEL INSTANT.
   Update UI first (optimistic update), then do the actual operation.
   Roll back UI if operation fails.

7. NEVER SHOW TECHNICAL ERROR MESSAGES TO USERS.
   All errors in plain English. All errors have an action (Retry, Settings, etc.)

8. FLASHY DISK ICON IS UNIQUE — NOT a standard folder icon.
   It is a rounded rectangle with a lightning bolt inside.
   Build as a custom widget with Container + Icon.

9. PERMISSIONS ARE REQUESTED PROGRESSIVELY.
   Never request storage permission on app launch.
   Only when the user first tries to browse local files.

10. KEYBOARD OPENS IMMEDIATELY in all bottom sheets that have text input.
    Use autofocus: true on all TextFields in bottom sheets.

11. ALL LISTS USE ListView.builder or GridView.builder (never ListView with children:[]).
    This is mandatory for performance with large file counts.

12. SMOOTH THEME TRANSITIONS. Wrap MaterialApp with theme and darkTheme.
    Use AnimatedTheme for smooth color interpolation on theme switch.

13. RUN flutterfire configure AFTER package setup to generate firebase_options.dart.
    Command: flutterfire configure --project=flashy-647b2

14. MINIMUM SDK: Android minSdkVersion 23 (Android 6.0 Marshmallow).
    This is required for flutter_secure_storage and other packages.

================================================================================
                          END OF MASTER PROMPT v2.0
================================================================================


]



Add to Github : error 
Microsoft Windows [Version 10.0.19045.6466]                                          
(c) Microsoft Corporation. All rights reserved.                                      
                                                                                     
C:\flutter_app_website\Flashy\flashy>echo "# flashy" >> README.md                    
                                                                                     
C:\flutter_app_website\Flashy\flashy>git init                                        
Initialized empty Git repository in C:/flutter_app_website/Flashy/flashy/.git/

C:\flutter_app_website\Flashy\flashy>git add README.md

C:\flutter_app_website\Flashy\flashy>git commit -m "first commit"
[master (root-commit) 4be3c75] first commit
 1 file changed, 4 insertions(+)
 create mode 100644 README.md

C:\flutter_app_website\Flashy\flashy>git branch -M main

C:\flutter_app_website\Flashy\flashy>git remote add origin https://github.com/theDev-Boy/flashy.git

C:\flutter_app_website\Flashy\flashy>git push -u origin main
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Writing objects: 100% (3/3), 259 bytes | 129.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Internal Server Error
remote: Request ID EC8C:3EA3B3:4D496A:52B7D3:6A14105D
remote: Time 2026-05-25T09:03:27Z
To https://github.com/theDev-Boy/flashy.git
 ! [remote rejected] main -> main (Internal Server Error)
error: failed to push some refs to 'https://github.com/theDev-Boy/flashy.git'

C:\flutter_app_website\Flashy\flashy>git push
fatal: The current branch main has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin main

To have this happen automatically for branches without a tracking
upstream, see 'push.autoSetupRemote' in 'git help config'.


C:\flutter_app_website\Flashy\flashy>git push --set-upstream origin main
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Writing objects: 100% (3/3), 259 bytes | 1024 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Internal Server Error
remote: Request ID ECBF:37EA07:4C992F:51FA4A:6A14107D
remote: Time 2026-05-25T09:04:02Z
To https://github.com/theDev-Boy/flashy.git
 ! [remote rejected] main -> main (Internal Server Error)
error: failed to push some refs to 'https://github.com/theDev-Boy/flashy.git'

C:\flutter_app_website\Flashy\flashy>


Build a wokrflow like this :
name: Build APK

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: 📥 Checkout repository
        uses: actions/checkout@v4

      - name: ☕ Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: "temurin"
          java-version: "17"

      - name: 🎯 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: "stable"

      - name: 💾 Cache Flutter & Gradle dependencies
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
            ~/.pub-cache
          key: ${{ runner.os }}-flutter-${{ hashFiles('pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-flutter-

      - name: 📦 Install dependencies
        run: flutter pub get

      - name: 🔍 Analyze code
        run: flutter analyze

      - name: 🔨 Build APK
        run: flutter build apk

      - name: 📤 Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk 
# Implementation Reflection

## Overview
Integrating Firebase with Flutter for this Kigali City Services directory required careful handling of asynchronous state, Firestore data modeling, and authentication constraints such as email verification.

## Key Integration Challenges and Resolutions

### Challenge 1: Firebase initialization error at app start

**Observed issue**
`[core/no-app] No Firebase App '[DEFAULT]' has been created` appeared when navigating to screens that relied on Firebase before initialization completed.

**Root cause**
App screens were rendered before Firebase initialization was complete.

**Resolution**
- Added startup bootstrap in `lib/app.dart` using `FutureBuilder(Firebase.initializeApp())`
- Displayed loading and explicit initialization error UI
- Routed to `AuthGate` only after initialization completes

**Result**
No premature Firebase access at startup.

---

### Challenge 2: Email verification not reflected immediately

**Observed issue**
A verified user remained blocked after clicking the email verification link because local auth state had stale `emailVerified` value.

**Root cause**
Firebase user object is cached until explicitly reloaded.

**Resolution**
- Added `reloadCurrentUser()` in `AuthService`
- Added "I Verified, Refresh" action in `VerifyEmailScreen`
- Synced user profile document with updated verification status

**Result**
Users can verify email and immediately proceed without restarting the app.

---

### Challenge 3: Firestore query/index issue on My Listings

**Observed issue**
Firestore required a composite index for query:
- `where('createdBy', isEqualTo: uid)`
- `orderBy('createdAt', descending: true)`

**Root cause**
Combined filtering + ordering requires a composite Firestore index.

**Resolution**
- Kept query in service layer for clean architecture
- Created required index via Firebase Console link from runtime logs

**Result**
My Listings loads in real time and stays sorted by newest first.

## State Management Reflection

Riverpod improved separation of concerns by:
- keeping Firestore/Auth logic out of widgets,
- exposing reactive stream providers for real-time updates,
- and handling loading/error/success through `AsyncValue`.

This made Directory, My Listings, and Map screens rebuild automatically whenever data changed in Firestore.

## What I would improve next

- Persist notification toggle using local storage (`shared_preferences`)
- Add form validation for Rwanda phone number patterns
- Add Firestore security rules tests and emulator-based integration tests

## Screenshots to include before PDF submission

Replace this section with your own screenshots from your machine:
1. Firebase init error message
2. Firestore index prompt/error
3. Email verification enforcement flow

> Export this file to PDF as: `Implementation_Reflection.pdf`

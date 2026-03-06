# Demo Video Script (7–12 minutes)

## Target Duration
- 8 to 10 minutes

## Recording Setup
- Show emulator/phone on one side
- Show code + Firebase Console on the other side (split screen)

## Flow

### 1) Intro (0:00–0:45)
- State app name and objective
- Mention stack: Flutter + Firebase Auth + Cloud Firestore + Riverpod

### 2) Architecture Walkthrough (0:45–2:00)
- Show folders: `models`, `services`, `controllers`, `providers`, `screens`
- Explain no direct Firestore calls in UI
- Show `providers.dart` and one controller method

### 3) Authentication (2:00–3:30)
- Sign up with email/password
- Show verification-required screen
- Open email link and verify
- Tap refresh and access app
- Show user profile doc in Firestore `users/{uid}`

### 4) Create Listing (3:30–4:40)
- Go to My Listings
- Tap Add Listing and submit
- Show new document in Firestore `listings`
- Show listing appears immediately in Directory/My Listings/Map

### 5) Edit Listing (4:40–5:30)
- Open menu on listing > Edit
- Change fields and save
- Show updates in app and Firestore

### 6) Delete Listing (5:30–6:10)
- Delete listing from My Listings
- Show it disappears in real time
- Confirm removal in Firestore

### 7) Search + Filtering (6:10–7:00)
- Search by partial listing name
- Change category filters
- Show dynamic result updates

### 8) Detail + Map + Navigation (7:00–8:20)
- Open listing detail
- Show embedded map marker from Firestore coordinates
- Tap navigation button to launch Google Maps directions

### 9) Settings + Wrap-up (8:20–9:00)
- Show profile information
- Toggle location-based notifications setting
- Logout and return to auth

## Required Code Files to Show During Demo
- `lib/services/auth_service.dart`
- `lib/services/listing_service.dart`
- `lib/providers/providers.dart`
- `lib/controllers/listing_controller.dart`
- `lib/screens/directory/directory_screen.dart`
- `lib/screens/listings/my_listings_screen.dart`
- `lib/screens/listings/listing_detail_screen.dart`
- `lib/screens/map/map_view_screen.dart`

## Final Checklist Before Recording
- Firebase auth enabled
- Firestore indexes created
- Google Maps key configured
- Email inbox available for verification
- Emulator reset to clean start state

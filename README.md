## Kigali City Services

Flutter mobile app that helps Kigali residents discover and manage essential city services and public places, built with **Flutter**, **Firebase Authentication**, **Cloud Firestore**, **Google Maps**, and **Riverpod** for state management.

This README is written to satisfy the assignment requirement for a clear explanation of **features**, **Firestore database structure**, **state management approach**, and **navigation structure**.

---

### 1. Features Overview

- **Authentication (Firebase Auth + email verification)**
  - Email/password **signup, login, and logout** using Firebase Authentication.
  - **Email verification enforced**: unverified users are redirected to a verification screen until their email is confirmed.
  - A **user profile document** is created/maintained in Firestore at `users/{uid}` for every authenticated user.

- **Location listings (CRUD with Firestore)**
  - Users can **create, view, edit, and delete** listings of services/places in Kigali.
  - Each listing includes:
    - Place/Service name
    - Category (Hospital, Police Station, Library, Restaurant, Café, Park, Tourist Attraction, etc.)
    - Address
    - Contact number
    - Description
    - Geographic coordinates (latitude & longitude)
    - `createdBy` (creator’s Firebase UID)
    - `createdAt` (timestamp)
  - **Directory** tab shows all listings (shared directory).
  - **My Listings** tab shows only listings whose `createdBy` matches the current user’s UID.

- **Search and category filtering**
  - Users can **search by name** and **filter by category**.
  - Search text and category chips drive a filtered view of Firestore-backed listings.
  - Results update **dynamically** as Firestore data changes (no manual refresh).

- **Detail page & map integration**
  - Tapping a listing opens a detail page that displays all listing fields.
  - An embedded **Google Map** shows a marker at the listing’s coordinates.
  - A **“Open Navigation”** button launches turn‑by‑turn directions in the Google Maps app using the stored latitude/longitude.

- **Map View**
  - A dedicated **Map View** tab renders all listings on a map as markers.
  - Initial camera position centers on Kigali or the first listing returned from Firestore.

- **Settings**
  - Shows the **authenticated user’s profile** (name + email) read from the `users` collection.
  - Provides a **location‑based notifications toggle** stored locally (simulated as allowed by the assignment).
  - Includes a **Logout** button wired to Firebase Auth via the state management layer.

- **Navigation**
  - A bottom `NavigationBar` provides four main tabs:
    - Directory
    - My Listings
    - Map View
    - Settings

---

### 2. Tech Stack

- **Flutter** (Dart 3.x)
- **Firebase**
  - Authentication (email/password + email verification)
  - Cloud Firestore (NoSQL database)
- **State management**: Riverpod
- **Maps**: `google_maps_flutter`
- **Deep links / external navigation**: `url_launcher`

---

### 3. Architecture & Folder Structure

Application state and Firebase access are **not** handled inside UI widgets. Instead, there is a clear separation between:

- **Models** (data structures)
- **Services** (Firestore/Auth access)
- **Controllers** (stateful logic for mutations)
- **Providers** (Riverpod wiring between data and UI)
- **Screens & widgets** (presentation only)

Key layout:

```text
lib/
  main.dart                 # App entry, Firebase.initializeApp + ProviderScope
  app.dart                  # MaterialApp + AuthGate

  core/
    constants.dart          # Shared constants (e.g., category list)
    theme.dart              # Light theme, colors, typography

  models/
    listing.dart            # Listing model + Firestore mapping
    user_profile.dart       # UserProfile model + Firestore mapping

  services/
    auth_service.dart       # FirebaseAuth + Firestore user profile logic
    listing_service.dart    # Firestore CRUD for listings

  controllers/
    auth_controller.dart    # Auth mutations and AsyncValue state
    listing_controller.dart # Listing mutations (create/update/delete) and AsyncValue state

  providers/
    providers.dart          # Riverpod providers for Firebase, services, controllers, streams, filters, etc.

  screens/
    auth/                   # Login/Sign Up UI, email verification screen
    home/                   # HomeShell with bottom navigation
    directory/              # Shared directory of all listings
    listings/               # My listings, listing form, listing detail
    map/                    # Map view showing all listings
    settings/               # Settings + profile + notifications toggle

  widgets/
    listing_card.dart       # Reusable card for displaying a listing
```

---

### 4. Firestore Database Structure

The app uses **two main collections**: `users` and `listings`.

#### 4.1 `users` collection

- **Document ID**: Firebase Auth UID (`user.uid`)
- **Fields**:
  - `uid` (`String`): same as document ID
  - `email` (`String`)
  - `displayName` (`String?`)
  - `emailVerified` (`bool`)
  - `createdAt` (`Timestamp`)

Example:

```json
{
  "uid": "auth_uid",
  "email": "student@example.com",
  "displayName": "Student Name",
  "emailVerified": true,
  "createdAt": "Timestamp"
}
```

#### 4.2 `listings` collection

- **Document ID**: auto‑generated by Firestore
- **Fields**:
  - `name` (`String`)
  - `category` (`String`)
  - `address` (`String`)
  - `contactNumber` (`String`)
  - `description` (`String`)
  - `latitude` (`double`)
  - `longitude` (`double`)
  - `createdBy` (`String` – UID referencing `users/{uid}`)
  - `createdAt` (`Timestamp`)

Example:

```json
{
  "name": "CHUK Hospital",
  "category": "Hospital",
  "address": "KN 123 St, Kigali",
  "contactNumber": "+250 788 000 000",
  "description": "24/7 emergency services.",
  "latitude": -1.9579,
  "longitude": 30.0915,
  "createdBy": "auth_uid",
  "createdAt": "Timestamp"
}
```

This schema supports:

- Global browsing (Directory – all listings)
- User‑specific views (My Listings – filtered by `createdBy == current UID`)
- Map markers & navigation using persisted coordinates

---

### 5. State Management Approach (Riverpod)

The app uses **Riverpod** to connect Firebase to the UI in a clean, testable way.

- **Firebase providers**
  - `firebaseAuthProvider` – exposes `FirebaseAuth.instance`
  - `firestoreProvider` – exposes `FirebaseFirestore.instance`

- **Service providers**
  - `authServiceProvider` – wraps `AuthService`
  - `listingServiceProvider` – wraps `ListingService`

- **Controllers (mutation state)**
  - `authControllerProvider` – a `StateNotifier<AsyncValue<void>>` used for:
    - Signup, login, logout, resend verification email, reload user
  - `listingControllerProvider` – a `StateNotifier<AsyncValue<void>>` used for:
    - Create, update, and delete listing
  - Controllers expose **loading/success/error** via `AsyncValue`, which the UI uses to show progress indicators and error SnackBars.

- **Stream providers (read state)**
  - `authStateChangesProvider` – Firebase Auth user stream
  - `currentUserProfileProvider` – Firestore stream of the current user’s profile document
  - `allListingsProvider` – all listings ordered by `createdAt` descending
  - `myListingsProvider` – listings filtered by `createdBy == current UID`

- **Filter and UI state providers**
  - `searchQueryProvider` – current search text
  - `selectedCategoryProvider` – current category filter (e.g., “All”, “Hospital”)
  - `notificationsEnabledProvider` – local toggle for settings screen
  - `filteredListingsProvider` – derived provider combining `allListingsProvider`, `searchQueryProvider`, and `selectedCategoryProvider` to produce the list shown in the Directory screen.

**Key principle:** **UI widgets never call Firestore or Firebase Auth directly.** They only:

1. **Read** from Riverpod providers to render state.
2. **Call** controller methods (which delegate to services) for CRUD and auth mutations.

This satisfies the rubric’s requirement that Firestore operations go through a dedicated service/repository layer and state management solution.

---

### 6. Navigation Structure

Navigation is built around a **bottom `NavigationBar` shell**:

- `HomeShell` hosts:
  - **Directory** (`DirectoryScreen`) – shared listing directory with category chips, search input, and a scrollable list of filtered listings.
  - **My Listings** (`MyListingsScreen`) – the current user’s listings with **edit/delete** actions and a FAB to open the **listing form**.
  - **Map View** (`MapViewScreen`) – city map with markers for all listings.
  - **Settings** (`SettingsScreen`) – user profile info + notification toggle + logout.

Additional navigation flows:

- From **Directory** and **My Listings**, tapping a card opens **ListingDetailScreen**.
- From **My Listings**, FAB opens **ListingFormScreen** in **create** mode; popup menu opens the same screen in **edit** mode.
- `AuthGate` decides whether to show:
  - `AuthScreen` (login / signup tabs),
  - `VerifyEmailScreen` (until the user’s email is verified),
  - or `HomeShell` (for verified users).

---

### 7. Running the App Locally

1. **Prerequisites**
   - Flutter SDK installed and on your `PATH`.
   - Android Studio / Android emulator or Xcode + iOS Simulator / physical device.
   - Firebase project configured for Android and iOS (already done via `flutterfire configure` for project ID `kigalicityservices-250`).

2. **Clone the repository**

```bash
git clone https://github.com/<your-username>/kigali_city_services.git
cd kigali_city_services
```

3. **Install dependencies**

```bash
flutter pub get
```

4. **(If needed) Reconfigure FlutterFire**

If you change the Firebase project, run:

```bash
flutterfire configure --project <your-firebase-project-id> --platforms android,ios
```

This regenerates `lib/firebase_options.dart`.

5. **Run on a device or emulator**

```bash
flutter run
```

> Note: This project is designed and graded for **Android/iOS**. A pure web build will not meet the assignment requirements.

---

### 8. Demo Video Checklist (7–12 minutes)

Use this checklist while recording your demo video to align with the rubric:

- **Authentication**
  - Show signup with email/password.
  - Show email verification enforcement (cannot access app until verified).
  - Show login and logout.
  - With Firebase Console visible, point to the **Auth** users list and the `users` collection document.

- **Listings CRUD**
  - Create a new listing (Directory/My Listings update immediately).
  - Edit an existing listing and show the updated data reflected in:
    - My Listings
    - Directory
    - Map View / Detail screen (if relevant).
  - Delete a listing and show it disappearing from My Listings, Directory, and Firebase Console (`listings` collection).

- **Search & filter**
  - Demonstrate searching by name and filtering by category.
  - Explain briefly how `filteredListingsProvider` combines Firestore streams + filters.

- **Detail & map**
  - Open a listing detail page.
  - Show the embedded Google Map with a marker.
  - Tap the button to launch external Google Maps navigation to that coordinate.

- **Map View**
  - Show the Map View tab with markers for all places.

- **Code walkthrough**
  - While demonstrating, show:
    - `auth_service.dart`, `listing_service.dart` (Firestore/Auth layer)
    - `auth_controller.dart`, `listing_controller.dart` (state layer)
    - `providers.dart` (Riverpod wiring)
    - Key screens (Directory, My Listings, Map View, Settings, Auth, VerifyEmail) to explain how state flows from Firestore → providers → UI.

---
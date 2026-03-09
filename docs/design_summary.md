# Design Summary (Kigali City Services)

This document is intended to be exported to PDF (1–2 pages) and included as the **Design Summary** section of your assignment submission.

---

## 1. Firestore Database Design

The backend is intentionally small but expressive, using **two top‑level collections**: `users` and `listings`. This keeps queries simple and aligns directly with the assignment’s requirements for authentication and location listings.

### 1.1 `users` collection

- **Document ID**: Firebase Auth UID (`user.uid`)
- **Fields**:
  - `uid` (`String`) – redundant copy of the document ID for convenience
  - `email` (`String`) – the user’s email from Firebase Auth
  - `displayName` (`String?`) – optional full name provided at sign‑up
  - `emailVerified` (`bool`) – mirrors the Auth flag so UI can be driven from Firestore if needed
  - `createdAt` (`Timestamp`) – when the profile document was first created

This collection is written by `AuthService` whenever a user signs up or when their profile is synchronized after login/verification.

### 1.2 `listings` collection

- **Document ID**: auto‑generated Firestore ID for each listing
- **Fields**:
  - `name` (`String`) – place or service name
  - `category` (`String`) – e.g., Hospital, Police Station, Restaurant, Café, Park, Tourist Attraction
  - `address` (`String`) – human‑readable address
  - `contactNumber` (`String`) – phone contact
  - `description` (`String`) – free‑text description
  - `latitude` (`double`) – geographic latitude
  - `longitude` (`double`) – geographic longitude
  - `createdBy` (`String`) – Firebase UID referencing `users/{uid}`
  - `createdAt` (`Timestamp`) – creation time used for ordering and recent listings

This schema supports:

- Global directory views (query entire `listings` collection)
- User‑specific views (filter by `createdBy`)
- Mapping and navigation (use `latitude` and `longitude` in Google Maps)

---

## 2. Listings Modelling and CRUD Strategy

### 2.1 Listing model

Listings are represented by the `Listing` model (`lib/models/listing.dart`), which:

- Encapsulates all listing fields as strongly‑typed properties.
- Provides `toMap()` to serialize data into Firestore‑friendly JSON.
- Provides `Listing.fromFirestore(...)` to construct model instances from Firestore snapshots.
- Offers a `copyWith(...)` method used for **immutable updates** in edit workflows.

Keeping the mapping logic inside the model simplifies both the service layer and the UI; any field changes are made once in the model instead of scattered across the codebase.

### 2.2 CRUD service layer

All listings CRUD is centralized in `ListingService` (`lib/services/listing_service.dart`):

- `watchAllListings()` – returns a `Stream<List<Listing>>` ordered by `createdAt` descending.
- `watchListingsByUser(String uid)` – returns a stream filtered by `createdBy == uid`.
- `createListing(Listing listing)` – inserts a new document into `listings`.
- `updateListing(Listing listing)` – updates an existing document by ID.
- `deleteListing(String listingId)` – deletes a listing.

The **UI never calls Firestore directly**. Instead, `ListingController` (a Riverpod `StateNotifier`) is responsible for:

- Constructing a new `Listing` instance (including `createdBy` UID and `createdAt` timestamp).
- Calling the appropriate `ListingService` methods.
- Exposing loading and error states through `AsyncValue<void>`.

This division of responsibilities ensures a clear separation of concerns:

- **Models** define data.
- **Services** talk to Firebase.
- **Controllers** manage user actions and mutation state.
- **Screens** are thin and react to provider state only.

---

## 3. State Management Design (Riverpod)

The app uses **Riverpod** to meet the requirement that state management be used for Firestore access and to avoid direct Firebase calls inside UI widgets.

### 3.1 Provider groups

- **Core Firebase providers**
  - `firebaseAuthProvider` – exposes `FirebaseAuth.instance`
  - `firestoreProvider` – exposes `FirebaseFirestore.instance`

- **Service providers**
  - `authServiceProvider` – wraps `AuthService`, which encapsulates all Auth + user‑profile logic.
  - `listingServiceProvider` – wraps `ListingService`, which encapsulates all listings CRUD.

- **Auth state providers**
  - `authStateChangesProvider` – stream of `User?` from Firebase Auth.
  - `currentUidProvider` – convenience provider for the current user’s UID.
  - `currentUserProfileProvider` – stream of `UserProfile` from `users/{uid}`.

- **Listings state providers**
  - `allListingsProvider` – stream of all listings from `ListingService`.
  - `myListingsProvider` – stream filtered to only the current user’s listings.

- **Filter and UI state**
  - `searchQueryProvider` – the current text in the search box.
  - `selectedCategoryProvider` – the chosen category (All/Hospital/etc.).
  - `notificationsEnabledProvider` – local toggle saved only in memory.
  - `filteredListingsProvider` – derived provider combining listings + filters.

- **Controller providers (mutations)**
  - `authControllerProvider` – handles sign up, sign in, sign out, resend verification, and user reload.
  - `listingControllerProvider` – handles create, update, and delete listing actions.

### 3.2 AsyncValue and UI behaviour

Controllers expose their state as `AsyncValue<void>`. The UI responds by:

- Displaying progress indicators while `isLoading` is `true`.
- Reacting to `error` states with SnackBars or textual error messages.
- Automatically closing forms when a mutation completes and the previous state was loading.

For read operations, `AsyncValue<List<Listing>>` and `AsyncValue<UserProfile?>` allow screens such as **Directory**, **My Listings**, and **Settings** to render loading spinners and error messages in a consistent, declarative way.

---

## 4. Navigation and Screen Responsibilities

The navigation design centers around a **bottom navigation shell** implemented in `HomeShell`:

1. **Directory** – consumes `filteredListingsProvider` and renders:
   - Category chips tied to `selectedCategoryProvider`.
   - A search field tied to `searchQueryProvider`.
   - A list of cards that navigate to `ListingDetailScreen`.

2. **My Listings** – consumes `myListingsProvider`:
   - Shows only listings where `createdBy` equals the current user’s UID.
   - Provides edit/delete actions via `ListingController`.
   - Floating Action Button opens `ListingFormScreen` to create a new listing.

3. **Map View** – consumes `allListingsProvider`:
   - Displays all listings as markers on `GoogleMap`.
   - Uses the first listing or a default Kigali coordinate as initial camera position.

4. **Settings** – consumes `currentUserProfileProvider` and `notificationsEnabledProvider`:
   - Renders user profile info.
   - Offers a toggle for simulated location notifications.
   - Exposes logout via `AuthController`.

An `AuthGate` composable decides whether to show:

- Authentication UI (login/sign‑up tabs),
- Email verification screen, or
- The `HomeShell` with all four tabs.

---

## 5. Design Trade‑offs and Technical Challenges

### 5.1 Design trade‑offs

- **Riverpod vs. other state managers**  
  Riverpod was chosen instead of Bloc or Provider to reduce boilerplate, provide strong typing around `AsyncValue`, and keep global state definitions centralized in `providers.dart`. This makes it easier to explain data flow during the demo.

- **Simple, flat Firestore schema**  
  Using flat `users` and `listings` collections avoids complex subcollection queries and keeps rules readable. Cross‑document relationships are expressed via `createdBy` UID instead of nested data structures.

- **Text entry for coordinates**  
  Latitude and longitude are entered as text fields in the form instead of being picked from a live map. This keeps the focus on Firebase CRUD and state management while still providing realistic data for Google Maps integration.

- **Local notification preference**  
  The notification toggle is intentionally implemented as local state only (no FCM), matching the assignment’s allowance for simulated notification preferences and avoiding extra setup complexity.

### 5.2 Technical challenges (for reflection)

Some notable technical issues encountered during development (you can expand on these in your reflection PDF and include screenshots):

- **FlutterFire CLI and project configuration**  
  - Installing and activating `flutterfire_cli`, ensuring it was on the `PATH`, and running  
    `flutterfire configure --project=kigalicityservices-250 --platforms=android,ios`.  
  - Resolving the `xcodeproj` Ruby gem error on macOS by installing `cocoapods` and `xcodeproj`.

- **Ensuring single, centralized Firebase initialization**  
  - Moving all initialization logic to `main.dart` using `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` and simplifying `app.dart` to avoid double initialization issues.

- **Email verification enforcement**  
  - Making sure that unverified users are blocked from accessing the main app shell and are instead routed to a dedicated verification screen with actions to resend the email and reload the user.

Documenting these challenges makes it clearer in the reflection how the architecture supports error handling and debugging for Firebase features.

---

> **Submission tip:**  
> Export this file as `Design_Summary.pdf` and include it in your final single PDF document alongside your **Implementation Reflection**, **GitHub link**, and **demo video link**. Make sure the reflection is written in your own words and that you understand all of the code paths you present. 


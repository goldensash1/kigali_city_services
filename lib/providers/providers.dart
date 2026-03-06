import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../controllers/listing_controller.dart';
import '../models/listing.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/listing_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(firebaseAuthProvider), ref.read(firestoreProvider));
});

final listingServiceProvider = Provider<ListingService>((ref) {
  return ListingService(ref.read(firestoreProvider));
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});

final listingControllerProvider =
    StateNotifierProvider<ListingController, AsyncValue<void>>((ref) {
  return ListingController(ref);
});

final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateChangesProvider).value?.uid;
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.read(authServiceProvider).watchCurrentUserProfile();
});

final allListingsProvider = StreamProvider<List<Listing>>((ref) {
  return ref.read(listingServiceProvider).watchAllListings();
});

final myListingsProvider = StreamProvider<List<Listing>>((ref) {
  final String? uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return Stream<List<Listing>>.value(const <Listing>[]);
  }
  return ref.read(listingServiceProvider).watchListingsByUser(uid);
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

final filteredListingsProvider = Provider<AsyncValue<List<Listing>>>((ref) {
  final AsyncValue<List<Listing>> allListings = ref.watch(allListingsProvider);
  final String query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final String category = ref.watch(selectedCategoryProvider);

  return allListings.whenData((listings) {
    return listings.where((listing) {
      final bool matchesQuery = query.isEmpty || listing.name.toLowerCase().contains(query);
      final bool matchesCategory = category == 'All' || listing.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  });
});

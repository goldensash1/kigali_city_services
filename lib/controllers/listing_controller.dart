import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/listing.dart';
import '../providers/providers.dart';

class ListingController extends StateNotifier<AsyncValue<void>> {
  ListingController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> createListing({
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    final String? uid = ref.read(currentUidProvider);
    if (uid == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final Listing listing = Listing(
        id: '',
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdBy: uid,
        createdAt: DateTime.now(),
      );
      return ref.read(listingServiceProvider).createListing(listing);
    });
  }

  Future<void> updateListing(Listing listing) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(listingServiceProvider).updateListing(listing);
    });
  }

  Future<void> deleteListing(String listingId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(listingServiceProvider).deleteListing(listingId);
    });
  }
}

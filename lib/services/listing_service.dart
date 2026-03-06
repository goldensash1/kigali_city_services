import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/listing.dart';

class ListingService {
  ListingService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _listingRef =>
      _firestore.collection('listings');

  Stream<List<Listing>> watchAllListings() {
    return _listingRef.orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map(Listing.fromFirestore).toList();
      },
    );
  }

  Stream<List<Listing>> watchListingsByUser(String uid) {
    return _listingRef
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(Listing.fromFirestore).toList(),
        );
  }

  Future<void> createListing(Listing listing) async {
    await _listingRef.add(listing.toMap());
  }

  Future<void> updateListing(Listing listing) async {
    await _listingRef.doc(listing.id).update(listing.toMap());
  }

  Future<void> deleteListing(String listingId) async {
    await _listingRef.doc(listingId).delete();
  }
}

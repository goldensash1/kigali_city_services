import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/listing.dart';
import '../../providers/providers.dart';

class MapViewScreen extends ConsumerWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsState = ref.watch(allListingsProvider);

    return listingsState.when(
      data: (listings) {
        final CameraPosition initialPosition = CameraPosition(
          target: listings.isNotEmpty
              ? LatLng(listings.first.latitude, listings.first.longitude)
              : const LatLng(-1.9441, 30.0619),
          zoom: 12,
        );

        final Set<Marker> markers = listings
            .map(
              (Listing listing) => Marker(
                markerId: MarkerId(listing.id),
                position: LatLng(listing.latitude, listing.longitude),
                infoWindow: InfoWindow(title: listing.name, snippet: listing.category),
              ),
            )
            .toSet();

        return GoogleMap(
          initialCameraPosition: initialPosition,
          markers: markers,
          myLocationButtonEnabled: false,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
  }
}

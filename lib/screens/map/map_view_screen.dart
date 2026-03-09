import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/listing.dart';
import '../../providers/providers.dart';

const double _kigaliLat = -1.9441;
const double _kigaliLng = 30.0619;

bool _isValidCoord(double lat, double lng) {
  return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180 && (lat != 0 || lng != 0);
}

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingsState = ref.watch(allListingsProvider);

    return listingsState.when(
      data: (listings) {
        final validListings = listings.where((l) => _isValidCoord(l.latitude, l.longitude)).toList();
        final LatLng center = validListings.isNotEmpty
            ? LatLng(validListings.first.latitude, validListings.first.longitude)
            : const LatLng(_kigaliLat, _kigaliLng);

        final Set<Marker> markers = validListings
            .map(
              (Listing listing) => Marker(
                markerId: MarkerId(listing.id),
                position: LatLng(listing.latitude, listing.longitude),
                infoWindow: InfoWindow(title: listing.name, snippet: listing.category),
              ),
            )
            .toSet();

        return SizedBox.expand(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: center, zoom: 12),
            markers: markers,
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController c) {
              _mapController = c;
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
  }
}

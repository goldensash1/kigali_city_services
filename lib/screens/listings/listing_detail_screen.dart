import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/listing.dart';

/// Default center (Kigali) when listing coordinates are missing or invalid.
const double _kigaliLat = -1.9441;
const double _kigaliLng = 30.0619;

bool _isValidCoordinate(double lat, double lng) {
  return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180 && (lat != 0 || lng != 0);
}

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key, required this.listing});

  final Listing listing;

  LatLng get _location {
    if (_isValidCoordinate(listing.latitude, listing.longitude)) {
      return LatLng(listing.latitude, listing.longitude);
    }
    return const LatLng(_kigaliLat, _kigaliLng);
  }

  Future<void> _openMapsUrl(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open maps. Install Google Maps or try again.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng location = _location;
    final bool hasValidCoords = _isValidCoordinate(listing.latitude, listing.longitude);
    final double lat = hasValidCoords ? listing.latitude : _kigaliLat;
    final double lng = hasValidCoords ? listing.longitude : _kigaliLng;

    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          SizedBox(
            height: 200,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: location, zoom: 15),
                markers: <Marker>{
                  Marker(
                    markerId: MarkerId(listing.id),
                    position: location,
                    infoWindow: InfoWindow(title: listing.name),
                  ),
                },
                zoomControlsEnabled: true,
                myLocationButtonEnabled: false,
                liteModeEnabled: false,
                mapType: MapType.normal,
              ),
            ),
          ),
          if (!hasValidCoords)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Map centered on Kigali (listing coordinates missing or invalid).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            listing.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('${listing.category} • ${listing.address}'),
          const SizedBox(height: 8),
          Text('Contact: ${listing.contactNumber}'),
          const SizedBox(height: 16),
          Text(listing.description),
          const SizedBox(height: 24),
          Text(
            'Open in Google Maps',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openMapsUrl(context, 'https://www.google.com/maps?q=$lat,$lng'),
                  icon: const Icon(Icons.map_outlined, size: 20),
                  label: const Text('View on map'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openMapsUrl(
                    context,
                    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
                  ),
                  icon: const Icon(Icons.directions_outlined, size: 20),
                  label: const Text('Get directions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

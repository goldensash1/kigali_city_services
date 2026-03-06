import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/listing.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final LatLng location = LatLng(listing.latitude, listing.longitude);

    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE4E7EB)),
            ),
            clipBehavior: Clip.antiAlias,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: location, zoom: 15),
              markers: <Marker>{
                Marker(
                  markerId: MarkerId(listing.id),
                  position: location,
                  infoWindow: InfoWindow(title: listing.name),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
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
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              final Uri uri = Uri.parse(
                'https://www.google.com/maps/dir/?api=1&destination=${listing.latitude},${listing.longitude}',
              );
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.navigation_outlined),
            label: const Text('Open Navigation'),
          ),
        ],
      ),
    );
  }
}

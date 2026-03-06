import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/listing.dart';
import '../../providers/providers.dart';
import '../../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'listing_form_screen.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Listing>> myListings = ref.watch(myListingsProvider);

    ref.listen<AsyncValue<void>>(listingControllerProvider, (previous, next) {
      next.whenOrNull(error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      });
    });

    return Scaffold(
      body: myListings.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('You have not created any listing yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final listing = items[index];
              return ListingCard(
                listing: listing,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: listing),
                    ),
                  );
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListingFormScreen(existingListing: listing),
                        ),
                      );
                    } else if (value == 'delete') {
                      await ref
                          .read(listingControllerProvider.notifier)
                          .deleteListing(listing.id);
                    }
                  },
                  itemBuilder: (context) => const <PopupMenuEntry<String>>[
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListingFormScreen()),
          );
        },
        label: const Text('Add Listing'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

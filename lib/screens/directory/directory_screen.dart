import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../models/listing.dart';
import '../../providers/providers.dart';
import '../../widgets/listing_card.dart';
import '../listings/listing_detail_screen.dart';

class DirectoryScreen extends ConsumerWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Listing>> listings = ref.watch(filteredListingsProvider);
    final String selectedCategory = ref.watch(selectedCategoryProvider);

    return Column(
      children: <Widget>[
        Container(
          color: const Color(0xFF0A2A67),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: listingCategories.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = listingCategories[index];
                    final isSelected = selectedCategory == category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(selectedCategoryProvider.notifier).state = category;
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Search for service',
                  suffixIcon: const Icon(Icons.search),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: listings.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('No listings found.'));
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
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
          ),
        ),
      ],
    );
  }
}

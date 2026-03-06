import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../models/listing.dart';
import '../../providers/providers.dart';

class ListingFormScreen extends ConsumerStatefulWidget {
  const ListingFormScreen({super.key, this.existingListing});

  final Listing? existingListing;

  @override
  ConsumerState<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends ConsumerState<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    final listing = widget.existingListing;

    _nameController = TextEditingController(text: listing?.name ?? '');
    _addressController = TextEditingController(text: listing?.address ?? '');
    _contactController = TextEditingController(text: listing?.contactNumber ?? '');
    _descriptionController = TextEditingController(text: listing?.description ?? '');
    _latitudeController = TextEditingController(
      text: listing != null ? listing.latitude.toString() : '-1.9441',
    );
    _longitudeController = TextEditingController(
      text: listing != null ? listing.longitude.toString() : '30.0619',
    );
    _selectedCategory = listing?.category ?? 'Hospital';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingListing != null;
    final mutationState = ref.watch(listingControllerProvider);

    ref.listen<AsyncValue<void>>(listingControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous?.isLoading == true && mounted) {
            Navigator.pop(context);
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Listing' : 'Create Listing')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Place or Service Name'),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: listingCategories
                  .where((c) => c != 'All')
                  .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value ?? 'Hospital'),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: 'Contact Number'),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _latitudeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Latitude'),
              validator: (value) => double.tryParse(value ?? '') == null ? 'Enter valid latitude' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _longitudeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Longitude'),
              validator: (value) =>
                  double.tryParse(value ?? '') == null ? 'Enter valid longitude' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: mutationState.isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      final latitude = double.parse(_latitudeController.text.trim());
                      final longitude = double.parse(_longitudeController.text.trim());

                      if (isEditing) {
                        final original = widget.existingListing!;
                        await ref.read(listingControllerProvider.notifier).updateListing(
                              original.copyWith(
                                name: _nameController.text.trim(),
                                category: _selectedCategory,
                                address: _addressController.text.trim(),
                                contactNumber: _contactController.text.trim(),
                                description: _descriptionController.text.trim(),
                                latitude: latitude,
                                longitude: longitude,
                              ),
                            );
                      } else {
                        await ref.read(listingControllerProvider.notifier).createListing(
                              name: _nameController.text.trim(),
                              category: _selectedCategory,
                              address: _addressController.text.trim(),
                              contactNumber: _contactController.text.trim(),
                              description: _descriptionController.text.trim(),
                              latitude: latitude,
                              longitude: longitude,
                            );
                      }
                    },
              child: Text(isEditing ? 'Update Listing' : 'Create Listing'),
            ),
          ],
        ),
      ),
    );
  }
}

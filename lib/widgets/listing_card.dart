import 'package:flutter/material.dart';

import '../models/listing.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.trailing,
  });

  final Listing listing;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE4E7EB)),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          listing.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${listing.category} • ${listing.address}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                const Icon(Icons.star, color: Color(0xFFF3B52F), size: 18),
                Text(
                  '${listing.latitude.toStringAsFixed(2)}, ${listing.longitude.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
      ),
    );
  }
}

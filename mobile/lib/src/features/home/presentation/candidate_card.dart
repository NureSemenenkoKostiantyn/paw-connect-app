import 'package:flutter/material.dart';

import '../../../models/candidate_user.dart';
import '../../../models/dog_response.dart';

class CandidateCard extends StatelessWidget {
  final CandidateUser candidate;
  final VoidCallback? onTap;

  const CandidateCard({super.key, required this.candidate, this.onTap});

  @override
  Widget build(BuildContext context) {
    final DogResponse? dog =
        candidate.dogs.isNotEmpty ? candidate.dogs.first : null;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: dog != null && dog.photoUrls.isNotEmpty
                    ? NetworkImage(dog.photoUrls.first)
                    : null,
                child: dog == null || dog.photoUrls.isNotEmpty
                    ? null
                    : Text(dog.name.isNotEmpty ? dog.name[0] : '?'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.username,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${candidate.distanceKm.toStringAsFixed(1)} km away',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (dog != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        dog.name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (dog.breed != null)
                        Text(
                          dog.breed!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

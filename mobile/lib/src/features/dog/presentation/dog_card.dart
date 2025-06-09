import 'package:flutter/material.dart';
import '../../../models/dog.dart';

class DogCard extends StatelessWidget {
  final Dog dog;
  final VoidCallback? onTap;

  const DogCard({super.key, required this.dog, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(dog.name.isNotEmpty ? dog.name[0] : '?'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dog.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (dog.breed != null)
                      Text(
                        dog.breed!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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

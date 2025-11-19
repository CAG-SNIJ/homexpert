import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/horizontal_card_list.dart';
import '../../../core/widgets/hoverable_card.dart';

class HomepageExploreSection extends StatelessWidget {
  const HomepageExploreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                'EXPLORE NEAR YOU',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find Properties in Your Area',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Looking for something nearby? Start with the popular searched areas in Malaysia.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: HorizontalCardList(
              maxWidth: 1400, // Maximum width for the card list
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                CityCard(
                  city: 'Kuala Lumpur',
                  description: 'Explore properties in the vibrant capital city.',
                  imageUrl: 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=400',
                ),
                CityCard(
                  city: 'Selangor',
                  description: 'Discover properties in the most populous state.',
                  imageUrl: 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=400',
                ),
                CityCard(
                  city: 'Penang',
                  description: 'Find properties in the Pearl of the Orient.',
                  imageUrl: 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=400',
                ),
                CityCard(
                  city: 'Johor',
                  description: 'Explore properties in the southern gateway of Malaysia.',
                  imageUrl: 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=400',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable City Card widget
/// Can be used anywhere in the app for displaying city information
class CityCard extends StatelessWidget {
  final String city;
  final String description;
  final String imageUrl;
  final VoidCallback? onTap;

  const CityCard({
    super.key,
    required this.city,
    required this.description,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        city,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


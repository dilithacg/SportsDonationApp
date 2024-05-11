import 'package:flutter/material.dart';

import 'package:sportsdonationapp/src/features/screens/Home_Screen/spvideos.dart';
import '../Coaches_Screen/coaches.dart';
import '../Donation_Screen/items_screen.dart';
import '../ItemDonate_Screen/ItemDonate.dart';
import 'Category.dart';

class CategoryGridItem extends StatelessWidget {
  const CategoryGridItem({
    Key? key,
    required this.category,
  }) : super(key: key);

  final Category category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _navigateToCategoryScreen(context, category); // Call navigation method
      },
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                _getImagePath(category.id),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Text overlay
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    category.color.withOpacity(0.4),
                    category.color.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  category.title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,

                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  String _getImagePath(String categoryId) {

    switch (categoryId) {
      case 'c1':
        return ButtonImg.items[0];
      case 'c2':
        return ButtonImg.items[1];
      case 'c3':
        return ButtonImg.items[2];
      case 'c4':
        return ButtonImg.items[3];
      default:
        return '';
    }
  }
  void _navigateToCategoryScreen(BuildContext context, Category category) {

    switch (category.id) {
      case 'c1':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemsList()),
        );
        break;
      case 'c2':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => YoutubeVideoListScreen(videos: youtubeVideos)),
        );
        break;
      case 'c3':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDonate()),
        );
        break;
      case 'c4':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CoachesScreen()),

        );
        break;

      default:
      // Handle the default case
        break;
    }
  }
}

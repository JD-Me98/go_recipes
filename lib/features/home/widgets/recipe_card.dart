import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String recipeImageUrl; // The URL of the recipe image
  final String recipeTitle;    // The title of the recipe
  final int cookingTime;
  final String username;       // Cooking time in minutes

  RecipeCard({
    required this.recipeImageUrl,
    required this.recipeTitle,
    required this.cookingTime,
    required this.username,

  });

  @override
  Widget build(BuildContext context) {
    
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Recipe Image
            Positioned.fill(
              child: recipeImageUrl.isNotEmpty
                  ? Image.network(
                      recipeImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                      },
                    )
                  : Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Recipe Title and Cooking Time
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Title
                  Text(
                    recipeTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  // Cooking Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer, color: Colors.white, size: 16),
                          SizedBox(width: 5),
                          Text(
                            '$cookingTime mins',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person,
                          color: Colors.white,),
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

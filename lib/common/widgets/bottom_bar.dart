import 'package:flutter/material.dart';
import 'package:go_recipes/features/home/screens/home_page.dart';
import 'package:go_recipes/features/recipes/screens/add_recipe.dart';
import 'package:go_recipes/features/favorites/screens/favorite_recipes.dart';
import 'package:go_recipes/features/recipes/screens/my_recipes.dart';
import 'package:go_recipes/features/settings/screens/settings_screen.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteRecipes()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.food_bank),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyRecipes()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

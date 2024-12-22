import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_recipes/common/widgets/bottom_bar.dart';
import 'package:go_recipes/features/authentication/controllers/user_provider.dart';
import 'package:go_recipes/features/recipes/controllers/recipe_service.dart';
import 'package:go_recipes/features/recipes/models/recipe.dart';
import 'package:go_recipes/features/recipes/screens/add_recipe.dart';
import 'package:go_recipes/features/recipes/screens/recipe_details.dart';
import 'package:provider/provider.dart';

class MyRecipes extends StatefulWidget {
  const MyRecipes({super.key});

  @override
  State<MyRecipes> createState() => _MyRecipesState();
}

  String loggedUserId = '';

  List<Recipe> userRecipes = [];

  CollectionReference _refernce = FirebaseFirestore.instance.collection('gr-recipes');

  String recipeImage='';
  String recipeTitle='';
  String recipeCookingTime = '';

  final RecipeService recipeService = RecipeService();

class _MyRecipesState extends State<MyRecipes> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    loggedUserId = user!.id;
    return Scaffold(
      appBar: AppBar(
        title: Text("My Recipes"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Recipe>>(
            future: recipeService.fetchRecipesByUserId(loggedUserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error loading recipes"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("You have no Recipes"));
              } else {
                final recipes = snapshot.data!;
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(recipe.recipeImage),
                      ),
                      title: Text(recipe.recipeTitle),
                      subtitle: Text('Cooking Time: ${recipe.recipeCookingTime} mins'),
                      onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                      },
                    );
                  },
                );
              }
            },
          ),
          Positioned(
            bottom: 10,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => AddRecipeScreen())
                  );
              },
              child: const Icon(Icons.add),
              ),
              
          )
        ],
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
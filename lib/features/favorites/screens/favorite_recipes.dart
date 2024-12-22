import 'package:flutter/material.dart';
import 'package:go_recipes/common/widgets/bottom_bar.dart';
import 'package:go_recipes/features/favorites/controller/favorite_service.dart';
import 'package:go_recipes/features/recipes/models/recipe.dart';
import 'package:go_recipes/features/favorites/models/favorite.dart';
import 'package:go_recipes/features/recipes/screens/my_recipes.dart';
import 'package:go_recipes/features/recipes/screens/recipe_details.dart';
import 'package:provider/provider.dart';
import 'package:go_recipes/features/authentication/controllers/user_provider.dart';

class FavoriteRecipes extends StatefulWidget {
  const FavoriteRecipes({super.key});

  @override
  State<FavoriteRecipes> createState() => _FavoriteRecipesState();
}

class _FavoriteRecipesState extends State<FavoriteRecipes> {
  late FavoriteService favoriteService;
  late String loggedUserId;
  List<Recipe> favoriteRecipes = [];
  bool isLoading = true;

 @override
void initState() {
  super.initState();
  // Initialize the service first
  favoriteService = FavoriteService();
  
  // Defer the execution to ensure the context is ready
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      loggedUserId = user.id;
      print("Logged-in User ID: $loggedUserId");
      _loadFavoriteRecipes();
    } else {
      print("No user is currently logged in.");
    }
  });
}


Future<void> _loadFavoriteRecipes() async {
  try {
    List<Favorite> favorites = await favoriteService.getFavoritesByUser(loggedUserId);

    print("Favorites retrieved: ${favorites.map((f) => f.toMap()).toList()}");

    // Fetch recipe details for each favorite
    for (var favorite in favorites) {
      if (favorite.recipeId != null) { // Ensure recipeId is not null
        Recipe? recipe = await recipeService.getRecipeById(favorite.recipeId!); // Use non-nullable version
        if (recipe != null) {
          favoriteRecipes.add(recipe);
        }
      } else {
        print("Skipped a favorite with null recipeId.");
      }
    }
  } catch (e) {
    print("Error loading favorite recipes: $e");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Recipes"),
        backgroundColor: Colors.deepOrange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteRecipes.isEmpty
              ? const Center(child: Text("No favorite recipes found!"))
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: favoriteRecipes.length,
                    itemBuilder: (context, index) {
                      Recipe recipe = favoriteRecipes[index];
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(
                                  recipe: recipe,
                                ),
                              ),
                            );
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                  child: Image.network(
                                    recipe.recipeImage,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  recipe.recipeTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "Cooking time: ${recipe.recipeCookingTime} mins",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,)
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomNavigationBar: const BottomBar(),
    );
  }
}

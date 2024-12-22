import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_recipes/features/authentication/controllers/user_provider.dart';
import 'package:go_recipes/features/favorites/controller/favorite_service.dart';
import 'package:go_recipes/features/favorites/models/favorite.dart';
import 'package:go_recipes/features/recipes/controllers/recipe_service.dart';
import 'package:go_recipes/features/recipes/models/recipe.dart';
import 'package:go_recipes/features/recipes/screens/my_recipes.dart';
import 'package:go_recipes/features/recipes/screens/update_recipe.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {

  late String loggedUserId;
  bool isFavorite = false;
  late FavoriteService favoriteService;

  @override
  void initState() {
    super.initState();
    favoriteService = FavoriteService();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    loggedUserId = user!.id;

    _checkFavoriteStatus(); // Check favorite status at initialization
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      Favorite? favorite = await favoriteService.getFavoriteByUserAndRecipe(
        loggedUserId,
        widget.recipe.recipeId,
      );
      setState(() {
        isFavorite = favorite != null;
      });
    } catch (e) {
      print("Error checking favorite status: $e");
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (isFavorite) {
        await favoriteService.removeFavorite(loggedUserId, widget.recipe.recipeId);
      } else {
        Favorite favorite = Favorite(
          id: const Uuid().v4(),
          userId: loggedUserId,
          recipeId: widget.recipe.recipeId,
        );
        await favoriteService.addFavorite(favorite);
      }
      _checkFavoriteStatus(); // Recheck status after operation
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }




  Future<Favorite?> checkFavorite(String userId, String recipeId) async {
  try {
    FavoriteService favoriteService = FavoriteService();
    Favorite? favorite = await favoriteService.getFavoriteByUserAndRecipe(userId, recipeId);
    return favorite; // Return the favorite object or null
  } catch (e) {
    print("Error checking favorite: $e");
    return null; // Return null on error
  }
}

//delete recipe
void _deleteRecipe(String recipeId) async {
  // Show a confirmation dialog before deleting
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete Recipe"),
        content: const Text("Are you sure you want to delete this recipe?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User cancels deletion
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User confirms deletion
            },
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );

  // If the user confirmed, proceed with deletion
  if (confirmed == true) {
    final recipeService = RecipeService();
    await recipeService.deleteRecipeById(recipeId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recipe deleted successfully")),
    );

    // Navigate back to the recipe list or home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyRecipes()),
    );
  }
}


  @override
  Widget build(BuildContext context) {   
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.recipeTitle),
        backgroundColor: Colors.deepOrange,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLandscape = constraints.maxWidth > 600; // Landscape mode

          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: isLandscape
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image on the left
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Image.network(
                            widget.recipe.recipeImage,
                            height: constraints.maxHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20), // Space between image and content

                      // Recipe details on the right
                      Expanded(
                        flex: 2,
                        child: ListView(
                          padding: const EdgeInsets.all(0),
                          children: [
                            Text(
                              widget.recipe.recipeTitle,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'cooking time: ${widget.recipe.recipeCookingTime} mins',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 20),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              widget.recipe.recipeDescription,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'ingredients'.tr(), // Localized "Ingredients"
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.recipe.recipeIngredients.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    "- $index ${widget.recipe.recipeIngredients[index]}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'instructions'.tr(), // Localized "Instructions"
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.recipe.recipeInstructions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    "step $index ${widget.recipe.recipeInstructions[index]}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  )
                : Stack(
                  children: [
                      ListView(
                        // Portrait mode
                        padding: const EdgeInsets.all(0),
                        children: [
                          Container(
                            child: Image.network(
                              widget.recipe.recipeImage,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.recipe.recipeTitle,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'cooking time: ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                '${widget.recipe.recipeCookingTime} mins',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),],
                              ),
                              
                              const SizedBox(width: 20),
                             
                            ],
                          ),
                          const SizedBox(height: 30),
                          Text(
                            widget.recipe.recipeDescription,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'ingredients'.tr(), // Localized "Ingredients"
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.recipe.recipeIngredients.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  "   - ${index + 1} ${widget.recipe.recipeIngredients[index]}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'instructions'.tr(), // Localized "Instructions"
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.recipe.recipeInstructions.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 15.0),
                                  child: Text(
                                    "step ${index + 1}    ${widget.recipe.recipeInstructions[index]}",
                                    style: const TextStyle(fontSize: 16,),
                                  ),
                              );
                            },
                          ),
                          const SizedBox(height: 80),
                          
                        ],
                      ),
                      Positioned(
                        bottom: 20,
                        right: 10,
                        child: widget.recipe.userId == loggedUserId ? Row(
                            children: [
                              Container(
                                child: FloatingActionButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(builder: (context) => UpdateRecipeScreen(recipeId: widget.recipe.recipeId)));
                                  }, 
                                  child: const Icon(Icons.edit,
                                  color: Colors.black,),), 
                              ),
                              const SizedBox(width: 10,),
                              Container(
                                child: FloatingActionButton(
                                  onPressed: () {
                                    _deleteRecipe(widget.recipe.recipeId);
                                  }, 
                                  child: const Icon(Icons.delete,
                                  color: Colors.black,),), 
                              ),
                              const SizedBox(width: 10,),
                              FloatingActionButton(
                                onPressed: () {
                                  _toggleFavorite();                                  
                                },
                                child: Icon(Icons.star,
                                  color: isFavorite == true ? Colors.orange : Colors.black,
                                ),
                                )
                            ],
                          ) : Row(
                            children: [
                              FloatingActionButton(
                                onPressed: () {
                                  _toggleFavorite(); 
                                },
                                child: Icon(Icons.star,
                                  color: isFavorite == true ? Colors.orange : Colors.black,
                                ),
                                )
                              
                            ],
                          ) ,
                        )
                    ],
                ),
          );
        },
      ),
    );
  }
}

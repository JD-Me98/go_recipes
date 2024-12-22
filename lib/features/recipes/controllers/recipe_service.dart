import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart'; // Adjust the path as necessary

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //update the recipe by recipeId
  

  // Fetch recipes by userId
  Future<List<Recipe>> fetchRecipesByUserId(String userId) async {
    try {
      print("Fetching recipes for userId: $userId"); // Debugging step

      final querySnapshot = await _firestore
          .collection('gr-recipes')
          .where('userId', isEqualTo: userId)
          .withConverter<Recipe>(
            fromFirestore: Recipe.fromFirestore,
            toFirestore: (Recipe recipe, _) => recipe.toFirestore(),
          )
          .get();

          
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching recipes by userId: $e");
      return [];
    }
  }

  // Fetch a single recipe by its recipeId
Future<Recipe?> getRecipeById(String recipeId) async {
  try {
    print("Fetching recipe for recipeId: $recipeId"); // Debugging step

    // Query the collection where the 'recipeId' field matches the provided recipeId
    final querySnapshot = await _firestore
        .collection('gr-recipes')
        .where('id', isEqualTo: recipeId) // Query by recipeId field
        .withConverter<Recipe>(
          fromFirestore: Recipe.fromFirestore,
          toFirestore: (Recipe recipe, _) => recipe.toFirestore(),
        )
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      print("Recipe found for recipeId: $recipeId");
      return querySnapshot.docs.first.data(); // Retrieve the converted Recipe object
    } else {
      print("Recipe not found for recipeId: $recipeId");
      return null;
    }
  } catch (e) {
    print("Error fetching recipe by recipeId: $e");
    return null;
  }
}


  // Fetch a single recipe by userId
Future<Recipe?> getRecipeByUserId(String userId) async {
  try {
    print("Fetching a recipe for userId: $userId"); // Debugging step

    final querySnapshot = await _firestore
        .collection('gr-recipes')
        .where('userId', isEqualTo: userId)
        .withConverter<Recipe>(
          fromFirestore: Recipe.fromFirestore,
          toFirestore: (Recipe recipe, _) => recipe.toFirestore(),
        )
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final recipe = querySnapshot.docs.first.data();
      return recipe;
    } else {
      print("No recipes found for userId: $userId");
      return null;
    }
  } catch (e) {
    print("Error fetching a recipe by userId: $e");
    return null;
  }
}


  //fetch all recipes
  Future<List<Recipe>> fetchAllRecipes() async {
    try { // Debugging step

      final querySnapshot = await _firestore
          .collection('gr-recipes')
          .withConverter<Recipe>(
            fromFirestore: Recipe.fromFirestore,
            toFirestore: (Recipe recipe, _) => recipe.toFirestore(),
          )
          .get();

          
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching recipes by userId: $e");
      return [];
    }
  }

   // Delete a recipe by recipeId
  Future<void> deleteRecipeById(String recipeId) async {
    try {
      // Query to find the document with the matching recipeId
      final querySnapshot = await _firestore
          .collection('gr-recipes')
          .where('id', isEqualTo: recipeId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Document found, delete it using the document ID
        final docId = querySnapshot.docs.first.id;
        await _firestore.collection('gr-recipes').doc(docId).delete();

        print("Recipe deleted successfully.");
      } else {
        print("No recipe found with recipeId: $recipeId");
      }
    } catch (e) {
      print("Error deleting recipe by recipeId: $e");
    }
  }  
}

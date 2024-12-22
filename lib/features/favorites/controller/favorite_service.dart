import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_recipes/features/favorites/models/favorite.dart';

class FavoriteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Method to add a favorite
  Future<void> addFavorite(Favorite favorite) async {
    try {
      // Add the favorite document to the Firestore collection
      await _db.collection('gr-favorites').add(favorite.toFirestore());
    } catch (e) {
      print("Error adding favorite: $e");
      throw Exception("Failed to add favorite");
    }
  }

  // Method to get all favorites by userId
  Future<List<Favorite>> getFavoritesByUser(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('gr-favorites')
          .where('userId', isEqualTo: userId)
          .withConverter<Favorite>(
            fromFirestore: Favorite.fromFirestore,
            toFirestore: (Favorite favorite, _) => favorite.toFirestore(),
          )
          .get();

      print("Fetched ${querySnapshot.docs.length} favorites for userId: $userId");
      
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching favorites by userId: $e");
      throw Exception("Failed to fetch favorites for user");
    }
  }


  // Method to remove a favorite
  Future<void> removeFavorite(String userId, String recipeId) async {
  try {
    // Find the favorite document by userId and recipeId
    final querySnapshot = await _db
        .collection('gr-favorites')
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: recipeId)
        .get();

    // Check if a favorite document exists
    if (querySnapshot.docs.isNotEmpty) {
      // Get the document ID
      String docId = querySnapshot.docs.first.id;

      // Delete the favorite document
      await _db.collection('gr-favorites').doc(docId).delete();
      print('Favorite removed successfully.');
    } else {
      print('Favorite not found.');
    }
  } catch (e) {
    print("Error removing favorite: $e");
    throw Exception("Failed to remove favorite");
  }
}


 

  // Method to get a favorite by userId and recipeId
  Future<Favorite?> getFavoriteByUserAndRecipe(String userId, String recipeId) async {
    try {
      print("Checking favorite for userId: $userId, recipeId: $recipeId");

      final querySnapshot = await _db
          .collection('gr-favorites')
          .where('userId', isEqualTo: userId)
          .where('recipeId', isEqualTo: recipeId)
          .withConverter<Favorite>(
            fromFirestore: Favorite.fromFirestore,
            toFirestore: (Favorite favorite, _) => favorite.toFirestore(),
          )
          .get();

      print("Query result size: ${querySnapshot.size}");

      if (querySnapshot.docs.isNotEmpty) {
        print('Found favorites: ${querySnapshot.docs.map((doc) => doc.data()).toList()}');
        return querySnapshot.docs.first.data();
      }

      print('No favorite found for the given userId and recipeId.');
      return null; // Return null if no favorite exists
    } catch (e) {
      print("Error fetching favorite by userId and recipeId: $e");
      return null;
    }
  }

}

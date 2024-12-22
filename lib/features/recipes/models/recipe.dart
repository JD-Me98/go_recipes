import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String recipeId;
  final String recipeTitle;
  final String recipeDescription;
  final String recipeImage;
  final int recipeCookingTime;
  final List<String> recipeIngredients;
  final List<String> recipeInstructions;
  final String userId;

  Recipe({
    required this.recipeId, 
    required this.recipeTitle,
    required this.recipeDescription,
    required this.recipeImage,
    required this.recipeCookingTime,
    required this.recipeIngredients,
    required this.recipeInstructions,
    required this.userId,
  });

  // Convert Recipe to a Map for storing in the database
  Map<String, dynamic> toMap() {
    return {
      'id': recipeId,
      'title': recipeTitle,
      'description': recipeDescription,
      'image': recipeImage,
      'cooking_time': recipeCookingTime,
      'ingredients': recipeIngredients,
      'instructions': recipeInstructions,
      'userId': userId,
    };
  }

  // Convert Map to Recipe object with null safety
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      recipeTitle: map['title'] ?? '', // Default empty string if null
      recipeDescription: map['description'] ?? '',
      recipeImage: map['image'] ?? '', 
      recipeCookingTime: map['cooking_time'] ?? 0, // Default to 0 if null
      recipeIngredients: List<String>.from(map['ingredients']?? []),
      recipeInstructions: List<String>.from(map['instructions'] ?? []), 
      userId: map['userId'] ?? '', 
      recipeId: map['id'], // Default empty string if null
    );
  }

   // Convert Firestore document to Recipe object
  static Recipe fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? options) {
    final data = doc.data()!;
    return Recipe(
      recipeId: data['id'],
      recipeTitle: data['title'] ?? '',
      recipeDescription: data['description'] ?? '',
      recipeImage: data['image'] ?? '',
      recipeCookingTime: data['cooking_time'] ?? 0,
      recipeIngredients: List<String>.from(data['ingredients'] ?? []),
      recipeInstructions: List<String>.from(data['instructions'] ?? []),
      userId: data['userId'] ?? '',
    );
  }

  // Convert Recipe object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': recipeId,
      'title': recipeTitle,
      'description': recipeDescription,
      'image': recipeImage,
      'cooking_time': recipeCookingTime,
      'ingredients': recipeIngredients,
      'instructions': recipeInstructions,
      'userId': userId,
    };
  }
  
}


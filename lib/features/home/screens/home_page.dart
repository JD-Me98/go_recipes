import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_recipes/common/widgets/bottom_bar.dart';
import 'package:go_recipes/features/authentication/controllers/user_provider.dart';
import 'package:go_recipes/features/authentication/models/user.dart';
import 'package:go_recipes/features/home/widgets/logout_dialog.dart';
import 'package:go_recipes/features/home/widgets/recipe_card.dart';
import 'package:go_recipes/features/recipes/controllers/recipe_service.dart';
import 'package:go_recipes/features/recipes/models/recipe.dart';
import 'package:go_recipes/features/recipes/screens/recipe_details.dart'; // Ensure RecipeDetails screen is imported
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String searchQuery = '';
  String _username='';

  Future<String> getUsername(String userId) async {
    try {
      // Check if the user exists in Firestore by searching for the 'id' field
      QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('gr-users')
          .where('id', isEqualTo: userId)
          .get();

      // If the user exists in Firestore, return their username
      if (userDocs.docs.isNotEmpty) {
        // Access the first document that matches the query
        DocumentSnapshot userDoc = userDocs.docs.first;
        return userDoc['username'] ?? "Unknown User";
      } else {
        // If user doesn't exist in Firestore, check if it's a Google user
        return _username;
        
      }
    } catch (e) {
      return "Error fetching user: $e";
    }
  }



  @override
  Widget build(BuildContext context) {
     // Ensure that user is not null before using it
      final user = Provider.of<UserProvider>(context).currentUser;
      if (user == null) {
        // Handle the case where the user is not logged in or null
        _username = 'Google User';
        return const Scaffold(
          body: Center(child: Text('No user logged in')),
        );
      }else{
        // Get the username based on the auth method
        _username = user.authMethod == AuthMethod.google
        ? user.username
        : 'Google User';
      }

  
    final RecipeService recipeService = RecipeService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Recipes'),
        actions: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: user.photo != null && user.photo!.isNotEmpty
                    ? (user.photo!.startsWith('http')
                        ? NetworkImage(user.photo!)
                        : MemoryImage(base64Decode(user.photo!)))
                    : const AssetImage('assets/images/user.png') as ImageProvider,
              ),
              const SizedBox(width: 10),
              Text(
                user?.username ?? 'Guest',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutDialog().showLogoutDialog(context),
            tooltip: 'logout'.tr(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'search_hint'.tr(),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).secondaryHeaderColor,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase(); // Update search query
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Recipe>>(
                future: recipeService.fetchAllRecipes(),
                builder: (context, data) {
                  if (data.hasError) {
                    return Text("${data.error}");
                  } else if (data.hasData) {
                    var items = data.data!;
                    var filteredItems = items
                        .where((recipe) => recipe.recipeTitle.toLowerCase().contains(searchQuery)) // Filter recipes by title
                        .toList();

                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // Responsive column count
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 4 / 2.5, // Adjust this ratio to fit the card's height/width
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(
                                  recipe: filteredItems[index],
                                ),
                              ),
                            );
                          },
                          child: FutureBuilder<String>(
                            future: getUsername(filteredItems[index].userId), // Fetch username
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator()); // Show loading indicator
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}'); // Display error message
                              } else if (!snapshot.hasData || snapshot.data == null) {
                                return const Text('No username found'); // Handle empty data
                              } else {
                                return RecipeCard(
                                  recipeImageUrl: filteredItems[index].recipeImage,
                                  recipeTitle: filteredItems[index].recipeTitle,
                                  cookingTime: filteredItems[index].recipeCookingTime,
                                  username: snapshot.data!, // Pass fetched username
                                );
                              }
                            },
                          ),
                        
                        );
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}

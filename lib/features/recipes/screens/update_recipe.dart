import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_recipes/features/authentication/controllers/user_provider.dart';
import 'package:go_recipes/features/recipes/controllers/recipe_service.dart';
import 'package:go_recipes/features/recipes/models/recipe.dart';
import 'package:go_recipes/features/recipes/screens/my_recipes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UpdateRecipeScreen extends StatefulWidget {
  final String recipeId;

  UpdateRecipeScreen({required this.recipeId});

  @override
  _UpdateRecipeScreenState createState() => _UpdateRecipeScreenState();
}

class _UpdateRecipeScreenState extends State<UpdateRecipeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();

  String loggedUserID = '';
  List<String> ingredients = [];
  List<String> instructions = [];
  File? _pickedImage;
  String? recipeImageUrl;

  Recipe? recipe;

  CollectionReference _reference = FirebaseFirestore.instance.collection('gr-recipes');

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
  }

  Future<void> _loadRecipeData() async {
    final recipeService = RecipeService();
    final recipeData = await recipeService.getRecipeById(widget.recipeId);
    
    if (recipeData != null) {
      setState(() {
        recipe = recipeData;
        _titleController.text = recipe!.recipeTitle;
        _descriptionController.text = recipe!.recipeDescription;
        _cookingTimeController.text = recipe!.recipeCookingTime.toString();
        ingredients = List<String>.from(recipe!.recipeIngredients);
        instructions = List<String>.from(recipe!.recipeInstructions);
        recipeImageUrl = recipe!.recipeImage;
      });
    } else {
      print('Recipe not found.');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      _pickedImage = File(pickedFile.path);
      String uniqueFileName = 'Recipe-${DateTime.now().millisecondsSinceEpoch.toString()}';
      final path = 'uploads/$uniqueFileName';

      await Supabase.instance.client.storage
          .from('gr-images')
          .upload(path, _pickedImage!)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload successful!')));
      });

      final storage = Supabase.instance.client.storage;
      recipeImageUrl = await storage.from('gr-images').getPublicUrl(path);

      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void updateRecipe() async {
  if (_titleController.text.isNotEmpty &&
      _descriptionController.text.isNotEmpty &&
      _cookingTimeController.text.isNotEmpty &&
      loggedUserID.isNotEmpty) {
    // Use the existing recipeId from the loaded recipe
    final updatedRecipe = Recipe(
      recipeId: recipe!.recipeId, // Keep the existing recipeId
      recipeTitle: _titleController.text,
      recipeDescription: _descriptionController.text,
      recipeImage: recipeImageUrl ?? recipe!.recipeImage, // Use the updated image if selected
      recipeCookingTime: int.parse(_cookingTimeController.text),
      recipeIngredients: ingredients,
      recipeInstructions: instructions,
      userId: loggedUserID,
    );

    try {
      // Query to find the document with the matching recipeId
      final querySnapshot = await _reference
          .where('id', isEqualTo: widget.recipeId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Document found, update it using the document ID
        final docId = querySnapshot.docs.first.id;
        await _reference.doc(docId).update(updatedRecipe.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recipe updated successfully")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyRecipes()),
        );
      } else {
        print("Recipe with recipeId ${widget.recipeId} not found.");
      }
    } catch (e) {
      print("Error updating recipe: $e");
    }

    print(updatedRecipe.toMap()); // Here you can handle the recipe submission logic
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please fill all fields and upload an image")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    loggedUserID = user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("Update Recipe"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Recipe Image", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo),
                        title: Text("Pick from Gallery"),
                        onTap: () {
                          pickImage(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.camera),
                        title: Text("Take a Picture"),
                        onTap: () {
                          pickImage(ImageSource.camera);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _pickedImage == null
                      ? recipeImageUrl != null
                          ? Image.network(recipeImageUrl!, fit: BoxFit.cover)
                          : Center(child: Icon(Icons.add, size: 50))
                      : Image.file(_pickedImage!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20),
              Text("Recipe Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(controller: _titleController, decoration: InputDecoration(labelText: "Recipe Title")),
              TextFormField(controller: _descriptionController, decoration: InputDecoration(labelText: "Recipe Description")),
              TextFormField(
                controller: _cookingTimeController,
                decoration: InputDecoration(labelText: "Cooking Time"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Text("Ingredients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...ingredients.asMap().entries.map((entry) {
                int index = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value,
                        onChanged: (value) => setState(() => ingredients[index] = value),
                        decoration: InputDecoration(labelText: "Ingredient"),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeItem(ingredients, index),
                    ),
                  ],
                );
              }).toList(),
              TextButton.icon(
                onPressed: addIngredient,
                icon: Icon(Icons.add, color: Colors.deepOrange),
                label: Text("Add Ingredient"),
              ),
              SizedBox(height: 20),
              Text("Instructions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...instructions.asMap().entries.map((entry) {
                int index = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value,
                        onChanged: (value) => setState(() => instructions[index] = value),
                        decoration: InputDecoration(labelText: "Instruction"),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeItem(instructions, index),
                    ),
                  ],
                );
              }).toList(),
              TextButton.icon(
                onPressed: addInstruction,
                icon: Icon(Icons.add, color: Colors.deepOrange),
                label: Text("Add Instruction"),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateRecipe,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: Text("Update Recipe", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void removeItem(List<String> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  void addIngredient() {
    setState(() {
      ingredients.add('');
    });
  }

  void addInstruction() {
    setState(() {
      instructions.add('');
    });
  }
}

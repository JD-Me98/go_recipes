import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_recipes/features/authentication/controllers/user_provider.dart';
import 'package:go_recipes/features/recipes/models/recipe.dart';
import 'package:go_recipes/features/recipes/screens/all_recipes.dart';
import 'package:go_recipes/features/recipes/screens/my_recipes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();

  String loggedUserID='';

  List<String> ingredients = [];
  List<String> instructions = [];

  CollectionReference _refernce = FirebaseFirestore.instance.collection('gr-recipes');

  File? _pickedImage;

  String? recipeImageUrl;

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

  void removeItem(List<String> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    _pickedImage = File(pickedFile!.path);

     String uniqueFileName = 'Recipe-${DateTime.now().millisecondsSinceEpoch.toString()}';
    final path = 'uploads/$uniqueFileName';

    //upload image to supabase storage
    await Supabase.instance.client.storage
      .from('gr-images')
      .upload(path, _pickedImage!)
      .then(
        (value) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('image upload successfull!'))),
      );
    
      final storage = Supabase.instance.client.storage;
      recipeImageUrl= await storage.from('gr-images').getPublicUrl(path);

      if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      }
  }

  void submitRecipe() async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _cookingTimeController.text.isNotEmpty &&
        loggedUserID.isNotEmpty) {
      final recipe = Recipe(
        recipeId: const Uuid().v4(),
        recipeTitle: _titleController.text,
        recipeDescription: _descriptionController.text,
        recipeImage: recipeImageUrl!,
        recipeCookingTime: int.parse(_cookingTimeController.text),
        recipeIngredients: ingredients,
        recipeInstructions: instructions,
        userId: loggedUserID, 
      );

      await _refernce.add(recipe.toMap());

       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe added successfully")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyRecipes()),
      );

      print(recipe.toMap()); // Here you can handle recipe submission logic
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and upload an image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    loggedUserID = user!.id;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Recipe"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image Upload Section
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
                    ? Center(child: Icon(Icons.add, size: 50))
                    : Image.file(_pickedImage!, fit: BoxFit.cover), 
                ),
              ),

              SizedBox(height: 20),

              // Recipe Details
              Text("Recipe Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(controller: _titleController, decoration: InputDecoration(labelText: "Recipe Title")),
              TextFormField(controller: _descriptionController, decoration: InputDecoration(labelText: "Recipe Description")),
              TextFormField(
                controller: _cookingTimeController,
                decoration: InputDecoration(labelText: "Cooking Time"),
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 20),

              // Ingredients Section
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

              // Instructions Section
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

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitRecipe,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: Text("Add Recipe",
                  style: TextStyle(
                    color: Colors.white,
                  ),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NewRecipe extends StatefulWidget {
  const NewRecipe({super.key});

  @override
  State<NewRecipe> createState() => _NewRecipeState();
}

class _NewRecipeState extends State<NewRecipe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Recipe Title'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Recipe Title'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Recipe Title'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Recipe Title'),
            ),
          ],
        ),
      ),
    );
  }
}
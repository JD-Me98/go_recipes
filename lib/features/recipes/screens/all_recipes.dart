import 'package:flutter/material.dart';

class RecipesListPage extends StatefulWidget {
  const RecipesListPage({super.key});

  @override
  State<RecipesListPage> createState() => _RecipesListPageState();
}

class _RecipesListPageState extends State<RecipesListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Recipes List"),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Image picker for importing images

class AddIngredient extends StatefulWidget {
  const AddIngredient({Key? key}) : super(key: key);

  @override
  _AddIngredientState createState() => _AddIngredientState();
}

class _AddIngredientState extends State<AddIngredient> {
  String name = '';
  String imagePath = '';

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    // Show a dialog to choose between camera or gallery
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick Image'),
          content: const Text('Choose an image source:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: const Text('Gallery'),
            ),
          ],
        );
      },
    );

    // If the user has selected a source, proceed to pick the image
    if (source != null) {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imagePath = pickedFile.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Ingredient'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TextField for the name
          TextField(
            decoration: const InputDecoration(labelText: 'Ingredient Name'),
            onChanged: (value) {
              name = value;
            },
          ),
          // Button to pick the image
          TextButton(
            onPressed: _pickImage,
            child: const Text('Pick Image'),
          ),
          // Show the image preview if selected
          if (imagePath.isNotEmpty)
            Image.file(
              File(imagePath),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (name.isNotEmpty && imagePath.isNotEmpty) {
              Navigator.of(context).pop(newIngredient(name: name, imagePath: imagePath)); // Return the new ingredient
            }
          },
          child: const Text('Add Ingredient'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class newIngredient {
  final String name;
  final String imagePath;

  newIngredient({required this.name, required this.imagePath});
}

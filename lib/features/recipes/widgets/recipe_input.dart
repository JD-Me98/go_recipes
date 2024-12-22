import 'package:flutter/material.dart';
class RecipeTextInput extends StatelessWidget {
  const RecipeTextInput({
    super.key,
    required TextEditingController textController,
    required this.hintText,
  }) : _textController = textController;

  final TextEditingController _textController;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
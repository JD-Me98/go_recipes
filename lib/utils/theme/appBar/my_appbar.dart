import 'package:flutter/material.dart';
import 'package:go_recipes/utils/constants/colors.dart';
class AppBarUtils {
  // Static method to get a customizable AppBar
  static AppBar buildAppBar({
    required String title,
    bool centerTitle = true,
    Widget? leading,
    List<Widget>? actions,
    Color backgroundColor = Gcolors.primary,
    TextStyle? titleTextStyle,
    double elevation = 4.0,
  }) {
    return AppBar(
      title: Text(
        title,
        style: titleTextStyle ?? const TextStyle(color: Gcolors.textWhite),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      leading: leading,
      actions: actions,
      elevation: elevation,
    );
  }
}

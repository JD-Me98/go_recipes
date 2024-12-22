import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_recipes/features/authentication/controllers/user_provider.dart';
import 'package:go_recipes/features/authentication/screens/login_screen.dart';
import 'package:go_recipes/utils/API/google_signin_api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutDialog {
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("logout".tr()),
          content: Text("logout_confirm".tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel".tr()),
            ),
            TextButton(
              onPressed: () async {
                // Clear user and navigate to login screen
                Provider.of<UserProvider>(context, listen: false).clearUser();
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                
                prefs.setString('loggedIn', '');

                await GoogleSigninApi.logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Text("logout".tr()),
            ),
          ],
        );
      },
    );
  }
}
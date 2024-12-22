import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_recipes/common/widgets/bottom_bar.dart';
import 'package:go_recipes/features/authentication/controllers/user_provider.dart';
import 'package:go_recipes/features/authentication/models/user.dart';
import 'package:go_recipes/features/authentication/screens/update_user.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserProvider>(context).currentUser;



  return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 60,
              backgroundImage: user?.photo == null
                  ? const AssetImage('assets/images/user.png') as ImageProvider
                  : NetworkImage(user!.photo!),
            ),
            const SizedBox(height: 10), // Add some spacing between elements
            user?.authMethod == AuthMethod.email
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UpdateUser()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  )
                : const Text(
                    'Cannot edit Google profile',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
          ],
        ),
      ),
    ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
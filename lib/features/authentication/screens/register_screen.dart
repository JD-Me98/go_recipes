import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_recipes/data/repositories/database_helper.dart';
import 'package:go_recipes/features/authentication/models/user.dart' as grUser;
import 'package:go_recipes/features/authentication/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  File? _profileImage; // To store the profile image file

  String _imageUrl='';

  CollectionReference _refernce = FirebaseFirestore.instance.collection('gr-users');

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
   

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("pick image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text("gallery"),
                onTap: () async {
                  
                  try{

                  
                  //pick image
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  _profileImage = File(image!.path);

                  //create a unique name for image file.
                  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
                  final path = 'uploads/$uniqueFileName';

                  //upload image to supabase storage
                  await Supabase.instance.client.storage
                    .from('gr-images')
                    .upload(path, _profileImage!)
                    .then(
                      (value) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('image upload successfull!'))),
                    );
                  
                    final storage = Supabase.instance.client.storage;
                    _imageUrl = await storage.from('gr-images').getPublicUrl(path);

                  if (image != null) {
                    setState(() {
                      _profileImage = File(image.path);
                    });

                  }
                  Navigator.of(context).pop();
                  }catch(error){
                    print('error: ${error}');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text("camera"),
                onTap: () async {
                  try{
                  //pick image
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);

                 //create a unique name for image file.
                  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
                  final path = 'uploads/$uniqueFileName';

                  //upload image to supabase storage
                  await Supabase.instance.client.storage
                    .from('gr-images')
                    .upload(path, _profileImage!)
                    .then(
                      (value) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('image upload successfull!'))),
                    );
                  
                    final storage = Supabase.instance.client.storage;
                    _imageUrl = await storage.from('gr-images').getPublicUrl(path);

                  if (image != null) {
                    setState(() {
                      _profileImage = File(image.path);
                    });

                  }
                  Navigator.of(context).pop();
                  }catch(error){
                    print('error: ${error}');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("passwords do not match")),
      );
      return;
    }

    final user = grUser.User(
      id: const Uuid().v4(),
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      photo: _imageUrl,
      authMethod: grUser.AuthMethod.email,
    );

    await _refernce.add(user.toMap());

    // Navigate to the login screen after signup
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  width: double.infinity,
                  height: 300,
                  child: Image.asset('assets/images/page_design.png'),
                ),
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: const BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 80,
                              backgroundImage: _profileImage == null
                                  ? const AssetImage('assets/images/user.png')
                                  : FileImage(_profileImage!) as ImageProvider,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.camera_alt),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'sign_up'.tr(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTextField('username'.tr(), _usernameController),
                      const SizedBox(height: 16),
                      _buildTextField('email'.tr(), _emailController),
                      const SizedBox(height: 16),
                      _buildTextField('password'.tr(), _passwordController, isPassword: true),
                      const SizedBox(height: 16),
                      _buildTextField('confirm_password'.tr(), _confirmPasswordController, isPassword: true),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 0.0,
                          ),
                          child: Text(
                            'sign_up'.tr(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('already_have_account'.tr()),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: Text('login'.tr()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'or'.tr(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildGoogleSignInButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.grey, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 0.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/google.png', width: 24),
            const SizedBox(width: 16),
            Text('login_with_google'.tr(), style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

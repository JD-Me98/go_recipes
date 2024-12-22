
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_recipes/data/repositories/database_helper.dart';
import 'package:go_recipes/features/authentication/controllers/user_provider.dart';
import 'package:go_recipes/features/authentication/models/user.dart';
import 'package:go_recipes/features/authentication/screens/register_screen.dart';
import 'package:go_recipes/features/home/screens/home_page.dart';
import 'package:go_recipes/utils/API/google_signin_api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  
  String? _errorMessage;

  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              width: double.infinity,
              height: 180,
              child: Image.asset('assets/images/page_design.png'),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'login'.tr(),
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
                      _buildTextField(_emailController, 'email'.tr(), false),
                      const SizedBox(height: 16),
                      _buildTextField(_passwordController, 'password'.tr(), true),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text('forgot_password'.tr(), style: TextStyle(color: Colors.blue)),
                      const SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text('Remember Me'),
                          ],
                        ),
                        const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 0.0,
                          ),
                          child: Text(
                            'login'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSignUpButton(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('or'.tr(), 
                            style: const TextStyle(color: Colors.grey)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildGoogleLoginButton(),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, bool isObscured) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: TextField(
          controller: controller,
          obscureText: isObscured,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Row(
      children: [
        Text('signup_prompt'.tr()),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const SignupScreen()));
          },
          style: ElevatedButton.styleFrom(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: Text(
            'signup_button'.tr(),
            style: const TextStyle(color: Colors.deepOrange),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: google_signin, // Add Google login logic here
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
            Text(
              'login_with_google'.tr(),
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {

    final firestore = FirebaseFirestore.instance;
  try {
    String email = _emailController.text.trim(); // Add trim()
    String password = _passwordController.text;

     final querySnapshot = await firestore
        .collection('gr-users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    // Input validation
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "please_enter_email_password".tr();
      });
      return;
    }

    // Show loading indicator
    setState(() {
      _errorMessage = null; // Clear any previous errors
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();

     // If a matching user is found, return the User object
    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data();
      
      final User user = User.fromMap(userData);
      
      // check mounted
      if (!mounted) return;
      
      // Handle remember me preference
      if (rememberMe == true) {
        await prefs.setString('loggedIn', user.id);
      } else {
        await prefs.remove('loggedIn'); // Use remove instead of setting empty string
      }

      // Update provider and navigate
      Provider.of<UserProvider>(context, listen: false).setUser(user);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );

    } else {
      setState(() {
        _errorMessage = "invalid_email_password".tr();
      });
      return null;
    }    

  } catch (e) {
    // Handle any errors that occur during the login process
    if (!mounted) return;
    setState(() {
      _errorMessage = "email or password not correct".tr(); // Add this translation key
    });
    print('Login error: $e'); // For debugging
  }
}

  Future google_signin() async{
    final googleUser = await GoogleSigninApi.login();
    if(googleUser == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('login_failed'.tr())));
    }else{
      
      User user = User.fromGoogle(googleUser);

      Provider.of<UserProvider>(context, listen: false).setUser(user);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage(),
      ));
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_recipes/features/authentication/controllers/user_provider.dart';
import 'package:go_recipes/features/authentication/models/user.dart' as grUser;
import 'package:go_recipes/features/authentication/screens/login_screen.dart';
import 'package:go_recipes/features/home/screens/home_page.dart';
import 'package:go_recipes/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_recipes/utils/constants/supabase_keys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: SupabaseKeys.projectUrl,
    anonKey: SupabaseKeys.anonKey,
  );

  await EasyLocalization.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
          Locale('es'),
        ],
        path: 'assets/lang',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? userId;
  bool isLoading = true; // To show loading indicator while fetching data

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  void initializeApp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Print the stored userId from SharedPreferences
    String? loggedInUserId = prefs.getString('loggedIn');
    print('Stored userId: $loggedInUserId');

    setState(() {
      userId = loggedInUserId ?? "";
      isLoading = false; // Stop loading once data is fetched
    });

    // Fetch user details if logged in
    if (userId!.isNotEmpty) {
      print('user id is: ${userId}');
    }
  }

  Future<grUser.User> fetchUser(String userId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final querySnapshot = await firestore
        .collection('gr-users')
        .where('id', isEqualTo: userId)
        .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        print("user data: $userData");

        final grUser.User user = grUser.User.fromMap(userData);
        print("user: $user");

        return user;
      }
    } catch (error) {
      print('Error fetching user: $error');
    }

    throw Exception('User not found');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Theme Switcher',
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          color: Colors.deepOrange,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.black, fontSize: 24),
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.grey[850],
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          color: Colors.grey[850],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontSize: 24),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading
          : FutureBuilder<grUser.User>(
              future: fetchUser(userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const LoginScreen();
                } else if (snapshot.hasData) {
                  // Set the user in the provider
                  Provider.of<UserProvider>(context, listen: false)
                      .setUser(snapshot.data!);

                  // Return HomePage after setting user in provider
                  return const HomePage();
                } else {
                  return const LoginScreen();
                }
              },
            ),
    );
  }
}

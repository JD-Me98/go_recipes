import 'package:google_sign_in/google_sign_in.dart';

class User {
  String id; // Store the ID as String
  String email;
  String username;
  String password; // Retain this for normal authentication
  String? photo;
  AuthMethod authMethod;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
    this.photo,
    required this.authMethod,
  });

  // Factory constructor for Google users
  factory User.fromGoogle(GoogleSignInAccount googleUser) {
    return User(
      id: googleUser.id,  // Google ID stays as string
      email: googleUser.email,
      username: googleUser.displayName ?? "No Name",
      password: "",  // Google users don’t have a password
      photo: googleUser.photoUrl,
      authMethod: AuthMethod.google,
    );
  }

  // Factory constructor for email/password users
  factory User.fromEmail(int id, String email, String username, String password, {String? photo}) {
    return User(
      id: id.toString(),  // Convert the auto-incremented integer ID to string
      email: email,
      username: username,
      password: password,
      photo: photo,
      authMethod: AuthMethod.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Store as string (even though it's an integer in SQLite for normal users)
      'email': email,
      'username': username,
      'password': password,
      'photo': photo,
      'authMethod': authMethod.toString(),
    };
  }

  User.fromMap(Map<String, dynamic> map)
      : id = map['id'].toString(),  // Convert back to string
        email = map['email'],
        username = map['username'],
        password = map['password'],
        photo = map['photo'],
        authMethod = AuthMethod.values.firstWhere((e) => e.toString() == map['authMethod']);

  // Override toString to get a readable representation of the User
  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, photo: $photo}';
  }
}

enum AuthMethod { google, email }

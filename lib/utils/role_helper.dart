import 'package:firebase_auth/firebase_auth.dart';

class RoleHelper {
  static const String _adminEmail = 'admin@gmail.com';

  static bool get isAdmin {
    final email = FirebaseAuth.instance.currentUser?.email;
    return email == _adminEmail;
  }
}
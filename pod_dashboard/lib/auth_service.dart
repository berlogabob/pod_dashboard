import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future<String> signInAnonymously() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    return userCredential.user!.uid;
  }

  static String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

import 'package:firebase_auth/firebase_auth.dart';

class AuthUtil{
  static Future signUp(String name,String email,String password)async{
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      return;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }

      throw AuthException(e.message??e.toString());
    } catch (e) {
      print(e);
      throw AuthException(e.toString());
    }
  }

  static Future signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }

      throw AuthException(e.message ?? e.toString());
    } catch (e) {
      print(e);
      throw AuthException(e.toString());
    }
  }

  static User? getCurrentUser(){
    var currentUser = FirebaseAuth.instance.currentUser;
    return currentUser;
  }

  static bool isLoggedIn(){
    return getCurrentUser()!=null;
  }

  static Future logout()async{
    await FirebaseAuth.instance.signOut();
  }
}

class AuthException {
  String _message;
  AuthException(this._message);
  String toString(){
    return "Exception: $_message";
  }
}


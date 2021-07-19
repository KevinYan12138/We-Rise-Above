import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

enum Status { Uninitialized, UserAuthenticated, Authenticating, Unauthenticated, AdminAuthenticated }

class UserRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User _user;
  String _errorMessage;
  Status _status = Status.Uninitialized;

  UserRepository(): _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Status get status => _status;
  User get user => _user;
  String get errorMessage => _errorMessage;

  set setErrorMessage(String error) => _errorMessage = error;

  Future<String> register(String email, String password) async {
    try{
      _status = Status.Authenticating;
      notifyListeners();
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
      User user = result.user;
    }catch(e){
      switch (e.code) {
      case "ERROR_OPERATION_NOT_ALLOWED":
        _errorMessage = "Anonymous accounts are not enabled";
        break;
      case "ERROR_WEAK_PASSWORD":
        _errorMessage = "The length of password should be longer than 6";
        break;
      case "ERROR_INVALID_EMAIL":
        _errorMessage = "Your email is invalid";
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        _errorMessage = "Email is already in use on different account";
        break;
      case "ERROR_INVALID_CREDENTIAL":
        _errorMessage = "Your email is invalid";
        break;
      default:
        _errorMessage = "An undefined Error happened.";
    }
    _status = Status.Unauthenticated;
    notifyListeners();
    return null;
  }
    return user.uid;
  }

  Future<String> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      switch (e.code) {
      case "ERROR_INVALID_EMAIL":
        _errorMessage = "Your email address appears to be malformed.";
        break;
      case "ERROR_WRONG_PASSWORD":
        _errorMessage = "Your password is wrong.";
        break;
      case "ERROR_USER_NOT_FOUND":
        _errorMessage = "User with this email doesn't exist.";
        break;
      case "ERROR_USER_DISABLED":
        _errorMessage = "User with this email has been disabled.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        _errorMessage = "Too many requests. Try again later.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        _errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      default:
        _errorMessage = "An undefined Error happened.";
    }
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
      return user.uid;
  }

  Future<User> getCurrentUser() async {
    User user = await _auth.currentUser;
    return user;
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      String status = '';
      await FirebaseFirestore.instance.collection('users').doc(_user.uid).get().then((DocumentSnapshot ds) {
            status = ds['status'];
      });
      if (status == "admin") {
        _status = Status.AdminAuthenticated;
      } else{
        _status = Status.UserAuthenticated;

      }
    }
    notifyListeners();
  }
}
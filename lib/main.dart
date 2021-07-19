import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Auth/LogIn.dart';
import 'Auth/UserRepository.dart';
import 'Manager/ManagerBottomNavigation.dart';
import 'Member/BottomNavigation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            theme: ThemeData(
              primaryColor: Colors.black,
              textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
              ),
              primaryIconTheme: IconThemeData(color: Colors.white),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: MyHomePage(),
            debugShowCheckedModeBanner: false,
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserRepository(),
      child: Consumer(
        builder: (context, UserRepository user, _) {
          switch (user.status) {
            case Status.Uninitialized:
              return Splash();
            case Status.Unauthenticated:
              return LogInPage();
            case Status.Authenticating:
              return Splash();
            case Status.UserAuthenticated:
              return BottomNavigation(
                user: user.user,
              );
            case Status.AdminAuthenticated:
              return ManagerBottomNavigation(
                user: user.user,
              );
          }
        },
      ),
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightBlue)),
      ),
    );
  }
}

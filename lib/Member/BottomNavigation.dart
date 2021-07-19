import 'package:WeRiseAbove/UI/About.dart';
import 'package:WeRiseAbove/UI/Blog.dart';
import 'package:WeRiseAbove/UI/Chat.dart';
import 'package:WeRiseAbove/UI/GroupChat.dart';
import 'package:WeRiseAbove/UI/Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Auth/UserRepository.dart';

class BottomNavigation extends StatefulWidget {

  final User user;

  const BottomNavigation({Key key, this.user}) : super(key: key);


  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentap = 1;

  About aboutPage;
  Chat messagingPage;
  GroupChat groupChatPage;
  Blog blogViewPage;
  List<Widget> pages;
  Widget currentPage;

  final PageStorageBucket bucket = PageStorageBucket();

  void initState() {
    aboutPage = About();
    messagingPage = Chat();
    groupChatPage = GroupChat();
    blogViewPage = Blog();
    pages = [aboutPage, blogViewPage, messagingPage, groupChatPage];
    currentPage = blogViewPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('We Rise Above', style: GoogleFonts.lobster(textStyle: TextStyle())),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app, ),
        onPressed: () => Provider.of<UserRepository>(context, listen: false).signOut()),
          ],
          leading: IconButton(
              icon: Icon(Icons.person, ),
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => Profile()),);
              }),
        ),
        body: PageStorage(
          child: currentPage,
          bucket: bucket,
        ),
        bottomNavigationBar: new BottomNavigationBar(
          currentIndex: _currentap,
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          onTap: (int _index) {
            setState(() {
              _currentap = _index;
              currentPage = pages[_index];
            });
          },
          items: [
            new BottomNavigationBarItem(icon: new Icon(Icons.book), label: "About"),
            new BottomNavigationBarItem(icon: new Icon(Icons.photo), label: "Blog"),
            new BottomNavigationBarItem(icon: new Icon(Icons.mail), label: "Messages"),
            new BottomNavigationBarItem(icon: new Icon(Icons.group), label: "Groups"),

          ],
        )
    );
  }
}

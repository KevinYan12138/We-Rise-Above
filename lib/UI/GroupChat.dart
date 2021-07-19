import 'package:WeRiseAbove/Manager/GroupCreator.dart';
import 'package:WeRiseAbove/UI/GroupChatScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupChat extends StatefulWidget {
  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  SharedPreferences preferences;

  String status = '';
  String id = '';

  @override
  void initState() {
    readLocal();
    super.initState();
  }

  void readLocal() async {
    preferences = await SharedPreferences.getInstance();
    status = preferences.getString('status');
    id = preferences.getString('id');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
          padding: EdgeInsets.only(top: 20),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('groupChats').where('members', arrayContains: id).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  );
                default:
                  return new ListView(
                    children: snapshot.data.docs.map((DocumentSnapshot document) {
                      return Column(children: [
                        new ListTile(
                            leading: CachedNetworkImage(
                              imageUrl: document['groupIcon'].toString(),
                              imageBuilder: (context, imageProvider) => Container(
                                width: 60.0,
                                height: 60.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
                                ),
                              ),
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  shape: BoxShape.circle
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(document['groupName'][0], style: TextStyle(fontSize: 20,),)),
                              ),
                            ),
                            title: Text(document['groupName']),
                            onTap: () {
                              Navigator.push( context, MaterialPageRoute( builder: (context) => GroupChatScreen(
                                          groupId: document['groupId'],
                                          groupName: document['groupName'],
                                        )
                                      ),
                              );
                            }),
                      ]);
                    }).toList(),
                  );
              }
            },
          )),
      floatingActionButton: Container(
        child: Visibility(
          //visible: status.toString() == 'member' ? false : true,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => GroupCreator()));
            },
            child: Icon(
              Icons.add,
            ),
          ),
        ),
      ),
    );
  }
}

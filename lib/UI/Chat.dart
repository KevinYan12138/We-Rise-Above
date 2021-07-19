import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatScreen.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
} 

class _ChatState extends State<Chat> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  SharedPreferences prefs;
  User user;
  String id;
  String groupId;
  String lastMessage;

  var dayFormat = new DateFormat.d();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    user = await FirebaseAuth.instance.currentUser;
    id = prefs.getString('id') ?? '';
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
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.white,
                  );
                default:
                  return new ListView(
                    children: snapshot.data.docs.map((DocumentSnapshot document){
                      if (document['id'].toString().hashCode >= id.hashCode){
                          groupId = (document['id']).toString() + id;
                        } else {
                          groupId = id + (document['id']).toString();
                        }
                      return Column(children: [
                        user.uid.toString() == document['id'].toString()
                            ? Container()
                            : new ListTile(
                                leading: CachedNetworkImage(
                                  imageUrl: document['photoUrl'].toString(),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 60.0,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  shape: BoxShape.circle
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(document['username'][0].toUpperCase(), style: TextStyle(fontSize: 20,),)),
                              ),
                                ),
                                title: Text(document['username']),
                                subtitle: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance.collection('chats').doc(groupId).collection(groupId)
                                            .where('sendTo', isEqualTo: id).snapshots(),
                                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                              if(snapshot.data == null) return Text('Loading...');
                                              int count = snapshot.data.docs.length;
                                              if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                                              switch (snapshot.connectionState) {
                                                case ConnectionState.waiting: return Text('Loading...');
                                                default: 
                                                  if(count == 0) {
                                                    return Text('');
                                                   }else if(snapshot.data.docs[count-1]['message'].toString().contains('firebasestorage')){
                                                     return Text('[Image]', style: TextStyle(color: Colors.grey));
                                                   }else return Text(snapshot.data.docs[count-1]['message'], style: TextStyle(color: Colors.grey));
                                              }
                                            },
                                          ),
                                trailing: Container(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance.collection('chats').doc(groupId).collection(groupId)
                                    .where('sendTo', isEqualTo: id).snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if(snapshot.data == null) return CircularProgressIndicator();
                                      int count = snapshot.data.docs.length;
                                      int readCount=0;
                                      for(int i =0; i<count; i++){
                                        snapshot.data.docs[i]['read'] == false ? readCount++ : '';
                                      }
                                      int nowDay = int.parse(dayFormat.format(DateTime.now()));
                                      if(snapshot.data == null) return Text('Loading...');
                                      if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting: return Text('Loading...');
                                        default: 
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              (count == 0) ? Text('')
                                              :(nowDay == snapshot.data.docs[count-1]['day']) ? Text(snapshot.data.docs[count-1]['hour'].toString(), style: TextStyle(color: Colors.grey),)
                                              :Text(snapshot.data.docs[count-1]['month'].toString()+' '+snapshot.data.docs[count-1]['day'].toString(), style: TextStyle(color: Colors.grey,)),
                                              SizedBox(height: 10,),
                                              readCount == 0 ? SizedBox(): Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(readCount.toString(), style: TextStyle(color: Colors.white))
                                          )
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            document['username'],
                                            document['id'],
                                            document["photoUrl"].toString())),
                                  );
                                }
                                ),
                                user.uid.toString() == document['id'].toString()
                            ? Container():
                        new Divider()
                      ]);
                    }).toList(),
                  );
              }
            },
          )),
    );
  }
}

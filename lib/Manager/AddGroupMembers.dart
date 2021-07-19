import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddGroupMembers extends StatefulWidget {
  final groupId;

  const AddGroupMembers({Key key, this.groupId}) : super(key: key);
  @override
  _AddGroupMembersState createState() => _AddGroupMembersState();
}

class _AddGroupMembersState extends State<AddGroupMembers> {
  SharedPreferences preferences;

  String id;

  @override
  void initState() {
    readLocal();
    super.initState();
  }

  void readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    setState(() {});
  }

  Future<String> isUserJoined(String groupId, String id) async {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(id);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    List<String> groups = await List.from(userDocSnapshot.data()['groups']);

    if (groups.contains(groupId)) {
      return 'Joined';
    } else {
      return 'Add';
    }
  }

  Future<void> joinGroup(String id) async {
    await FirebaseFirestore.instance.collection('users').doc(id).update({
      'groups': FieldValue.arrayUnion([widget.groupId]),
    });
    await FirebaseFirestore.instance.collection('groupChats').doc(widget.groupId).update({
      'members': FieldValue.arrayUnion([id]),
    });
  }

  Future<void> removeGroup(String id) async {
    await FirebaseFirestore.instance.collection('users').doc(id).update({
      'groups': FieldValue.arrayRemove([widget.groupId]),
    });
    await FirebaseFirestore.instance.collection('groupChats').doc(widget.groupId).update({
      'members': FieldValue.arrayRemove([id]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
          padding: EdgeInsets.only(top: 20),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  );
                default:
                  return new ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot document = snapshot.data.docs[index];
                      return document['id'] == id ? Container(): Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: ListTile(
                            leading: CachedNetworkImage(
                              imageUrl: document['photoUrl'].toString(),
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
                                  child: Text(document['username'][0].toUpperCase(), style: TextStyle(fontSize: 20,),)),
                              ),
                            ),
                            title: Text(document['username']),
                            trailing: FutureBuilder(
                              future: isUserJoined(widget.groupId, document['id']),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return RaisedButton(
                                    onPressed: () {
                                      snapshot.data == 'Joined' ? removeGroup(document['id']) : joinGroup(document['id']);
                                    },
                                    child: Text(snapshot.data),
                                  );
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            )),
                      );
                    },
                  );
              }
            },
          )),
    );
  }
}

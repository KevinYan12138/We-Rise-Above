import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupCreator extends StatefulWidget {
  @override
  _GroupCreatorState createState() => _GroupCreatorState();
}

class _GroupCreatorState extends State<GroupCreator> {
  String groupName = '';
  String id = '';

  SharedPreferences preferences;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> handleUpdateData() async {
    DocumentReference groupDocRef = await FirebaseFirestore.instance.collection('groupChats').add({
      'groupName': groupName,
      'admin': id,
      'members': [],
      'groupIcon': '',
    });
    await groupDocRef.update({
      'members': FieldValue.arrayUnion([id]),
      'groupId': groupDocRef.id,
    });
    await FirebaseFirestore.instance.collection('users').doc(id).update({
      'groups': FieldValue.arrayUnion([groupDocRef.id])
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(children: [
            SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              width: size.width * 0.8,
              child: TextFormField(
                maxLines: 1,
                decoration: InputDecoration(
                    labelText: 'Group Name',
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    )),
                validator: (value) => value.isEmpty ? 'Group Name can\'t be empty' : null,
                onSaved: (value) => groupName = value,
              ),
            ),
            SizedBox(height: 30),
            Container(
              height: 40,
              width: size.width * 0.8,
              child: RaisedButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0), side: BorderSide(color: Colors.white)),
                child: Text('Post'),
                onPressed: () async {
                  if (_validateAndSave()) {
                    handleUpdateData();
                  }
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.lightBlue,
      ),
      body: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController usernameController;
  final FocusNode focusNodeUsername = new FocusNode();
  SharedPreferences prefs;

  String id = '';
  String username = '';
  String photoUrl = '';
  File avatarImageFile;
  bool isLoading = false;
  bool isImageLoading = false;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    username = prefs.getString('username') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    usernameController = new TextEditingController(text: username);

    setState(() {});
  }

  Future getImage() async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        avatarImageFile = File(pickedFile.path);
        isImageLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    StorageReference reference = FirebaseStorage.instance.ref().child('users').child(id);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          FirebaseFirestore.instance.collection('users').doc(id).update({'photoUrl': photoUrl}).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              isImageLoading = false;
            });
            Scaffold.of(context).showSnackBar(SnackBar(content: Text("Upload success")));
          });
        });
      }
    });
  }

  void handleUpdateData() {
    focusNodeUsername.unfocus();

    setState(() {
      isLoading = true;
      CircularProgressIndicator();
    });

    FirebaseFirestore.instance.collection('users').doc(id).update({
      'username': username,
    }).then((data) async {
      await prefs.setString('username', username);
      await prefs.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
      });

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Update success"),
      ));
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(err.toString()),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        (photoUrl == null || photoUrl.isEmpty)
            ? Align(
                alignment: Alignment.center,
                child: GestureDetector(
                    onTap: () => getImage(),
                    child: Container(
                      height: size.width * 0.24,
                      width: size.width * 0.24,
                      child: Stack(children: [
                        isImageLoading
                            ? Container()
                            : Icon(
                                Icons.account_circle,
                                size: size.width * 0.27,
                                color: Colors.grey,
                              ),
                        isImageLoading
                            ? Container()
                            : Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.lightBlue),
                                    child: Icon(
                                      Icons.add,
                                      size: size.width * 0.06,
                                      color: Colors.black,
                                    ))),
                        isImageLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                              ))
                            : Container()
                      ]),
                    )),
              )
            : Align(
                alignment: Alignment.center,
                child: GestureDetector(
                    onTap: () => getImage(),
                    child: Container(
                      height: size.width * 0.24,
                      width: size.width * 0.24,
                      child: Stack(children: [
                        isImageLoading
                            ? Container()
                            : CachedNetworkImage(
                                imageUrl: photoUrl,
                                imageBuilder: (context, imageProvider) => Center(
                                  child: Container(
                                    width: size.width * 0.24,
                                    height: size.width * 0.24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.account_circle,
                                  size: 60,
                                ),
                              ),
                        isImageLoading
                            ? Container()
                            : Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.lightBlue),
                                    child: Icon(
                                      Icons.add,
                                      size: size.width * 0.06,
                                      color: Colors.black,
                                    ))),
                        isImageLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                              ))
                            : Container()
                      ]),
                    )),
              ),
        Container(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Username',
              contentPadding: new EdgeInsets.all(5.0),
              hintStyle: TextStyle(color: Colors.grey),
            ),
            controller: usernameController,
            onChanged: (value) {
              username = value;
            },
            focusNode: focusNodeUsername,
          ),
          margin: EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
        ),
        Container(
          child: FlatButton(
            onPressed: handleUpdateData,
            child: Text(
              'UPDATE',
              style: TextStyle(fontSize: 16.0),
            ),
            color: Color(0xff203152),
            highlightColor: new Color(0xff8d93a0),
            splashColor: Colors.transparent,
            textColor: Colors.white,
            padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
          ),
          margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
        ),
      ]),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BlogCreator extends StatefulWidget {
  @override
  _BlogCreatorState createState() => _BlogCreatorState();
}

enum FormMode { IMAGE, LINK, ARTICLE }

class _BlogCreatorState extends State<BlogCreator> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FormMode _formMode = FormMode.IMAGE;

  String type = '';
  String title = '';
  String content = '';
  String photoUrl = '';
  File coverImage;
  bool isLoading = false;
  bool isImageLoading = false;
  final picker = ImagePicker();

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _changeFormToARTICLE() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.ARTICLE;
    });
  }

  void _changeFormToLINK() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.LINK;
    });
  }

  void _changeFormToIMAGE() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.IMAGE;
    });
  }

  Future getImage() async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadFile() async {
    StorageReference reference = FirebaseStorage.instance.ref().child('posts').child(title);
    StorageUploadTask uploadTask = reference.putFile(coverImage);
    if (uploadTask.isSuccessful || uploadTask.isComplete) {
      photoUrl = await reference.getDownloadURL();
    } else if (uploadTask.isInProgress) {
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      photoUrl = await storageTaskSnapshot.ref.getDownloadURL();
    } else {}
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          print('phtotUrl');
        });
      }
    });
  }

  Future<void> handleUpdateData() async {
    FirebaseFirestore.instance.collection('posts').doc(title).set({
      'image': photoUrl,
      'type': type,
      'title': title,
      'content': content,
    }).then((data) async {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: Text("Posted successfully"),
      ));
      Future.delayed(new Duration(seconds: 3)).then((value) => Navigator.pop(context));
    }).catchError((err) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(err.toString()),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('We Rise Above'),
      ),
      body: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: _formMode == FormMode.IMAGE,
                    child: Stack(
                      children: [
                        Center(
                          child: GestureDetector(
                              onTap: () => getImage(),
                              child: coverImage == null
                                  ? Container(
                                      height: 150,
                                      width: size.width * 0.8,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.add_a_photo,
                                      ),
                                    )
                                  : Container(height: 150, width: size.width * 0.8, child: Image.file(coverImage))),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 50,
                    width: size.width * 0.8,
                    child: TextFormField(
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: 'Title',
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
                      validator: (value) => value.isEmpty ? 'Title can\'t be empty' : null,
                      onSaved: (value) => title = value,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: _formMode != FormMode.IMAGE,
                    child: Container(
                      height: 150,
                      width: size.width * 0.8,
                      child: TextFormField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            labelText: _formMode == FormMode.ARTICLE ? 'Content' : 'Link, must contain https://',
                            labelStyle: TextStyle(color: Colors.grey),
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
                        validator: (value) => value.isEmpty ? 'Content can\'t be empty' : null,
                        onSaved: (value) => content = value,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  FlatButton(
                      onPressed: () => (_formMode == FormMode.IMAGE)
                          ? _changeFormToLINK()
                          : (_formMode == FormMode.LINK)
                              ? _changeFormToARTICLE()
                              : _changeFormToIMAGE(),
                      child: _formMode == FormMode.IMAGE
                          ? Text('Only Insert a Link', style: TextStyle(color: Colors.white))
                          : _formMode == FormMode.LINK
                              ? Text('Post an Article', style: TextStyle(color: Colors.white))
                              : Text('Only Post an Image', style: TextStyle(color: Colors.white))),
                  SizedBox(height: 30),
                  Container(
                    height: 40,
                    width: size.width * 0.8,
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0), side: BorderSide(color: Colors.white)),
                      child: Text('Post'),
                      onPressed: () async {
                        if (_formMode == FormMode.IMAGE) {
                          _formKey.currentState.save();
                          if (title.isNotEmpty && title != null) {                            
                            if (coverImage == null) {
                              _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text("Please attach an image or enter title")));
                            } else {
                              type = 'image';
                              await uploadFile();
                              handleUpdateData();
                            }
                          }
                        } else {
                          if (_validateAndSave()) {
                            if (_formMode == FormMode.ARTICLE) {
                              type = 'article';
                            } else {
                              type = 'link';
                            }
                            handleUpdateData();
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            )),
      ),
    );
  }
}

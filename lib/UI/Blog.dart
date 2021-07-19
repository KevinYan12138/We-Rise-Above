import 'package:WeRiseAbove/Manager/BlogCreator.dart';
import 'package:WeRiseAbove/UI/BlogDetail.dart';
import 'package:WeRiseAbove/UI/FullPhoto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Blog extends StatefulWidget {
  @override
  _BlogState createState() => _BlogState();
}

class _BlogState extends State<Blog> {

  SharedPreferences preferences;

  String status = '';

  @override
  void initState() {
    readLocal();
    super.initState();
  }

  void readLocal() async{
    preferences = await SharedPreferences.getInstance();
    status = preferences.getString('status');
    setState(() {}); 
  } 

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new CircularProgressIndicator();
          default:
          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document){
              return status.toString() == 'admin' ? Dismissible(
                direction: DismissDirection.endToStart,
                background: Container(color: Colors.red),
                key: ObjectKey(document),
                onDismissed: (direction){
                  setState(() {
                    document.reference.delete();
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    if(document['type'] == 'link'){
                      setState(() {
                        launch(document['content']);
                      });
                    }else if(document['type'] == 'image'){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['image'])));
                    }else{
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BlogDetail(title: document['title'], content: document['content'],)));
                    }
                  },
                  child: Center(
                    child: document['type'] == 'image' ? Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: CachedNetworkImage(
                        imageUrl: document['image'],
                        imageBuilder: (context, imageProvider) => Container(
                          height: 200,
                          width: size.width * 0.95,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover
                            ),
                          ),
                        ),
                      ),
                    ): Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Card(
                        color: Colors.white,
                        child: Container(
                          height: 125,
                          width: size.width * 0.95,
                          child: Center(
                            child: Text(document['title'], style: GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))
                          )
                        ),
                      ),
                    ),
                  ),
                ),
              )): GestureDetector(
                  onTap: () {
                    if(document['type'] == 'link'){
                      setState(() {
                        launch(document['content']);
                      });
                    }else if(document['type'] == 'image'){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['image'])));
                    }else{
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BlogDetail(title: document['title'], content: document['content'],)));
                    }
                  },
                  child: Center(
                    child: document['type'] == 'image' ? Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: CachedNetworkImage(
                        imageUrl: document['image'],
                        imageBuilder: (context, imageProvider) => Container(
                          height: 200,
                          width: size.width * 0.95,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover
                            ),
                          ),
                        ),
                      ),
                    ): Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Card(
                        color: Colors.white,
                        child: Container(
                          height: 125,
                          width: size.width * 0.95,
                          child: Center(
                            child: Text(document['title'], style: GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))
                          )
                        ),
                      ),
                    ), 
                  ),
                ),
              );
            }).toList(),
          );
        } 
        }),
      floatingActionButton: Container(
        child: Visibility(
          visible: status.toString() == 'member' ? false : true,
          child: FloatingActionButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => BlogCreator()));
            },
            child: Icon(Icons.add, ),
          ),
        ),
      ),
    );
  }
}
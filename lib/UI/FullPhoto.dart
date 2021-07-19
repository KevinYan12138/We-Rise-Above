import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:photo_view/photo_view.dart';

class FullPhoto extends StatefulWidget {
  final String url;

  const FullPhoto({Key key, this.url}) : super(key: key);
  @override
  _FullPhotoState createState() => _FullPhotoState();
}

class _FullPhotoState extends State<FullPhoto> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      key: _scaffoldKey,
      appBar: new AppBar(actions: [
        FlatButton(
            child: Text(
              'Save Image',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              var imageId = await ImageDownloader.downloadImage(widget.url);
              setState(() {
                isLoading = false;
              });
              _scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: Text('Image Downloaded'),
                backgroundColor: Colors.lightBlue[400],
              ));
              if (imageId == null) {
                return;
              }
            })
      ]),
      body: Container(
        child: Stack(children: [
          PhotoView(
            imageProvider: NetworkImage(widget.url),
            loadingBuilder: (context, event) => Center(
              child: Container(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                ),
              ),
            ),
          ),
          isLoading
              ? Center(
                  child: Container(
                      height: size.width * 0.3,
                      width: size.width * 0.3,
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                      )),
                )
              : Container(),
        ]),
      ),
    );
  }
}

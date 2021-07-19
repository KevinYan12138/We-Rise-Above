import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              title: Text('WHO WE ARE', 
              style: GoogleFonts.bebasNeue( fontSize: 20)), 
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://wrafoundation.org/who-we-are/')
            ),
            ListTile(
              title: Text('WEEKLY NEWSLETTER', 
              style: GoogleFonts.bebasNeue( fontSize: 20)), 
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://wrafoundation.org/wra-weekly-newsletter/')
            ),
            ListTile(
              title: Text('SPOTLIGHT', 
              style: GoogleFonts.bebasNeue( fontSize: 20)), 
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://wrafoundation.org/wra-podcast/')
            ),
            ListTile(
              title: Text('ARTICLES', 
              style: GoogleFonts.bebasNeue( fontSize: 20)), 
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://wrafoundation.org/wra-blog-articles/')
            ),
            ListTile(
              title: Text('WORKSHOPS', 
              style: GoogleFonts.bebasNeue( fontSize: 20)), 
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://wrafoundation.org/wra-workshops/')
            ),
            ListTile(
              title: Text('INSTAGRAM', 
              style: GoogleFonts.bebasNeue( fontSize: 20)), 
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://www.youtube.com/channel/UCb69VMLANmJRj57iu3nNbqw/featured?view_as=subscriber')
            ),
            ListTile(
              title: Text('FACEBOOK', 
              style: GoogleFonts.bebasNeue( fontSize: 20)), 
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://www.facebook.com/weriseabove2019/')
            ),
            ListTile(
              title: Text('INFORMATIONAL GRAPHICS', 
              style: GoogleFonts.bebasNeue( fontSize: 20)),  
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://wrafoundation.org/wra-informational-graphics/')
            ),
            ListTile(
              title: Text('YOUTUBE', 
              style: GoogleFonts.bebasNeue( fontSize: 20)),  
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://www.instagram.com/weriseaboveofficial/')
            ),
            ListTile(
              title: Text('INSTAGRAM', 
              style: GoogleFonts.bebasNeue( fontSize: 20)), 
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://www.youtube.com/channel/UCb69VMLANmJRj57iu3nNbqw/featured?view_as=subscriber')
            ),
            ListTile(
              title: Text('TikToK', 
              style: GoogleFonts.bebasNeue( fontSize: 20, )), 
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://www.tiktok.com/@weriseaboveofficial?_d=secCgsIARCbDRgBIAIoARI%2BCjz4GdNNDMPdWQ%2FAVAJ3ek982sVCHWD9Z3dnZJE%2BPQy6VMvYwXduR0nbYu8fsMZmBzzxK7dnJ7v3mCx2j2IaAA%3D%3D&language=en&sec_uid=MS4wLjABAAAAquaXQmTlyvo-vShhg384j0rXRlZFcnO3Tz0XQ3RuGyFfRGLdf96_vbS7jHG3w7pB&share_author_id=6839513558083044357&tt_from=copy&u_code=dd25l20g3i23m3&user_id=6839513558083044357&utm_campaign=client_share&utm_medium=ios&utm_source=copy&source=h5_m')
            ),
            ListTile(
              title: Text('RESOURCES', 
              style: GoogleFonts.bebasNeue( fontSize: 20)), 
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://wrafoundation.org/resources/')
            ),
            ListTile(
              title: Text('CONTACT US', 
              style: GoogleFonts.bebasNeue( fontSize: 20)), 
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white,), 
              onTap: () => launch('https://wrafoundation.org/contact-us/')
            ),
          ]
        ).toList(),
      ),
    );
  }
}

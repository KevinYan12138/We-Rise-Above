import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ResetPassword.dart';
import 'UserRepository.dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LogInPageState extends State<LogInPage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FormMode _formMode = FormMode.LOGIN;

  bool _agree = false;

  String _email;
  String _username;
  String _password;
  var _value;
  SharedPreferences prefs;

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  void initState() {
    new Future.delayed(const Duration(seconds: 1)).then((_) => _buildSnackBar());
    super.initState();
  }

  _buildSnackBar() {
    final user = Provider.of<UserRepository>(context, listen: false);

    user.errorMessage == null
        ? print('')
        : _scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: new Text(user.errorMessage),
          ));
    user.setErrorMessage = null;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        key: _scaffoldKey,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  //_formMode == FormMode.LOGIN ? Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold)): Text('SIGN UP', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Image.asset(
                    'assets/We Rise Above.png',
                    height: size.height * 0.3,
                  ),
                  SizedBox(height: 10),
                  _showUsername(),
                  _showEmailInput(),
                  _showPasswordInput(),
                  _showSecondaryButton(),
                  _showTerms(),
                  _showPrimaryButton(),
                  _resetPassword(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _showUsername() {
    Size size = MediaQuery.of(context).size;
    return Visibility(
        visible: _formMode == FormMode.LOGIN ? false : true,
        child: Container(
          width: size.width * 0.8,
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.emailAddress,
            autofocus: false,
            decoration: InputDecoration(
                icon: Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
                hintText: 'Enter Username',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none),
            validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
            onSaved: (value) => _username = value,
          ),
        ));
  }

  Widget _showEmailInput() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            icon: Icon(
              Icons.email,
              color: Colors.grey,
            ),
            hintText: 'Enter Email',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showPasswordInput() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          icon: Icon(Icons.lock, color: Colors.grey),
          border: InputBorder.none,
          hintText: 'Enter Password',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showTerms() {
    Size size = MediaQuery.of(context).size;
    return Visibility(
      visible: _formMode == FormMode.LOGIN ? false : true,
      child: Row(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: Colors.white,
            ),
            child: Checkbox(
              value: _agree,
              onChanged: (bool newValue) {
                setState(() {
                  _agree = newValue;
                });
              },
            ),
          ),
          Container(
            width: size.width * 0.8,
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 12),
                children: <TextSpan>[
                  TextSpan(
                    text: "I agree to We Rise Above's ",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  TextSpan(
                    text: "Terms and Conditions and Privacy Policy",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('https://wrafoundation.org/policies/');
                      },
                    style: TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline),
                  ),
                  // TextSpan(
                  //   text: " and ",
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 12,
                  //   ),
                  // ),
                  // TextSpan(
                  //   text: "Privacy Policy",
                  //   recognizer: TapGestureRecognizer()
                  //     ..onTap = () {
                  //       launch("https://oneaptitude.weebly.com/privacy-policy.html");
                  //     },
                  //   style: TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Oops!', style: TextStyle(color: Colors.black))),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You must accept the Terms and Conditions and Privacy Policy.', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showPrimaryButton() {
    Size size = MediaQuery.of(context).size;
    return Container(
        height: size.height * 0.06,
        width: size.width * 0.8,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: RaisedButton(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0), side: BorderSide(color: Colors.white)),
          onPressed: () async {
            if (_validateAndSave()) {
              final user = Provider.of<UserRepository>(context, listen: false);
              SharedPreferences pref = await SharedPreferences.getInstance();
              if (_formMode == FormMode.LOGIN) {
                String id = await user.signIn(_email, _password);

                if (id != null) {
                  FirebaseFirestore.instance.collection('users').doc(id).update({
                    'password': _password,
                  });

                  SharedPreferences pref = await SharedPreferences.getInstance();
                  await pref.setString("id", id);

                  DocumentReference documentReference = FirebaseFirestore.instance.collection("users").doc(id);
                  documentReference.get().then((snapshot) async {
                    if (snapshot.exists) {
                      await pref.setString('username', snapshot.data()['username']);
                      await pref.setString('photoUrl', snapshot.data()['photoUrl']);
                      await pref.setString('status', snapshot.data()['status']);
                    } else {
                      print("No such user");
                    }
                  });
                }
              } else {
                if (_agree) {
                  String id = await user.register(_email, _password);

                  if (id != null) {
                    FirebaseFirestore.instance.collection('users').doc(id).set({'id': id, 'email': _email, 'password': _password, 'username': _username, 'groups': [], 'photoUrl': '', 'status': 'member', 'token': 'waiting'});
                    SharedPreferences pref = await SharedPreferences.getInstance();
                    await pref.setString("id", id);
                    await pref.setString('status', 'member');
                    await pref.setString("username", _username);
                    await pref.setString("photoUrl", '');
                  }
                } else {
                  _showMyDialog();
                }
              }
            }
          },
          child: _formMode == FormMode.LOGIN ? new Text('Login', style: new TextStyle(fontSize: 18.0, color: Colors.black)) : new Text('Create account', style: new TextStyle(fontSize: 18.0, color: Colors.black)),
        ));
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _formMode == FormMode.LOGIN ? new Text('Create an account', style: new TextStyle(fontSize: 15.0, color: Colors.grey)) : new Text('Have an account? Sign in', style: new TextStyle(fontSize: 15.0, color: Colors.grey)),
      onPressed: _formMode == FormMode.LOGIN ? _changeFormToSignUp : _changeFormToLogin,
    );
  }

  Widget _resetPassword() {
    return FlatButton(
        child: Text('Forget password?', style: new TextStyle(fontSize: 17.0, fontWeight: FontWeight.w300, color: Colors.grey)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResetPasswordPage()),
          );
        });
  }
}

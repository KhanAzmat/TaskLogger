import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:task_logger/Animation/FadeAnimation.dart';
import 'package:task_logger/api/login_api.dart';
import 'package:task_logger/api/userSetup.dart';
import 'package:task_logger/model/User1.dart';
import 'package:task_logger/notifier/auth_notifier.dart';
import 'package:task_logger/api/crud.dart';
import 'package:task_logger/pages/adminPage.dart';
import 'HomePage.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final gugleSignIn = GoogleSignIn();
  var log = Logger();
  final _globalkey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool vis = false;
  bool circular = false;
  bool validate = false;
  User1 _user = new User1();

  googleSignIn() async {
    GoogleSignInAccount googleSignInAccount = await gugleSignIn.signIn();
    if (googleSignInAccount != null) {
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      User user = (await auth.signInWithCredential(credential)).user;

      FirebaseFirestore.instance
          .collection('data')
          .doc(user.uid)
          .get()
          .then((value) {
        if (value.data()["name"] == null) {
          _user.name = user.displayName;
          _user.admin = false;
          addUserData(_user, user.uid);
        }
      });

      FirebaseFirestore.instance
          .collection('data')
          .doc(user.uid)
          .get()
          .then((value) {
        if (value.data()["admin"] == true) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
              (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage(uid: user.uid)),
              (route) => false);
        }
      });
    }
  }

  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    initializeCurrentUser(authNotifier);
    super.initState();
  }

  Future<void> showSignInEmailDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                    content: Form(
                      key: _globalkey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Sign in with email",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            emailTextField(),
                            passwordTextField(),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                          child: Text('Sign In'),
                          onPressed: () {
                            if (!_globalkey.currentState.validate()) {
                              return;
                            } else {
                              _globalkey.currentState.save();

                              AuthNotifier authNotifier =
                                  Provider.of<AuthNotifier>(context,
                                      listen: false);

                              login(_user, authNotifier, context);
                            }
                          }),
                      TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                    ])));
  }

  Future<void> showSignUpDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Form(
                  key: _globalkey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        usernameTextField(),
                        emailTextField(),
                        passwordTextField(),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                      child: Text('Register'),
                      onPressed: () {
                        if (!_globalkey.currentState.validate()) {
                          return;
                        } else {
                          _globalkey.currentState.save();

                          AuthNotifier authNotifier =
                              Provider.of<AuthNotifier>(context, listen: false);
                          _user.admin = false;
                          signUp(_user, authNotifier, context);

                          // Navigator.pushAndRemoveUntil(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => HomePage()),
                          //     (route) => false);
                        }
                      }),
                  TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ]));
  }

  Widget usernameTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
      child: Column(
        children: [
          Text("Username"),
          TextFormField(
            controller: _usernameController,
            validator: (String value) {
              if (value.isEmpty) {
                return "Name is required";
              }
              return null;
            },
            onSaved: (String value) {
              _user.name = value;
            },
            decoration: InputDecoration(
              //errorText: validate ? null : errorText,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget emailTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
      child: Column(
        children: [
          Text("Email"),
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value.isEmpty) return "Email can't be empty";
              if (!value.contains("@")) return "Email is Invalid";
              return null;
            },
            onSaved: (String value) {
              _user.email = value;
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget passwordTextField() {
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
        child: Column(
          children: [
            Text("Password"),
            TextFormField(
              controller: _passwordController,
              validator: (value) {
                if (value.isEmpty) return "Password can't be empty";
                if (value.length < 8) return "Password lenght must have >=8";
                return null;
              },
              onSaved: (String value) {
                _user.password = value;
              },
              obscureText: vis,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(vis ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      vis = !vis;
                    });
                  },
                ),
                helperStyle: TextStyle(
                  fontSize: 14,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
            child: Column(children: [
          Container(
            height: 400,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Stack(children: [
              Positioned(
                  left: 30,
                  width: 88,
                  height: 200,
                  child: FadeAnimation(
                    1.2,
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('images/light-1.png'),
                      )),
                    ),
                  )),
              Positioned(
                  left: 140,
                  width: 88,
                  height: 150,
                  child: FadeAnimation(
                    1.7,
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('images/light-2.png'),
                      )),
                    ),
                  )),
              Positioned(
                right: 40,
                top: 40,
                width: 80,
                height: 150,
                child: FadeAnimation(
                  1.9,
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/clock.png'),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: FadeAnimation(
                  2.2,
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(143, 148, 251, 1),
                          Color.fromRGBO(1413, 148, 251, 0.6)
                        ])),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 5),
                      child: InkWell(
                        onTap: () async {
                          await showSignInEmailDialog(context);
                        },
                        child: Row(children: [
                          Image.asset('images/email.png',
                              height: 25, width: 25),
                          SizedBox(width: 40),
                          Text('Sign in with email',
                              style: TextStyle(fontSize: 25)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: FadeAnimation(
                  2.1,
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(colors: [
                            Color.fromRGBO(143, 148, 251, 1),
                            Color.fromRGBO(1413, 148, 251, 0.6)
                          ])),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 5),
                        child: InkWell(
                          onTap: () {
                            googleSignIn()
                                // .whenComplete(() =>
                                //     Navigator.pushReplacement(
                                //         context,
                                //         MaterialPageRoute(
                                //             builder: (context) => HomePage())))
                                ;
                          },
                          child: Row(children: [
                            Image.asset('images/google.png',
                                height: 25, width: 25),
                            SizedBox(width: 40),
                            Text('Sign in with Google',
                                style: TextStyle(fontSize: 25)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: FadeAnimation(
                  2.2,
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(143, 148, 251, 1),
                          Color.fromRGBO(1413, 148, 251, 0.6)
                        ])),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 5),
                      child: InkWell(
                        onTap: () async {
                          await showSignUpDialog(context);
                        },
                        child: Row(children: [
                          Image.asset('images/login.jpg',
                              height: 25, width: 25),
                          SizedBox(width: 40),
                          Text('Sign Up', style: TextStyle(fontSize: 25)),
                        ]),
                      ),
                    ),
                  ),
                ),
              )
            ]),
          )
        ])),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

import 'signup.dart';
import 'profimg.dart';

class Home extends StatefulWidget {
  Home({this.uid});
  final String uid;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("User Profile"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () {
                FirebaseAuth auth = FirebaseAuth.instance;
                auth.signOut().then((res) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                          (Route<dynamic> route) => false);
                });
              },
            )
          ],
        ),
        body: Center(
          child: Column(
              children: <Widget>[
                Center(child: Text('Name:',style: TextStyle(fontSize: 20),)),
                FutureBuilder(
                    future: FirebaseDatabase.instance
                        .reference()
                        .child("Users")
                        .child(widget.uid)
                        .once(),
                    builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data.value['name']);
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
                Center(child: Text('Email:',style: TextStyle(fontSize: 20),)),
                FutureBuilder(
                    future: FirebaseDatabase.instance
                        .reference()
                        .child("Users")
                        .child(widget.uid)
                        .once(),
                    builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data.value['email']);
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
                Center(child: Text('Hobbies:',style: TextStyle(fontSize: 20),)),
                FutureBuilder(
                    future: FirebaseDatabase.instance
                        .reference()
                        .child("Users")
                        .child(widget.uid)
                        .once(),
                    builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data.value['hobby']);
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),

                new ListTile(
                  title: new RaisedButton(
                    child: new Text("Get Location"),
                    onPressed: () {

                      return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(_currentAddress
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                new ListTile(
                  title: new RaisedButton(
                    child: new Text("Show Profile Image"),
                    onPressed: () {
                      print(widget.uid);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfImgShow(uid: widget.uid)),
                      );

                    },
                  ),
                ),
              ]
          ),


        ),
        drawer: NavigateDrawer(uid: this.widget.uid));
  }
}


class NavigateDrawer extends StatefulWidget {
  final String uid;
  NavigateDrawer({Key key, this.uid}) : super(key: key);
  @override
  _NavigateDrawerState createState() => _NavigateDrawerState();
}

class _NavigateDrawerState extends State<NavigateDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: FutureBuilder(
                future: FirebaseDatabase.instance
                    .reference()
                    .child("Users")
                    .child(widget.uid)
                    .once(),
                builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.value['email']);
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
            accountName: FutureBuilder(
                future: FirebaseDatabase.instance
                    .reference()
                    .child("Users")
                    .child(widget.uid)
                    .once(),
                builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.value['name']);
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.home, color: Colors.black),
              onPressed: () => null,
            ),
            title: Text('Home'),
            onTap: () {
              print(widget.uid);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home(uid: widget.uid)),
              );
            },
          ),
          ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.settings, color: Colors.black),
              onPressed: () => null,
            ),
            title: Text('Update Profile'),
            onTap: () {
              print(widget.uid);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(uid: widget.uid)),
              );
            },
          ),
          ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.settings, color: Colors.black),
              onPressed: () => null,
            ),
            title: Text('Set Profile Image'),
            onTap: () {
              print(widget.uid);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfImgPage(uid: widget.uid)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  SettingsPage({this.uid});
  final String uid;
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference dbRef =
  FirebaseDatabase.instance.reference().child("Users");
  TextEditingController nameController = TextEditingController();
  TextEditingController hobbyController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Update Profile")),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Enter User Name",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter User Name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: hobbyController,
                      decoration: InputDecoration(
                        labelText: "Enter your Hobbies",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter your Hobbies';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: isLoading
                        ? CircularProgressIndicator()
                        : RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          updateToFb();
                        }
                      },
                      child: Text('Update'),
                    ),
                  )
                ]))));
  }

  void updateToFb() {
    var firebaseUser = FirebaseAuth.instance.currentUser;

      dbRef.child(firebaseUser.uid).update({
        "hobby": hobbyController.text,
        "name": nameController.text
      }).then((res) {
        isLoading = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home(uid: firebaseUser.uid)),
        );
      });
  }



  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    hobbyController.dispose();
  }
}


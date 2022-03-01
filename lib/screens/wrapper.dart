import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:level_up_ya_life/screens/authenticate/authenticate.dart';
import 'package:level_up_ya_life/screens/home/home.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}
class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return Home();
          }else if (snapshot.hasError){
            return Center(child: Text('Something Went Wrong!'));
          }
          else {
            return Authenticate();
          }
        }
    );
  }
}

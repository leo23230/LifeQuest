import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text('Coming Soon...', style: GoogleFonts.montserrat(fontSize: 48, color: Colors.black),),
      ),
    );
  }
}

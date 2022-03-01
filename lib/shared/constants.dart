import 'package:flutter/material.dart';

class Constants {
  static const String personal = "Personal";
  static const String school = "School";
  static const String programming = "Porgramming";

  static const List<String> choices = <String> [
    personal,
    school,
    programming
  ];
}

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.all(12.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.pink, width: 2.0),
  ),
);

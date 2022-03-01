// @dart=2.9

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:level_up_ya_life/provider/google_sign_in.dart';
import 'package:level_up_ya_life/screens/shop_item_creator.dart';
import 'package:level_up_ya_life/screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'screens/home/home.dart';
import 'package:level_up_ya_life/screens/quest_creater.dart';
import 'shared/constants.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        title: 'Life Quest',
        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/':(context) => Wrapper(),
        '/quest-builder':(context) => QuestBuilder(),
        '/shop-builder':(context) => ShopItemBuilder(),
      },
    );
  }
}

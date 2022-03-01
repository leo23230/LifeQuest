import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:level_up_ya_life/services/database.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSingIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    final googleUser = await googleSingIn.signIn();
    if(googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential (credential);

    final firebaseUser = FirebaseAuth.instance.currentUser;

    //check if user doc exists
    var collectionRef = FirebaseFirestore.instance.collection('profiles');
    var doc = await collectionRef.doc(firebaseUser.uid).get();
    if(!doc.exists){
      await DatabaseService(uid: firebaseUser.uid).updateUserData(userId: firebaseUser.uid,
          name: firebaseUser.displayName, gold: 50, quests: [], shopItems: [], categories: {});
    }

    notifyListeners();
  }

  Future logout() async {
    await googleSingIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
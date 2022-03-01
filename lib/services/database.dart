// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_up_ya_life/models/profile.dart';
import 'package:level_up_ya_life/models/userdata.dart';

class DatabaseService {

  final String uid;

  DatabaseService({this.uid});

  // collection reference
  // a reference to a collection in the Firestore database
  //this variable is used to add new documents, read, update, and remove existing documents
  final CollectionReference profilesCollection = FirebaseFirestore.instance.collection('profiles');
  List<Profile> profiles = List<Profile>();

  //Used both to initialize the user data doc and update the existing doc with new data
  Future updateUserData({String userId, String name, int gold, List<dynamic> quests,
    List<dynamic> shopItems, Map categories}) async {
    return await profilesCollection.doc(uid).set({
      //If the optional named parameter = null we don't overwrite the existing value
      //could not use ternary operator
      if(userId != null) 'uid' : userId,
      if(name != null) 'name': name,
      if(gold != null) 'gold' : gold,
      if(quests != null) 'quests' : quests,
      if(shopItems != null) 'shopItems' : shopItems,
      if(categories != null) 'categories' : categories,
    },
      //insures that we merge the data with the existing doc, and don't overwrite the entire doc
      SetOptions(merge:true),
    );
  }

  //Gets a profile from a query snapshot
  //Will use this for swiping screen (Home)
  List<Profile> _profileListFromSnapshot(List<DocumentSnapshot> docs) {
    //a map function that takes the list of documents and converts it to a list of Profile objects
    //perform a function for each document that takes the document and returns a single profile

    //for each document in the List of documents add a profile object to the profiles list
    for(final doc in docs) {
      profiles.add(Profile(
        //doc.data is a map, so we pass the key 'name' to get value
        uid: doc.data()['uid'] ?? '',
        name: doc.data()['name'] ?? '',
        quests: doc.data()['quests'] ?? '',
      ));
    }
    return profiles;
  }

  //UserData from snapshot
  //takes the user doc snapshot and turns it into a UserData object
  //This is for profile settings
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid:uid,
      name: snapshot.data()['name'],
      gold: snapshot.data()['gold'],
      quests: snapshot.data()['quests'],
      shopItems: snapshot.data()['shopItems'],
      categories: snapshot.data()['categories']
    );
  }

  Future<UserData> otherUserDataFromSnapshot ()async{
    DocumentSnapshot doc;
    UserData otherUserData;
    doc = await profilesCollection.doc(uid).get();
    otherUserData = _userDataFromSnapshot(doc);
    return otherUserData;
  }

  //get profile stream
  // Stream<List<Profile>> get otherProfiles {
  //   return profilesCollection.snapshots().map(_profileListFromSnapshot);
  // }

  //stream that gets a profile snapshot from the uid and returns a UserData object
  Stream<UserData> get userData {
    return profilesCollection.doc(uid).snapshots().map(_userDataFromSnapshot); //every time the doc changes we get a snapshot
  }

  // Stream<List<Profile>> get profilesList {
  //   GeoFirePoint center = geo.point(latitude: lat, longitude: lng);
  //   return geo.collection(collectionRef: profilesCollection)
  //       .within(
  //     center: center,
  //     radius: rad.toDouble(),
  //     field: 'geoHash',
  //     strictMode: true,
  //   )
  //       .map(_profileListFromSnapshot);
  // }
}
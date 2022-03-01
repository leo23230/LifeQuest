// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:level_up_ya_life/models/userdata.dart';
import 'package:level_up_ya_life/services/database.dart';
import 'package:level_up_ya_life/shared/constants.dart';

class QuestBuilder extends StatefulWidget {
  final Map existingQuest;
  final int existingQuestIndex;
  final bool isCopy;
  QuestBuilder({Key key, this.existingQuest, this.existingQuestIndex, this.isCopy}) : super(key:key);
  @override
  _QuestBuilderState createState() => _QuestBuilderState();
}

class _QuestBuilderState extends State<QuestBuilder> {
  //form key
  final _formKey = GlobalKey<FormState>();

  //text field state
  String _questName = '';
  String _questDescription = '';
  int _questGoldReward = 0;
  Timestamp _createdAt = Timestamp.now();
  var _newQuest = {'createdAt': null, 'name':'', 'description': '', 'reward': 0, 'repeat': true, 'category':''};
  String _category;
  bool _repeat = true;

  //bool to set initial quest attributes once
  bool _setInitQuestAttributes = false;

  @override
  Widget build(BuildContext context) {
    if(widget.existingQuest != null && !_setInitQuestAttributes){
      _questName = widget.existingQuest['name'];
      if(widget.existingQuest['createdAt'] != null)_createdAt = widget.existingQuest['createdAt'];
      _questDescription = widget.existingQuest['description'];
      _questGoldReward = widget.existingQuest['reward'];
      if(widget.existingQuest['repeat'] != null)_repeat = widget.existingQuest['repeat'];
      if(widget.existingQuest['category'] != null)_category = widget.existingQuest['category'];

      _setInitQuestAttributes = true;
    }
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        //check for data
        final UserData userData = snapshot.data;

        return Scaffold(
          backgroundColor: Colors.orange[50],
          appBar: AppBar(
            backgroundColor: Colors.brown[800],
            title: Text(
              "Quest Builder",
              style: GoogleFonts.montserrat(fontSize: 22, color: Colors.white),
            ),
          ),
            body: Center(
              child: Form(
              key: _formKey,
              child: Column(
                children: <Widget> [
                  SizedBox(height: 10.0),
                  Text(
                    '*Quest Name',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 8.0),
                  SizedBox( //Quest Name Form Field
                    width: 250,
                    child: TextFormField(
                      initialValue: _questName,
                      decoration: textInputDecoration,
                      validator: (val) => val.isEmpty ? 'Please enter a name' : null,
                      onChanged: (val) {
                        if(val.length > 0) {
                          setState(() => _questName = val);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Quest Description',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 8.0),
                  SizedBox( //Quest Description
                    width: 250,
                    child: TextFormField(
                      initialValue: _questDescription,
                      decoration: textInputDecoration,
                      //validator: (val) => val.isEmpty ? 'Enter a name' : null,
                      minLines: 3,
                      maxLines: 8,
                      onChanged: (val) {
                        if(val.length > 0) {
                          setState(() => _questDescription = val);
                          print(_questDescription);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '*Reward',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 8.0),
                  SizedBox( //Quest Award Form Field
                    width: 250,
                    child: TextFormField(
                      initialValue: _questGoldReward.toString(),
                      decoration: textInputDecoration,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if(val.isEmpty){
                          return 'Please enter a reward';
                        }
                        else if (int.tryParse(val) == null){
                          return 'Please enter a whole number';
                        }
                        else if(int.tryParse(val) != null && int.tryParse(val).isNegative){
                          return 'Please enter a positive whole number';
                        }
                        else{
                          return null;
                        }
                      },
                      onChanged: (val) {
                        if(val.length > 0) {
                          setState(() => _questGoldReward = int.parse(val));
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Category',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(
                    width: 250,
                    child: widget.existingQuest != null ? DropdownButtonFormField(
                      value: widget.existingQuest['category'] != null ? _category : null,
                      decoration: InputDecoration(hintText: widget.existingQuest['category'] != null ? _category : 'Select a Category'),
                      items: userData.categories.keys.map((category){
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category)
                        );
                      }).toList(),
                      validator: (val) => val.isEmpty ? 'Please choose a category' : null,
                      onChanged: (val) {
                        setState(() {
                          _category = val;
                        });
                        print(_category);
                      }
                    ) :
                    DropdownButtonFormField(
                        decoration: InputDecoration(hintText: 'Select a Category'),
                        items: userData.categories.keys.map((category){
                          return DropdownMenuItem(
                              value: category,
                              child: Text(category)
                          );
                        }).toList(),
                        validator: (val) => val.isEmpty ? 'Please choose a category' : null,
                        onChanged: (val) {
                          setState(() {
                            _category = val;
                          });
                          print(_category);
                        }
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Repeat',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 8.0),
                  SizedBox( //Quest Award Form Field
                    width: 250,
                    child: Checkbox(
                      value: _repeat,
                      onChanged: (val){
                        setState(() {
                          _repeat = !_repeat;
                        });
                      },
                    ),
                  ),
                  RaisedButton(onPressed: () async{
                    if(_formKey.currentState.validate()){
                      _newQuest['createdAt'] = _createdAt;
                      _newQuest['name'] = _questName;
                      _newQuest['description'] = _questDescription;
                      _newQuest['reward'] = _questGoldReward;
                      _newQuest['repeat'] = _repeat;
                      _newQuest['category'] = _category;

                      print(_newQuest['category']);

                      if(widget.existingQuest != null) {
                        var _oldCategory = widget.existingQuest['category'];
                        if(_oldCategory != _category){
                          //delete timestamp from old category array
                          //add timestamp to new category array
                          List<dynamic> oldCategoryArray = userData.categories[_oldCategory].toList();
                          List<dynamic> newCategoryArray = userData.categories[_category].toList();
                          oldCategoryArray.remove(_createdAt);
                          newCategoryArray.add(_createdAt);
                          userData.categories[_oldCategory] = oldCategoryArray;
                          userData.categories[_category] = newCategoryArray;
                        }
                        else{
                          //we don't want to do anything then
                        }
                      }
                      else{
                        List<dynamic> _categoryArray = userData.categories[_category];
                        _categoryArray.add(_createdAt);
                        userData.categories[_category] = _categoryArray;
                      }
                      //update userData.quests
                      if(widget.existingQuest == null || widget.isCopy) {
                          //if this quest is a new quest, we want to insert it into the list
                          print('isCopy Called');
                          userData.quests.insert(0, _newQuest);
                        }
                        else {
                          //if this quest exists, and is being updated, we want to set it equal to
                          //new quest
                          userData.quests[widget.existingQuestIndex] = _newQuest;
                      }
                      // //we need to get a count of existing quests in that category and set
                      // //category index equal to that
                      // //this works no matter what because the new category is always gaining
                      // //a new item
                      // var _itemCount = 0;
                      // for(int i = 0; i < userData.quests.length; i++){
                      //   if(userData.quests[i]['category'] == _newQuest['category']){
                      //     _itemCount += 1;
                      //   }
                      // }
                      // _newQuest['categoryIndex'] = _itemCount;
                      //
                      // //Next we have to add the new quest or update an existing one
                      // print(_newQuest);
                      //
                      // //update userData.quests
                      // if(widget.existingQuest == null || widget.isCopy){
                      //   //if this quest is a new quest, we want to insert it into the list
                      //   print('isCopy Called');
                      //   userData.quests.insert(0, _newQuest);
                      // }
                      // else {
                      //   //if this quest exists, and is being updated, we want to set it equal to
                      //   //new quest
                      //   userData.quests[widget.existingQuestIndex] = _newQuest;
                      //
                      //   //in here we also want to check if the category has changed
                      //   //this is after we update userData.quests because the quest needs to be updated first
                      //   //so we can count how many quests are in the old category
                      //   if(widget.existingQuest['category'] != null){
                      //     var _oldCategory = widget.existingQuest['category'];
                      //     if(_oldCategory != _category){
                      //       //this means the category is being changed
                      //       //we have to take any quests that match the old category and update their indices
                      //       List<dynamic> _categoryItems = [];
                      //       for(int i = 0; i < userData.quests.length; i++){
                      //         if(userData.quests[i]['category'] == _oldCategory){
                      //           _categoryItems.add(userData.quests[i]);
                      //         }
                      //       }
                      //       //then we want to order them from least to greatest
                      //       _categoryItems.sort((map1, map2){
                      //         return map1['categoryIndex'].compareTo(map2['categoryIndex']);
                      //       });
                      //       //REORGANIZE
                      //       //now that they're sorted, we can use a for loop to correct the
                      //       //indices of all existing quests under that category
                      //       //since there will be a gap, we will use this to fill the gap
                      //       //by basically counting up by one, and setting anything that is not equal to the
                      //       //current count equal to i, closing the gap
                      //       for(int i = 0; i<_categoryItems.length; i++){
                      //         if(_categoryItems[i]['categoryIndex'] != i) _categoryItems[i]['categoryIndex'] = i;
                      //       }
                      //       //now that the indices are correct, we can finally update userData.quests
                      //       print(_categoryItems);
                      //       var counter = 0;
                      //       for(int i = 0; i < userData.quests.length; i++){
                      //         for(int j = 0; j < _categoryItems.length; j++){
                      //           if(userData.quests[i]['name'] == _categoryItems[j]['name']){
                      //             counter += 1;
                      //             print(counter);
                      //             userData.quests[i]['categoryIndex'] = _categoryItems[j]['categoryIndex'];
                      //           }
                      //         }
                      //       }
                      //     }
                      //     else{
                      //       userData.quests[widget.existingQuestIndex]['categoryIndex'] = widget.existingQuest['categoryIndex'];
                      //     }
                      //   }
                      // }

                      //now that all category indices are accounted for, we can update the doc
                      await DatabaseService(uid: user.uid).updateUserData(
                        categories: userData.categories,
                        quests: userData.quests,
                      );

                      //pop back to profile screen
                      Navigator.pop(context);
                    }
                  })
                ],
              )
          ),
            ),
        );
      }
    );
  }
}

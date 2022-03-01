//@dart=2.9

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:level_up_ya_life/models/userdata.dart';
import 'package:level_up_ya_life/screens/quest_creater.dart';
import 'package:level_up_ya_life/services/database.dart';
import 'package:level_up_ya_life/shared/loading.dart';

class Quests extends StatefulWidget {
  final String category;
  Quests({Key key, this.category}) : super(key:key);
  @override
  _QuestsState createState() => _QuestsState();
}

class _QuestsState extends State<Quests> {

  ConfettiController _confettiController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _confettiController = new ConfettiController(duration: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _confettiController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _arrangeFilteredQuests(UserData userData) async{
    List<dynamic> filteredQuests = [];
    List<dynamic> updatedQuests = userData.quests;
    List<dynamic> _newCategoryArray = [];
    List<dynamic> _updatedCategoryArray = userData.categories[widget.category];
    Map updatedCategories = userData.categories;

    if(widget.category == 'All'){
      filteredQuests = userData.quests;
      return filteredQuests;
    }

    //add time stamps if they don't already exist
    for(int i = 0; i < updatedQuests.length; i++){
      if(updatedQuests[i]['createdAt'] == null){
        updatedQuests[i]['createdAt'] = Timestamp.now();
      }
    }
    //now that everything has a timestamp we can
    //add timestamps to the corresponding category array
    for(int i = 0; i < updatedQuests.length; i++){
      if(updatedQuests[i]['category'] == widget.category){
        _newCategoryArray.add(updatedQuests[i]['createdAt']);
      }
    }
    // now we have a list of all category timestamps
    // we need to check the existing db array against this one and set the old equal to the new
    //if it is not equal to the new one's length
    if(_updatedCategoryArray.length != _newCategoryArray.length){
      _updatedCategoryArray = _newCategoryArray;
    }
    filteredQuests = _updatedCategoryArray;
    updatedCategories[widget.category] = _updatedCategoryArray;

    // now we have to update the doc if anything has changed
      await DatabaseService(uid: userData.uid).updateUserData(
        quests: updatedQuests,
        categories: updatedCategories,
      );


    // for(int i = 0; i < userData.quests.length; i++){
    //   if(userData.quests[i]['category'] != null){
    //     if(userData.quests[i]['category'] == widget.category){
    //       filteredQuests.add(userData.quests[i]);
    //     }
    //   }
    // }
    // //insert items into proper index
    // var questsFiltered = 0;
    // for(int i = 0; i < userData.quests.length; i++){
    //   if(userData.quests[i]['category'] != null){
    //     if(userData.quests[i]['category'] == widget.category){
    //       if(userData.quests[i]['categoryIndex'] != null){
    //         var categoryIndex = userData.quests[i]['categoryIndex'];
    //         filteredQuests[categoryIndex] = userData.quests[i];
    //         questsFiltered += 1;
    //       }
    //       else{
    //         print('TRIGGERED CATEGORY INDEX CHECK');
    //         var _categoryIndex = questsFiltered;
    //         questsFiltered += 1;
    //
    //         final Map _quest = userData.quests[i];//get the current quest
    //
    //         var _newQuests = userData.quests; //get all current quests
    //         _quest['categoryIndex'] = _categoryIndex; //set quest category index
    //         _newQuests[i] = _quest;
    //         await DatabaseService(uid: userData.uid).updateUserData(
    //             quests: _newQuests
    //         );
    //       }
    //     }
    //   }
    // }
    return filteredQuests;
  }

  @override

  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<UserData>(
      stream:  DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        final UserData userData = snapshot.data;
        if (snapshot.hasData){
          //add to list
          return FutureBuilder(
            future: _arrangeFilteredQuests(userData),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                List<dynamic> filteredQuests = snapshot.data;
                return Stack(
                  children: [
                    ReorderableListView.builder(
                      onReorder: (oldIndex, newIndex) async {

                        List<dynamic> quests = filteredQuests;
                        List<dynamic> allQuests = userData.quests;
                        var oI = oldIndex;
                        var nI = newIndex;

                        if(newIndex > oldIndex){
                          nI -=1;
                        }
                        if(widget.category == 'All'){
                          final item = allQuests.removeAt(oI);
                          allQuests.insert(nI, item);
                        }
                        else{
                          final item = quests.removeAt(oI);
                          quests.insert(nI, item);
                          // final item = quests.removeAt(oI);
                          // quests.insert(nI, item);
                          //
                          // //reset category index
                          // for(int i = 0; i < allQuests.length; i++) {
                          //   for (int j = 0; j < quests.length; j++){
                          //     if(allQuests[i]['name'] == quests[j]['name']){
                          //       allQuests[i]['categoryIndex'] = j;
                          //     }
                          //   }
                          // }
                        }

                        await DatabaseService(uid:userData.uid).updateUserData(
                          quests: allQuests,
                        );

                        setState((){});
                      },
                      itemCount: filteredQuests.length,
                      itemBuilder: (context, index){
                        Map currentQuest = new Map();
                        int questOriginalIndex = 0;
                        if(widget.category == 'All'){
                          currentQuest = filteredQuests[index];
                          questOriginalIndex = index;
                        }
                        else{
                          for(int i = 0; i < userData.quests.length; i++){
                            if(userData.quests[i]['createdAt'] == filteredQuests[index]){
                              currentQuest = userData.quests[i];
                              questOriginalIndex = i; //need this to update data if edited
                            }
                          }
                        }
                        return Card(
                          key: ValueKey(index),
                          child: ListTile(
                            onTap: () {
                              showQuestCompleteConfirmation(context, userData, questOriginalIndex);
                            },
                            leading: PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              onSelected: (choice){
                                if(choice == 'edit') _awaitReturnValueFromQuestBuilder(context, currentQuest, questOriginalIndex, isCopy: false);
                                else if(choice == 'delete') showDeleteConfirmation(context, userData, questOriginalIndex);
                                else if (choice == 'copy') _awaitReturnValueFromQuestBuilder(context, currentQuest, questOriginalIndex, isCopy: true);
                              },
                              itemBuilder: (BuildContext context){
                                return [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(children: [Padding(padding: EdgeInsets.fromLTRB(0,0,4,0),child:Icon(Icons.edit)), Text('Edit', style: GoogleFonts.montserrat(fontSize: 14))]),
                                  ),
                                  PopupMenuItem(
                                    value: 'copy',
                                    child: Row(children: [Padding(padding: EdgeInsets.fromLTRB(0,0,4,0),child:Icon(Icons.copy)), Text('Copy', style: GoogleFonts.montserrat(fontSize: 14))]),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [Padding(padding: EdgeInsets.fromLTRB(0,0,4,0),child:Icon(Icons.delete)), Text('Delete', style: GoogleFonts.montserrat(fontSize: 14))]),
                                  ),
                                ];
                              },
                            ),
                            title: Text(currentQuest['name'], style: GoogleFonts.montserrat(fontSize: 18)),
                            subtitle: Text(currentQuest['description'], style: GoogleFonts.montserrat(fontSize: 14)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(currentQuest['reward'].toString(), style: GoogleFonts.montserrat(fontSize: 18, color: Colors.yellow[700])),
                              ],
                            ),
                            minVerticalPadding: 10,
                          ),
                        );
                      },
                    ),
                    ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      minBlastForce: 18,
                      maxBlastForce: 36,
                      emissionFrequency: 0.5,
                      gravity: 0.3,
                      colors: [
                        Colors.yellow,
                        Colors.yellow[700],
                        Colors.white,
                      ],
                    )
                  ],
                );
              }
              else if(snapshot.hasError){
                print(snapshot.error);
                return Container();
              }
              else{
                return Loading();
              }
            }
          );
        }
        else{
          return Loading();
        }
      }
    );
  }

  showQuestCompleteConfirmation(BuildContext context, userData, index) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Complete Quest?'),
      content: Text('Collect ' + userData.quests[index]['reward'].toString() + ' gold'),
      actions: [
        FlatButton(
            onPressed: () async{
              List<dynamic> updatedQuests = userData.quests;
              Map updatedCategories = userData.categories;
              Map _quest = updatedQuests.elementAt(index);
              int currentGold = userData.gold;
              currentGold += userData.quests[index]['reward'];

              //check if repeat first, if not delete quest from userdata
              if(userData.quests[index]['repeat'] != null){
                if(!userData.quests[index]['repeat']){
                  updatedQuests.removeAt(index);

                  // remove associated timestamp from category array
                  List<dynamic> categoryArray = updatedCategories[_quest['category']].toList();
                  categoryArray.remove(_quest['createdAt']);
                  //update categories
                  updatedCategories[_quest['category']] = categoryArray;
                }
              }


              //update database document
              await DatabaseService(uid: userData.uid).updateUserData(
                gold: currentGold,
                categories: updatedCategories,
                quests: updatedQuests,
              );

              // if(_quest['category'] != null){
              //   var _oldCategory = _quest['category'];
              //   //we have to take any quests that match the old category and update their indices
              //   List<dynamic> _categoryItems = [];
              //   for(int i = 0; i < updatedQuests.length; i++){
              //     if(updatedQuests[i]['category'] == _oldCategory){
              //       _categoryItems.add(updatedQuests[i]);
              //     }
              //   }
              //   //then we want to order them from least to greatest
              //   _categoryItems.sort((map1, map2){
              //     return map1['categoryIndex'].compareTo(map2['categoryIndex']);
              //   });
              //   //REORGANIZE
              //   //now that they're sorted, we can use a for loop to correct the
              //   //indices of all existing quests under that category
              //   //since there will be a gap, we will use this to fill the gap
              //   //by basically counting up by one, and setting anything that is not equal to the
              //   //current count equal to i, closing the gap
              //   for(int i = 0; i<_categoryItems.length; i++){
              //     if(_categoryItems[i]['categoryIndex'] != i) _categoryItems[i]['categoryIndex'] = i;
              //   }
              //   //now that the indices are correct, we can finally update updatedQuests
              //   print(_categoryItems);
              //
              //   for(int i = 0; i < updatedQuests.length; i++){
              //     for(int j = 0; j < _categoryItems.length; j++){
              //       if(updatedQuests[i]['name'] == _categoryItems[j]['name']){
              //         updatedQuests[i]['categoryIndex'] = _categoryItems[j]['categoryIndex'];
              //       }
              //     }
              //   }
              // }

              _confettiController.play();

              Navigator.pop(context);
            },
            child: Text("Yes")
        ),
        FlatButton(onPressed: (){Navigator.pop(context);}, child: Text("No"))
      ],
    )
  );
  showDeleteConfirmation(BuildContext context, userData, index) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ' + userData.quests[index]['name'] + '?'),
        actions: [
          FlatButton(
              onPressed: () async{
                List<dynamic> updatedQuests = userData.quests;
                Map updatedCategories = userData.categories;
                Map _quest = updatedQuests.elementAt(index);
                //update quests
                updatedQuests.removeAt(index);

                // remove associated timestamp from category array
                List<dynamic> categoryArray = updatedCategories[_quest['category']].toList();
                categoryArray.remove(_quest['createdAt']);
                //update categories
                updatedCategories[_quest['category']] = categoryArray;
                // if(_quest['category'] != null){
                //   var _oldCategory = _quest['category'];
                //     //we have to take any quests that match the old category and update their indices
                //   List<dynamic> _categoryItems = [];
                //   for(int i = 0; i < updatedQuests.length; i++){
                //     if(updatedQuests[i]['category'] == _oldCategory){
                //       _categoryItems.add(updatedQuests[i]);
                //     }
                //   }
                //   //then we want to order them from least to greatest
                //   _categoryItems.sort((map1, map2){
                //     return map1['categoryIndex'].compareTo(map2['categoryIndex']);
                //   });
                //   //REORGANIZE
                //   //now that they're sorted, we can use a for loop to correct the
                //   //indices of all existing quests under that category
                //   //since there will be a gap, we will use this to fill the gap
                //   //by basically counting up by one, and setting anything that is not equal to the
                //   //current count equal to i, closing the gap
                //   for(int i = 0; i<_categoryItems.length; i++){
                //     if(_categoryItems[i]['categoryIndex'] != i) _categoryItems[i]['categoryIndex'] = i;
                //   }
                //   //now that the indices are correct, we can finally update updatedQuests
                //   print(_categoryItems);
                //
                //   for(int i = 0; i < updatedQuests.length; i++){
                //     for(int j = 0; j < _categoryItems.length; j++){
                //       if(updatedQuests[i]['name'] == _categoryItems[j]['name']){
                //         updatedQuests[i]['categoryIndex'] = _categoryItems[j]['categoryIndex'];
                //       }
                //     }
                //   }
                // }
                await DatabaseService(uid: userData.uid).updateUserData(
                  categories: updatedCategories,
                  quests: updatedQuests
                );
                Navigator.pop(context);
              },
              child: Text("Delete")
          ),
          FlatButton(onPressed: (){Navigator.pop(context);}, child: Text("Cancel"))
        ],
      )
  );

  void _awaitReturnValueFromQuestBuilder(BuildContext context, Map quest, int index, {bool isCopy}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          QuestBuilder(
            existingQuest: (quest != null) ? quest : null,
            existingQuestIndex: (index != null) ? index : null,
            isCopy: (isCopy != null) ? isCopy : false,
          )),
    );
  }
}
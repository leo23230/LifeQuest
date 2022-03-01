//@dart=2.9

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:level_up_ya_life/models/userdata.dart';
import 'package:level_up_ya_life/screens/shop_item_creator.dart';
import 'package:level_up_ya_life/services/database.dart';
import 'package:level_up_ya_life/shared/loading.dart';
import 'package:sticky_headers/sticky_headers.dart';

class Store extends StatefulWidget {
  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> with SingleTickerProviderStateMixin{

  AnimationController _animController;
  Animation<double> _flashAnimation;
  Animation _curve;
  bool animationReverse = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _curve = CurvedAnimation(parent: _animController, curve: Curves.bounceInOut);

    _flashAnimation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 0.7),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.7, end: 0),
          weight: 50,
        )
      ],
    ).animate(_curve);

    //check animation status to reverse it
    _animController.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        setState(() {
          animationReverse = true;
        });
      }
      if(status == AnimationStatus.dismissed){
        setState(() {
          animationReverse = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {

        final userData = snapshot.data;

        if(snapshot.hasData){
          return Stack(
              children: [
                AnimatedBuilder(
                  animation: _animController,
                  builder: (BuildContext context, _){
                    return Container(
                      color: Color.fromRGBO(255, 0, 0, _flashAnimation.value),
                    );
                  },
                ),
                if(userData.shopItems.length < 1) Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on_outlined, color: Colors.yellow[700], size: 38),
                    Text(
                      userData.gold.toString(),
                      style: GoogleFonts.montserrat(fontSize: 42, color: Colors.yellow[700]),
                    ),
                  ],
                ),
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 120,
                      backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                      pinned: false,
                      floating: true,
                      collapsedHeight: 120,
                      flexibleSpace: FlexibleSpaceBar(
                        titlePadding: EdgeInsets.all(0),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.monetization_on_outlined, color: Colors.yellow[700], size: 32),
                            Text(
                              userData.gold.toString(),
                              style: GoogleFonts.montserrat(fontSize: 42, color: Colors.yellow[700])
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index){
                        return Card(
                          child: ListTile(
                            leading: PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              onSelected: (choice){
                                if(choice == 'edit') _awaitReturnValueFromShopItemBuilder(context, userData.shopItems[index], index, isCopy: false);
                                else if(choice == 'delete') showDeleteConfirmation(context, userData, index);
                                else if (choice == 'copy') _awaitReturnValueFromShopItemBuilder(context, userData.shopItems[index], index, isCopy: true);
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
                            onTap: () {
                              if(userData.gold >= userData.shopItems[index]['cost']){
                                showPurchaseConfirmation(context, userData, index);
                              }
                              else{
                                animationReverse ? _animController.reverse() : _animController.forward();
                              }
                            },
                            onLongPress: (){
                              showDeleteConfirmation(context, userData, index);
                            },
                            title: Text(userData.shopItems[index]['name'], style: GoogleFonts.montserrat(fontSize: 18)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('-' + userData.shopItems[index]['cost'].toString(), style: GoogleFonts.montserrat(fontSize: 18, color: Colors.yellow[700])),
                              ],
                            ),
                            minVerticalPadding: 10,
                          ),
                        );
                      },
                        childCount: userData.shopItems.length,
                      ),
                    )
                  ],
                )
              ]
          );
        }
        else{
          return Loading();
        }
      }
    );
  }
}

void showPurchaseConfirmation(BuildContext context, userData, index) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Buy ' + userData.shopItems[index]['name'] + '?'),
      content: Text('Spend ' + userData.shopItems[index]['cost'].toString() + ' gold'),
      actions: [
        FlatButton(
            onPressed: () async{
              int currentGold = userData.gold;
              currentGold -= userData.shopItems[index]['cost'];
              await DatabaseService(uid: userData.uid).updateUserData(gold: currentGold);
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
      title: Text('Delete ' + userData.shopItems[index]['name'] + '?'),
      actions: [
        FlatButton(
            onPressed: () async{
              List<dynamic> updatedItems = userData.shopItems;
              updatedItems.removeAt(index);
              print(updatedItems);
              await DatabaseService(uid: userData.uid).updateUserData(
                  shopItems: updatedItems
              );
              Navigator.pop(context);
            },
            child: Text("Delete")
        ),
        FlatButton(onPressed: (){Navigator.pop(context);}, child: Text("Cancel"))
      ],
    )
);

void _awaitReturnValueFromShopItemBuilder(BuildContext context, Map quest, int index, {bool isCopy}) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>
        ShopItemBuilder(
          existingItem: (quest != null) ? quest : null,
          existingItemIndex: (index != null) ? index : null,
          isCopy: (isCopy != null) ? isCopy : false,
        )),
  );
}
//@dart=2.9

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:level_up_ya_life/models/userdata.dart';
import 'package:level_up_ya_life/services/database.dart';
import 'package:level_up_ya_life/shared/constants.dart';

class ShopItemBuilder extends StatefulWidget {
  final Map existingItem;
  final int existingItemIndex;
  final bool isCopy;
  ShopItemBuilder({Key key, this.existingItem, this.existingItemIndex, this.isCopy}) : super(key:key);
  @override
  _ShopItemBuilderState createState() => _ShopItemBuilderState();
}

class _ShopItemBuilderState extends State<ShopItemBuilder> {
  //form key
  final _formKey = GlobalKey<FormState>();

  //text field state
  String _itemName = '';
  int _itemCost = 0;
  var _newItem = {'name':'', 'cost': 0};

  //bool to set initial item attributes once
  bool _setInitItemAttributes = false;

  @override
  Widget build(BuildContext context) {
    if(widget.existingItem != null && !_setInitItemAttributes){
      _itemName = widget.existingItem['name'];
      _itemCost = widget.existingItem['cost'];
      _setInitItemAttributes = true;
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
                        'Item Name',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black),
                      ),
                      SizedBox(height: 8.0),
                      SizedBox( //Item Name Form Field
                        width: 250,
                        child: TextFormField(
                          initialValue: _itemName,
                          decoration: textInputDecoration,
                          validator: (val) => val.isEmpty ? 'Enter a name' : null,
                          onChanged: (val) {
                            if(val.length > 0) {
                              setState(() => _itemName = val);
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Item Cost',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black),
                      ),
                      SizedBox(height: 8.0),
                      SizedBox( //Quest Award Form Field
                        width: 250,
                        child: TextFormField(
                          initialValue: _itemCost.toString(),
                          decoration: textInputDecoration,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if(val.isEmpty){
                              return 'Enter a cost';
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
                              setState(() => _itemCost = int.parse(val));
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 8.0),
                      RaisedButton(onPressed: () async{
                        if(_formKey.currentState.validate()){
                          // print(_itemName);

                          _newItem['name'] = _itemName;
                          _newItem['cost'] = _itemCost;

                          print(_newItem);

                          if(widget.existingItem == null || widget.isCopy){
                            userData.shopItems.add(_newItem);
                          }
                          else {
                            userData.shopItems[widget.existingItemIndex] = _newItem;
                            print(_newItem);
                            print(userData.shopItems[widget.existingItemIndex]);
                          }

                          print(userData.shopItems);

                          await DatabaseService(uid: user.uid).updateUserData(
                            shopItems: userData.shopItems,
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

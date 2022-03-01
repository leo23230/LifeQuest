//@dart=2.9

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:level_up_ya_life/models/userdata.dart';
import 'package:level_up_ya_life/provider/google_sign_in.dart';
import 'package:level_up_ya_life/screens/friends.dart';
import 'package:level_up_ya_life/screens/home/quests.dart';
import 'package:level_up_ya_life/services/database.dart';
import 'package:level_up_ya_life/shared/loading.dart';
import 'package:provider/provider.dart';
import 'store.dart';
import 'package:level_up_ya_life/shared/constants.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<Home> {

  int _counter = 0;
  int _currentIndex = 1;
  final _controller = PageController(
    initialPage: 1,
  );
  final appBarTitles = ["General Goods", "Quests", "Friends"];
  final screens = [
    Store(),
    Quests(),
    Friends(),
  ];
  final appBarLeading = [

  ];

  List<dynamic> categories = [];

  //The actual category to sort the list tiles
  String category = 'All';

  final _categoryFormKey = GlobalKey<FormState>();

  AnimationController animationController;
  Animation degOneTranslationAnimation,degTwoTranslationAnimation,degThreeTranslationAnimation;
  Animation rotationAnimation;


  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    animationController = AnimationController(vsync: this,duration: Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.2,end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.4,end: 1.0), weight: 45.0),
    ]).animate(animationController);
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.75), weight: 35.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.75,end: 1.0), weight: 65.0),
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 180.0,end: 0.0).animate(CurvedAnimation(parent: animationController
        , curve: Curves.easeOut));
    super.initState();
    animationController.addListener((){
      setState(() {

      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return StreamProvider.value(
      value: DatabaseService(uid: user.uid).userData,
      builder: (context, child){
        if(Provider.of<UserData>(context) != null){
          final userData = Provider.of<UserData>(context);
          if(userData.categories != null){
            categories = userData.categories.keys.toList();
          }
          return Scaffold(
            backgroundColor: Colors.orange[50],
            appBar: AppBar(
              title: Text(
                _currentIndex == 1 ? user.displayName + '\'s ' + appBarTitles[_currentIndex] : appBarTitles[_currentIndex],
                style: GoogleFonts.montserrat(fontSize: 22, color: Colors.white),
              ),
              backgroundColor: Colors.brown[800],
              leading: PopupMenuButton(
                onSelected:(choice){
                  if(choice == 'Add new category') _createCategoroy(context, userData);
                  else setState(() {
                    category = choice;
                  });
                },
                itemBuilder: (BuildContext context){
                  List<String> _categoryOptions = [];

                  if(categories != null) {
                    for(int i = 0; i < categories.length; i++){
                      _categoryOptions.add(categories[i]);
                    }
                  }

                  _categoryOptions.add('All');

                  _categoryOptions.add('Add new category');

                  return _categoryOptions.map((String choice){
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                icon: Icon(Icons.menu),
              ),
              actions: [
                IconButton(
                    onPressed: (){
                      final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                      provider.logout();
                    },
                    icon: Icon(Icons.logout)
                ),
              ],
            ),
            body: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  PageView(
                    physics: PageScrollPhysics(),
                    controller: _controller,
                    children:[
                      Store(),
                      Quests(category: category),
                      Friends()
                    ],
                    onPageChanged: (index){
                      setState((){
                        _currentIndex = index;
                      });
                    },
                  ),
                  IgnorePointer(
                    child: Container(
                      color: Colors.transparent,
                      height: 150.0,
                      width: 150.0,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(270),degOneTranslationAnimation.value * 100),
                    child: Transform(
                      transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value))..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        color: Colors.green[700],
                        width: 50,
                        height: 50,
                        icon: Icon(
                          Icons.post_add,
                          color: Colors.white,
                        ),
                        onClick: (){
                          //bring us back to the quest page
                          if(_currentIndex != 1) {
                            setState(() {_currentIndex = 1;});
                            _controller.animateToPage(_currentIndex, duration: Duration(milliseconds: 400), curve: Curves.easeOut);
                          }
                          Navigator.pushNamed(context, '/quest-builder');
                        },
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(225),degTwoTranslationAnimation.value * 100),
                    child: Transform(
                      transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value))..scale(degTwoTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        color: Colors.yellow[700],
                        width: 50,
                        height: 50,
                        icon: Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                        ),
                        onClick: (){
                          if(_currentIndex != 0) {
                            setState(() {_currentIndex = 0;});
                            _controller.animateToPage(_currentIndex, duration: Duration(milliseconds: 400), curve: Curves.easeOut);
                          }
                          Navigator.pushNamed(context, '/shop-builder');
                        },
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(180),degThreeTranslationAnimation.value * 100),
                    child: Transform(
                      transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value))..scale(degThreeTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        color: Colors.black,
                        width: 50,
                        height: 50,
                        icon: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        onClick: (){
                          print('Third Button');
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Transform(
                      transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value)),
                      alignment: Alignment.center,
                      child: CircularButton(
                        color: Colors.brown[700],
                        width: 60,
                        height: 60,
                        icon: Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        onClick: (){
                          if (animationController.isCompleted) {
                            animationController.reverse();
                          } else {
                            animationController.forward();
                          }
                        },
                      ),
                    ),
                  )
                ]
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.shifting,
              selectedItemColor: Colors.yellow[700],
              unselectedItemColor: Colors.grey[600],
              currentIndex: _currentIndex,
              onTap:(index) => setState(() {
                _currentIndex = index;
                _controller.animateToPage(_currentIndex, duration: Duration(milliseconds: 400), curve: Curves.easeOut);
              }),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money),
                  title: Text('Store'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.request_page_rounded),
                  title: Text('Quests'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum),
                  title: Text('Friends'),
                ),
              ],
            ),
          );
        }
        else{
          return Loading();
        }
      }
    );
  }

  void _createCategoroy(BuildContext context, UserData userData) {
    String _categoryName;
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Add A New Category',
                style: GoogleFonts.montserrat(fontSize: 18)),
            content: Form(
              key: _categoryFormKey,
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(hintText: 'Enter Category Name'),
                validator: (val) => val.isEmpty ? 'Enter a name' : null,
                onChanged: (val) => _categoryName = val,
              ),
            ),
            actions: [
              TextButton(
                child: Text('Submit'),
                onPressed: () {
                  if(_categoryFormKey.currentState.validate()){
                    Map _newCategories = {};
                    if(userData.categories != null)_newCategories = userData.categories;
                    _newCategories[_categoryName] = [];
                    DatabaseService(uid: userData.uid).updateUserData(
                      categories: _newCategories,
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
    );
  }

}

class CircularButton extends StatelessWidget {

  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final Function onClick;

  CircularButton({this.color, this.width, this.height, this.icon, this.onClick});


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color,shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(icon: icon,enableFeedback: true, onPressed: onClick),
    );
  }
}


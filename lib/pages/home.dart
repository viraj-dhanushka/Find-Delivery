import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finddelivery/models/user.dart';
import 'package:finddelivery/pages/choose_account.dart';
import 'package:finddelivery/pages/profile.dart';
import 'package:finddelivery/pages/search.dart';
import 'package:finddelivery/pages/timeline.dart';
import 'package:finddelivery/pages/upload.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_feed.dart';
import 'buyer_profile.dart';
import 'closest_shop.dart';

final userRef = Firestore.instance.collection('users');
final activityFeedRef = Firestore.instance.collection('feed');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');

final StorageReference storageRef = FirebaseStorage.instance.ref();
// final DateTime timestamp = DateTime.now();
final int timestamp = DateTime.now().millisecondsSinceEpoch;

final FacebookLogin facebookSignIn = new FacebookLogin();
final GoogleSignIn googleSignIn = GoogleSignIn();

FirebaseAuth _auth;

User currentUserWithInfo;

class Home extends StatefulWidget {
  static const String id = "home";
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool showSpinner = false;
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  // FirebaseUser mCurrentUser;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _auth = FirebaseAuth.instance;
    _getCurrentUser();

    // Detects when user signed in
    // googleSignIn.onCurrentUserChanged.listen((account) {
    //   addFirebaseAuth(account);
    //   handleSignIn(account);
    // }, onError: (err) {
    //   showToast('Signing In Failed');
    //   print('Error signing in: $err');
    // });
    // Reauthenticate user when app is opened
    // googleSignIn.signInSilently(suppressErrors: false).then((account) {
    //   handleSignIn(account);
    // }).catchError((err) {
    //   print('silently: $err');
    // });
  }

  _getCurrentUser() async {
    // mCurrentUser = await _auth.currentUser(); //user in the cache
    // setState(() {
    //   mCurrentUser != null ? isAuth = true : isAuth = false;
    // });

    //get currentUserInfo for signed in user

    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loggedUserId = prefs.getString('loggedUserId');
    if (loggedUserId != null) {
      DocumentSnapshot documentSnapshot =
          await userRef.document(loggedUserId).get();

      if (documentSnapshot.exists) {
        setState(() {
          currentUserWithInfo = User.fromDocument(documentSnapshot);
        });
        print(currentUserWithInfo);
        print(currentUserWithInfo.name);
        setState(() {
          isAuth = true;
        });
        shredPrefConfigurePushNotifications(currentUserWithInfo);
      } else {
        //block user => delete document/auth
        setState(() {
          isAuth = false;
        });
      }
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  // addFirebaseAuth(GoogleSignInAccount googleUser) async {
  //   if (googleUser != null) {
  //     GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.getCredential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     final FirebaseUser user =
  //         (await _auth.signInWithCredential(credential)).user;
  //     showToast("Hi, " + user.displayName);
  //   }
  // }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 250), curve: Curves.easeInCirc);
  }

  void showToast(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        // toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.blue,
        textColor: Colors.white);
  }

//google stuff
  // final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    handleSignIn(googleSignInAccount);
  }

  handleSignIn(GoogleSignInAccount googleSignInAccount) async {
    if (googleSignInAccount != null) {
      // print('User signed in!: $googleSignInAccount');

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult =
          await _auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      // showToast("Hi, " + user.displayName);
      try {
        await createUserInFirestore(user);
      } catch (err) {
        showToast(user.displayName + ", please try again");
        setState(() {
          showSpinner = false;
          isAuth = false;
        });
        _signOut();
      }

      // return 'signInWithGoogle succeeded: $user';
      shredprefUser(user.uid);

      setState(() {
        showSpinner = false;
        isAuth = true;
      });
      configurePushNotifications(user);
    } else {
      setState(() {
        showSpinner = false;
        isAuth = false;
      });
    }
  }

//facebook stuff
  // static final FacebookLogin facebookSignIn = new FacebookLogin();

  Future _signIn(BuildContext context) async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token);

        FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
        // showToast("Hi, " + user.displayName);
        try {
          await createUserInFirestore(user);
        } catch (err) {
          showToast(user.displayName + ", login again");
          setState(() {
            showSpinner = false;
            isAuth = false;
          });
          _signOut();
        }
        shredprefUser(user.uid);

        setState(() {
          isAuth = true; //showLoggedInUI
        });

        configurePushNotifications(user);

        break;
      case FacebookLoginStatus.cancelledByUser:
        // showCancelledMessage
        showToast('Signing In Cancelled');
        setState(() {
          isAuth = false;
        });
        break;
      case FacebookLoginStatus.error:
        // showErrorOnUI
        showToast('Signing In Failed');
        setState(() {
          isAuth = false;
        });
        break;
    }
  }

  shredPrefConfigurePushNotifications(User user) {
    // final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      userRef.document(user.id).updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async {},
      // onResume: (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
        print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.id) {
          print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: Text(
            body,
            overflow: TextOverflow.ellipsis,
          ));
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
        print("Notification NOT shown");
      },
    );
  }

  configurePushNotifications(FirebaseUser user) {
    // final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      userRef
          .document(user.uid)
          .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async {},
      // onResume: (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
        print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.uid) {
          print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: Text(
            body,
            overflow: TextOverflow.ellipsis,
          ));
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
        print("Notification NOT shown");
      },
    );
  }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings registered: $settings");
    });
  }

  Future<void> shredprefUser(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('loggedUserId', uid);
  }

  createUserInFirestore(FirebaseUser user) async {
    DocumentSnapshot documentSnapshot = await userRef.document(user.uid).get();
    //go to createAccount page - only for first reigstration
    if (!documentSnapshot.exists) {
      final userInfoDetails = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChooseAccount(
                    dispUser: user,
                  )));
      // userRef.document(user.uid).setData({
      //   "id": user.uid,
      //   "name": userInfoDetails.name,
      //   "company": userInfoDetails.company,
      //   "companyBranch": userInfoDetails.companyBranch,
      //   "jobTitle": userInfoDetails.jobTitle,
      //   "whatsappNum": userInfoDetails.whatsappNum,
      //   "contactNum": userInfoDetails.contactNum,
      //   "photoUrl": user.photoUrl,
      //   "timestamp": timestamp
      // });
      // make new user their own follower (to include their posts in their timeline)
      await followersRef
          .document(user.uid)
          .collection('userFollowers')
          .document(user.uid)
          .setData({});
    }
    documentSnapshot = await userRef.document(user.uid).get();

    currentUserWithInfo = User.fromDocument(documentSnapshot);
    print(currentUserWithInfo);
    print(currentUserWithInfo.name);
  }

  Future<void> _signOut() async {
    await facebookSignIn.logOut();

    await googleSignIn.signOut();
    await _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loggedUserId');

    setState(() {
      isAuth = false;
    });
  }

  Widget buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUserWithInfo),
          // RaisedButton(
          //   child: Text('Logout'),
          //   onPressed: _signOut,
          // ),

          ActivityFeed(),
          currentUserWithInfo.type == "buyer"
              ? ClosestShop()
              : Upload(currentUser: currentUserWithInfo),
          Search(),
          currentUserWithInfo.type == "buyer"
              ? BuyerProfile(profileId: currentUserWithInfo?.id)
              : Profile(profileId: currentUserWithInfo?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.whatshot),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
            ),
            BottomNavigationBarItem(
              icon: currentUserWithInfo.type == "buyer"
                  ? Icon(
                      Icons.local_grocery_store,
                      size: 35.0,
                    )
                  : Icon(
                      Icons.photo_camera,
                      size: 35.0,
                    ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
            ),
          ]),
    );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: ModalProgressHUD(
          // color: Colors.blueAccent,
          inAsyncCall: showSpinner,
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Find Delivery',
                  style: TextStyle(
                    fontFamily: 'Signatra',
                    fontSize: 70.0,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 250.0,
                  height: 250.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/delivery_cab.jpg'),
                        fit: BoxFit.cover),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                GoogleSignInButton(
                  onPressed: () {
                    setState(() {
                      showSpinner = true;
                    });
                    // login();
                    signInWithGoogle();
                  },
                  darkMode: true, // default: false
                ),
                SizedBox(
                  height: 25,
                ),
                FacebookSignInButton(onPressed: () {
                  _signIn(context)
                      // .then((FirebaseUser user) => print(user))
                      .catchError((e) {
                    if (e.code ==
                        "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL") {
                      showToast("Please Sign In With Google");
                    }
                  });
                }),
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}

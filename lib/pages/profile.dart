import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finddelivery/pages/chat_screen.dart';
import 'package:finddelivery/widgets/post_tile.dart';
import 'package:flutter/material.dart';
import 'package:finddelivery/models/user.dart';
import 'package:finddelivery/pages/edit_profile.dart';
import 'package:finddelivery/pages/home.dart';
import 'package:finddelivery/widgets/header.dart';
import 'package:finddelivery/widgets/progress.dart';
import 'package:finddelivery/widgets/post.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  static const String id = "profile";

  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // String _platformVersion = 'Unknown';
  String _phone = "";
  String _whatsapp = "";
  String _openingMsg = "Do you deliver today?";

  String postOrientation = "grid";
  final String currentUserId = currentUserWithInfo?.id;
  bool isLoading = false;
  int postCount = 0;
  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;

  List<Post> posts = [];
  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();

    // initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     platformVersion = await FlutterOpenWhatsapp.platformVersion;
  //   } on PlatformException {
  //     platformVersion = 'Failed to get platform version.';
  //   }

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot = await postsRef
        .document(widget.profileId)
        .collection('companyPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = querySnapshot.documents.length;
      posts =
          querySnapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 150.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: "Edit Profile", function: editProfile);
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
  }

  void showToast(message) {
    Fluttertoast.showToast(
        msg: message,
        // toastLength: Toast.LENGTH_SHORT,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.blue,
        textColor: Colors.white);
  }

  buildContactButton(User user) {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (!isProfileOwner) {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () => setState(() {
                  _phone = user.contactNum;
                  _makePhoneCall('tel:$_phone');
                }),
                child: SvgPicture.asset(
                  'assets/images/call.svg',
                ),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _whatsapp = user.whatsappNum;
                    _whatsapp = "94" + _whatsapp.substring(1);
                  });
                  FlutterOpenWhatsapp.sendSingleMessage(_whatsapp,
                      "Hi ${user.name}, I'm *${currentUserWithInfo.name}*.\n\nMy Delivery Address:\n*${currentUserWithInfo.homeNumber}*\n*${currentUserWithInfo.street1}*\n*${currentUserWithInfo.street2}*\n*${currentUserWithInfo.city}*\n\n$_openingMsg");
                },
                child: SvgPicture.asset(
                  'assets/images/whatsapp.svg',
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Text("");
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "name": currentUserWithInfo.name,
      "userId": currentUserId,
      "userProfileImg": currentUserWithInfo.photoUrl,
      "timestamp": timestamp,
      "userType":
          currentUserWithInfo.type, //send activity feed , seller or buyer
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: userRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 16.0,
            right: 16.0,
            bottom: 4.0,
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl !=
                            ""
                        ? user.photoUrl
                        : "gs://find-delivery-f678c.appspot.com/profile.png"),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("posts", postCount),
                            buildCountColumn("followers", followerCount),
                            buildCountColumn("following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          user.company,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 2.0, bottom: 4.0),
                        child: Text(
                          user.companyBranch,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        constraints: BoxConstraints(minWidth: 0, maxWidth: 120),
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // fontSize: 16.0,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        constraints: BoxConstraints(minWidth: 0, maxWidth: 120),
                        padding: EdgeInsets.only(top: 2.0),
                        child: Text(
                          "${user.jobTitle}",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChatScreen(currentUserId: currentUserId)));
                      showToast("Many features will be available soon!!!");
                    },
                    child: SvgPicture.asset(
                      'assets/images/chat.svg',
                    ),
                  ),
                  SizedBox(width: 20),
                  buildContactButton(user),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/no_content.svg', height: 260.0),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(height: 0.0),
          buildProfilePosts(),
        ],
      ),
    );
  }
}

Future<void> _makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

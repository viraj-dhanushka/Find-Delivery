import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finddelivery/pages/home.dart';
import 'package:finddelivery/pages/post_screen.dart';
import 'package:finddelivery/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:finddelivery/widgets/header.dart';
import 'package:finddelivery/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'buyer_profile.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUserWithInfo.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .getDocuments();
    List<ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
      // print('Activity Feed Item: ${doc.data}');
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, titleText: "Activity Feed"),
      body: Container(
          child: FutureBuilder(
        future: getActivityFeed(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return ListView(
            children: snapshot.data,
          );
        },
      )),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String name;
  final String company;
  final String userId;
  final String type; // 'like', 'follow', 'comment'
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final String userType; //seller or buyer
  // final Timestamp timestamp;
  final int timestamp;

  ActivityFeedItem({
    this.name,
    this.company,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
    this.userType,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      name: doc['name'],
      company: doc['company'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
      mediaUrl: doc['mediaUrl'],
      userType: doc['userType'],
    );
  }

  configureMediaPreview(context) {
    if (type == "like" || type == 'comment') {
      // if (type == "like") {
      mediaPreview = GestureDetector(
        // onTap: () => showPost(context, postId1: "0dc254c4-f99f-4e3c-8418-e7928c07630a", userId1: "nxoKJOetArS0zKGJNQB3O2wo2uG2"),
        onTap: () {
          // print(postId);
          // print(userId);
          // showPost(context, postId1: "933552cf-a0ad-4023-ab10-0bd36fae2343", userId1:"7PaD7ZlZ7mVNZs5wJabytDY5Hvz1");
          showPost(context, postId: postId, userId: currentUserWithInfo.id);
        },
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(mediaUrl),
                  ),
                ),
              )),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (type == 'like') {
      activityItemText = "liked your post";
    } else if (type == 'follow') {
      activityItemText = "is following you";
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
    } else {
      activityItemText = "Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => type == "follow"
                ? showProfile(context, profileId: userId, userType: userType)
                : showPost(context,
                    postId: postId, userId: currentUserWithInfo.id),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' $activityItemText',
                    ),
                  ]),
            ),
          ),
          leading: GestureDetector(
            onTap: () =>
                showProfile(context, profileId: userId, userType: userType),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
          ),
          subtitle: GestureDetector(
            onTap: () =>
                showProfile(context, profileId: userId, userType: userType),
            child: Text(
              timeago.format(DateTime.fromMillisecondsSinceEpoch(timestamp)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId, String userType}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => userType == "buyer"
              ? BuyerProfile(profileId: profileId)
              : Profile(profileId: profileId)));
}

showPost(BuildContext context, {String postId, String userId}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PostScreen(
                postId: postId,
                userId: userId,
              )));
}

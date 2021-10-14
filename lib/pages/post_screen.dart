import 'package:finddelivery/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:finddelivery/widgets/header.dart';
import 'package:finddelivery/widgets/post.dart';
import 'package:finddelivery/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
          .document(userId)
          .collection('companyPosts')
          .document(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            // appBar: header(context, titleText: post.description),
            appBar: header(context, titleText: post.company),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
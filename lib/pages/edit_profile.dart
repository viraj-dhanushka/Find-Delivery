import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finddelivery/widgets/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:finddelivery/models/user.dart';
import 'package:finddelivery/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

// final FacebookLogin facebookSignIn = new FacebookLogin();
// final GoogleSignIn googleSignIn = GoogleSignIn();

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController dispNameController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController companyBranchController = TextEditingController();
  TextEditingController jobTitleController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController contactNumController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _dispNameValid = true;
  bool _companyNameValid = true;
  bool _companyBranchValid = true;
  bool _jobTitleValid = true;
  bool _whatsappValid = true;
  bool _contactNumValid = true;

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    dispNameController.text = user.name;
    companyNameController.text = user.company;
    companyBranchController.text = user.companyBranch;
    jobTitleController.text = user.jobTitle;
    whatsappController.text = user.whatsappNum;
    contactNumController.text = user.contactNum;
    setState(() {
      isLoading = false;
    });
  }

  Column buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: dispNameController,
          decoration: InputDecoration(
            hintText: "Update Your Name",
            errorText: _dispNameValid ? null : "Enter a valid name",
          ),
        )
      ],
    );
  }

  Column buildCompanyNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Company Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: companyNameController,
          decoration: InputDecoration(
            hintText: "Update Your Company Name",
            errorText: _companyNameValid ? null : "Enter a valid company name",
          ),
        )
      ],
    );
  }

  Column buildCompanyBranchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Company Branch",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: companyBranchController,
          decoration: InputDecoration(
            hintText: "Update Your Company Branch",
            errorText:
                _companyBranchValid ? null : "Enter a valid company branch",
          ),
        )
      ],
    );
  }

  Column buildJobTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Job Title",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: jobTitleController,
          decoration: InputDecoration(
            hintText: "Update Job Title",
            errorText: _jobTitleValid ? null : "Job title is too long",
          ),
        )
      ],
    );
  }

  Column buildWhatsappNumField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "WhatsApp Number",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: whatsappController,
          decoration: InputDecoration(
            hintText: "Update Your WhatsApp Number",
            errorText: _whatsappValid ? null : "Enter a valid Number",
          ),
        )
      ],
    );
  }

  Column buildContactNumField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Contact Number (call)",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: contactNumController,
          decoration: InputDecoration(
            hintText: "Update Your Contact Number",
            errorText: _contactNumValid ? null : "Enter a valid Number",
          ),
        )
      ],
    );
  }

  updateProfileData() {
    setState(() {
      dispNameController.text.trim().length < 3 ||
              dispNameController.text.isEmpty
          ? _dispNameValid = false
          : _dispNameValid = true;
      companyNameController.text.trim().length < 3 ||
              dispNameController.text.isEmpty
          ? _companyNameValid = false
          : _companyNameValid = true;
      jobTitleController.text.trim().length > 120
          ? _jobTitleValid = false
          : _jobTitleValid = true;

      (whatsappController.text.trim().length != 10)
          ? _whatsappValid = false
          : _whatsappValid = true;

      (contactNumController.text.trim().length != 10)
          ? _contactNumValid = false
          : _contactNumValid = true;
    });

    if (_dispNameValid &&
        _companyNameValid &&
        _companyBranchValid &&
        _jobTitleValid &&
        _whatsappValid &&
        _contactNumValid) {
      userRef.document(widget.currentUserId).updateData({
        "name": dispNameController.text,
        "company": companyNameController.text,
        "companyBranch": companyBranchController.text,
        "jobTitle": jobTitleController.text,
        "whatsappNum": whatsappController.text,
        "contactNum": contactNumController.text,
      });
      SnackBar snackBar = SnackBar(content: Text("Profile Updated!"));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  Future<void> _signOut() async {
    await facebookSignIn.logOut();

    await googleSignIn.signOut();
    await _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loggedUserId');

    Navigator.of(context)
        .pushNamedAndRemoveUntil(Home.id, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //     top: 16.0,
                      //     bottom: 8.0,
                      //   ),
                      //   child: CircleAvatar(
                      //     radius: 50.0,
                      //     backgroundImage:
                      //         CachedNetworkImageProvider(user.photoUrl),
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildNameField(),
                            buildCompanyNameField(),
                            buildCompanyBranchField(),
                            buildJobTitleField(),
                            buildWhatsappNumField(),
                            buildContactNumField(),
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: updateProfileData,
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: FlatButton.icon(
                          onPressed: _signOut,
                          icon: Icon(Icons.cancel, color: Colors.red),
                          label: Text(
                            "Logout",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

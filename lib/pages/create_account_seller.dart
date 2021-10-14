import 'package:finddelivery/widgets/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'home.dart';

class CreateAccountSeller extends StatefulWidget {
  final FirebaseUser dispUser;

  CreateAccountSeller({Key key, @required this.dispUser}) : super(key: key);
  @override
  _CreateAccountSellerState createState() => _CreateAccountSellerState();
}

class _CreateAccountSellerState extends State<CreateAccountSeller> {
  final _formKey = GlobalKey<FormState>();

  String name;
  String company;
  String companyBranch;
  String jobTitle;
  String whatsappNum;
  String contactNum;
  submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      showToast("Hi, $name");
      UserInfoDetails userInfoDetails = new UserInfoDetails(
          name, company, jobTitle, companyBranch, whatsappNum, contactNum);
      userRef.document(widget.dispUser.uid).setData({
        "id": widget.dispUser.uid,
        "name": userInfoDetails.name,
        "company": userInfoDetails.company,
        "companyBranch": userInfoDetails.companyBranch,
        "jobTitle": userInfoDetails.jobTitle,
        "whatsappNum": userInfoDetails.whatsappNum,
        "contactNum": userInfoDetails.contactNum,
        "photoUrl": widget.dispUser.photoUrl,
        "timestamp": timestamp,
        "type": "seller"
      });

      Navigator.popUntil(
        context,
        ModalRoute.withName(Home.id),
      );

    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: header(context,
          titleText: "Set up your profile", removeBackbtn: false),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            autovalidate: true,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    validator: (val) {
                      if (val.trim().length < 3 || val.trim().length == 0) {
                        return "Enter valid Name";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (val) => name = val,
                    initialValue: widget.dispUser.displayName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Name",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Enter your name",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    validator: (val) {
                      if (val.trim().length < 2 || val.trim().length == 0) {
                        return "Enter Valid Company Name";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (val) => company = val,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Company Name",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Enter Your Company Name",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    validator: (val) {
                      if (val.trim().length < 2 || val.trim().length == 0) {
                        return "Enter Valid Company Branch / City";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (val) => companyBranch = val,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Company Branch / City",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Eg: Matara",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    validator: (val) {
                      if (val.trim().length < 2 || val.trim().length == 0) {
                        return "Enter Valid Job Title";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (val) => jobTitle = val,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Job Title",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Enter your Job Title",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    validator: (val) {
                      if ((0 < val.trim().length && 10 > val.trim().length) ||
                          val.trim().length > 10) {
                        return "Enter valid Number";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (val) => whatsappNum = val,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "WhatsApp Number",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Eg: 071-------",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextFormField(
                    validator: (val) {
                      if ((0 < val.trim().length && 10 > val.trim().length) ||
                          val.trim().length > 10) {
                        return "Enter valid Number";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (val) => contactNum = val,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Contact Number (Call)",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Eg: 071-------",
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Next",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

void showToast(message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      // toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.blue,
      textColor: Colors.white);
}

class UserInfoDetails {
  UserInfoDetails(
    this.name,
    this.company,
    this.companyBranch,
    this.jobTitle,
    this.whatsappNum,
    this.contactNum,
  );

  String name;
  String company;
  String companyBranch;
  String jobTitle;
  String whatsappNum;
  String contactNum;
}

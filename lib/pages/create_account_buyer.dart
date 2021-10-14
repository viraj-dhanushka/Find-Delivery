import 'package:finddelivery/pages/home.dart';
import 'package:finddelivery/widgets/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateAccountBuyer extends StatefulWidget {
  final FirebaseUser dispUser;

  CreateAccountBuyer({Key key, @required this.dispUser}) : super(key: key);
  @override
  _CreateAccountBuyerState createState() => _CreateAccountBuyerState();
}

class _CreateAccountBuyerState extends State<CreateAccountBuyer> {
  final _formKey = GlobalKey<FormState>();

  String name;
  String age;
  String homeNumber;
  String street1;
  String street2;
  String city;
  String contactNum;

  submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      showToast("Hi, $name");
      UserInfoDetails userInfoDetails = new UserInfoDetails(
          name, age, homeNumber, street1, street2, city, contactNum);

      userRef.document(widget.dispUser.uid).setData({
        "id": widget.dispUser.uid,
        "name": userInfoDetails.name,
        "age": userInfoDetails.age,
        "homeNumber": userInfoDetails.homeNumber,
        "street1": userInfoDetails.street1,
        "street2": userInfoDetails.street2,
        "city": userInfoDetails.city,
        "contactNum": userInfoDetails.contactNum,
        "photoUrl": widget.dispUser.photoUrl,
        "timestamp": timestamp,
        "type": "buyer"
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
                      if (val.trim().length > 2 || val.trim().length == 0) {
                        return "Enter Valid age";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (val) => age = val,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Age",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Enter Your age",
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
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: Text(
                    "Delivery Address",
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    onSaved: (hn) => homeNumber = hn,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Home Number",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Enter your home number",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    onSaved: (strN1) => street1 = strN1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Street Name",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Enter your street name 1",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    onSaved: (strN2) => street2 = strN2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Street Name",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Enter your street name 2",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextFormField(
                    onSaved: (cty) => city = cty,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "City",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Enter your city",
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
  UserInfoDetails(this.name, this.age, this.homeNumber, this.street1,
      this.street2, this.city, this.contactNum);

  String name;
  String age;
  String homeNumber;
  String street1;
  String street2;
  String city;
  String contactNum;
}

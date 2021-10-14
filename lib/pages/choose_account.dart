import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'create_account_buyer.dart';
import 'create_account_seller.dart';

class ChooseAccount extends StatefulWidget {
  final FirebaseUser dispUser;

  ChooseAccount({Key key, @required this.dispUser}) : super(key: key);
  @override
  _ChooseAccountState createState() => _ChooseAccountState();
}

class _ChooseAccountState extends State<ChooseAccount> {
  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        // color: Colors.white,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 150.0,
              height: 150.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/Find_Delivery_Logo.png'),
                    fit: BoxFit.cover),
              ),
            ),

            SizedBox(
              height: 20,
            ),

            RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateAccountSeller(
                            dispUser: widget.dispUser,
                          )),
                );
              },
              child: Text(
                "I want to sell",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(
              height: 10,
            ),

            RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateAccountBuyer(
                            dispUser: widget.dispUser,
                          )),
                );
              },
              child: Text(
                "I want to buy",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Padding(
            //   padding: EdgeInsets.all(16.0),
            //   child: FlatButton.icon(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => CreateAccountSeller(
            //                   dispName: widget.dispName,
            //                 )),
            //       );
            //     },
            //     icon: Icon(Icons.cancel, color: Colors.red),
            //     label: Text(
            //       "I want to sell",
            //       style: TextStyle(color: Colors.red, fontSize: 20.0),
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.all(16.0),
            //   child: FlatButton.icon(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => CreateAccountBuyer(
            //                   dispName: widget.dispName,
            //                 )),
            //       );
            //     },
            //     icon: Icon(Icons.cancel, color: Colors.red),
            //     label: Text(
            //       "I want to buy",
            //       style: TextStyle(color: Colors.red, fontSize: 20.0),
            //     ),
            //   ),
            // ),
          ],
        ),
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

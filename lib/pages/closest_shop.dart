import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finddelivery/components/dialog_box.dart';
import 'package:finddelivery/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

class ClosestShop extends StatefulWidget {
  static const String id = "closest_shop";

  @override
  _ClosestShopState createState() => _ClosestShopState();
}

class _ClosestShopState extends State<ClosestShop> {
  LatLng userLocation = LatLng(7.8731, 80.7718);
  var zoom = 7.5;

  DialogBox _dialogBox = DialogBox();

  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;

  List<Marker> allMarkers = [];

  MapController mapController;

  @override
  void initState() {
    // intialize the controllers
    mapController = MapController();

    super.initState();
    getCurrentUser();
  }

  void _getCurrentLocation() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      zoom = 12.0;
      mapController.move(userLocation, zoom);

      allMarkers.add(
        Marker(
          width: 45.0,
          height: 45.0,
          point: userLocation,
          builder: (context) => Container(
            child: IconButton(
              icon: Icon(Icons.location_on),
              color: Colors.green,
              iconSize: 45,
              onPressed: () {},
            ),
          ),
        ),
      );
    });
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      loggedInUser = user;
    } catch (e) {
      print(e);
    }
  }

  Widget loadMap() {
    return StreamBuilder(
      stream: Firestore.instance.collection('markers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Text('Loading maps..');
        for (int i = 0; i < snapshot.data.documents.length; i++) {
          allMarkers.add(
            Marker(
              width: 45.0,
              height: 45.0,
              point: LatLng(snapshot.data.documents[i]['coords'].latitude,
                  snapshot.data.documents[i]['coords'].longitude),
              builder: (context) => Container(
                child: IconButton(
                  icon: Icon(Icons.location_on),
                  color: Colors.red,
                  iconSize: 45,
                  onPressed: () {
                    print(snapshot.data.documents[i]['place']);
                  },
                ),
              ),
            ),
          );
        }

        return new FlutterMap(
          mapController: mapController,
          options: new MapOptions(
            center: userLocation,
//            zoom: 8.0,
            zoom: zoom,
          ),
          layers: [
            new TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
//              urlTemplate:
//              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
//              subdomains: ['a', 'b', 'c'],
//              tileProvider: CachedNetworkTileProvider(),
            ),
            MarkerLayerOptions(
              markers: allMarkers,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, titleText: "Find Closest Shops"),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
              child: Icon(Icons.location_searching),
              label: "My Location",
              labelBackgroundColor: Colors.green,
              backgroundColor: Colors.green,
              onTap: () {
                _getCurrentLocation();
              }),
          SpeedDialChild(
              child: Icon(Icons.local_pharmacy),
              label: "Medicine",
              labelBackgroundColor: Colors.purpleAccent,
              backgroundColor: Colors.purpleAccent,
              onTap: () {
                _dialogBox.information(context, 'Pharmacies',
                    'This feature will be available very soon.Thank you for the understanding.');
              }),
          SpeedDialChild(
              child: Icon(Icons.add_shopping_cart),
              labelBackgroundColor: Colors.orangeAccent,
              backgroundColor: Colors.orangeAccent,
              label: "Grocery",
              onTap: () {
                _dialogBox.information(context, 'Supermarkets & Shops',
                    'This feature will be available very soon.Thank you for the understanding.');
              }),
          SpeedDialChild(
              child: Icon(Icons.restaurant),
              labelBackgroundColor: Colors.brown.shade400,
              backgroundColor: Colors.brown,
              label: "Food",
              onTap: () {
                _dialogBox.information(context, 'Restaurants & Cafes',
                    'This feature will be available very soon.Thank you for the understanding.');
              }),              
        ],
      ),
      body: loadMap(),
    );
  }
}

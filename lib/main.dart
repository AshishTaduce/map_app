import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_app/theme.dart';
import 'package:provider/provider.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      builder: (_) => ThemeChanger(ThemeData.light()),
      child: new MaterialAppWithThemeChanger(),
    );
  }
}

class MaterialAppWithThemeChanger extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      title: 'Sample Map App',
      theme: theme.getTheme(),
      home: TeddyMaps(
      ),
    );
  }
}

class TeddyMaps extends StatefulWidget {
  @override
  _TeddyMapsState createState() => _TeddyMapsState();
}

class _TeddyMapsState extends State<TeddyMaps> {

  GoogleMapController mapController;

  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(12.9716, 77.5946),
    zoom: 15.0,
  );

  Set<Marker> _markers = {};

  _remove_marker(MarkerId input) {
    _markers.removeWhere((Marker marker) => marker.markerId == input);
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  LatLng _currentLocation = LatLng(12.9716, 77.5946);

  void _onCameraMove(CameraPosition position) {
    _currentLocation = position.target;
    setState(() {});
  }

  double _sliderValue = 15;
  int markerID = 1;

  void _markerButtonBluePressed() {
    if (markerID == 12) {
      print('More than 12 pins not supported');
      return;
    }

    print('button pressed');
    var marker = Marker(
      markerId: MarkerId('marker_no_$markerID',),
      onTap: _remove_marker(MarkerId('marker_no_$markerID'),),
      position: _currentLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure,),
      infoWindow: InfoWindow(
        title: 'Here is marker no. $markerID',
        snippet: 'Max of 12 markers',
      ),
    );
    _markers.add(marker);
    markerID++;
    setState(() {});
  }

  void _markerButtonRedPressed() {
    if (markerID == 12) {
      return;
    }
    print('button pressed');
    var marker = Marker(
        markerId: MarkerId('marker_no_$markerID'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: 'Here is marker no. $markerID',
          snippet: 'Maximum 12 markers allowed',
        ),
        rotation: 0
    );
    //_markers.add(marker);
    _markers.add(marker);


    markerID++;
    setState(() {});
  }

  bool isMovingPosition = false;

  void _switchMoving() {
    isMovingPosition ? isMovingPosition = false : isMovingPosition = true;
    setState(() {});
  }

  void _moveToMyPosition() async {
    Position position;
    print(_markers);
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print('Location = $position');
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );
    _switchMoving();
  }

  @override
  void initState() {
    Geolocator().checkGeolocationPermissionStatus();
    rootBundle.loadString('assets/map_style_light.txt').then((string) {
      {
        mapController.setMapStyle(string);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    //var size = MediaQuery.of(context).size;
    bool lightMode = _themeChanger.getTheme() == ThemeData.light();
    return Scaffold(
      drawer: Drawer(),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GoogleMap(
              onCameraMove: _onCameraMove,
              markers: _markers,
              onMapCreated: _onMapCreated,
              zoomGesturesEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(12.9716, 77.5946),
                zoom: 15.0,
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Container(
                decoration: BoxDecoration(
                    color: lightMode ? Colors.white : Colors.blueGrey,
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                padding: EdgeInsets.all(5),
                child: Row(children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: lightMode ? Colors.grey : Colors.white70,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  Expanded(
                    child: Container(
                      color: lightMode ? Colors.white : Colors.blueGrey,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          contentPadding: EdgeInsets.all(7),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => null,
                  ),
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                width: 300,
                height: 50,

                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.black,
                    trackHeight: 4.0,
                    thumbColor: Colors.yellow,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayColor: Colors.green.withAlpha(50),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
                  ),
                  child: Slider(
                      value: _sliderValue,
                      min: 5,
                      max: 20,
                      divisions: 10,
                      onChanged: (double changedValue) {
                        setState(() {
                          _sliderValue = changedValue;
                          mapController.animateCamera(
                              CameraUpdate.newCameraPosition(CameraPosition(
                                target: LatLng(_currentLocation.latitude,
                                    _currentLocation.longitude),
                                zoom: changedValue,
                              )));
                        });
                      }
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 150, 8, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.lightbulb_outline,
                      color: lightMode ? Colors.black : Colors.yellow,
                      size: 40,
                    ),
                    onPressed: () {
                      lightMode
                          ? _themeChanger.setTheme(ThemeData.dark())
                          : _themeChanger.setTheme(ThemeData.light());
                      lightMode
                          ? rootBundle.loadString('assets/map_style_dark.txt')
                          .then((string) {
                        mapController.setMapStyle(string);
                      })
                          : rootBundle.loadString('assets/map_style_light.txt')
                          .then((string) {
                        mapController.setMapStyle(string);
                      });
                      setState(() {

                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_location,
                      color: Colors.red,
                      size: 40,
                    ),
                    onPressed: _markerButtonRedPressed,
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_location,
                      color: Colors.blue,
                      size: 40,
                    ),
                    onPressed: _markerButtonBluePressed,
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.gps_fixed,
                      color: Colors.blue,
                      size: 40,
                    ),
                    onPressed: () {
                      _switchMoving();
                      _moveToMyPosition();
                    },
                    color: Colors.white,
                  ),
//                Container(
//                  width: 50,
//                  height: 300,
//                  color: Colors.green,
//                  child: Transform.rotate(
//                    angle: (pi/2) - pi,
//                    child: Slider(
//                        inactiveColor: Colors.orange,
//                        activeColor: Colors.white,
//                        value: _sliderValue,
//                        min: 0,
//                        max: 35,
//                        divisions: 35,
//                        onChanged:(double changedValue){
//                          setState(() {
//                            _sliderValue = changedValue;
//                            mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
//                              target: LatLng(_currentLocation.latitude, _currentLocation.longitude),
//                              zoom: changedValue,
//                            )));
//                          });
//                        }
//                    ),
//                  ),
//                ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isMovingPosition,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                color: Colors.white.withAlpha(100),
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationsSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return null;
  }
}

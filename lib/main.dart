import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:map_app/theme.dart';
import 'package:provider/provider.dart';

import 'city_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      // ignore: deprecated_member_use
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
      debugShowCheckedModeBanner: false,
      title: 'Sample Map App',
      theme: theme.getTheme(),
      home: TeddyMaps(),
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
      markerId: MarkerId(
        'marker_no_$markerID',
      ),
      onTap: null,
      position: _currentLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure,
      ),
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
        rotation: 0);
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

  List<Cities> cities = [];
  Client client;

  void getCitiesFromJSON(client) async {
    cities = await fetchCities(client);
  }

  @override
  void initState() {
    Geolocator().checkGeolocationPermissionStatus();
//    rootBundle.loadString('assets/map_style_light.txt').then((string) {
//      {
//        mapController.setMapStyle(string);
//      }
//    });
    getCitiesFromJSON(client);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    //var size = MediaQuery.of(context).size;
    bool lightMode = _themeChanger.getTheme() == ThemeData.light();
    return Scaffold(
      appBar: AppBar(
        leading: new Builder(builder: (context) {
          return new IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Icon(
              Icons.list,
              color: lightMode ? Colors.black54 : Colors.white70,
            ),
          );
        }),
        centerTitle: true,
        backgroundColor: lightMode ? Colors.yellow : Colors.black54,
        shape: RoundedRectangleBorder(),
        elevation: 50,
        title: Text(
          'Go Roam!',
          style: TextStyle(
              fontSize: 28, color: lightMode ? Colors.black : Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: lightMode ? Colors.black54 : Colors.white70,
            ),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: LocationsSearch(
                    themeDATA: lightMode ? ThemeData.light() : ThemeData.dark(),
                    citiesList: cities,
                  ));
              setState(() {
              });
            },
          )
        ],
      ),
      drawer: Drawer(),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GoogleMap(
              onCameraMove: _onCameraMove,
              zoomGesturesEnabled: false,
              markers: _markers,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(12.9716, 77.5946),
                zoom: _sliderValue,
              ),
              mapType: MapType.normal,
              //myLocationEnabled: true,
              //myLocationButtonEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: lightMode ? Colors.yellow : Colors.indigo,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                width: 300,
                height: 50,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor:
                    lightMode ? Colors.black87 : Colors.yellow,
                    inactiveTrackColor: lightMode ? Colors.white : Colors.white,
                    trackHeight: 4.0,
                    thumbColor: lightMode ? Colors.blue : Colors.teal,
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
                      }),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Container(
                        color: lightMode ? Colors.white70 : Colors.blueGrey,
                        child: IconButton(
                          icon: Icon(
                            Icons.lightbulb_outline,
                            color: lightMode ? Colors.black : Colors.yellow,
                            size: 32,
                          ),
                          onPressed: () {
                            lightMode
                                ? _themeChanger.setTheme(ThemeData.dark())
                                : _themeChanger.setTheme(ThemeData.light());
                            lightMode
                                ? rootBundle
                                .loadString('assets/map_style_dark.txt')
                                .then((string) {
                              mapController.setMapStyle(string);
                            })
                                : rootBundle
                                .loadString('assets/map_style_light.txt')
                                .then((string) {
                              mapController.setMapStyle(string);
                            });
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Container(
                        color: lightMode ? Colors.white70 : Colors.blueGrey,
                        child: IconButton(
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.redAccent,
                            size: 32,
                          ),
                          onPressed: _markerButtonRedPressed,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Container(
                        color: lightMode ? Colors.white70 : Colors.blueGrey,
                        child: IconButton(
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.blueAccent,
                            size: 32,
                          ),
                          onPressed: _markerButtonBluePressed,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Container(
                        color: lightMode ? Colors.white70 : Colors.blueGrey,
                        child: IconButton(
                          icon: Icon(
                            Icons.gps_fixed,
                            color: lightMode ? Colors.grey : Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            _switchMoving();
                            _moveToMyPosition();
                          },
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
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
  LocationsSearch({@required this.themeDATA, @required this.citiesList,
//  @required
    this.moveCamera
  });

  final ThemeData themeDATA;
  final List<Cities> citiesList;
  final Function moveCamera;

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = themeDATA;
    assert(theme != null);
    return theme;
  }

  Widget buildResults(BuildContext context) {
    List<Cities> results = citiesList
        .where(
            (cityName) =>
            cityName.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    // TODO: implement buildResults
    return Container(
      child: AnimatedList(
          initialItemCount: citiesList.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (context, index, animation) {
            return ListTile(
              onTap: () {
                double lat = results[index].latitide;
                double lng = results[index].latitide;
                print('$lat $lng');
              },
              dense: true,
              title: Text(results[index].name),
            );
          }),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Cities> results = citiesList.toList();

    // TODO: implement buildSuggestions
    return Container(
      child: AnimatedList(
          initialItemCount: citiesList.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (context, index,
              animation) {
            return ListTile(
              onTap: () {
                double lat = results[index].latitide;
                double lng = results[index].latitide;
                print('$lat $lng');
              },
              dense: true,
              title: Text(results[index].name),
            );
          }),
    );
  }
}

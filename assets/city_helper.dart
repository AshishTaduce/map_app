import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';

class Cities {
  String name;
  double latitide;
  double longitude;

  Cities(this.longitude, this.latitide, this.name);

  makeCity(String cityName, double lat, double lon) {
    name = cityName;
    latitide = lat;
    longitude = lon;
    return Cities;
  }
}

Future<String> _loadCityAsset() async {
  return await rootBundle.loadString('assets/cities.json');
}
//String jsonString = _loadAStudentAsset();
//List<Map> parsedJson = jsonDecode('assets/cities.json');

Future loadCities() async {
  String jsonString = await _loadCityAsset();
  final parsedJson = json.decode(jsonString);
  List<Cities> listOfCities = parsedJson
      .map((item) => new Cities(item['name'], item['lat'], item['lon']))
      .toList();
}

void main() {
  print(listOfCities[0].name);
}

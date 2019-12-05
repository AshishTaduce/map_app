import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class Cities {
  String name;
  double latitide;
  double longitude;

  Cities({this.longitude, this.latitide, this.name});

  factory Cities.fromJson(Map<String, dynamic> json){
    return Cities(
      name: json['name'],
      latitide: json['lat'],
      longitude: json['lng'],
    );
  }

  makeCity(String cityName, double lat, double lon) {
    name = cityName;
    latitide = lat;
    longitude = lon;
    return Cities;
  }
}

List<Cities> parseCities(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Cities>((json) => Cities.fromJson(json)).toList();
}

String citiesJson = '';

void loadAsset() async {
  citiesJson = await rootBundle.loadString('assets/cities.json');
}

List<Cities> fetchCities(Client client) {
//  final response =
//  await client.get(
//    'https://raw.githubusercontent.com/lutangar/cities.json/master/cities.json',);
  // Use the compute function to run parsePhotos in a separate isolate.

  return compute(parseCities(),
      citiesJson
//      response.body
  );
}
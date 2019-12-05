class Cities {
  String name;
  double latitide;
  double longitude;

  Cities({this.longitude, this.latitide, this.name});

  factory Cities.fromJson(Map<String, dynamic> json){
    return Cities(
      name: json['name'],
      latitide: double.parse(json['lat']),
      longitude: double.parse(json['lng']),
    );
  }

  makeCity(String cityName, double lat, double lon) {
    name = cityName;
    latitide = lat;
    longitude = lon;
    return Cities;
  }
}


//List<Cities> parseCities(String responseBody) {
//  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
//
//  return parsed.map<Cities>((json) => Cities.fromJson(json)).toList();
//}
//
//
//Future<String> loadAsset() async {
//  return await rootBundle.loadString('assets/cities.json');
//}
//
//Future<List<Cities>> fetchCities(Client client) async {
//    final response =
//  await client.get(
//    'https://raw.githubusercontent.com/lutangar/cities.json/master/cities.json',);
//   Use the compute function to run parsePhotos in a separate isolate.
//  return await compute(
//      parseCities,
////      loadAsset()
//      response.body
//  );
//}

//void main()async{
//  String abcd = await loadAsset();
////  Map jsonMap = json.decode(abcd).cast<Map<String, dynamic>>();
//  List<Cities> a = [];
//  final parsed = json.decode(abcd).cast<Map<String, dynamic>>();
//
//  var x = parsed.map<Cities>((json) => Cities.fromJson(json)).toList();
//  print (x);
//}
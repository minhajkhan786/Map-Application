import 'package:cloud_firestore/cloud_firestore.dart';

class LocationHistory {
  LocationHistory({
    required this.lat,
    required this.long,
    required this.place,
    required this.date,
  });

  late final num lat;
  late final num long;
  late final String place;
  late final DateTime date;

  LocationHistory.fromJson(Map<String, dynamic> json) {
    lat = json['lat'] ?? '';
    long = json['long'] ?? '';
    place = json['place'] ?? '';
    date =  (json['date'] as Timestamp).toDate();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['lat'] = lat;
    data['long'] = long;
    data['place'] = place;
    data['date'] = Timestamp.fromDate(date);
    return data;
  }
}
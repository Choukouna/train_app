import 'dart:core';

class Location {

  final String stadeName;
  final String ville;
  final int codePostal;

  const Location(this.stadeName, this.ville, this.codePostal);

  String get stade => stadeName;
  String get city => ville;
  int get code => codePostal;

  Map<String, dynamic> toMap() {
    return {
      'stade': stade,
      'city': city,
      'codePostal': codePostal,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      map['stade'] as String,
      map['city'] as String,
      map['codePostal'] as int,
    );
  }

  String formatForUI() {
    String response = stadeName;
    bool optional = false;
    if (ville != '') {
      response += ', ' + ville;
      optional = true;
    }
    if (!optional && codePostal != 0) {
      response += ', ' + codePostal.toString();
    }
    return response;
  }
}
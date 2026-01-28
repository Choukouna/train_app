import 'package:jeusetmatch/dto/rank.dart';

class Player {
  String pseudo;
  String name;
  String lastname;
  String city;
  Rank rank;
  final int matchesWon;
  final int matchesLost;

  Player(this.pseudo, this.name, this.lastname, this.city, this.rank, this.matchesWon, this.matchesLost);
}
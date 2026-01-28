import 'dart:convert';
import 'package:jeusetmatch/dto/rank.dart';
import 'package:jeusetmatch/dto/set_score.dart';

import '../dto/slot.dart';

class Utils {
  static final _listRank = [
    '40/2', '40/1', '40',
    '30/5', '30/4', '30/3', '30/2', '30/1', '30',
    '15/5', '15/4', '15/3', '15/2', '15/1',
    '15', '5/6', '4/6', '3/6', '2/6', '1/6', '0',
    '-2/6', '-4/6', '-15'
  ];

  static List<SetScore> convertScoreFromStringToSets(String score) {
    List<String> scoreSplited = score.split(' ');
    List<SetScore> result = [];
    for (var e in scoreSplited) {
      List<String> setSplited = e.split('/');
      result.add(SetScore(gamesA: int.parse(setSplited[0]), gamesB: int.parse(setSplited[1])));
    }
    return result;
  }

  static List<SetScore> convertScoreFromDBToSets(String score) {
    final matchScore = jsonDecode(score) as List<dynamic>;
    final List<SetScore> result = [];
    for (var set in matchScore) {
      result.add(SetScore(gamesA: set['gamesA'], gamesB: set['gamesB']));
    }
    return result;
  }

  static bool isValidRank(String? rank) {
    return rank != null ?  _listRank.contains(rank) : false;
  }

  static Rank extractRankFromString(String rankString) {
    if (isValidRank(rankString)) {
      Rank ranking = Rank('', 0, 0);
      String rankWithoutSign = rankString;
      if (rankString.startsWith('-')) {
        ranking.signe = '-';
        rankWithoutSign = rankString.replaceRange(0, 1, '');
      }
      List<String> rankSplit = rankWithoutSign.split('/');
      ranking.numerator = int.parse(rankSplit[0]);
      ranking.deno = rankSplit.length > 1
          ? int.parse(rankSplit[1])
          : 0;
      return ranking;
    }
    throw Exception('Trying to convert an unknown rank threw an exception');
  }

  /// Returns les créneaux dont les lieux ressemblent
  static List<Slot> filterSlotByCity(List<Slot> inputSlot, String userCity) {
    final normalizedCity = userCity.trim().toLowerCase();

    return inputSlot.where((slot) {
      final slotCity = slot.location.city.trim().toLowerCase();
      return slotCity.contains(normalizedCity) || normalizedCity.contains(slotCity);
    }).toList();
  }
}
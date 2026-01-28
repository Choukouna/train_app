import 'set_score.dart';

class Match {
  String playerId;
  String opponentId;
  final List<SetScore> sets;
  bool result;
  DateTime matchDay;
  String comment;

  Match(this.playerId, this.opponentId, this.sets, this.result, this.matchDay, this.comment);

  /// Build sets string to save it in DB
  String formatSetsForDB() {
    String result = '[';
    int i = 0;
    for(SetScore set in sets) {
      String setString = '{"gamesA": ${set.gamesA}, "gamesB": ${set.gamesB}}\n';
      result += setString;
      if (i < sets.length - 1) { /// Ne pas ajouter la virgule après le dernier set
        result += ',';
      }
      i += 1;
    }
    return result += ']';
  }

  /// Retrieve string from DB and format it for UI purpose
  String formatSetsForUI() {
    String result = '';
    for(SetScore set in sets) {
      result += '$set ';
    }
    return result;
  }
}
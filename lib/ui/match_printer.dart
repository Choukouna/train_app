import 'package:flutter/material.dart';
import 'package:jeusetmatch/dto/constant.dart';
import 'package:jeusetmatch/ui/shared/base_scaffold.dart';

import '../dto/match.dart';
import '../dto/player.dart';
import '../utils/protected_route.dart';
import 'match_detail.dart';

class MatchPrinter extends StatelessWidget {

  final Match match;
  final Player opponent;
  final int parentIndex;
  const MatchPrinter({super.key, required this.match, required this.opponent, required this.parentIndex});

  @override
  Widget build(BuildContext context) {
    switch(parentIndex) {
      case 0: // ListMatch is the parent caller
        return printOnListMatch(context);
      case 1: // MatchDetail is the parent caller
        return printOnMatchDetail(context);
      default:
        return const Text("Not found");
    }
  }

  Container printOnListMatch(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 20),
        child: Card(
            elevation: 8, // 👈 gives floating (shadow) effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // rounded corners
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProtectedRoute(title: Constante.MATCH_DETAIL, body: MatchDetail(match: match, opponent: opponent))),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          match.result == true ? Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.close, color: Colors.red),
                          Text(
                              style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 18),
                              opponent.rank.toString()
                          )
                        ],
                      )),
                  Expanded(
                      flex: 2,
                      child: Text(
                          style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 18),
                          "${opponent.name}  ${opponent.lastname.toUpperCase()}"
                      )
                  ),
                  Expanded(
                      flex: 2,
                      child: Text(
                          style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 18),
                          match.formatSetsForUI())
                  ),
                  Expanded(
                      flex: 1,
                      child: match.result == true ? Icon(Icons.sentiment_very_satisfied) : Icon(Icons.sentiment_very_dissatisfied)
                  )
                ],
              ),
            )
        )
    );
  }

  TableRow buildRow(String dataType, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(dataType, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(value),
        ),
      ],
    );
  }

  Widget printOnMatchDetail(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Card(
          elevation: 8, // 👈 gives floating (shadow) effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // rounded corners
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // wrap content
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                Constante.MATCH_DETAILS,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(24.0), // inner spacing
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    buildRow('Date du match', match.matchDay.toString()),
                    buildRow('Adversaire', "${opponent.name}  ${opponent.lastname.toUpperCase()}"),
                    buildRow('Résultat', match.result == true ? Constante.WIN : Constante.DEFEAT),
                    buildRow('Score', match.formatSetsForUI()),
                    buildRow('Commentaire', match.comment),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}
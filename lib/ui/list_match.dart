import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jeusetmatch/dto/constant.dart';
import 'package:provider/provider.dart';

import '../db/crud.dart';
import '../db/user_provider.dart';
import '../dto/match.dart';
import '../dto/player.dart';
import '../utils/utils_functions.dart';
import 'match_printer.dart';

class ListMatch extends StatefulWidget {
  const ListMatch({super.key});

  @override
  ListMatchState createState() => ListMatchState();
}

class ListMatchState extends State<ListMatch> {

  final List<Match> _matches = [];
  final List<Player> _opponents = [];
  bool _isLoading = true;
  String _currentUid = '';
  
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.loading) {
      return;
    }
    final userData = userProvider.userData;
     _currentUid = userData?['uid'] ?? 'Unknown';

    Crud.readUserMatches(_currentUid)
        .then((myMatches) {
          setState(() {
            for (var element in myMatches) {
              Match match = buildMatchDto(element);
              Player opponent = buildOpponentDto(element);
              _matches.add(match);
              _opponents.add(opponent);
            }
            _isLoading = false;
          });
        })
        .catchError((error) {
          /// TODO: gerer erreur
          _isLoading = false;
        });
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_matches.isEmpty) {
      return Container(
          margin: EdgeInsets.only(top: 20),
          child: Card(
            elevation: 8, // 👈 gives floating (shadow) effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // rounded corners
            ),
            child: SizedBox(
                width: 400,
                height: 100,
                child: Center(
                  child: Text(
                    Constante.NO_MATCH,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                )
            ),
          )
      );
    }

    return ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) => MatchPrinter(match: _matches[index], opponent: _opponents[index], parentIndex: 0)
    );
  }

  Match buildMatchDto(matchJson) {
    Timestamp matchTime = matchJson['date'];
    return Match('playerUid', 'opponentUid', Utils.convertScoreFromDBToSets(matchJson['sets']), matchJson['winnerId'] == _currentUid ? true : false, matchTime.toDate(), matchJson['comment']);
  }

  Player buildOpponentDto(matchJson) {
    return matchJson['opponentName'] == '' && matchJson['opponentLastname'] == ''
        ? Player('connectedUid', matchJson['opponentPseudo'], '', '', Utils.extractRankFromString(matchJson['opponentRank']), 0, 0)
        : Player('opponentUid', matchJson['opponentName'], matchJson['opponentLastname'], '', Utils.extractRankFromString(matchJson['opponentRank']), 0, 0);
  }
}

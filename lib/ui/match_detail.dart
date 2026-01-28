import 'package:flutter/material.dart';
import '../dto/match.dart';
import '../dto/player.dart';
import 'match_printer.dart';

class MatchDetail extends StatelessWidget {
  final Match match;
  final Player opponent;
  const MatchDetail({super.key, required this.match, required this.opponent});

  @override
  Widget build(BuildContext context) {
    return MatchPrinter(match: match, opponent: opponent, parentIndex: 1);
  }
}

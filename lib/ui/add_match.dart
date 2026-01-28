import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jeusetmatch/dto/rank.dart';
import 'package:jeusetmatch/dto/set_score.dart';
import 'package:jeusetmatch/ui/home_page.dart';
import 'package:jeusetmatch/ui/shared/base_scaffold.dart';
import 'package:provider/provider.dart';

import '../db/crud.dart';
import '../db/user_provider.dart';
import '../dto/constant.dart';
import '../dto/match.dart';
import '../utils/utils_functions.dart';

class AddMatch extends StatefulWidget {
  const AddMatch({super.key});

  @override
  AddMatchState createState() => AddMatchState();
}

class AddMatchState extends State<AddMatch> {

  final _formKey = GlobalKey<FormState>();

  // Fields controller
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _identifiantController = TextEditingController();
  final TextEditingController _classementController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _nomPnomController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  // Field to retrieve radio button values
  String? _jaValue = '', _groupValue = '';
  String? _result = '';
  Timer? _debounce; // Timer sur le champ pseudo pour déclencher le search en BD
  bool _rankIsEnabled = true;
  String _opponentUid = '';

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _identifiantController.dispose();
    _classementController.dispose();
    _scoreController.dispose();
    _nomPnomController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  /// Selectionner une date sur le calendrier
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // default date
      firstDate: DateTime(2025),   // earliest allowed date
      lastDate: DateTime(2101),    // latest allowed date
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  /// Search user
  void _searchUser() {
    final pseudo = _identifiantController.text.trim();
    final contextCopy = ScaffoldMessenger.of(context);
    Crud.getUserFromPseudo(pseudo)
        .then((user) {
          setState(() {
            if (user == null) {
              _nomPnomController.text = 'Pseudo erroné';
              _rankIsEnabled = true;
              _opponentUid = '';
            } else {
              _classementController.text = user['rank'];
              _rankIsEnabled = false;
              _opponentUid = user['uid'];
              if (user['name'] != null || user['lastname'] != null) {
                _nomPnomController.text = '${user['name']} ${user['lastname']}';
              } else {
                _nomPnomController.text = _identifiantController.text.trim();
              }
            }
          });
        })
        .catchError((error) {
          contextCopy.showSnackBar(
            SnackBar(content: Text('Erreur: $error')),
          );
        });
  }

  /// Manage form submission data
  void _handleSubmit() async {
    final contextCopy = ScaffoldMessenger.of(context);
    /// Retrieve current user uid
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.loading) {
      return;
    }
    final userData = userProvider.userData;
    final currentUid = userData?['uid'] ?? 'Unknown';
    /// Retrieve opponent uid if he is JA
    if (_opponentUid == '') {
      String jaPseudo = '$_jaValue${_classementController.text.trim().replaceAll('/', '_')}';
      final jAnonyme = await Crud.getUserFromPseudo(jaPseudo);
      _opponentUid = jAnonyme?['uid'];
    }
    /// Build match
    bool victoire = (_result == 'victoire') ? true : false;
    DateFormat format = DateFormat("dd/MM/yyyy");
    DateTime matchTime = format.parse(_dateController.text);
    List<SetScore> score = Utils.convertScoreFromStringToSets(_scoreController.text);
    Match match = Match(currentUid, _opponentUid, score, victoire, matchTime, _commentController.text);
    /// call DB function to add match
    Crud.addMatchToDB(match: match)
      .then((_) {
        if (_formKey.currentState!.validate()) {
          contextCopy.showSnackBar(
            SnackBar(content: Text(Constante.MATCH_SAVED)),
          );
        }
      })
      .catchError((error) {
        contextCopy.showSnackBar(
          SnackBar(content: Text('Erreur: $error')),
        );
      });
    
    // Check if it was his best/worst match and update stat
    Rank bestMatchRank = Utils.extractRankFromString(userData?['bestWin']);
    Rank worstMatchRank = Utils.extractRankFromString(userData?['worstDefeat']);
    Rank opponentRank = Utils.extractRankFromString(_classementController.text.trim());
    if (victoire) {
      if (opponentRank.isGreaterThan(bestMatchRank)) { // Current best match rank < today victory opp rank
        Crud.updateTopWin(currentUid, opponentRank.toString())
            .then((onValue) {
            })
            .catchError((error) {
              contextCopy.showSnackBar(
                SnackBar(content: Text('Erreur: $error')),
              );
            });
      }
    } else {
      if (opponentRank.isLessThan(worstMatchRank)) { // Opponent rank < current worst match rank
        Crud.updateWorstDefeat(currentUid, opponentRank.toString())
            .then((onValue) {
            })
            .catchError((error) {
          contextCopy.showSnackBar(
            SnackBar(content: Text('Erreur: $error')),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Card(
        elevation: 8, // 👈 gives floating (shadow) effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // rounded corners
        ),
        child: Padding(
            padding: const EdgeInsets.all(24), // inner spacing
            child: ListView(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // wrap content
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        Constante.ADD_MATCH_VERB,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Row 1
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _identifiantController,
                              decoration: InputDecoration(
                                labelText: Constante.PSEUDO,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onChanged: (value) {
                                if (_debounce?.isActive ?? false) _debounce!.cancel();
                                _debounce = Timer(const Duration(milliseconds: 1000), _searchUser);
                              },
                            ),
                          ),
                          Expanded(
                            child:
                            RadioGroup<String>(
                              groupValue: _groupValue,
                              onChanged: (String? value) {
                                setState(() {
                                  _groupValue = value;
                                  _nomPnomController.text = Constante.ANO_PLAYER;
                                  _jaValue = value;
                                  _rankIsEnabled = true;
                                });
                              },
                              child: Column(
                                children: [
                                  RadioListTile<String>(
                                    value: 'ja',
                                    title: Text(Constante.ANO_PLAYER_ACRONYM),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      // Row 2
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nomPnomController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _classementController,
                              decoration: InputDecoration(
                                labelText: Constante.RANKING_LABEL,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              readOnly: !_rankIsEnabled,
                            ),
                          )
                        ],
                      ),
                      // Row 3
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                icon: Icon(Icons.calendar_today),
                                labelText: Constante.MATCH_DATE,
                                border: OutlineInputBorder(),
                              ),
                              onTap: () => _selectDate(context),
                            ),
                          ),
                          Expanded(
                            child: RadioGroup<String>(
                              groupValue: _result,
                              onChanged: (String? value) {
                                setState(() {
                                  _result = value;
                                  _rankIsEnabled = true;
                                });
                              },
                              child: Column(
                                children: [
                                  RadioListTile<String>(
                                    value: Constante.WIN,
                                    title: Text('V'),
                                  ),
                                  RadioListTile<String>(
                                    value: Constante.DEFEAT,
                                    title: Text('D'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(child: TextFormField(
                            controller: _scoreController,
                            decoration: InputDecoration(
                              labelText: 'Score',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return Constante.INPUT_MATCH;
                              }
                              if (value.length < 3) {
                                return Constante.ADD_ONE_SET;
                              }
                              return null;
                            },
                          )),
                        ],
                      ),
                      // Row 4
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextFormField(
                              minLines: 3,
                              maxLines: 5,
                              keyboardType: TextInputType.multiline,
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: Constante.COMMENT_MATCH,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Row 5
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.deepOrangeAccent,
                        ),
                        child: Text(
                          Constante.SAVE_MATCH,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}
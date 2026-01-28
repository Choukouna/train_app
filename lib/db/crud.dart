import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeusetmatch/dto/player.dart';

import '../dto/auth_info.dart';
import '../dto/constant.dart';
import '../dto/match.dart';
import '../dto/slot.dart';

/// Class to interact with Firestore DB
class Crud {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static void checkUserIsLogged() {
    _auth.authStateChanges().listen((User? user) {
      return;
    });
  }

  /// Check if an user pseudo already exists
  static Future<bool> userExists(String pseudo) async {
    final userSnapshot = await _firestore
        .collection('players')
        .where('pseudo', isEqualTo: pseudo)
        .limit(1)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      return Future.value(true);
    }
    return Future.value(false);
  }

  /// Retrieve an user thanks to his pseudo
  static Future<Map<String, dynamic>?> getUserFromPseudo(String pseudo) async {
    final userSnapshot = await _firestore
        .collection('players')
        .where('pseudo', isEqualTo: pseudo)
        .limit(1)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final doc = userSnapshot.docs.first;
      final userData = {
        'uid': doc.id,          // the document ID (user UID)
        ...doc.data(),          // spread operator merges the fields
      };
      return userData; // returns Map<String, dynamic>
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getUserFromUid(String uid) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('players')
        .doc(uid)
        .get();

    if (userSnapshot.exists) {
      return userSnapshot.data();// returns Map<String, dynamic>
    }
    return null;
  }

  /// DB function to create new user account
  static Future<void> signUp({required Player player, required AuthInfo authInfo}) async {
    bool exists = await Crud.userExists(player.pseudo);
    if (exists) {
      throw Exception(Constante.PSEUDO_BUSY);
    }
    UserCredential userCred = await _auth.createUserWithEmailAndPassword(
      email: authInfo.username,
      password: authInfo.mdp,
    );
    await _firestore.collection('players').doc(userCred.user!.uid).set({
      'name': player.name,
      'lastname': player.lastname,
      'city': player.city,
      'pseudo': player.pseudo,
      'email': authInfo.username,
      'rank': player.rank.toString(),
      'wins': 0,
      'losses': 0,
      'bestWin': '',
      'worstDefeat': '',
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    });
  }

  /// Update user stats after new match related to him
  static Future<void> updateUserStat(String uid, bool isWin) async {
      await FirebaseFirestore.instance
          .collection('players')
          .doc(uid)
          .update({
        'wins': FieldValue.increment(isWin ? 1 : 0),
        'losses': FieldValue.increment(isWin ? 0 : 1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
  }

  /// Update user top win rank
  static Future<void> updateTopWin(String uid, String winRank) async {
    await FirebaseFirestore.instance
        .collection('players')
        .doc(uid)
        .update({
      'bestWin': winRank,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update user worst defeat rank
  static Future<void> updateWorstDefeat(String uid, String defeatRank) async {
    await FirebaseFirestore.instance
        .collection('players')
        .doc(uid)
        .update({
      'worstDefeat': defeatRank,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// DB function to log in
  static Future<void> signIn(AuthInfo authInfo) async {
    var userData = await Crud.getUserFromPseudo(authInfo.username);
    if (userData == null) {
      throw Exception(Constante.PSEUDO_NOT_FOUND);
    }

    await _auth.signInWithEmailAndPassword(
      email: userData['email'],
      password: authInfo.mdp,
    );
  }

  /// DB function to save a match
  static Future<void> addMatchToDB({ required Match match }) async {
    await _firestore.collection('matches').add({
      'player1Id': match.playerId,
      'player2Id': match.opponentId,
      'winnerId': match.result ? match.playerId : match.opponentId,
      'score': match.formatSetsForDB(),
      'playDate': match.matchDay,
      'comment': match.comment
    });
    // Update stat (win/loss numbers) for each player
    await updateUserStat(match.playerId, match.result);
    await updateUserStat(match.opponentId, !match.result);
  }

  /// Read user matches and retrieve opponents data
  static Future<List<Map<String, dynamic>>> readUserMatches(String connectedUid) async {
    final matchesRef = _firestore.collection('matches');
    final usersRef = _firestore.collection('players');

    final matchesSnapshot = await matchesRef
        .where(Filter.or(
          Filter('player1Id', isEqualTo: connectedUid),
          Filter('player2Id', isEqualTo: connectedUid),
        ))
        .orderBy('playDate', descending: true)
        .get();

    final List<Map<String, dynamic>> results = [];

    /// For each match, retrieve opponent profile (name, rank..)
    for (final doc in matchesSnapshot.docs) {
      final match = doc.data();
      final opponentId = (match['player1Id'] == connectedUid)
          ? match['player2Id']
          : match['player1Id'];

      final opponentSnapshot = await usersRef.doc(opponentId).get();
      final opponent = opponentSnapshot.data();

      results.add({
        "matchId": doc.id,
        "date": match['playDate'],
        "sets": match['score'],
        "winnerId": match['winnerId'],
        "comment": match['comment'] != null ? match['comment'] : 'Aucun commentaire saisi pour le match',
        "opponentPseudo": opponent != null ? "${opponent['pseudo']}" : 'OpponentPseudo',
        "opponentName": opponent != null
            ? "${opponent['name']}"
            : 'Joueur',
        "opponentLastname": opponent != null
            ? "${opponent['lastname']}"
            : 'Anonyme',
        "opponentRank": opponent != null ? "${opponent['rank']}" : 'ND'
      });
    }

    return results;
  }

  /// List of methods to manage availability on firestore
  static CollectionReference slotsRef() =>
      _firestore.collection('players_slot');

  static Future<void> addSlot(String connectedUid, Slot slot) async {
    await slotsRef()
          .add(slot.toMap());
  }

  /// Add opponent request to play with slot owner
  static Future<void> addPlayRequestToSlot(String ownerUid, connectedUid, String username, String? slotUid) async {
    await slotsRef()
        .doc(slotUid)
        .update({
          'opponentUid': connectedUid,
          'participants': FieldValue.arrayUnion([ownerUid, connectedUid]),
          'opponentUsername': username,
          'status': 'Pending',
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Respond to play request sent on our slot
  static Future<void> respondToPlayRequest(String? slotUid, String response) async {
    await slotsRef()
        .doc(slotUid)
        .update({
      'status': response,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteSlot(String slotId) async {
    await slotsRef().doc(slotId).delete();
  }

  /// List user's week slots availability
  static Stream<List<Slot>> watchWeekSlots(
      String connectedUid,
      DateTime weekStart,
      DateTime weekEnd,
      ) {

    return slotsRef()
        .where('participants', arrayContains: connectedUid)
        .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .where('start', isLessThan: Timestamp.fromDate(weekEnd))
        .snapshots()
        .map(
                (snapshot) => snapshot.docs.map(
                        (doc) => Slot.fromDoc(doc)
                    ).toList()
        );
  }

  /// Get all players busy slots for a given day and location
  static Stream<List<Slot>> availabilityForDayStream(DateTime day, String? stade, String? city, int? codePostal) {
    DateTime dayKey = DateUtils.dateOnly(day);
    final dayKeyUtc = DateTime.utc(dayKey.year, dayKey.month, dayKey.day);
    final dayStartUtc = DateTime.utc(day.year, day.month, day.day);
    final dayEndUtc = dayKeyUtc.add(const Duration(days: 1));
    return slotsRef()
        .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStartUtc)) // start slot plus grand que 00h du jour J
        .where('start', isLessThan: Timestamp.fromDate(dayEndUtc)) // End day plus petit que jour J+1
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Slot.fromDoc(doc);
      }).toList();
    });
  }

  /// Group day's busy slot by hour
  static Map<int, List<Slot>> groupByHour(List<Slot> list) {
    final Map<int, List<Slot>> map = {};
    for (final a in list) {
      map.putIfAbsent(a.start.hour, () => []);
      map[a.start.hour]!.add(a);
    }
    return map;
  }
}
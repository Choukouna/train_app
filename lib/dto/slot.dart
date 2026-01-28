import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jeusetmatch/dto/location.dart';

class Slot {
  String _ownerUid;
  DateTime _start;
  DateTime _end;
  Location _location;
  String? _id;
  String? _status;
  String? _opponentUid;
  String? _opponentUsername;

  Slot(this._ownerUid, this._start, this._end, this._location, [this._id, this._status, this._opponentUid, this._opponentUsername]);

  String? get id => this._id;
  String? get status => this._status;
  String? get opponentUid => this._opponentUid;
  String? get opponentUsername => this._opponentUsername;
  String get ownerUid => this._ownerUid;
  DateTime get start => this._start;
  DateTime get end => this._end;
  Location get location => this._location;
  bool get isLocked => this._status == 'Accepted';
  bool get isPending => this._status == 'Pending';
  bool get isAvailable => this._status == 'Available';

  set location(Location value) {
    this._location = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': _ownerUid,
      'participants': [_ownerUid],
      'status': this._status ?? 'Available',
      'start': Timestamp.fromDate(_start),
      'end': Timestamp.fromDate(_end),
      'location': location.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Slot.fromDoc(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;

      final ownerUid = data['ownerUid'] ?? '';
      final startTs = data['start'] as Timestamp;
      final endTs = data['end'] as Timestamp;
      final status = data['status'] ?? '';
      final opponentUid = data['opponentUid'] ?? '';
      final opponentUsername = data['opponentUsername'] ?? '';
      final rawLocation = data['location'];

      late final Map<String, dynamic> locationMap;
      locationMap = Map<String, dynamic>.from(rawLocation);

      return Slot(
        ownerUid,
        startTs.toDate().toLocal(),
        endTs.toDate().toLocal(),
        Location.fromMap(locationMap),
        doc.id,
        status,
        opponentUid,
        opponentUsername
      );
    } catch (e, s) {
      print('🔥 AvailabilitySlot.fromDoc ERROR');
      print(e);
      print(s);
      rethrow; // IMPORTANT
    }
  }
}

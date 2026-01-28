import 'package:flutter/material.dart';
import 'package:jeusetmatch/dto/constant.dart';
import 'package:jeusetmatch/dto/slot.dart';
import 'package:jeusetmatch/ui/shared/dialog_shower.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../db/crud.dart';
import '../db/user_provider.dart';
import '../utils/utils_functions.dart';

class PlayersCalendar extends StatefulWidget {
  const PlayersCalendar({super.key});

  @override
  State<PlayersCalendar> createState() => _PlayersCalendarState();
}

/// Print a normal calendar focused on d-day
class _PlayersCalendarState extends State<PlayersCalendar> {
  _PlayersCalendarState();

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  DateTime get startOfWeek {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - DateTime.monday));
    return DateTime(monday.year, monday.month, monday.day); // 00:00
  }

  DateTime get endOfWeek {
    final sunday = startOfWeek.add(const Duration(days: 6));
    return DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.loading) {
      return CircularProgressIndicator();
    }
    final userData = userProvider.userData;
    final userCity = userData?['city'] ?? '';

    final hours = List.generate(14, (i) => i + 8);

    return Column(
      children: [
        TableCalendar(
          firstDay: startOfWeek,
          lastDay: endOfWeek,
          focusedDay: focusedDay,
          calendarFormat: CalendarFormat.week,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerVisible: false,
          selectedDayPredicate: (day) =>
              isSameDay(day, selectedDay),
          onDaySelected: (day, focused) {
            setState(() {
              selectedDay = day;
              focusedDay = focused;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blueGrey,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ),

        const Divider(),

        Expanded(
            child: StreamBuilder<List<Slot>>(
              stream: Crud.availabilityForDayStream(selectedDay, null, null, null),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final busySlots = Utils.filterSlotByCity(snapshot.data ?? [], userCity);

                final groupedSlotsMap = Crud.groupByHour(busySlots);
                return ListView.builder(
                  itemCount: hours.length,
                  itemBuilder: (context, index) {
                    final hour = hours[index];
                    List<Slot> busySlots = [];
                    if (groupedSlotsMap[hour] != null) {
                      busySlots = groupedSlotsMap[hour] as List<Slot>;
                    }
                    return HourRow(
                      hour: hour,
                      busySlots: busySlots,
                    );
                  },
                );
              },
            )
        ),
      ],
    );
  }
}

/// Print an hour on a row and list of availabilities saved by some players for this hour
class HourRow extends StatelessWidget {
  final int hour;
  final List<Slot> busySlots;

  const HourRow({
    super.key,
    required this.hour,
    required this.busySlots,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 80,
      child: Row(
        children: [
          Text(
            '${hour.toString().padLeft(2, '0')}:00',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20,), // Create empty space between slot and location
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: busySlots.asMap().entries.map((entry) {
                final index = entry.key;
                final busySlot = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: LocationPrinter(
                    busySlot: busySlot,
                    index: index,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationPrinter extends StatelessWidget {
  final Slot busySlot;
  final int index;

  const LocationPrinter({
    super.key,
    required this.busySlot,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.loading) {
      return CircularProgressIndicator();
    }
    final userData = userProvider.userData;
    final connectedUid = userData?['uid'];
    final connectedUsername = '${userData?['name']} ${userData?['lastname']}';

    return GestureDetector(
      onTap: () async {
        if (busySlot.isLocked) {
          DialogShower.showTemporaryDialog(context, Constante.BUSY_SLOT);
          return;
        }
        if (connectedUid == busySlot.ownerUid) {
          DialogShower.showTemporaryDialog(context, Constante.SLOT_OWNER);
          return;
        }
        final confirmed = await _confirmJoinSlot(context);
        if (!confirmed) return;
        Crud.addPlayRequestToSlot(busySlot.ownerUid, connectedUid, connectedUsername, busySlot.id);
        DialogShower.showTemporaryDialog(context, Constante.SLOT_REQUESTED);
      },
      child: FutureBuilder<Map<String, dynamic>?>(
        future: Crud.getUserFromUid(busySlot.ownerUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return const Text('Error loading player');
          }

          final playerData = snapshot.data!;
          final playerName = "${playerData['lastname'][0].toUpperCase()}${playerData['lastname'].substring(1)}";

          return Container(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    busySlot.location.formatForUI(),
                    style: const TextStyle(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        playerName,
                        style: const TextStyle(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),

                      if (busySlot.isLocked) ... [
                        const SizedBox(width: 4),
                        const Icon(Icons.lock, color: Colors.green, size: 16,),
                      ]
                    ],
                  )
                ],
              ),
            )
          );
        },
      ),
    );
  }

  /// Popup pour confirmer ou non notre volonté de jouer sur un creneau
  Future<bool> _confirmJoinSlot(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Voulez-vous valider la demande pour jouer ? (le propriétaire du créneau devra valider)'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    ) ??
        false;
  }
}

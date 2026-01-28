import 'package:flutter/material.dart';
import 'package:jeusetmatch/ui/shared/dialog_shower.dart';

import '../db/crud.dart';
import '../dto/location.dart';
import '../dto/slot.dart';

class HourSlotsList extends StatelessWidget {
  final DateTime selectedDay;
  final String connectedUid;
  final List<Slot> busySlots;

  const HourSlotsList({
    super.key,
    required this.selectedDay,
    required this.busySlots,
    required this.connectedUid,
  });

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(14, (index) => index + 8); // 08 → 22

    return ListView.builder(
      itemCount: hours.length,
      itemBuilder: (context, index) {
        final hour = hours[index];
        final start = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          hour,
        );

        return HourSlotTile(start: start, connectedUid: connectedUid, busySlots: busySlots);
      },
    );
  }
}

class HourSlotTile extends StatelessWidget {
  final DateTime start;
  final String connectedUid;
  final List<Slot> busySlots;

  const HourSlotTile({
    super.key,
    required this.start,
    required this.connectedUid,
    required this.busySlots,
  });

  @override
  Widget build(BuildContext context) {
    bool selected = false;
    Location? selectedLocation;
    final end = start.add(const Duration(hours: 1)); // Compute slot endDate

    // Find if this hour is already saved in busySlots
    Slot? existingSlot;
    for (final slot in busySlots) {
      if (_isSameHour(slot.start, start)) {
        existingSlot = slot;
        break;
      }
    }

    selected = existingSlot != null;
    selectedLocation = existingSlot?.location;

    return GestureDetector(
      onTap: () async { // Action quand on tape sur un slot
        if (selected) { // if it was already selected
          if (connectedUid != existingSlot?.ownerUid) { // Click sur un slot qu'on a pas créé
            if (connectedUid != existingSlot!.opponentUid) { // Ni le owner ni l'opponent => ancien opponent refusé
              DialogShower.showTemporaryDialog(context, "Votre demande de jeu a été refusé par l'initiateur du créneau :(");
            } else {
              if (existingSlot.isPending) {
                DialogShower.showTemporaryDialog(context, "Votre demande de jeu est toujours en attente..");
              } else if (existingSlot.isLocked) {
                DialogShower.showTemporaryDialog(context, "Votre demande de jeu a été acceptée :)");
              } else if (existingSlot.isAvailable) {
                DialogShower.showTemporaryDialog(context, "Votre demande de jeu a été refusé par l'initiateur du créneau :(");
              }
            }
          } else { // Owner tap
            if (existingSlot?.id != null) { // deselect => delete from firestore
              if (existingSlot!.isAvailable) {
                await Crud.deleteSlot(existingSlot.id!);
                selectedLocation = null;
              } else if (existingSlot.isPending) {
                final confirmed = await DialogShower.respondToPlayerRequest(context, existingSlot.opponentUsername);
                if (!confirmed) { // Owner refuses a player, make slot available again
                  Crud.respondToPlayRequest(existingSlot.id, 'Available');
                  await DialogShower.showTemporaryDialog(context, "Vous avez refusé la proposition de jeu");
                  return;
                }
                Crud.respondToPlayRequest(existingSlot.id, 'Accepted');
                await DialogShower.showTemporaryDialog(context, "Vous avez accepté la proposition de jeu");
              } else if (existingSlot.isLocked){
                // TODO pop-up attention creneau deja booked
              }
              return;
            }
          }
          return;
        }
        // ADD new slot
        final Location? pickedLocation = await DialogShower.pickLocation(context);
        if (pickedLocation == null) return;

        final Slot newSlot = Slot(connectedUid, start, end, pickedLocation,);

        await Crud.addSlot(connectedUid, newSlot);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: !selected
              ? Colors.grey.shade200
              : existingSlot.isAvailable
              ? Colors.blueAccent
              : existingSlot.isPending
              ? Colors.pink.shade100
              : Colors.green.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_format(start)} - ${_format(end)}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 5,), // Create empty space between slot and location
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  selected
                      ? (selectedLocation?.formatForUI() ?? "")
                      : "",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              )
            ),
            if (selected)
              const Icon(Icons.check, color: Colors.white),
          ],
        ),
      ),
    );
  }

  String _format(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:00";
  }

  bool _isSameHour(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour;
  }
}
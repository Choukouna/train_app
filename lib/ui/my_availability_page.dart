import 'package:flutter/material.dart';
import 'package:jeusetmatch/dto/slot.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../db/crud.dart';
import '../db/user_provider.dart';
import 'hours_slot.dart';

class MyAvailabilityPage extends StatefulWidget {
  const MyAvailabilityPage({super.key});

  @override
  State<MyAvailabilityPage> createState() => _MyAvailabilityPageState();
}

class _MyAvailabilityPageState extends State<MyAvailabilityPage> {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  DateTime get startOfWeek {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - DateTime.monday));
    return DateTime(monday.year, monday.month, monday.day); // 00:00
  }

  DateTime get endOfWeek {
    return startOfWeek.add(const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.loading) {
      return CircularProgressIndicator();
    }
    final userData = userProvider.userData;
    final connectedUid = userData?['uid'];

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
              stream: Crud.watchWeekSlots(connectedUid, startOfWeek, endOfWeek),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final busySlots = snapshot.data ?? [];
                return HourSlotsList(
                  selectedDay: selectedDay,
                  connectedUid: connectedUid,
                  busySlots: busySlots,
                );
              },
            )
        ),
      ],
    );
  }
}

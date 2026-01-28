import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeusetmatch/dto/constant.dart';
import 'package:jeusetmatch/ui/my_availability_page.dart';
import 'package:jeusetmatch/ui/players_calendar.dart';
import 'package:jeusetmatch/ui/shared/base_scaffold.dart';
import 'package:jeusetmatch/utils/protected_route.dart';
import 'package:provider/provider.dart';

import '../db/user_provider.dart';
import 'add_match.dart';
import 'home_page.dart';
import 'list_match.dart';

class FeaturesPage extends StatefulWidget {
  const FeaturesPage({super.key});
  final String title = 'TenApp';

  @override
  State<FeaturesPage> createState() => _FeaturesPageState();
}

class _FeaturesPageState extends State<FeaturesPage> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<UserProvider>().refreshUserInfos();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const HomePage();
    }

    return BaseScaffold(body: Container(
      margin: EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 👈 2 columns → total 4 items = 2x2 grid
          mainAxisSpacing: 16, // vertical space
          crossAxisSpacing: 16, // horizontal space
          childAspectRatio: 1.0, // square cards
          children: [
            _buildFeatureCard(Icons.add, Constante.ADD_MATCH_VERB, Colors.blue, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProtectedRoute(title: Constante.ADD_MATCH_TITLE, body: AddMatch())),
              );
            }),
            _buildFeatureCard(Icons.read_more, Constante.PRINT_MATCH, Colors.green, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProtectedRoute(title: Constante.PALMARES, body: ListMatch())),
              );
            }),
            _buildFeatureCard(Icons.add, Constante.ADD_AVAILABILITY, Colors.orange, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProtectedRoute(title: Constante.AVAILABILITY_TITLE, body: MyAvailabilityPage())),
              );
            }),
            _buildFeatureCard(Icons.read_more, Constante.PLAYERS_AVAILABILITY, Colors.purple, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProtectedRoute(title: Constante.PLAYERS_CALENDAR, body: PlayersCalendar())),
              );
            }),
          ],
        ),
      ),
    ), title: Constante.APPNAME);
  }

  Widget _buildFeatureCard(IconData icon, String title, Color color, GestureTapCallback action) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: action,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                radius: 28,
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 5),
              Expanded(
                  child: SingleChildScrollView (
                    scrollDirection: Axis.vertical,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}

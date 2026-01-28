import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/user_provider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentUser = userProvider.userData;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No user data')),
      );
    }

    final user = {
      'name': '${currentUser['name']} ${currentUser['lastname']}',
      'level': currentUser['rank'],
      'avatar': null,
    };
    final int wins = currentUser['wins'] ?? 0;
    final int losses = currentUser['losses'] ?? 0;
    final stats = {
      'matches': wins + losses,
      'wins': wins,
      'losses': losses,
      'winRate':
      wins + losses == 0 ? 0 : ((wins / (wins + losses)) * 100).round(),
      'bestWin': currentUser['bestWin'],
      'worstDefeat': currentUser['worstDefeat'],
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(user: user),
            const SizedBox(height: 24),
            const Text(
              'Mes stats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _StatsGrid(stats: stats),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              child: Text(
                user['name'][0],
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Classement: ${user['level']}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(title: 'Match(es)', value: stats['matches'].toString()),
        _StatCard(title: 'Victoire(s)', value: stats['wins'].toString()),
        _StatCard(title: 'Défaite(s)', value: stats['losses'].toString()),
        _StatCard(title: 'De victoire', value: '${stats['winRate']}%'),
        _StatCard(title: 'Top victoire', value: '${stats['bestWin']}'),
        _StatCard(title: 'Pire défaite ', value: '${stats['worstDefeat']}'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }
}

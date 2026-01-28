class SetScore {
  final int gamesA; // Nb jeu du joueur dans le set
  final int gamesB; // Nb jeu adversaire dans le set

  SetScore({required this.gamesA, required this.gamesB});

  @override
  String toString() {
    return '$gamesA/$gamesB';
  }
}

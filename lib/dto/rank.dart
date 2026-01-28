class Rank {
  String _signe;
  int _numerator;
  int _deno;

  Rank(this._signe, this._numerator, this._deno);

  // Getters
  String get signe => _signe;
  int get numerator => _numerator;
  int get deno => _deno;

  set signe(String value) {
    _signe = value;
  }

  set numerator(int value) {
    _numerator = value;
  }

  set deno(int value) {
    _deno = value;
  }

  bool isGreaterThan(Rank rank2) {
    return compareTo(rank2) == 1;
  }

  bool isLessThan(Rank rank2) {
    return compareTo(rank2) == -1;
  }

  bool isEqual(Rank rank2) {
    return compareTo(rank2) == 0;
  }

  String toString() {
    return deno == 0 ? '$signe$numerator' : '$signe$numerator/$deno';
  }

  int compareTo(Rank rank2) {
    final int sign1 = signe == '-' ? -1 : 1;
    final int rank2Sign = rank2.signe == '-' ? -1 : 1;

    // Different signs
    if (sign1 != rank2Sign) { // 1 negat VS 1 positif OU 1 positif VS 1 negat
      return sign1 < rank2Sign ? 1 : -1;
    }
    // Same sign
    final result = _compareAbsolute(rank2);

    // If both are negative, invert result
    return sign1 == -1 ? -result : result;
  }

  int _compareAbsolute(rank2) { // Compare 2 classements de même signe (si 2 negat, interpreter le résultat par une négation)
    if (numerator != rank2.numerator) {
      return numerator > rank2.numerator  ? -1: 1;
    }
    if (deno != rank2.deno) {
        return deno > rank2.deno ? -1 : 1;
    }
    return 0;
  }
}
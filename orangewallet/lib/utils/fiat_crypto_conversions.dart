class FiatCryptoConversions {
  static double fiatToCrypto(double qoute, double amount) {
    if (qoute == 0) {
      return amount;
    }
    if (amount == null) {
      return 0;
    }
    return amount / qoute;
  }

  static double cryptoToFiat(double amount, double qoute) {
    if (amount == null) {
      amount = 0;
    }

    return amount * qoute;
  }
}

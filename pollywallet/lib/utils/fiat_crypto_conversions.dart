class FiatCryptoConversions {
  static double fiatToCrypto(double qoute, double amount) {
    if (qoute == 0) {
      return amount;
    }
    return amount / qoute;
  }

  static double cryptoToFiat(double amount, double qoute) {
    print(amount);
    print(qoute);
    return amount * qoute;
  }
}

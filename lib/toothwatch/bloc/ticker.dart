class Ticker {
  Stream<int> sequentialSeconds() {
    return Stream.periodic(Duration(seconds: 1), (x) => x + 1);
  }

  Stream<int> sequentialTenthSeconds() {
    return Stream.periodic(Duration(milliseconds: 100), (x) => x + 1);
  }
}
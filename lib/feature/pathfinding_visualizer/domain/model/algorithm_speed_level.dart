enum AlgorithmSpeedLevel {
  turbo(1),
  fast(20),
  medium(100),
  mediumSlow(250),
  slow(500);

  const AlgorithmSpeedLevel(this.delay);

  final int delay;
}

enum AlgorithmSpeedLevel {
  turbo,
  fast,
  medium,
  mediumSlow,
  slow,
}

int mapAlgorithmSpeedLevelToDelay(AlgorithmSpeedLevel algorithmSpeedLevel) {
  switch (algorithmSpeedLevel) {
    case AlgorithmSpeedLevel.slow:
      return 500;
    case AlgorithmSpeedLevel.mediumSlow:
      return 250;
    case AlgorithmSpeedLevel.medium:
      return 100;
    case AlgorithmSpeedLevel.fast:
      return 20;
    case AlgorithmSpeedLevel.turbo:
      return 1;
  }
}

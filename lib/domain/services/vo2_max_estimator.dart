import 'dart:math';

/// A data point in a workout stream for VO2 Max estimation.
class WorkoutDataPoint {
  final DateTime timestamp;
  final double heartRateBpm;
  final double speedMetersPerSec;

  const WorkoutDataPoint({
    required this.timestamp,
    required this.heartRateBpm,
    required this.speedMetersPerSec,
  });
}

/// Result of a single segment's VO2 Max estimation.
class SegmentVo2Result {
  final double estimatedVo2Max;
  final double averageHr;
  final double averageSpeed;

  const SegmentVo2Result({
    required this.estimatedVo2Max,
    required this.averageHr,
    required this.averageSpeed,
  });
}

/// A service that estimates VO2 Max using a Firstbeat-style algorithm.
/// It filters erratic data and relies on the linear relationship between
/// heart rate reserve and running speed.
class Vo2MaxEstimator {
  final double userMaxHr;
  final double userRestingHr;
  
  // Configuration
  final Duration windowSize = const Duration(seconds: 30);
  final int minHrThresholdPercent = 70; // Must be at least 70% of max HR
  final double maxHrVariance = 5.0; // BPM
  final double maxSpeedVariance = 0.5; // m/s
  final Duration warmupDuration = const Duration(minutes: 10);

  Vo2MaxEstimator({
    required this.userMaxHr,
    required this.userRestingHr,
  });

  /// Processes an entire workout stream to compute a session VO2 max.
  double? processWorkout(List<WorkoutDataPoint> workoutData) {
    if (workoutData.isEmpty) return null;

    final startTime = workoutData.first.timestamp;
    
    // Filter out warmup (first 10 minutes)
    final activeData = workoutData.where(
      (point) => point.timestamp.difference(startTime) > warmupDuration
    ).toList();

    if (activeData.isEmpty) return null;

    List<SegmentVo2Result> validSegments = [];
    List<WorkoutDataPoint> currentWindow = [];

    for (var point in activeData) {
      currentWindow.add(point);
      
      // Keep window strictly to windowSize duration
      while (currentWindow.isNotEmpty && 
             point.timestamp.difference(currentWindow.first.timestamp) > windowSize) {
        currentWindow.removeAt(0);
      }

      // Check if we have a full window
      if (currentWindow.isNotEmpty && 
          currentWindow.last.timestamp.difference(currentWindow.first.timestamp) >= windowSize) {
        
        if (_isValidSegment(currentWindow)) {
          final result = _calculateSegmentVo2(currentWindow);
          validSegments.add(result);
          // Clear window to avoid overlapping segments or just let it slide? 
          // Sliding is fine, but to be strict, we can clear to find independent segments.
          currentWindow.clear();
        }
      }
    }

    if (validSegments.isEmpty) return null;

    return _aggregateSegments(validSegments);
  }

  bool _isValidSegment(List<WorkoutDataPoint> segment) {
    if (segment.isEmpty) return false;

    double sumHr = 0;
    double sumSpeed = 0;
    for (var p in segment) {
      sumHr += p.heartRateBpm;
      sumSpeed += p.speedMetersPerSec;
    }
    double avgHr = sumHr / segment.length;
    double avgSpeed = sumSpeed / segment.length;

    // 1. Intensity Threshold (e.g. >70% Max HR)
    if (avgHr < (userMaxHr * (minHrThresholdPercent / 100.0))) {
      return false;
    }

    // 2. Stability check (calculate variance/standard deviation)
    double hrVarianceSum = 0;
    double speedVarianceSum = 0;
    for (var p in segment) {
      hrVarianceSum += pow(p.heartRateBpm - avgHr, 2);
      speedVarianceSum += pow(p.speedMetersPerSec - avgSpeed, 2);
    }
    
    double hrStdDev = sqrt(hrVarianceSum / segment.length);
    double speedStdDev = sqrt(speedVarianceSum / segment.length);

    if (hrStdDev > maxHrVariance || speedStdDev > maxSpeedVariance) {
      return false; // Not a steady state
    }

    // Ensure speed is > 0 (actually running)
    if (avgSpeed < 1.5) return false; // less than ~5.4 km/h is usually walking

    return true;
  }

  SegmentVo2Result _calculateSegmentVo2(List<WorkoutDataPoint> segment) {
    double sumHr = 0;
    double sumSpeed = 0;
    for (var p in segment) {
      sumHr += p.heartRateBpm;
      sumSpeed += p.speedMetersPerSec;
    }
    double avgHr = sumHr / segment.length;
    double avgSpeedMps = sumSpeed / segment.length;

    // Convert speed to m/min for ACSM formula
    double speedMetersPerMin = avgSpeedMps * 60.0;
    
    // ACSM Running Equation (Oxygen cost at this speed on flat ground)
    // VO2 = 3.5 + (0.2 * speed) + (0.9 * speed * grade). Assuming grade = 0.
    double currentVo2 = 3.5 + (0.2 * speedMetersPerMin);
    
    // Heart Rate Reserve Percentage (%HRR)
    double hrReserve = userMaxHr - userRestingHr;
    double percentHrr = (avgHr - userRestingHr) / hrReserve;
    
    // Cap percentHrr to 1.0 to avoid weird extrapolation if HR > MaxHR
    percentHrr = min(percentHrr, 1.0);
    // Prevent division by zero or very small numbers
    percentHrr = max(percentHrr, 0.1); 

    // Extrapolate to VO2 Max
    double estimatedVo2Max = currentVo2 / percentHrr;

    return SegmentVo2Result(
      estimatedVo2Max: estimatedVo2Max,
      averageHr: avgHr,
      averageSpeed: avgSpeedMps,
    );
  }

  double _aggregateSegments(List<SegmentVo2Result> segments) {
    // Sort by VO2 Max estimate
    segments.sort((a, b) => a.estimatedVo2Max.compareTo(b.estimatedVo2Max));

    // Interquartile Range (IQR) filtering to remove extreme outliers
    int dropCount = (segments.length * 0.1).floor(); // Drop top/bottom 10%
    
    int startIndex = dropCount;
    int endIndex = segments.length - dropCount;
    
    if (startIndex >= endIndex) {
      // If we don't have enough segments, just average all
      startIndex = 0;
      endIndex = segments.length;
    }

    double sum = 0;
    int count = 0;
    for (int i = startIndex; i < endIndex; i++) {
      sum += segments[i].estimatedVo2Max;
      count++;
    }

    return sum / count;
  }
}

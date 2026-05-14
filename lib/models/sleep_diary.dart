import 'package:flutter/material.dart';

class SleepDiaryEntry {
  final String id;
  final DateTime date;
  final TimeOfDay bedTime;
  final TimeOfDay wakeTime;
  final int sleepLatency; // minutes
  final int wakeCount;
  final int wakeDuration; // minutes (WASO)
  final int mood; // 1-5

  const SleepDiaryEntry({
    required this.id,
    required this.date,
    required this.bedTime,
    required this.wakeTime,
    required this.sleepLatency,
    required this.wakeCount,
    required this.wakeDuration,
    required this.mood,
  });

  /// Time in bed in hours
  double get tib {
    double bed = bedTime.hour + bedTime.minute / 60.0;
    double wake = wakeTime.hour + wakeTime.minute / 60.0;
    if (wake <= bed) wake += 24;
    return wake - bed;
  }

  /// Total sleep time in hours
  double get tst {
    final waso = wakeDuration / 60.0;
    final sl = sleepLatency / 60.0;
    final result = tib - sl - waso;
    return result < 0 ? 0 : result;
  }

  /// Sleep efficiency as 0.0 - 1.0
  double get se {
    if (tib <= 0) return 0;
    return (tst / tib).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'bedHour': bedTime.hour,
        'bedMinute': bedTime.minute,
        'wakeHour': wakeTime.hour,
        'wakeMinute': wakeTime.minute,
        'sleepLatency': sleepLatency,
        'wakeCount': wakeCount,
        'wakeDuration': wakeDuration,
        'mood': mood,
      };

  factory SleepDiaryEntry.fromJson(Map<String, dynamic> json) =>
      SleepDiaryEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        bedTime: TimeOfDay(
            hour: json['bedHour'] as int, minute: json['bedMinute'] as int),
        wakeTime: TimeOfDay(
            hour: json['wakeHour'] as int, minute: json['wakeMinute'] as int),
        sleepLatency: json['sleepLatency'] as int,
        wakeCount: json['wakeCount'] as int,
        wakeDuration: json['wakeDuration'] as int,
        mood: json['mood'] as int,
      );

  SleepDiaryEntry copyWith({
    String? id,
    DateTime? date,
    TimeOfDay? bedTime,
    TimeOfDay? wakeTime,
    int? sleepLatency,
    int? wakeCount,
    int? wakeDuration,
    int? mood,
  }) =>
      SleepDiaryEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        bedTime: bedTime ?? this.bedTime,
        wakeTime: wakeTime ?? this.wakeTime,
        sleepLatency: sleepLatency ?? this.sleepLatency,
        wakeCount: wakeCount ?? this.wakeCount,
        wakeDuration: wakeDuration ?? this.wakeDuration,
        mood: mood ?? this.mood,
      );
}

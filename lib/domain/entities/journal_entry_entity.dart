import 'package:equatable/equatable.dart';

/// Domain entity representing a behavior log or lifestyle habit tag.
class JournalEntryEntity extends Equatable {
  final int? id;
  final String userId;
  final DateTime date;
  final DateTime timestamp;
  final int timeZoneOffsetMinutes;
  final String tag;
  final String? value;
  final String? notes;

  const JournalEntryEntity({
    this.id,
    this.userId = 'local_user',
    required this.date,
    required this.timestamp,
    this.timeZoneOffsetMinutes = 0,
    required this.tag,
    this.value,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        timestamp,
        timeZoneOffsetMinutes,
        tag,
        value,
        notes,
      ];
}


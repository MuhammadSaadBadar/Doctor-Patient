import 'package:doctor/features/patient/models/patient_card.dart';

class BriefUser {
  final int id;
  final String email;
  final String firstName;
  final String lastName;

  BriefUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory BriefUser.fromJson(Map<String, dynamic> json) {
    return BriefUser(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }
}

class WaterIntakeEntry {
  final int id;
  final BriefUser patient;
  final int amountMl;
  final DateTime loggedAt;
  final DateTime logDate;
  final DateTime createdAt;

  WaterIntakeEntry({
    required this.id,
    required this.patient,
    required this.amountMl,
    required this.loggedAt,
    required this.logDate,
    required this.createdAt,
  });

  factory WaterIntakeEntry.fromJson(Map<String, dynamic> json) {
    return WaterIntakeEntry(
      id: json['id'] as int,
      patient: BriefUser.fromJson(json['patient'] as Map<String, dynamic>),
      amountMl: json['amount_ml'] as int,
      loggedAt: DateTime.parse(json['logged_at'] as String),
      logDate: DateTime.parse(json['log_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': {
        'id': patient.id,
        'email': patient.email,
        'first_name': patient.firstName,
        'last_name': patient.lastName,
      },
      'amount_ml': amountMl,
      'logged_at': loggedAt.toIso8601String(),
      'log_date': logDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  // For creating new entries (request body)
  Map<String, dynamic> toCreateJson({int? patientId}) {
    final map = {
      'amount_ml': amountMl,
      'log_date': logDate.toIso8601String().split('T')[0],
    };
    if (patientId != null) {
      map['patient_id'] = patientId;
    }
    return map;
  }
}

class WaterIntakeToday {
  final DateTime date;
  final int totalMl;
  final List<WaterIntakeEntry> entries;

  WaterIntakeToday({
    required this.date,
    required this.totalMl,
    required this.entries,
  });

  factory WaterIntakeToday.fromJson(Map<String, dynamic> json) {
    return WaterIntakeToday(
      date: DateTime.parse(json['date'] as String),
      totalMl: json['total_ml'] as int,
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => WaterIntakeEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WaterIntakeListResult {
  final int count;
  final String? next;
  final String? previous;
  final List<WaterIntakeEntry> results;

  WaterIntakeListResult({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory WaterIntakeListResult.fromJson(Map<String, dynamic> json) {
    return WaterIntakeListResult(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => WaterIntakeEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
}

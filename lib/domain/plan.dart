enum PlanStatus { running, done, partial, missed, abandoned }

class Plan {
  const Plan({
    required this.id,
    required this.title,
    required this.durationSec,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.note,
    required this.locale,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final int durationSec;
  final DateTime startAt;
  final DateTime endAt;
  final PlanStatus status;
  final String? note;
  final String locale;
  final DateTime createdAt;

  Plan copyWith({
    Object? id = _unset,
    String? title,
    int? durationSec,
    DateTime? startAt,
    DateTime? endAt,
    PlanStatus? status,
    Object? note = _unset,
    String? locale,
    DateTime? createdAt,
  }) {
    return Plan(
      id: identical(id, _unset) ? this.id : id as int?,
      title: title ?? this.title,
      durationSec: durationSec ?? this.durationSec,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      status: status ?? this.status,
      note: identical(note, _unset) ? this.note : note as String?,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Plan &&
            other.id == id &&
            other.title == title &&
            other.durationSec == durationSec &&
            other.startAt == startAt &&
            other.endAt == endAt &&
            other.status == status &&
            other.note == note &&
            other.locale == locale &&
            other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      durationSec,
      startAt,
      endAt,
      status,
      note,
      locale,
      createdAt,
    );
  }
}

const Object _unset = Object();

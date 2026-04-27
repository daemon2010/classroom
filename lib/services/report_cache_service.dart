import "dart:convert";
import "dart:io";

import "package:path_provider/path_provider.dart";

import "../models/classroom_models.dart";

class CachedReport {
  const CachedReport({
    required this.profile,
    required this.courses,
    required this.snapshot,
    required this.checkedAt,
  });

  final ClassroomProfile profile;
  final List<ClassroomCourse> courses;
  final ReportSnapshot snapshot;
  final DateTime checkedAt;
}

class ReportCacheService {
  static const _version = 1;
  static const _fileName = "cache.json";

  Future<CachedReport?> load({String? profileId, String? emailAddress}) async {
    try {
      final file = await _cacheFile();
      if (!await file.exists()) {
        return null;
      }

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic> || decoded["version"] != _version) {
        return null;
      }

      final profile = _profileFromJson(_map(decoded["profile"]));
      if (!_matchesProfile(
        profile: profile,
        profileId: profileId,
        emailAddress: emailAddress,
      )) {
        return null;
      }

      final checkedAt =
          _dateTime(decoded["checkedAt"]) ??
          _dateTime(decoded["savedAt"]) ??
          DateTime.now();
      final courses = [
        for (final value in _list(decoded["courses"]))
          _courseFromJson(_map(value)),
      ];
      final snapshot = _snapshotFromJson(_map(decoded["snapshot"]));

      return CachedReport(
        profile: profile,
        courses: courses,
        snapshot: snapshot,
        checkedAt: checkedAt,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    required ClassroomProfile profile,
    required List<ClassroomCourse> courses,
    required ReportSnapshot snapshot,
    required DateTime checkedAt,
  }) async {
    final file = await _cacheFile();
    await file.parent.create(recursive: true);
    final payload = {
      "version": _version,
      "savedAt": DateTime.now().toIso8601String(),
      "checkedAt": checkedAt.toIso8601String(),
      "profile": _profileToJson(profile),
      "courses": courses.map(_courseToJson).toList(growable: false),
      "snapshot": _snapshotToJson(snapshot),
    };
    await file.writeAsString(jsonEncode(payload), flush: true);
  }

  Future<void> clear() async {
    try {
      final file = await _cacheFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Cache cleanup should never block sign-out.
    }
  }

  Future<File> _cacheFile() async {
    final directory = await getApplicationSupportDirectory();
    return File("${directory.path}/$_fileName");
  }

  bool _matchesProfile({
    required ClassroomProfile profile,
    required String? profileId,
    required String? emailAddress,
  }) {
    final cleanProfileId = profileId?.trim();
    if (cleanProfileId != null && cleanProfileId.isNotEmpty) {
      return profile.id == cleanProfileId;
    }

    final cleanEmail = emailAddress?.trim().toLowerCase();
    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      return profile.emailAddress.trim().toLowerCase() == cleanEmail;
    }

    return true;
  }

  Map<String, dynamic> _profileToJson(ClassroomProfile profile) {
    return {
      "id": profile.id,
      "emailAddress": profile.emailAddress,
      "fullName": profile.fullName,
      "photoUrl": profile.photoUrl,
    };
  }

  ClassroomProfile _profileFromJson(Map<String, dynamic> json) {
    return ClassroomProfile(
      id: _string(json["id"]),
      emailAddress: _string(json["emailAddress"]),
      fullName: _string(json["fullName"]),
      photoUrl: _nullableString(json["photoUrl"]),
    );
  }

  Map<String, dynamic> _courseToJson(ClassroomCourse course) {
    return {
      "id": course.id,
      "name": course.name,
      "section": course.section,
      "subject": course.subject,
      "descriptionHeading": course.descriptionHeading,
      "courseState": course.courseState,
      "alternateLink": course.alternateLink,
    };
  }

  ClassroomCourse _courseFromJson(Map<String, dynamic> json) {
    return ClassroomCourse(
      id: _string(json["id"]),
      name: _string(json["name"]),
      section: _nullableString(json["section"]),
      subject: _nullableString(json["subject"]),
      descriptionHeading: _nullableString(json["descriptionHeading"]),
      courseState: _nullableString(json["courseState"]),
      alternateLink: _nullableString(json["alternateLink"]),
    );
  }

  Map<String, dynamic> _snapshotToJson(ReportSnapshot snapshot) {
    return {
      "generatedAt": snapshot.generatedAt.toIso8601String(),
      "creatorFilterUserId": snapshot.creatorFilterUserId,
      "summary": _summaryToJson(snapshot.summary),
      "rows": snapshot.rows.map(_rowToJson).toList(growable: false),
    };
  }

  ReportSnapshot _snapshotFromJson(Map<String, dynamic> json) {
    final rows = [
      for (final value in _list(json["rows"])) _rowFromJson(_map(value)),
    ];
    return ReportSnapshot(
      rows: rows,
      summary: _summaryFromJson(_map(json["summary"])),
      generatedAt: _dateTime(json["generatedAt"]) ?? DateTime.now(),
      creatorFilterUserId: _nullableString(json["creatorFilterUserId"]),
    );
  }

  Map<String, dynamic> _summaryToJson(ReportSummary summary) {
    return {
      "courseCount": summary.courseCount,
      "assignmentCount": summary.assignmentCount,
      "ungradedSubmissionCount": summary.ungradedSubmissionCount,
      "classesWithUngradedCount": summary.classesWithUngradedCount,
      "lateSubmissionCount": summary.lateSubmissionCount,
    };
  }

  ReportSummary _summaryFromJson(Map<String, dynamic> json) {
    return ReportSummary(
      courseCount: _int(json["courseCount"]),
      assignmentCount: _int(json["assignmentCount"]),
      ungradedSubmissionCount: _int(json["ungradedSubmissionCount"]),
      classesWithUngradedCount: _int(json["classesWithUngradedCount"]),
      lateSubmissionCount: _int(json["lateSubmissionCount"]),
    );
  }

  Map<String, dynamic> _rowToJson(UngradedSubmissionReportRow row) {
    return {
      "courseId": row.courseId,
      "courseName": row.courseName,
      "courseWorkId": row.courseWorkId,
      "assignmentTitle": row.assignmentTitle,
      "studentUserId": row.studentUserId,
      "studentName": row.studentName,
      "submissionId": row.submissionId,
      "submissionState": row.submissionState.name,
      "studentEmail": row.studentEmail,
      "classSection": row.classSection,
      "subject": row.subject,
      "dueDate": row.dueDate?.toIso8601String(),
      "submittedAt": row.submittedAt?.toIso8601String(),
      "updatedAt": row.updatedAt?.toIso8601String(),
      "createdAt": row.createdAt?.toIso8601String(),
      "maxPoints": row.maxPoints,
      "submissionUrl": row.submissionUrl,
      "assignmentUrl": row.assignmentUrl,
      "late": row.late,
    };
  }

  UngradedSubmissionReportRow _rowFromJson(Map<String, dynamic> json) {
    return UngradedSubmissionReportRow(
      courseId: _string(json["courseId"]),
      courseName: _string(json["courseName"]),
      courseWorkId: _string(json["courseWorkId"]),
      assignmentTitle: _string(json["assignmentTitle"]),
      studentUserId: _string(json["studentUserId"]),
      studentName: _string(json["studentName"]),
      submissionId: _string(json["submissionId"]),
      submissionState: _submissionState(json["submissionState"]),
      studentEmail: _nullableString(json["studentEmail"]),
      classSection: _nullableString(json["classSection"]),
      subject: _nullableString(json["subject"]),
      dueDate: _dateTime(json["dueDate"]),
      submittedAt: _dateTime(json["submittedAt"]),
      updatedAt: _dateTime(json["updatedAt"]),
      createdAt: _dateTime(json["createdAt"]),
      maxPoints: _double(json["maxPoints"]),
      submissionUrl: _nullableString(json["submissionUrl"]),
      assignmentUrl: _nullableString(json["assignmentUrl"]),
      late: _bool(json["late"]),
    );
  }

  Map<String, dynamic> _map(Object? value) {
    return value is Map<String, dynamic> ? value : const {};
  }

  List<Object?> _list(Object? value) {
    return value is List ? value.cast<Object?>() : const [];
  }

  String _string(Object? value) {
    return value is String ? value : "";
  }

  String? _nullableString(Object? value) {
    if (value is! String) {
      return null;
    }
    final clean = value.trim();
    return clean.isEmpty ? null : value;
  }

  int _int(Object? value) {
    return value is int ? value : 0;
  }

  double? _double(Object? value) {
    return switch (value) {
      int() => value.toDouble(),
      double() => value,
      _ => null,
    };
  }

  bool? _bool(Object? value) {
    return value is bool ? value : null;
  }

  DateTime? _dateTime(Object? value) {
    return value is String ? DateTime.tryParse(value) : null;
  }

  SubmissionState _submissionState(Object? value) {
    if (value is! String) {
      return SubmissionState.unknown;
    }
    return SubmissionState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => SubmissionState.unknown,
    );
  }
}

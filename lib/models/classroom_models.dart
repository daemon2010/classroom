class ClassroomProfile {
  const ClassroomProfile({
    required this.id,
    required this.emailAddress,
    required this.fullName,
    this.photoUrl,
  });

  final String id;
  final String emailAddress;
  final String fullName;
  final String? photoUrl;
}

class ClassroomCourse {
  const ClassroomCourse({
    required this.id,
    required this.name,
    this.section,
    this.subject,
    this.descriptionHeading,
    this.courseState,
    this.alternateLink,
  });

  final String id;
  final String name;
  final String? section;
  final String? subject;
  final String? descriptionHeading;
  final String? courseState;
  final String? alternateLink;
}

class ClassroomTopic {
  const ClassroomTopic({required this.id, required this.name, this.updateTime});

  final String id;
  final String name;
  final DateTime? updateTime;
}

class ClassroomAssignment {
  const ClassroomAssignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.subjectName,
    required this.creatorUserId,
    required this.workType,
    this.description,
    this.state,
    this.alternateLink,
    this.creationTime,
    this.updateTime,
    this.dueDate,
    this.dueTime,
    this.topicId,
    this.maxPoints,
  });

  final String id;
  final String courseId;
  final String title;
  final String? description;
  final String? state;
  final String? alternateLink;
  final DateTime? creationTime;
  final DateTime? updateTime;
  final DateTime? dueDate;
  final Duration? dueTime;
  final String? topicId;
  final String subjectName;
  final String creatorUserId;
  final String workType;
  final double? maxPoints;

  DateTime? get dueAt {
    final date = dueDate;
    if (date == null) {
      return null;
    }

    final time = dueTime;
    if (time == null) {
      return date;
    }

    return date.add(time);
  }

  ClassroomCourseWork toCourseWork() {
    return ClassroomCourseWork(
      id: id,
      courseId: courseId,
      title: title,
      creatorUserId: creatorUserId,
      dueDate: dueAt,
      subjectName: subjectName,
      alternateLink: alternateLink,
      createdAt: creationTime,
      maxPoints: maxPoints,
    );
  }
}

class ClassroomStudent {
  const ClassroomStudent({
    required this.id,
    required this.fullName,
    this.emailAddress,
    this.photoUrl,
  });

  final String id;
  final String fullName;
  final String? emailAddress;
  final String? photoUrl;
}

class ClassroomCourseWork {
  const ClassroomCourseWork({
    required this.id,
    required this.courseId,
    required this.title,
    required this.creatorUserId,
    this.dueDate,
    this.subjectName,
    this.alternateLink,
    this.createdAt,
    this.maxPoints,
  });

  final String id;
  final String courseId;
  final String title;
  final String creatorUserId;
  final DateTime? dueDate;
  final String? subjectName;
  final String? alternateLink;
  final DateTime? createdAt;
  final double? maxPoints;
}

class ClassroomSubmission {
  const ClassroomSubmission({
    required this.id,
    required this.courseId,
    required this.courseWorkId,
    required this.studentUserId,
    required this.studentName,
    required this.state,
    this.studentEmail,
    this.assignedGrade,
    this.draftGrade,
    this.updateTime,
    this.submissionUrl,
    this.late,
  });

  final String id;
  final String courseId;
  final String courseWorkId;
  final String studentUserId;
  final String studentName;
  final SubmissionState state;
  final String? studentEmail;
  final double? assignedGrade;
  final double? draftGrade;
  final DateTime? updateTime;
  final String? submissionUrl;
  final bool? late;

  bool get isUngraded {
    return state == SubmissionState.turnedIn &&
        assignedGrade == null &&
        draftGrade == null;
  }
}

enum SubmissionState {
  newSubmission,
  created,
  turnedIn,
  returned,
  reclaimedByStudent,
  unknown,
}

class UngradedSubmissionReportRow {
  const UngradedSubmissionReportRow({
    required this.courseId,
    required this.courseName,
    required this.courseWorkId,
    required this.assignmentTitle,
    required this.studentUserId,
    required this.studentName,
    required this.submissionId,
    required this.submissionState,
    this.studentEmail,
    this.classSection,
    this.subject,
    this.dueDate,
    this.updatedAt,
    this.createdAt,
    this.maxPoints,
    this.submissionUrl,
    this.assignmentUrl,
    this.late,
  });

  final String courseId;
  final String courseName;
  final String courseWorkId;
  final String assignmentTitle;
  final String studentUserId;
  final String studentName;
  final String submissionId;
  final SubmissionState submissionState;
  final String? studentEmail;
  final String? classSection;
  final String? subject;
  final DateTime? dueDate;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final double? maxPoints;
  final String? submissionUrl;
  final String? assignmentUrl;
  final bool? late;

  bool get isLate {
    final explicitLate = late;
    if (explicitLate != null) {
      return explicitLate;
    }

    final due = dueDate;
    final updated = updatedAt;
    if (due == null || updated == null) {
      return false;
    }
    return updated.isAfter(due);
  }
}

typedef UngradedReportRow = UngradedSubmissionReportRow;

class ReportSummary {
  const ReportSummary({
    required this.courseCount,
    required this.assignmentCount,
    required this.ungradedSubmissionCount,
    this.classesWithUngradedCount = 0,
    this.lateSubmissionCount = 0,
  });

  final int courseCount;
  final int assignmentCount;
  final int ungradedSubmissionCount;
  final int classesWithUngradedCount;
  final int lateSubmissionCount;
}

class ReportSnapshot {
  const ReportSnapshot({
    required this.rows,
    required this.summary,
    required this.generatedAt,
    required this.creatorFilterUserId,
  });

  factory ReportSnapshot.empty() {
    return ReportSnapshot(
      rows: const [],
      summary: const ReportSummary(
        courseCount: 0,
        assignmentCount: 0,
        ungradedSubmissionCount: 0,
        classesWithUngradedCount: 0,
        lateSubmissionCount: 0,
      ),
      generatedAt: DateTime.now(),
      creatorFilterUserId: null,
    );
  }

  final List<UngradedSubmissionReportRow> rows;
  final ReportSummary summary;
  final DateTime generatedAt;
  final String? creatorFilterUserId;
}

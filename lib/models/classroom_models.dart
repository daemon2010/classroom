class ClassroomProfile {
  const ClassroomProfile({
    required this.id,
    required this.emailAddress,
    required this.fullName,
  });

  final String id;
  final String emailAddress;
  final String fullName;
}

class ClassroomCourse {
  const ClassroomCourse({
    required this.id,
    required this.name,
    this.section,
    this.subject,
  });

  final String id;
  final String name;
  final String? section;
  final String? subject;
}

class ClassroomCourseWork {
  const ClassroomCourseWork({
    required this.id,
    required this.courseId,
    required this.title,
    required this.creatorUserId,
    this.dueDate,
  });

  final String id;
  final String courseId;
  final String title;
  final String creatorUserId;
  final DateTime? dueDate;
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
    this.subject,
    this.dueDate,
    this.updatedAt,
    this.submissionUrl,
    this.assignmentUrl,
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
  final String? subject;
  final DateTime? dueDate;
  final DateTime? updatedAt;
  final String? submissionUrl;
  final String? assignmentUrl;

  bool get isLate {
    final due = dueDate;
    final updated = updatedAt;
    if (due == null || updated == null) {
      return false;
    }
    return updated.isAfter(due);
  }
}

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

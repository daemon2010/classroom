import "../models/classroom_models.dart";

class ReportService {
  const ReportService();

  ReportSnapshot buildSnapshot({
    required ClassroomProfile? myProfile,
    required List<ClassroomCourse> courses,
    required List<ClassroomCourseWork> courseWork,
    required List<ClassroomSubmission> submissions,
  }) {
    final myProfileId = myProfile?.id;
    final ownedCourseWork = myProfileId == null
        ? <ClassroomCourseWork>[]
        : courseWork
              .where((work) => work.creatorUserId == myProfileId)
              .toList(growable: false);

    final coursesById = {for (final course in courses) course.id: course};
    final ownedCourseWorkById = {
      for (final work in ownedCourseWork) work.id: work,
    };

    final rows = submissions
        .where((submission) => submission.isUngraded)
        .where(
          (submission) =>
              ownedCourseWorkById.containsKey(submission.courseWorkId),
        )
        .map((submission) {
          final work = ownedCourseWorkById[submission.courseWorkId]!;
          final course = coursesById[submission.courseId];

          return UngradedSubmissionReportRow(
            courseId: submission.courseId,
            courseName: course?.name ?? "Unknown course",
            courseWorkId: submission.courseWorkId,
            assignmentTitle: work.title,
            studentUserId: submission.studentUserId,
            studentName: submission.studentName,
            submissionId: submission.id,
            submissionState: submission.state,
            studentEmail: submission.studentEmail,
            classSection: course?.section,
            subject: work.subjectName ?? course?.subject ?? course?.section,
            dueDate: work.dueDate,
            updatedAt: submission.updateTime,
            createdAt: work.createdAt,
            maxPoints: work.maxPoints,
            submissionUrl: submission.submissionUrl,
            assignmentUrl: work.alternateLink,
          );
        })
        .toList(growable: false);

    return ReportSnapshot(
      rows: rows,
      summary: ReportSummary(
        courseCount: courses.length,
        assignmentCount: ownedCourseWork.length,
        ungradedSubmissionCount: rows.length,
        classesWithUngradedCount: rows
            .map((row) => row.courseId)
            .toSet()
            .length,
        lateSubmissionCount: rows.where((row) => row.isLate).length,
      ),
      generatedAt: DateTime.now(),
      creatorFilterUserId: myProfileId,
    );
  }
}

import "package:classroom_ungraded_checker/models/classroom_models.dart";
import "package:classroom_ungraded_checker/services/report_service.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("includes only ungraded submissions for assignments created by me", () {
    const service = ReportService();
    final snapshot = service.buildSnapshot(
      myProfile: const ClassroomProfile(
        id: "teacher-me",
        emailAddress: "teacher@example.com",
        fullName: "Teacher",
      ),
      courses: const [ClassroomCourse(id: "course-1", name: "Electronics")],
      courseWork: const [
        ClassroomCourseWork(
          id: "work-mine",
          courseId: "course-1",
          title: "Logic gates",
          creatorUserId: "teacher-me",
        ),
        ClassroomCourseWork(
          id: "work-other",
          courseId: "course-1",
          title: "Counters",
          creatorUserId: "teacher-other",
        ),
      ],
      submissions: const [
        ClassroomSubmission(
          id: "submission-mine",
          courseId: "course-1",
          courseWorkId: "work-mine",
          studentUserId: "student-1",
          studentName: "Student One",
          state: SubmissionState.turnedIn,
        ),
        ClassroomSubmission(
          id: "submission-other",
          courseId: "course-1",
          courseWorkId: "work-other",
          studentUserId: "student-2",
          studentName: "Student Two",
          state: SubmissionState.turnedIn,
        ),
      ],
    );

    expect(snapshot.summary.assignmentCount, 1);
    expect(snapshot.summary.ungradedSubmissionCount, 1);
    expect(snapshot.rows.single.submissionId, "submission-mine");
    expect(snapshot.rows.single.assignmentTitle, "Logic gates");
  });

  test("keeps matching work scoped to its class", () {
    const service = ReportService();
    final snapshot = service.buildSnapshot(
      myProfile: const ClassroomProfile(
        id: "teacher-me",
        emailAddress: "teacher@example.com",
        fullName: "Teacher",
      ),
      courses: const [
        ClassroomCourse(id: "course-1", name: "Electronics"),
        ClassroomCourse(id: "course-2", name: "Programming"),
      ],
      courseWork: const [
        ClassroomCourseWork(
          id: "same-work-id",
          courseId: "course-1",
          title: "Logic gates",
          creatorUserId: "teacher-other",
        ),
        ClassroomCourseWork(
          id: "same-work-id",
          courseId: "course-2",
          title: "Loops",
          creatorUserId: "teacher-me",
        ),
      ],
      submissions: const [
        ClassroomSubmission(
          id: "submission-course-2",
          courseId: "course-2",
          courseWorkId: "same-work-id",
          studentUserId: "student-1",
          studentName: "Student One",
          state: SubmissionState.turnedIn,
          late: true,
        ),
      ],
    );

    expect(snapshot.summary.ungradedSubmissionCount, 1);
    expect(snapshot.rows.single.courseName, "Programming");
    expect(snapshot.rows.single.assignmentTitle, "Loops");
    expect(snapshot.rows.single.isLate, isTrue);
  });
}

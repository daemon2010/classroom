import "package:googleapis/classroom/v1.dart" as classroom;
import "package:googleapis_auth/auth_io.dart" as auth;

import "../models/classroom_models.dart";
import "google_auth_service.dart";

class ClassroomReadException implements Exception {
  const ClassroomReadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ClassroomApiService {
  ClassroomApiService([GoogleAuthService? googleAuth])
    : _googleAuth = googleAuth ?? GoogleAuthService();

  final GoogleAuthService _googleAuth;

  Future<ClassroomProfile> getMyProfile() async {
    final api = await _classroomApi();

    try {
      final profile = await api.userProfiles.get(
        "me",
        $fields: "id,emailAddress,name/fullName,photoUrl",
      );
      final profileId = profile.id?.trim();
      if (profileId == null || profileId.isEmpty) {
        throw const ClassroomReadException(
          "Could not load your Google Classroom profile.",
        );
      }

      return ClassroomProfile(
        id: profileId,
        fullName: profile.name?.fullName ?? "",
        emailAddress: profile.emailAddress ?? "",
        photoUrl: profile.photoUrl,
      );
    } on ClassroomReadException {
      rethrow;
    } catch (_) {
      throw const ClassroomReadException(
        "Could not load your Google Classroom profile.",
      );
    }
  }

  Future<List<ClassroomCourse>> listTeacherCourses() async {
    final api = await _classroomApi();
    final courses = <ClassroomCourse>[];
    String? pageToken;

    try {
      do {
        final response = await api.courses.list(
          teacherId: "me",
          courseStates: const ["ACTIVE"],
          pageSize: 100,
          pageToken: pageToken,
          $fields:
              "courses(id,name,section,subject,descriptionHeading,courseState,alternateLink),nextPageToken",
        );

        for (final course in response.courses ?? const <classroom.Course>[]) {
          if (course.courseState != "ACTIVE") {
            continue;
          }

          final id = course.id?.trim();
          final name = course.name?.trim();
          if (id == null || id.isEmpty || name == null || name.isEmpty) {
            continue;
          }

          courses.add(
            ClassroomCourse(
              id: id,
              name: name,
              section: course.section,
              subject: course.subject,
              descriptionHeading: course.descriptionHeading,
              courseState: course.courseState,
              alternateLink: course.alternateLink,
            ),
          );
        }

        pageToken = response.nextPageToken;
      } while (pageToken?.isNotEmpty ?? false);
    } catch (_) {
      throw const ClassroomReadException(
        "Could not load your active Google Classroom classes.",
      );
    }

    courses.sort((a, b) {
      final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      if (byName != 0) {
        return byName;
      }
      return (a.section ?? "").toLowerCase().compareTo(
        (b.section ?? "").toLowerCase(),
      );
    });

    return courses;
  }

  Future<List<ClassroomCourse>> listCourses() {
    return listTeacherCourses();
  }

  Future<List<ClassroomTopic>> listCourseTopics(String courseId) async {
    final api = await _classroomApi();
    final topics = <ClassroomTopic>[];
    String? pageToken;

    try {
      do {
        final response = await api.courses.topics.list(
          courseId,
          pageSize: 100,
          pageToken: pageToken,
          $fields: "topic(topicId,name,updateTime),nextPageToken",
        );

        for (final topic in response.topic ?? const <classroom.Topic>[]) {
          final id = topic.topicId?.trim();
          final name = topic.name?.trim();
          if (id == null || id.isEmpty || name == null || name.isEmpty) {
            continue;
          }

          topics.add(
            ClassroomTopic(
              id: id,
              name: name,
              updateTime: _parseTimestamp(topic.updateTime),
            ),
          );
        }

        pageToken = response.nextPageToken;
      } while (pageToken?.isNotEmpty ?? false);
    } catch (_) {
      throw const ClassroomReadException(
        "Could not load Google Classroom topics.",
      );
    }

    topics.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return topics;
  }

  Future<List<ClassroomAssignment>> listMyAssignments({
    required String courseId,
    required String myUserId,
  }) async {
    final api = await _classroomApi();
    final topics = await listCourseTopics(courseId);
    final topicNamesById = {for (final topic in topics) topic.id: topic.name};
    final assignments = <ClassroomAssignment>[];
    String? pageToken;

    try {
      do {
        final response = await api.courses.courseWork.list(
          courseId,
          pageSize: 100,
          pageToken: pageToken,
          $fields:
              "courseWork(id,courseId,title,description,state,alternateLink,creationTime,updateTime,dueDate,dueTime,topicId,creatorUserId,workType,maxPoints),nextPageToken",
        );

        for (final work
            in response.courseWork ?? const <classroom.CourseWork>[]) {
          final creatorUserId = work.creatorUserId?.trim();
          final workType = work.workType?.trim();
          if (creatorUserId == null || creatorUserId != myUserId) {
            continue;
          }
          if (workType != "ASSIGNMENT") {
            continue;
          }

          final id = work.id?.trim();
          final title = work.title?.trim();
          if (id == null ||
              id.isEmpty ||
              title == null ||
              title.isEmpty ||
              creatorUserId.isEmpty) {
            continue;
          }

          final topicId = work.topicId?.trim();
          assignments.add(
            ClassroomAssignment(
              id: id,
              courseId: work.courseId ?? courseId,
              title: title,
              description: work.description,
              state: work.state,
              alternateLink: work.alternateLink,
              creationTime: _parseTimestamp(work.creationTime),
              updateTime: _parseTimestamp(work.updateTime),
              dueDate: _parseDate(work.dueDate),
              dueTime: _parseTimeOfDay(work.dueTime),
              topicId: topicId?.isEmpty ?? true ? null : topicId,
              subjectName: topicId == null ? "" : topicNamesById[topicId] ?? "",
              creatorUserId: creatorUserId,
              workType: "ASSIGNMENT",
              maxPoints: work.maxPoints,
            ),
          );
        }

        pageToken = response.nextPageToken;
      } while (pageToken?.isNotEmpty ?? false);
    } catch (_) {
      throw const ClassroomReadException(
        "Could not load your Google Classroom assignments.",
      );
    }

    assignments.sort((a, b) {
      final aUpdated = a.updateTime ?? a.creationTime;
      final bUpdated = b.updateTime ?? b.creationTime;
      if (aUpdated != null && bUpdated != null) {
        return bUpdated.compareTo(aUpdated);
      }
      if (aUpdated != null) {
        return -1;
      }
      if (bUpdated != null) {
        return 1;
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return assignments;
  }

  Future<List<ClassroomCourseWork>> listCourseWork(String courseId) async {
    return const [];
  }

  Future<List<ClassroomSubmission>> listStudentSubmissions({
    required String courseId,
    required String courseWorkId,
  }) async {
    return const [];
  }

  Future<classroom.ClassroomApi> _classroomApi() async {
    return classroom.ClassroomApi(await _requireAuthClient());
  }

  DateTime? _parseTimestamp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  DateTime? _parseDate(classroom.Date? value) {
    final year = value?.year;
    final month = value?.month;
    final day = value?.day;
    if (year == null ||
        month == null ||
        day == null ||
        year <= 0 ||
        month <= 0 ||
        day <= 0) {
      return null;
    }
    return DateTime.utc(year, month, day);
  }

  Duration? _parseTimeOfDay(classroom.TimeOfDay? value) {
    if (value == null) {
      return null;
    }

    final hours = value.hours ?? 0;
    final minutes = value.minutes ?? 0;
    final seconds = value.seconds ?? 0;
    final nanos = value.nanos ?? 0;
    if (hours == 0 && minutes == 0 && seconds == 0 && nanos == 0) {
      return Duration.zero;
    }

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      microseconds: nanos ~/ 1000,
    );
  }

  Future<auth.AuthClient> _requireAuthClient() async {
    final client = await _googleAuth.getAuthClient();
    if (client == null) {
      throw const ClassroomReadException("Sign in with Google first.");
    }
    return client;
  }
}
